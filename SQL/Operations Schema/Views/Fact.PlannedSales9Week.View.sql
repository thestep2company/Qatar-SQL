USE [Operations]
GO
/****** Object:  View [Fact].[PlannedSales9Week]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [Fact].[PlannedSales9Week] AS

WITH Dates AS (
	SELECT DateKey, DateID
	FROM dbo.DimCalendarFiscal 
	WHERE [Day of Week Sort] = 1
		AND DateKey >= DATEADD(MONTH,-4,GETDATE())
	--ORDER BY DateKey
)
--hold on to saturday of prior week snapshots as "frozen" production
SELECT 9 AS ForecastID
		,l.LocationID
		,dc.DemandClassID
		,pm.ProductID
		,cf1.DateID AS ProductionDateID
		,cf2.DateID AS SnapshotDateID
		,cf3.DateID AS PlanDate
		,d.DateID AS PostDateID
		,SUM(Quantity) AS SalesQuantity
		,0 AS ForecastQuantity
		,SUM([QUANTITY]*ISNULL(fs111.ItemCost,fs122.ItemCost)) AS Cost
		,(d.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) >= DATEADD(WEEK,-14,d.DateKey) AND CAST(START_OF_WEEK AS DATE) < d.DateKey  
		AND DATEADD(WEEK,-14,DATEADD(HOUR,10,CAST(DateKey AS DATETIME))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshot for SB
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.DateKey = CAST(DATEADD(WEEK,-14,DATEADD(HOUR,10,CAST(d.DateKey AS DATETIME))) AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = DATEADD(WEEK,-13,d.DateKey)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 22 and (mov.order_type = 29)) AND d.DateID - cf2.DateID = 98 -- or mov.order_type = 30))
	AND cf2.DateKey < GETDATE()
GROUP BY l.LocationID
		,dc.DemandClassID
		,pm.ProductID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,d.DateID
		,fs111.Machine
		,fs122.Machine
UNION ALL
SELECT 9 AS ForecastID
		,l.LocationID
		,dc.DemandClassID
		,pm.ProductID
		,cf1.DateID AS ProductionDateID
		,cf2.DateID AS SnapshotDateID
		,cf3.DateID AS PlanDate
		,d.DateID AS PostDateID
		,0 AS SalesQuantity
		,SUM(Quantity) AS ForecastQuantity
		,SUM([QUANTITY]*ISNULL(fs111.ItemCost,fs122.ItemCost)) AS Cost
		,(d.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) >= DATEADD(WEEK,-14,d.DateKey) AND CAST(START_OF_WEEK AS DATE) < d.DateKey  
		AND DATEADD(WEEK,-14,DATEADD(HOUR,10,CAST(DateKey AS DATETIME))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshot for SB
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.DateKey = CAST(DATEADD(WEEK,-14,DATEADD(HOUR,10,CAST(d.DateKey AS DATETIME))) AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = DATEADD(WEEK,-13,d.DateKey)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 22 and (mov.order_type = 30)) AND d.DateID - cf2.DateID = 98
	AND cf2.DateKey < GETDATE()
GROUP BY l.LocationID
		,dc.DemandClassID
		,pm.ProductID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,d.DateID
		,fs111.Machine
		,fs122.Machine

GO
