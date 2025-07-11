USE [Operations]
GO
/****** Object:  View [Fact].[ProductionLive]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Fact].[ProductionLive] AS

WITH Standards AS (
	SELECT ProductID, LocationID, Machine, SUM(MachineHours) AS MachineHours, SUM(TotalStandardHours) AS StandardHours, MAX(UnitsPerSpider) AS UP, MAX(RoundsPerShift) AS RoundsPerShift
	FROM dbo.FactStandards --use the persisted fact table for speed
	GROUP BY ProductID, LocationID, Machine
)
, StandardsOverrideLocation AS (
	SELECT pro.ProductID, LocationID, Machine, MAX(MachineHours) AS MachineHours, MAX(TotalStandardHours) AS StandardHours, MAX(UnitsPerSpider) AS UP, MAX(RoundsPerShift) AS RoundsPerShift
	FROM dbo.FactStandards pro --use the persisted fact table for speed
	WHERE LocationID = 3 
	GROUP BY pro.ProductID, LocationID, Machine
)
, StandardFactor AS (
	SELECT '190' AS MachineSize, 31.0/36.0 AS StandardFactor, 36.0 AS RoundsPerShift
	UNION
	SELECT '220' AS MachineSize, 24.0/30.0 AS StandardFactor, 30.0 AS RoundsPerShift
	UNION
	SELECT '260' AS MachineSize, 24.0/30.0 AS StandardFactor, 30.0 AS RoundsPerShift
	UNION
	SELECT '280' AS MachineSize, 24.0/30.0 AS StandardFactor, 30.0 AS RoundsPerShift
)
, ShiftFactor AS (
	SELECT '111' AS LocationKey, 1.0 AS ShiftFactor
	UNION
	SELECT '122' AS LocationKey, 2.0/3.0 AS ShiftFactor
	UNION
	SELECT '133' AS LocationKey, 2.0/3.0 AS ShiftFactor
)
, PieceCount AS (
	SELECT PARENT_SKU, SUM(Component_Quantity) AS Pieces FROM Oracle.RotoParts 
	WHERE Parent_sku >= '400000' GROUP BY Parent_SKU
)
SELECT 
	--dims
	l.LocationID AS PlantID
	,s.ShiftID
	,m.MachineID
	,0 AS ComponentID
	,p.ProductID
	,c.DateID
	,DATEPART(HOUR,Trans_Date_Time) AS HourID
	,pro.SHIFT_ID AS CurrentShiftID
	,s.ShiftID*1000000 + c.DateID AS WorkDayID --l.LocationID*100000 + c.DateID AS WorkDayID
	,0 AS ShiftOffsetID

	--qty, cost, price
	,SUM([PRODUCTION_QTY]) AS [Production Qty]
	,MAX(CASE WHEN pro.[List_Less_7] = 0 THEN sp.LIST_LESS_7 ELSE pro.[List_Less_7] END) AS [List Less 7 %] --override blank pricing
	,SUM(CASE WHEN pro.[Total_Price] = 0 THEN CASE WHEN pro.[List_Less_7] = 0 THEN sp.LIST_LESS_7 ELSE pro.[List_Less_7] END * [Production_Qty] ELSE pro.[Total_Price] END) AS [Total Dollars]

	--overheads
	,SUM([Std_cost]*[PRODUCTION_QTY]) AS [Standard Cost]
	,SUM([Resource_Cost]*[PRODUCTION_QTY]) AS [Resource Cost]
	,SUM([Earned_Overhead]*[PRODUCTION_QTY]) AS [Earned Overhead Cost]
	,SUM([Material_Cost]*[PRODUCTION_QTY]) AS [Material Cost]
	,SUM([Material_Overhead_Cost]*[PRODUCTION_QTY]) AS [Material Overhead Cost]
	,SUM([Outside_Processing_Cost]*[PRODUCTION_QTY]) AS [Outside Processing Cost]

	--machine time @ standard
	,MAX([Resource_Hours]) AS [Required Hours]
	,MAX(CASE WHEN s1.[MachineHours] = 0 OR s1.[MachineHours] IS NULL THEN s2.[MachineHours] ELSE s1.[MachineHours] END) AS [Machine Hours]
	,MAX(CASE WHEN s1.[MachineHours] = 0 OR s1.[MachineHours] IS NULL THEN s2.[MachineHours] ELSE s1.[MachineHours] END)*SUM([PRODUCTION_QTY]) AS [Total Machine Hours]
	,MAX(CASE WHEN s1.[MachineHours] = 0 OR s1.[MachineHours] IS NULL THEN s2.[MachineHours] ELSE s1.[MachineHours] END*ISNULL(StandardFactor,1)) AS [Optimal Machine Hours]
	,MAX(CASE WHEN s1.[MachineHours] = 0 OR s1.[MachineHours] IS NULL THEN s2.[MachineHours] ELSE s1.[MachineHours] END*ISNULL(StandardFactor,1))*SUM([PRODUCTION_QTY]) AS [Optimal Total Machine Hours]
	,MAX(ISNULL(s1.[StandardHours],s2.[StandardHours])) AS [Standard Hours]
	,MAX(ISNULL(s1.[StandardHours],s2.[StandardHours]))*SUM([PRODUCTION_QTY]) AS [Total Standard Hours]
	
	--labor cost
	,SUM(s0.RotoOperHours*s0.LaborRate*Production_Qty) AS [Roto Oper Earned Cost]
	,SUM(s0.RotoFloatHours*s0.LaborRate*Production_Qty) AS [Roto Float Earned Cost]
	,SUM(s0.TotalRotoCost*Production_Qty) AS [Total Roto Earned Cost]
	,SUM(s0.AssyLaborHours*s0.LaborRate*Production_Qty) AS [Assembly Earned Cost]
	,SUM(s0.AssyLeadHours*s0.LaborRate*Production_Qty) AS [Assembly Lead Earned Cost]
	,SUM(s0.TotalAssyCost*Production_Qty) AS [Total Assembly Earned Cost]
	,SUM(s0.TotalProcessingCost*Production_Qty) AS [Total Earned Cost]
	,SUM(s0.MachineCost*Production_Qty) AS [Machine Earned Cost]
	
	--labor hours
	,SUM(s0.RotoOperHours*Production_Qty) AS [Roto Oper Earned Hours]
	,SUM(s0.RotoFloatHours*Production_Qty) AS [Roto Float Earned Hours]
	,SUM(s0.TotalRotoHours*Production_Qty) AS [Total Roto Earned Hours]
	,SUM(s0.AssyLaborHours*Production_Qty) AS [Assembly Earned Hours]
	,SUM(s0.AssyLeadHours*Production_Qty) AS [Assembly Lead Earned Hours]
	,SUM(s0.TotalAssyHours*Production_Qty) AS [Total Assembly Earned Hours]
	,SUM(s0.TotalStandardHours*[Production_Qty]) AS [Total Earned Hours]
	,SUM(s0.MachineHours*[Production_Qty]) AS [Machine Earned Hours]

	--standard targets
	
	--how many spiders does it take to make the quantity shown?
	,CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP))/8 END AS [Spiders Ran]  
	
	--aggregate the spiders for the machine
	,SUM(CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP))/8 END) OVER (PARTITION BY m.MachineID, pro.Shift_ID) AS [Total Spiders Ran]  
	
	--percentage of total spiders ran
	,CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP))/8 END/
	SUM(CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP))/8 END) OVER (PARTITION BY m.MachineID, pro.Shift_ID) AS [Spider Mix] 
	
	--restated as 8 spiders per machine
	,CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP)) END
	/SUM(CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP)) END) OVER (PARTITION BY m.MachineID, pro.Shift_ID)*8 AS [Effective Spiders]  
	
	--production goals utilizing all spiders with current mix for shift
	,CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP)) END 
	/SUM(CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP)) END) OVER (PARTITION BY m.MachineID, pro.Shift_ID)*8 
	*MAX(ISNULL(s1.UP,s2.UP))
	*MAX(ISNULL(s1.RoundsPerShift,s2.RoundsPerShift)) 
	*MAX(CASE WHEN ISNULL(s1.LocationID,s2.LocationID) = 3 THEN shf.ShiftFactor ELSE 1 END) AS ProductionGoal
	,MAX(ISNULL(s1.RoundsPerShift,s2.RoundsPerShift)) * MAX(CASE WHEN ISNULL(s1.LocationID,s2.LocationID) = 3 THEN shf.ShiftFactor ELSE 1 END) AS RoundsPerShift

	--misc weights/dimensions/cubes/roto pieces
	,MAX([FG_RESIN_WGT]) AS [FG Resign Weight]
	,SUM([FG_Total_Resin]) AS [FG Total Resin]
	,MAX([Unit_Volume]) AS [Unit Cube]
	,SUM([Total_Volume]) AS [Total Cube]
	,SUM([Pieces]*[PRODUCTION_QTY]) AS [Piece Count]
FROM [Manufacturing].[PRODUCTION] pro
	LEFT JOIN dbo.DimLocation l ON pro.Org_Code = l.LocationKey
	LEFT JOIN dbo.DimProductMaster p ON pro.[Part_Number] = p.ProductKey
	LEFT JOIN dbo.DimCalendarFiscal c ON CAST([Trans_Date_Time] AS DATE) = c.DateKey --no offset to shift data
	LEFT JOIN dbo.FactStandardsHistory s0 ON l.LocationID = s0.LocationID AND p.ProductID = s0.ProductID AND c.DateKey BETWEEN s0.StartDate AND s0.EndDate
	LEFT JOIN Standards s1 ON l.LocationID = s1.LocationID AND p.ProductID = s1.ProductID
	LEFT JOIN StandardsOverrideLocation s2 ON p.ProductID = s2.ProductID
	LEFT JOIN dbo.DimShift s ON pro.[Shift] = s.ShiftKey
	LEFT JOIN dbo.DimMachine m ON REPLACE(pro.[Line_Code],'OO','O') = m.MachineKey AND pro.Org_Code = m.LocationKey
	LEFT JOIN StandardFactor sf ON m.MachineModel = sf.MachineSize
	LEFT JOIN ShiftFactor shf ON l.LocationKey = shf.LocationKey
	INNER JOIN Dim.ShiftControl sc ON sc.CurrentShiftID = pro.Shift_ID
	LEFT JOIN PieceCount pc ON pc.PARENT_SKU = pro.[PART_NUMBER]
	LEFT JOIN Oracle.Pricing sp ON sp.ProductKey = pro.PART_NUMBER AND pro.TRANS_DATE_TIME BETWEEN sp.StartDate AND ISNULL(sp.EndDate,'9999-12-31')
WHERE pro.CurrentRecord = 1
GROUP BY l.LocationID
	,s.ShiftID
	,pro.SHIFT_ID
	,m.MachineID
	,p.ProductID
	,c.DateID
	,Trans_Date_Time
UNION ALL
SELECT
	--dims
	l.LocationID AS PlantID
	,s.ShiftID
	,m.MachineID
	,0 AS ComponentID
	,p.ProductID
	,c.DateID
	,DATEPART(HOUR,Trans_Date_Time) AS HourID
	,pro.SHIFT_ID AS CurrentShiftID
	,s.ShiftID*1000000 + c.DateID AS WorkDayID --l.LocationID*100000 + c.DateID AS WorkDayID
	,1 AS ShiftOffsetID

	--qty, cost, price
	,SUM([PRODUCTION_QTY]) AS [Production Qty]
	,MAX(CASE WHEN pro.[List_Less_7] = 0 THEN sp.LIST_LESS_7 ELSE pro.[List_Less_7] END) AS [List Less 7 %] --override blank pricing
	,SUM(CASE WHEN pro.[Total_Price] = 0 THEN CASE WHEN pro.[List_Less_7] = 0 THEN sp.LIST_LESS_7 ELSE pro.[List_Less_7] END * [Production_Qty] ELSE pro.[Total_Price] END) AS [Total Dollars]

	--overheads
	,SUM([Std_cost]*[PRODUCTION_QTY]) AS [Standard Cost]
	,SUM([Resource_Cost]*[PRODUCTION_QTY]) AS [Resource Cost]
	,SUM([Earned_Overhead]*[PRODUCTION_QTY]) AS [Earned Overhead Cost]
	,SUM([Material_Cost]*[PRODUCTION_QTY]) AS [Material Cost]
	,SUM([Material_Overhead_Cost]*[PRODUCTION_QTY]) AS [Material Overhead Cost]
	,SUM([Outside_Processing_Cost]*[PRODUCTION_QTY]) AS [Outside Processing Cost]

	--machine time @ standard
	,MAX([Resource_Hours]) AS [Required Hours]
	,MAX(CASE WHEN s1.[MachineHours] = 0 OR s1.[MachineHours] IS NULL THEN s2.[MachineHours] ELSE s1.[MachineHours] END) AS [Machine Hours]
	,MAX(CASE WHEN s1.[MachineHours] = 0 OR s1.[MachineHours] IS NULL THEN s2.[MachineHours] ELSE s1.[MachineHours] END)*SUM([PRODUCTION_QTY]) AS [Total Machine Hours]
	,MAX(CASE WHEN s1.[MachineHours] = 0 OR s1.[MachineHours] IS NULL THEN s2.[MachineHours] ELSE s1.[MachineHours] END*ISNULL(StandardFactor,1)) AS [Optimal Machine Hours]
	,MAX(CASE WHEN s1.[MachineHours] = 0 OR s1.[MachineHours] IS NULL THEN s2.[MachineHours] ELSE s1.[MachineHours] END*ISNULL(StandardFactor,1))*SUM([PRODUCTION_QTY]) AS [Optimal Total Machine Hours]
	,MAX(ISNULL(s1.[StandardHours],s2.[StandardHours])) AS [Standard Hours]
	,MAX(ISNULL(s1.[StandardHours],s2.[StandardHours]))*SUM([PRODUCTION_QTY]) AS [Total Standard Hours]
	
	--labor cost
	,SUM(s0.RotoOperHours*s0.LaborRate*Production_Qty) AS [Roto Oper Earned Cost]
	,SUM(s0.RotoFloatHours*s0.LaborRate*Production_Qty) AS [Roto Float Earned Cost]
	,SUM(s0.TotalRotoCost*Production_Qty) AS [Total Roto Earned Cost]
	,SUM(s0.AssyLaborHours*s0.LaborRate*Production_Qty) AS [Assembly Earned Cost]
	,SUM(s0.AssyLeadHours*s0.LaborRate*Production_Qty) AS [Assembly Lead Earned Cost]
	,SUM(s0.TotalAssyCost*Production_Qty) AS [Total Assembly Earned Cost]
	,SUM(s0.TotalProcessingCost*Production_Qty) AS [Total Earned Cost]
	,SUM(s0.MachineCost*Production_Qty) AS [Machine Earned Cost]
	
	--labor hours
	,SUM(s0.RotoOperHours*Production_Qty) AS [Roto Oper Earned Hours]
	,SUM(s0.RotoFloatHours*Production_Qty) AS [Roto Float Earned Hours]
	,SUM(s0.TotalRotoHours*Production_Qty) AS [Total Roto Earned Hours]
	,SUM(s0.AssyLaborHours*Production_Qty) AS [Assembly Earned Hours]
	,SUM(s0.AssyLeadHours*Production_Qty) AS [Assembly Lead Earned Hours]
	,SUM(s0.TotalAssyHours*Production_Qty) AS [Total Assembly Earned Hours]
	,SUM(s0.TotalStandardHours*[Production_Qty]) AS [Total Earned Hours]
	,SUM(s0.MachineHours*[Production_Qty]) AS [Machine Earned Hours]

	--standard targets
	
	--how many spiders does it take to make the quantity shown?
	,CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP))/8 END AS [Spiders Ran]  
	
	--aggregate the spiders for the machine
	,SUM(CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP))/8 END) OVER (PARTITION BY m.MachineID, pro.Shift_ID) AS [Total Spiders Ran]  
	
	--percentage of total spiders ran
	,CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP))/8 END/
	SUM(CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP))/8 END) OVER (PARTITION BY m.MachineID, pro.Shift_ID) AS [Spider Mix] 
	
	--restated as 8 spiders per machine
	,CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP)) END
	/SUM(CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP)) END) OVER (PARTITION BY m.MachineID, pro.Shift_ID)*8 AS [Effective Spiders]  
	
	--production goals utilizing all spiders with current mix for shift
	,CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP)) END 
	/SUM(CASE WHEN MAX(ISNULL(s1.UP,s2.UP)) > 0 THEN SUM([PRODUCTION_QTY])/MAX(ISNULL(s1.UP,s2.UP)) END) OVER (PARTITION BY m.MachineID, pro.Shift_ID)*8 
	*MAX(ISNULL(s1.UP,s2.UP))
	*MAX(ISNULL(s1.RoundsPerShift,s2.RoundsPerShift)) 
	*MAX(CASE WHEN ISNULL(s1.LocationID,s2.LocationID) = 3 THEN shf.ShiftFactor ELSE 1 END) AS ProductionGoal
	,MAX(ISNULL(s1.RoundsPerShift,s2.RoundsPerShift)) * MAX(CASE WHEN ISNULL(s1.LocationID,s2.LocationID) = 3 THEN shf.ShiftFactor ELSE 1 END) AS RoundsPerShift

	--misc weights/dimensions/cubes/roto pieces
	,MAX([FG_RESIN_WGT]) AS [FG Resign Weight]
	,SUM([FG_Total_Resin]) AS [FG Total Resin]
	,MAX([Unit_Volume]) AS [Unit Cube]
	,SUM([Total_Volume]) AS [Total Cube]
	,SUM([Pieces]*[PRODUCTION_QTY]) AS [Piece Count]
FROM [Manufacturing].[PRODUCTION] pro
	LEFT JOIN dbo.DimLocation l ON pro.Org_Code = l.LocationKey
	LEFT JOIN dbo.DimProductMaster p ON pro.[Part_Number] = p.ProductKey
	LEFT JOIN dbo.DimCalendarFiscal c ON CAST(DATEADD(HOUR,-6,[Trans_Date_Time]) AS DATE) = c.DateKey --offset shift data
	LEFT JOIN dbo.FactStandardsHistory s0 ON l.LocationID = s0.LocationID AND p.ProductID = s0.ProductID AND c.DateKey BETWEEN s0.StartDate AND s0.EndDate
	LEFT JOIN Standards s1 ON l.LocationID = s1.LocationID AND p.ProductID = s1.ProductID
	LEFT JOIN StandardsOverrideLocation s2 ON p.ProductID = s2.ProductID
	LEFT JOIN dbo.DimShift s ON pro.[Shift] = s.ShiftKey
	LEFT JOIN dbo.DimMachine m ON REPLACE(pro.[Line_Code],'OO','O') = m.MachineKey AND pro.Org_Code = m.LocationKey
	LEFT JOIN StandardFactor sf ON m.MachineModel = sf.MachineSize
	LEFT JOIN ShiftFactor shf ON l.LocationKey = shf.LocationKey
	INNER JOIN Dim.ShiftControl sc ON sc.CurrentShiftID = pro.Shift_ID
	LEFT JOIN PieceCount pc ON pc.PARENT_SKU = pro.[PART_NUMBER]
	LEFT JOIN Oracle.Pricing sp ON sp.ProductKey = pro.PART_NUMBER AND pro.TRANS_DATE_TIME BETWEEN sp.StartDate AND ISNULL(sp.EndDate,'9999-12-31')
WHERE pro.CurrentRecord = 1
GROUP BY l.LocationID
	,s.ShiftID
	,pro.SHIFT_ID
	,m.MachineID
	,p.ProductID
	,c.DateID
	,Trans_Date_Time

GO
