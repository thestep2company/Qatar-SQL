USE [Operations]
GO
/****** Object:  View [Fact].[PlanLive]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[PlanLive] AS

SELECT PlantID
	,ProductID
	,DemandClassID
	,InventoryCodeID
	,1 AS InventoryStatusID
	,DateID  
	,InventoryTypeID 
	,SUM([Sale Price]) AS [Sale Price]
	,SUM([Average Cost]) AS [Average Cost]
	,SUM([Inventory Cost]) AS [Inventory Cost]
	,SUM([Quantity]) AS [Quantity]
	,SUM([Machine Hours]) AS [Machine Hours]
FROM dbo.FactPlan
WHERE InventoryTypeID = 10
	AND DateID  >=
			(
		SELECT MIN(m2m.DateID) AS DateID
			FROM dbo.DimM2MTimeSeries m2m
			LEFT JOIN dbo.DimTimeSeries ts ON m2m.TimeSeriesID = ts.TimeSeriesID
			LEFT JOIN dbo.DimCalendarFiscal cf ON m2m.DateID = cf.DateID
		WHERE ts.TimeSeriesKey = 'T4W'
		)
GROUP BY 
	PlantID
	,ProductID
	,DemandClassID
	,InventoryCodeID
	,DateID
	,InventoryTypeID 
GO
