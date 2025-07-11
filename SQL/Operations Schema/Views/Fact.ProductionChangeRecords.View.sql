USE [Operations]
GO
/****** Object:  View [Fact].[ProductionChangeRecords]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[ProductionChangeRecords] AS 
WITH StandardOverride AS (
	SELECT ProductID, LocationID, SUM(MachineHours) AS MachineHours, SUM(TotalStandardHours) AS StandardHours
	FROM dbo.FactStandards
	GROUP BY ProductID, LocationID
)
, StandardFactor AS (
	SELECT '190' AS MachineSize, 32.0/38.0 AS StandardFactor
	UNION
	SELECT '220' AS MachineSize, 24.0/34.0 AS StandardFactor
	UNION
	SELECT '280' AS MachineSize, 24.0/30.0 AS StandardFactor
)
SELECT 
	l.LocationID AS PlantID
	,s.ShiftID
	,m.MachineID
	,0 AS ComponentID
	,p.ProductID
	,c.DateID
	,DATEPART(HOUR,Trans_Date_Time) AS HourID
	,CASE WHEN DATEDIFF(HOUR,Trans_Date_Time,GETDATE()) < 12 THEN 1 ELSE 0 END AS CurrentShiftID
	,0 AS ShiftOffsetID
	,SUM([PRODUCTION_QTY]) AS [Production Qty]
	,MAX([List_Less_7]) AS [List Less 7 %]
	,SUM([Total_Price]) AS [Total Dollars]
	,SUM([Std_cost]*[PRODUCTION_QTY]) AS [Standard Cost]
	,SUM([Resource_Cost]*[PRODUCTION_QTY]) AS [Resource Cost]
	,SUM([Earned_Overhead]*[PRODUCTION_QTY]) AS [Earned Overhead Cost]
	,SUM([Material_Cost]*[PRODUCTION_QTY]) AS [Material Cost]
	,SUM([Material_Overhead_Cost]*[PRODUCTION_QTY]) AS [Material Overhead Cost]
	,SUM([Outside_Processing_Cost]*[PRODUCTION_QTY]) AS [Outside Processing Cost]
	,MAX([Resource_Hours]) AS [Required Hours]
	,MAX(ISNULL([MachineHours],0)*ISNULL(StandardFactor,1)) AS [Machine Hours]
	,MAX(ISNULL([MachineHours],0)*ISNULL(StandardFactor,1))*SUM([PRODUCTION_QTY]) AS [Total Machine Hours]
	,MAX(ISNULL([StandardHours],0)) AS [Standard Hours]
	,MAX(ISNULL([StandardHours],0))*SUM([PRODUCTION_QTY]) AS [Total Standard Hours]
	,MAX([FG_RESIN_WGT]) AS [FG Resign Weight]
	,SUM([FG_Total_Resin]) AS [FG Total Resin]
	,MAX([Unit_Volume]) AS [Unit Cube]
	,SUM([Total_Volume]) AS [Total Cube]
FROM Diff.[PRODUCTION] pro
	LEFT JOIN dbo.DimLocation l ON pro.Org_Code = l.LocationKey
	LEFT JOIN dbo.DimProductMaster p ON pro.[Part_Number] = p.ProductKey
	LEFT JOIN StandardOverride so ON l.LocationID = so.LocationID AND p.ProductID = so.ProductID
	LEFT JOIN Dim.Shift s ON pro.[Shift] = s.ShiftKey
	LEFT JOIN dbo.DimMachine m ON REPLACE(pro.[Line_Code],'OO','O') = m.MachineKey 
	LEFT JOIN dbo.DimCalendarFiscal c ON CAST([Trans_Date_Time] AS DATE) = c.DateKey --no offset to shift data
	LEFT JOIN StandardFactor sf ON m.MachineModel = sf.MachineSize
WHERE pro.CurrentRecord = 1 
GROUP BY l.LocationID
	,s.ShiftID
	,m.MachineID
	,p.ProductID
	,c.DateID
	,DATEPART(HOUR,Trans_Date_Time) 
	,DATEDIFF(HOUR,Trans_Date_Time,GETDATE())
UNION ALL
SELECT 
	l.LocationID AS PlantID
	,s.ShiftID
	,m.MachineID
	,0 AS ComponentID
	,p.ProductID
	,c.DateID
	,DATEPART(HOUR,Trans_Date_Time) AS HourID
	,CASE WHEN DATEDIFF(HOUR,Trans_Date_Time,GETDATE()) < 12 THEN 1 ELSE 0 END AS CurrentShiftID
	,1 AS ShiftOffsetID
	,SUM([PRODUCTION_QTY]) AS [Production Qty]
	,MAX([List_Less_7]) AS [List Less 7 %]
	,SUM([Total_Price]) AS [Total Dollars]
	,SUM([Std_cost]*[PRODUCTION_QTY]) AS [Standard Cost]
	,SUM([Resource_Cost]*[PRODUCTION_QTY]) AS [Resource Cost]
	,SUM([Earned_Overhead]*[PRODUCTION_QTY]) AS [Earned Overhead Cost]
	,SUM([Material_Cost]*[PRODUCTION_QTY]) AS [Material Cost]
	,SUM([Material_Overhead_Cost]*[PRODUCTION_QTY]) AS [Material Overhead Cost]
	,SUM([Outside_Processing_Cost]*[PRODUCTION_QTY]) AS [Outside Processing Cost]
	,MAX([Resource_Hours]) AS [Required Hours]
	,MAX(ISNULL([MachineHours],0)*ISNULL(StandardFactor,1)) AS [Machine Hours]
	,MAX(ISNULL([MachineHours],0)*ISNULL(StandardFactor,1))*SUM([PRODUCTION_QTY]) AS [Total Machine Hours]
	,MAX(ISNULL([StandardHours],0)) AS [Standard Hours]
	,MAX(ISNULL([StandardHours],0))*SUM([PRODUCTION_QTY]) AS [Total Standard Hours]
	,MAX([FG_RESIN_WGT]) AS [FG Resign Weight]
	,SUM([FG_Total_Resin]) AS [FG Total Resin]
	,MAX([Unit_Volume]) AS [Unit Cube]
	,SUM([Total_Volume]) AS [Total Cube]
FROM Diff.[PRODUCTION] pro
	LEFT JOIN dbo.DimLocation l ON pro.Org_Code = l.LocationKey
	LEFT JOIN dbo.DimProductMaster p ON pro.[Part_Number] = p.ProductKey
	LEFT JOIN StandardOverride so ON l.LocationID = so.LocationID AND p.ProductID = so.ProductID
	LEFT JOIN Dim.Shift s ON pro.[Shift] = s.ShiftKey
	LEFT JOIN dbo.DimMachine m ON REPLACE(pro.[Line_Code],'OO','O') = m.MachineKey 
	LEFT JOIN dbo.DimCalendarFiscal c ON CAST(DATEADD(HOUR,-6,[Trans_Date_Time]) AS DATE) = c.DateKey --offset shift data
	LEFT JOIN StandardFactor sf ON m.MachineModel = sf.MachineSize
WHERE pro.CurrentRecord = 1 
GROUP BY l.LocationID
	,s.ShiftID
	,m.MachineID
	,p.ProductID
	,c.DateID
	,DATEPART(HOUR,Trans_Date_Time)
	,DATEDIFF(HOUR,Trans_Date_Time,GETDATE())
GO
