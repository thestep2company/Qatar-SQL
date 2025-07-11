USE [Operations]
GO
/****** Object:  View [Fact].[WeeklyGoal]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [Fact].[WeeklyGoal] AS
SELECT MIN(c.ID) AS DateID
	  ,l.LocationID AS [PlantID]
	  ,NULL AS ShiftID
      ,[ProductionDays]
      ,[MachineCount]
      ,[NSP]
	  ,[Cost]
	  ,0 AS MachineCountBudget
	  ,0 AS NSPBudget
	  ,0 AS CostBudget
	  ,0 AS Scrap
	  ,0 AS Repair
	  ,0 AS MissedCycle
FROM Manufacturing.Forecast g
	LEFT JOIN dbo.CalendarFiscal c ON g.Year = c.Year  AND g.Week = c.Week
	LEFT JOIN Dim.Location l ON g.PlantKey = l.LocationKey
GROUP BY 
	   l.LocationID 
	  ,g.Year
	  ,g.Week
      ,[ProductionDays]
      ,[MachineCount]
      ,[NSP]
	  ,[Cost]
UNION ALL
SELECT MIN(c.ID) AS DateID
	  ,l.LocationID AS [PlantID]
	  ,NULL AS ShiftID
      ,[ProductionDays]
      ,0 AS MachineCount
	  ,0 AS NSP
	  ,0 AS Cost
	  ,[MachineCount] AS MachineCountBudget
      ,[NSP] AS NSPBUdget
	  ,[Cost] AS CostBudget
	  ,0 AS Scrap
	  ,0 AS Repair
	  ,0 AS MissedCycle
FROM Manufacturing.Budget g
	LEFT JOIN dbo.CalendarFiscal c ON g.Year = c.Year  AND g.Week = c.Week
	LEFT JOIN Dim.Location l ON g.PlantKey = l.LocationKey
GROUP BY 
	   l.LocationID 
	  ,g.Year
	  ,g.Week
      ,[ProductionDays]
      ,[MachineCount]
      ,[NSP]
	  ,[Cost]
UNION ALL
SELECT c.ID AS DateID
	  ,l.LocationID AS [PlantID]
	  ,NULL AS ShiftID
      ,0 [ProductionDays]
      ,0 AS MachineCount
	  ,0 AS NSP
	  ,0 AS Cost
	  ,0 AS [MachineCount] 
      ,0 AS NSPBUdget
	  ,0 AS CostBudget
	  ,Scrap
	  ,Repair
	  ,MissedCycle
FROM Manufacturing.KPIGoal g
	LEFT JOIN dbo.CalendarFiscal c ON g.Year = c.Year  AND g.Week = c.Week
	LEFT JOIN Dim.Location l ON g.PlantKey = l.LocationKey

GO
