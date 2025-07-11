USE [Operations]
GO
/****** Object:  View [Fact].[Goal]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[Goal] AS
WITH Data AS (
/*
	SELECT c.ID AS DateID
		  ,l.LocationID AS PlantID
		  ,s.ShiftID
		  ,sc.Shift_ID AS CurrentShiftID
		  ,0 AS [ProductionDays]
		  ,0 AS [MachineCount]
		  ,[NSP]*pf.[Percent] AS [NSP]
		  ,[Cost]*pf.[Percent] AS [Cost]
		  ,[FTEHC]*SUM(pf.[Percent]) OVER (PARTITION BY s.ShiftID, l.LocationID, c.WeekID) AS [FTEHeadCount]
		  ,[TrainingHC]*SUM(pf.[Percent]) OVER (PARTITION BY s.ShiftID, l.LocationID, c.WeekID) AS [TrainingHeadcount]
		  ,0 AS MachineCountBudget
		  ,0 AS NSPBudget
		  ,0 AS CostBudget
		  ,0 AS [FTEBudget]
		  ,0 AS [TrainingBudget]
		  ,0 AS Scrap
		  ,0 AS Repair
		  ,0 AS MissedCycle
	FROM Manufacturing.Forecast g
		LEFT JOIN dbo.CalendarFiscal c ON g.Year = c.Year  AND g.Week = c.Week
		INNER JOIN xref.ProductionForecast pf ON g.PlantKey = pf.Org AND pf.Date = c.DateKey
		LEFT JOIN Dim.Location l ON g.PlantKey = l.LocationKey
		LEFT JOIN Dim.SHift s ON pf.Shift = s.ShiftKey
		LEFT JOIN Manufacturing.Shift sc ON sc.Shift = s.ShiftKey AND c.DateKey = CAST(sc.Start_Date_Time AS DATE) AND g.PlantKey = sc.Org
	UNION ALL
	SELECT c.ID AS DateID
		  ,l.LocationID AS PlantID
		  ,s.ShiftID
		  ,sc.Shift_ID AS CurrentShiftID
		  ,0 AS [ProductionDays]
		  ,g.MachineCount*mcf.[Percent] AS [MachineCount]
		  ,0 AS [NSP]
		  ,0 AS [Cost]
		  ,0 AS [FTEHeadcount]
		  ,0 AS [TrainingHeadcount]
		  ,0 AS MachineCountBudget
		  ,0 AS NSPBudget
		  ,0 AS CostBudget
		  ,0 AS [FTEBudget]
		  ,0 AS [TrainingBudget]
		  ,0 AS Scrap
		  ,0 AS Repair
		  ,0 AS MissedCycle
	FROM Manufacturing.Forecast g
		LEFT JOIN dbo.CalendarFiscal c ON g.Year = c.Year  AND g.Week = c.Week
		INNER JOIN xref.MachineCountForecast mcf ON g.PlantKey = mcf.Org AND mcf.Date = c.DateKey
		LEFT JOIN Dim.Location l ON g.PlantKey = l.LocationKey
		LEFT JOIN Dim.SHift s ON mcf.Shift = s.ShiftKey
		LEFT JOIN Manufacturing.Shift sc ON sc.Shift = s.ShiftKey AND c.DateKey = CAST(sc.Start_Date_Time AS DATE) AND g.PlantKey = sc.Org
*/
	SELECT DISTINCT --[ID]
		   c.DateID
		  ,l.LocationID AS PlantID
		  ,s.ShiftID
		  ,sc.Shift_ID AS CurrentShiftID
		  ,0 AS [ProductionDays]
		  ,0 AS MachineCount
		  ,[Value]*pf.[Percent] AS NSP
		  ,0 AS Cost
		  ,0 AS FTEHeadCount
		  ,0 AS TrainingHeadcount
		  ,0 AS MachineCountBudget
		  ,0 AS NSPBudget
		  ,0 AS CostBudget
		  ,0 AS FTEBudget
		  ,0 AS TrainingBudget
		  ,0 AS Scrap
		  ,0 AS Repair
		  ,0 AS MissedCycle
	  FROM [xref].[ManufacturingForecast] g
		LEFT JOIN dbo.DimCalendarFiscal c ON c.Year = g.Year AND c.WeekNum = g.Week
  		LEFT JOIN xref.ProductionForecast pf ON g.Plant = pf.Org AND pf.Date = c.DateKey
		LEFT JOIN dbo.DimLocation l ON g.Plant = l.LocationKey
		LEFT JOIN dbo.DimSHift s ON pf.Shift = s.ShiftKey
		LEFT JOIN Manufacturing.Shift sc ON sc.Shift = s.ShiftKey AND c.DateKey = CAST(sc.Start_Date_Time AS DATE) AND g.Plant = sc.Org
	  WHERE Account = 'NSP' AND pf.[Percent] <> 0
	  UNION
	SELECT DISTINCT --[ID]
		   c.DateID
		  ,l.LocationID AS PlantID
		  ,s.ShiftID
		  ,sc.Shift_ID AS CurrentShiftID
		  ,0 AS [ProductionDays]
		  ,0 AS MachineCount
		  ,0 AS NSP
		  ,[Value]*pf.[Percent] AS Cost
		  ,0 AS FTEHeadCount
		  ,0 AS TrainingHeadcount
		  ,0 AS MachineCountBudget
		  ,0 AS NSPBudget
		  ,0 AS CostBudget
		  ,0 AS FTEBudget
		  ,0 AS TrainingBudget
		  ,0 AS Scrap
		  ,0 AS Repair
		  ,0 AS MissedCycle
	  FROM [xref].[ManufacturingForecast] g
		LEFT JOIN dbo.DimCalendarFiscal c ON c.Year = g.Year AND c.WeekNum = g.Week
  		LEFT JOIN xref.ProductionForecast pf ON g.Plant = pf.Org AND pf.Date = c.DateKey
		LEFT JOIN dbo.DimLocation l ON g.Plant = l.LocationKey
		LEFT JOIN dbo.DimSHift s ON pf.Shift = s.ShiftKey
		LEFT JOIN Manufacturing.Shift sc ON sc.Shift = s.ShiftKey AND c.DateKey = CAST(sc.Start_Date_Time AS DATE) AND g.Plant = sc.Org
	  WHERE Account = 'Cost' AND pf.[Percent] <> 0
	UNION
	SELECT DISTINCT --[ID]
		   c.DateID
		  ,l.LocationID AS PlantID
		  ,s.ShiftID
		  ,sc.Shift_ID AS CurrentShiftID
		  ,0 AS [ProductionDays]
		  ,[Value]*pf.[Percent] AS MachineCount
		  ,0 AS NSP
		  ,0 AS Cost
		  ,0 AS FTEHeadCount
		  ,0 AS TrainingHeadcount
		  ,0 AS MachineCountBudget
		  ,0 AS NSPBudget
		  ,0 AS CostBudget
		  ,0 AS FTEBudget
		  ,0 AS TrainingBudget
		  ,0 AS Scrap
		  ,0 AS Repair
		  ,0 AS MissedCycle
	  FROM [xref].[ManufacturingForecast] g
		LEFT JOIN dbo.DimCalendarFiscal c ON c.Year = g.Year AND c.WeekNum = g.Week
  		LEFT JOIN xref.ProductionForecast pf ON g.Plant = pf.Org AND pf.Date = c.DateKey
		LEFT JOIN dbo.DimLocation l ON g.Plant = l.LocationKey
		LEFT JOIN dbo.DimSHift s ON pf.Shift = s.ShiftKey
		LEFT JOIN Manufacturing.Shift sc ON sc.Shift = s.ShiftKey AND c.DateKey = CAST(sc.Start_Date_Time AS DATE) AND g.Plant = sc.Org
	  WHERE Account = 'Machine' AND pf.[Percent] <> 0
	UNION ALL
	SELECT MIN(c.DateID) AS DateID
		  ,l.LocationID AS [PlantID]
		  ,NULL AS ShiftID
		  ,NULL AS CurrentShiftID
		  ,[ProductionDays]
		  ,[MachineCount]
		  ,[NSP]
		  ,[Cost]
		  ,[FTEHC] AS [FTEHeadcount]
		  ,[TrainingHC] AS [TrainingHeadcount]
		  ,0 AS MachineCountBudget
		  ,0 AS NSPBudget
		  ,0 AS CostBudget
		  ,0 AS [FTEBudget]
		  ,0 AS [TrainingBudget]
		  ,0 AS Scrap
		  ,0 AS Repair
		  ,0 AS MissedCycle
	FROM Manufacturing.Forecast g
		LEFT JOIN dbo.DimCalendarFiscal c ON g.Year = c.Year  AND g.Week = c.WeekNum
		LEFT JOIN dbo.DimLocation l ON g.PlantKey = l.LocationKey
		LEFT JOIN xref.ProductionForecast pf ON g.PlantKey = pf.Org AND pf.Date = c.DateKey
	WHERE pf.Date IS NULL 
	GROUP BY 
		   l.LocationID 
		  ,g.Year
		  ,g.Week
		  ,[ProductionDays]
		  ,[MachineCount]
		  ,[NSP]
		  ,[Cost]
		  ,[FTEHC]
		  ,[TrainingHC]
	UNION ALL
	SELECT MIN(c.DateID) AS DateID
		  ,l.LocationID AS [PlantID]
		  ,NULL AS ShiftID
		  ,NULL AS CurrentShiftID
		  ,[ProductionDays]
		  ,0 AS MachineCount
		  ,0 AS NSP
		  ,0 AS Cost
		  ,0 AS [FTEHeadcount]
		  ,0 AS [TrainingHeadcount]
		  ,[MachineCount] AS MachineCountBudget
		  ,[NSP] AS NSPBUdget
		  ,[Cost] AS CostBudget
		  ,[FTEHC] AS [FTEBudget]
		  ,[TrainingHC] AS [TrainingBudget]
		  ,0 AS Scrap
		  ,0 AS Repair
		  ,0 AS MissedCycle
	FROM Manufacturing.Budget g
		LEFT JOIN dbo.DimCalendarFiscal c ON g.Year = c.Year  AND g.Week = c.WeekNum
		LEFT JOIN dbo.DimLocation l ON g.PlantKey = l.LocationKey
	GROUP BY 
		   l.LocationID 
		  ,g.Year
		  ,g.Week
		  ,[ProductionDays]
		  ,[MachineCount]
		  ,[NSP]
		  ,[Cost]
		  ,[FTEHC]
		  ,[TrainingHC]
	UNION ALL
	SELECT c.DateID
		  ,l.LocationID AS [PlantID]
		  ,s.ShiftID
		  ,sc.Shift_ID AS CurrentShiftID
		  ,0 [ProductionDays]
		  ,0 AS MachineCount
		  ,0 AS NSP
		  ,0 AS Cost
		  ,0 AS [FTEHeadcount]
		  ,0 AS [TrainingHeadcount]
		  ,0 AS [MachineCount] 
		  ,0 AS NSPBUdget
		  ,0 AS CostBudget
		  ,0 AS [FTEBudget]
		  ,0 AS [TrainingBudget]
		  ,ISNULL(Scrap,0) AS Scrap
		  ,ISNULL(Repair,0) AS Repair
		  ,ISNULL(MissedCycle,0) AS MissedCycle
	FROM Manufacturing.KPIGoal g
		LEFT JOIN dbo.DimCalendarFiscal c ON g.Year = c.Year  AND g.Week = c.WeekNum
		LEFT JOIN dbo.DimLocation l ON g.PlantKey = l.LocationKey
		LEFT JOIN (SELECT DISTINCT Shift, Org FROM Manufacturing.Shift) xref ON g.PlantKey = xref.Org
		LEFT JOIN dbo.DimShift s ON xref.Shift = s.ShiftKey
		LEFT JOIN Manufacturing.Shift sc ON sc.Shift = s.ShiftKey AND c.DateKey = CAST(sc.Start_Date_Time AS DATE) AND g.PlantKey = sc.Org

)
SELECT d.DateID, d.PlantID, d.ShiftID, d.CurrentShiftID
	,AVG(d.ProductionDays) AS ProductionDays
	,CASE WHEN MAX(d.MachineCount) > 0 THEN 1 END AS ForecastDays
	,SUM(d.MachineCount) AS MachineCount
	,SUM(d.NSP) AS NSP
	,SUM(d.Cost) AS Cost
	,MAX(d.FTEHeadcount) AS FTEHeadcount
	,MAX(d.TrainingHeadcount) AS TrainingHeadcount
	,SUM(d.MachineCountBudget) AS MachineCountBudget
	,SUM(d.NSPBudget) AS NSPBudget
	,SUM(d.CostBudget) AS CostBudget
	,MAX(d.FTEBudget) AS FTEBudget
	,MAX(d.TrainingBudget) AS TrainingBudget
	,MAX(d.Scrap) AS Scrap
	,MAX(d.Repair) AS Repair
	,MAX(d.MissedCycle) AS MissedCycle
	,MIN(ISNULL(f.[Percent],1)) AS GoalFactor
FROM Data d
	LEFT JOIN Fact.GoalFactor f ON d.DateID = f.DateID AND d.PlantID = f.PlantID AND d.ShiftID = f.ShiftID AND f.ShiftOffsetID = 1
GROUP BY d.DateID, d.PlantID, d.ShiftID, d.CurrentShiftID
GO
