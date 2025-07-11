USE [Operations]
GO
/****** Object:  View [Fact].[StandardPending]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Fact].[StandardPending] AS 
WITH Standards AS (
	SELECT ISNULL(std.ProductID,cst.ProductID) AS ProductID
		,ISNULL(std.LocationID,cst.LocationID) AS LocationID
		,cf.DateID
		,Machine
		,ISNULL([RoundsPerShift],0) AS RoundsPerShift
		,ISNULL([UnitsPerSpider],0) AS UnitsPerSpider
		,ISNULL([SpidersPerUnit],0) AS SpidersPerUnit
		,ISNULL([MachineHours],0) AS MachineHours
		,ISNULL([MachineRate],0) AS MachineRate
		,ISNULL([MachineCost],0) AS MachineCost
		,ISNULL([LaborRate],0) AS LaborRate
		,ISNULL([RotoOperHours],0) AS RotoOperHours
		,ISNULL([RotoFloatHours],0) AS RotoFloatHours
		,ISNULL([TotalRotoHours],0) AS TotalRotoHours
		,ISNULL([TotalRotoCost],0) AS TotalRotoCost
		,ISNULL([AssyLaborHours],0) AS AssyLaborHours
		,ISNULL([AssyLeadHours],0) AS AssyLeadHours
		,ISNULL([TotalAssyHours],0) AS TotalAssyHours
		,ISNULL([TotalAssyCost],0) AS TotalAssyCost
		,ISNULL([TotalProcessingCost],0) AS TotalProcessingCost
		,ISNULL([TotalStandardHours],0) AS TotalStandardHours
		,ISNULL(ItemCost,0) AS ItemCost
		,ISNULL(MaterialCost,0) AS MaterialCost
		,ISNULL(MaterialOverheadCost,0) AS MaterialOverheadCost
		,ISNULL(ResourceCost,0) AS ResourceCost
		,ISNULL(OutsideProcessingCost,0) AS OutsideProcessingCost
		,ISNULL(OverheadCost,0) AS OverheadCost
		,CASE WHEN std.StartDate >= cst.StartDate THEN std.StartDate
			  ELSE cst.StartDate 
		 END AS StartDate
		,CASE WHEN ISNULL(std.EndDate,'9999-12-31') <= ISNULL(cst.EndDate,'9999-12-31') THEN ISNULL(std.EndDate,'9999-12-31')
			  ELSE ISNULL(cst.EndDate,'9999-12-31') 
		END AS EndDate
	FROM Fact.LaborStandardPending std 
		FULL OUTER JOIN Fact.MaterialStandardPending cst 
	ON std.ProductID = cst.ProductID
		AND std.LocationID = cst.LocationID
		AND (  std.StartDate BETWEEN cst.StartDate AND ISNULL(cst.EndDate,'9999-12-31') --T1.[Valid From] between T2.[Valid From] and T2.[Valid To]  
			OR (ISNULL(std.EndDate,'9999-12-31') BETWEEN cst.StartDate AND ISNULL(cst.EndDate,'9999-12-31'))
			OR cst.StartDate BETWEEN std.StartDate AND ISNULL(std.EndDate,'9999-12-31')
			OR (ISNULL(cst.EndDate,'9999-12-31') BETWEEN std.StartDate AND ISNULL(std.EndDate,'9999-12-31'))
		)
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(CASE WHEN std.StartDate >= cst.StartDate THEN std.StartDate ELSE cst.StartDate END AS DATE)  = cf.DateKey
)
, Dates AS (
	SELECT CAST(MIN(DateKey) AS DATETIME) AS StartDate
		,DATEADD(DAY,1,DATEADD(MILLISECOND,-10,MAX(CAST(DateKey AS DATETIME)))) AS EndDate 
	FROM dbo.DimCalendarFiscal GROUP BY [Month Sort] 
)
SELECT std.[ProductID]
      ,std.[LocationID]
      ,cf.[DateID]
      ,std.[Machine]
      ,std.[RoundsPerShift]
      ,std.[UnitsPerSpider]
      ,std.[SpidersPerUnit]
      ,std.[MachineHours]
      ,std.[MachineRate]
      ,std.[MachineCost]
      ,std.[LaborRate]
      ,std.[RotoOperHours]
      ,std.[RotoFloatHours]
      ,std.[TotalRotoHours]
      ,std.[TotalRotoCost]
      ,std.[AssyLaborHours]
      ,std.[AssyLeadHours]
      ,std.[TotalAssyHours]
      ,std.[TotalAssyCost]
      ,std.[TotalProcessingCost]
      ,std.[TotalStandardHours]
      ,std.[ItemCost]
      ,std.[MaterialCost]
      ,std.[MaterialOverheadCost]
      ,std.[ResourceCost]
      ,std.[OutsideProcessingCost]
      ,std.[OverheadCost]
	  ,CASE WHEN std.StartDate >= d.StartDate THEN std.StartDate
		  ELSE d.StartDate 
	   END AS StartDate
	  ,CASE WHEN ISNULL(std.EndDate,'9999-12-31') <= ISNULL(d.EndDate,'9999-12-31') THEN ISNULL(std.EndDate,'9999-12-31')
		  ELSE ISNULL(d.EndDate,'9999-12-31') 
	   END AS EndDate
FROM Standards std
	LEFT JOIN Dates d 
ON	(  std.StartDate BETWEEN d.StartDate AND ISNULL(d.EndDate,'9999-12-31') --T1.[Valid From] between T2.[Valid From] and T2.[Valid To]  
		OR (ISNULL(std.EndDate,'9999-12-31') BETWEEN d.StartDate AND ISNULL(d.EndDate,'9999-12-31'))
		OR d.StartDate BETWEEN std.StartDate AND ISNULL(std.EndDate,'9999-12-31')
		OR (ISNULL(d.EndDate,'9999-12-31') BETWEEN std.StartDate AND ISNULL(std.EndDate,'9999-12-31'))
	)
	INNER JOIN dbo.DimCalendarFiscal cf 
ON CAST(CASE WHEN ISNULL(std.EndDate,'9999-12-31') <= ISNULL(d.EndDate,'9999-12-31') THEN ISNULL(std.EndDate,'9999-12-31')
			  ELSE ISNULL(d.EndDate,'9999-12-31') 
	END AS DATE)  = cf.DateKey
WHERE cf.DateKey BETWEEN '2021-01-01' AND '9999-12-31'
GO
