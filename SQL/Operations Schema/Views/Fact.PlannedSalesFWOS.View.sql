USE [Operations]
GO
/****** Object:  View [Fact].[PlannedSalesFWOS]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--DROP TABLE dbo.FactPlannedSales
--SELECT * INTO dbo.FactPlannedSales FROM Fact.PlannedSales
--SELECT * FROM dbo.FactPlannedSales

CREATE VIEW [Fact].[PlannedSalesFWOS] AS
WITH Dates AS (
	SELECT [Week Sort], MIN(DateID) AS DateID
		, DATEADD(WEEK,DATEDIFF(WEEK,-1,DateKey),-1) AS DateKey
		, SUM(CAST(ShipDay AS INT)) AS ShipDays
		, SUM(CASE WHEN [Day Of Week Sort] BETWEEN 2 AND 6 THEN 1 ELSE 0 END) AS WeekDays
	FROM dbo.DimCalendarFiscal 
	WHERE (DateKey >= DATEADD(WEEK,-13,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) AND DateKey < DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) --prior 13 week ship days
		OR (DateKey >= CAST(GETDATE() AS DATE)) --AND DateKey < DATEADD(WEEK,DATEDIFF(WEEK,-1,DATEADD(WEEK,14,CAST(GETDATE() AS DATE))),-1)) --current day and forward
	GROUP BY [Week Sort], DATEADD(WEEK,DATEDIFF(WEEK,-1,DateKey),-1)
	HAVING SUM(CAST(ShipDay AS INT)) > 0
)
SELECT 0 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
		,cf2.DateID AS ProductionDateID
		,cf1.DateID AS SnapshotDateID
		--,d.DateID AS PlanDateID
		,d.DateID AS PostDateID
		,SUM(CASE WHEN Order_Type = 29 THEN Quantity ELSE 0 END)/ShipDays AS SalesQuantity
		,SUM(CASE WHEN Order_Type = 30 THEN Quantity ELSE 0 END)/ShipDays AS ForecastQuantity
		,(SUM([QUANTITY])/ShipDays)*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		,(d.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey  --AND CAST(START_OF_WEEK AS DATE) < DATEADD(WEEK,13,d.DateKey)  --AND GETDATE()  BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshot 
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(GETDATE() AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = d.[Week Sort] AND cf2.[Day of Week Sort] BETWEEN 2 AND 6 AND cf2.[ShipDay] = 1 AND cf2.DateKey >= CAST(GETDATE() AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = d.DateKey
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (29,30)) aND mov.CurrentRecord = 1
GROUP BY  l.LocationID
		,l.LocationKey
		,pm.ProductID
		,pm.ProductKey
		,dc.DemandClassID
		,dc.DemandClassKey
		,d.DateID
		,cf1.DateID
		,cf2.DateID
		,d.DateID
		,d.ShipDays
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
UNION
SELECT 13 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
		,cf2.DateID AS ProductionDateID
		,cf1.DateID AS SnapshotDateID
		--,d.DateID AS PlanDateID
		,d.DateID AS PostDateID
		,SUM(CASE WHEN Order_Type = 29 THEN Quantity ELSE 0 END)/ShipDays AS SalesQuantity
		,SUM(CASE WHEN Order_Type = 30 THEN Quantity ELSE 0 END)/ShipDays AS ForecastQuantity
		,(SUM([QUANTITY])/ShipDays)*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		,(d.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey AND CAST(START_OF_WEEK AS DATE) < DATEADD(WEEK,13,GETDATE()) --AND GETDATE()  BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshot 
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(GETDATE() AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = d.[Week Sort] AND cf2.[Day of Week Sort] BETWEEN 2 AND 6 AND cf2.[ShipDay] = 1 AND cf2.DateKey >= CAST(GETDATE() AS DATE) AND cf2.DateKey < CAST(DATEADD(WEEK,13,GETDATE()) AS DATE) --future weekdays within 13 weeks
	--LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = d.DateKey
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (29,30)) aND mov.CurrentRecord = 1
GROUP BY  l.LocationID
		,l.LocationKey
		,pm.ProductID
		,pm.ProductKey
		,dc.DemandClassID
		,dc.DemandClassKey
		,d.DateID
		,cf1.DateID
		,cf2.DateID
		,d.DateID
		,d.ShipDays
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
UNION
SELECT	-1 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf1.DateID AS ProductionDateID
		,cf2.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM(CASE WHEN ORDER_TYPE = 30 THEN [QUANTITY] ELSE 0 END) AS SalesQuantity 
		,SUM(CASE WHEN ORDER_TYPE = 29 THEN [QUANTITY] ELSE 0 END) AS ForecastQuantity 
		,SUM([QUANTITY])*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey AND DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshots
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.DateKey = CAST(DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1))) AS DATE)
	--LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = d.DateKey
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (29,30))
	AND cf1.DateKey > DATEADD(WEEK,-1,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) AND cf1.DateKey <= DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1) 
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		,pm.ProductKey
		,dc.DemandClassID
		,dc.DemandClassKey
		--,d.DateID
		,cf1.DateID
		,cf2.DateID
		--,cf3.DateID
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
		,mov.StartDate
		,mov.EndDate
UNION
SELECT	-4 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf1.DateID AS ProductionDateID
		,cf2.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM(CASE WHEN ORDER_TYPE = 30 THEN [QUANTITY] ELSE 0 END) AS SalesQuantity 
		,SUM(CASE WHEN ORDER_TYPE = 29 THEN [QUANTITY] ELSE 0 END) AS ForecastQuantity 
		,SUM([QUANTITY])*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey --AND CAST(START_OF_WEEK AS DATE) < d.DateKey  
		AND DATEADD(WEEK,-3,DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshot
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.DateKey = CAST(DATEADD(WEEK,-3,DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) AS DATE)
	--LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = d.DateKey --= DATEADD(WEEK,-4,d.DateKey)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (29,30))
	AND cf1.DateKey BETWEEN DATEADD(WEEK,-3,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) AND DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1) 
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		,pm.ProductKey
		,dc.DemandClassID
		,dc.DemandClassKey
		,cf1.DateID
		,cf2.DateID
		--,cf3.DateID
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
		,mov.StartDate
		,mov.EndDate
UNION
SELECT	-8 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf1.DateID AS ProductionDateID
		,cf2.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM(CASE WHEN ORDER_TYPE = 30 THEN [QUANTITY] ELSE 0 END) AS SalesQuantity 
		,SUM(CASE WHEN ORDER_TYPE = 29 THEN [QUANTITY] ELSE 0 END) AS ForecastQuantity 
		,SUM([QUANTITY])*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey --AND CAST(START_OF_WEEK AS DATE) < d.DateKey  
		AND DATEADD(WEEK,-7,DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshot
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.DateKey = CAST(DATEADD(WEEK,-7,DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) AS DATE)
	--LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = d.DateKey --DATEADD(WEEK,-8,d.DateKey)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (29,30)) 
	AND cf1.DateKey BETWEEN DATEADD(WEEK,-7,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) AND DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1) 
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		,pm.ProductKey
		,dc.DemandClassID
		,dc.DemandClassKey
		,cf1.DateID
		,cf2.DateID
		--,cf3.DateID
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
UNION
SELECT	-13 AS ForecastID
		,l.LocationID
--		,l.LocationKey
		,pm.ProductID
--		,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf1.DateID AS ProductionDateID
		,cf2.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM(CASE WHEN ORDER_TYPE = 30 THEN [QUANTITY] ELSE 0 END) AS SalesQuantity 
		,SUM(CASE WHEN ORDER_TYPE = 29 THEN [QUANTITY] ELSE 0 END) AS ForecastQuantity 
		,SUM([QUANTITY])*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey --AND CAST(START_OF_WEEK AS DATE) < d.DateKey  
		AND DATEADD(WEEK,-12,DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshot
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.DateKey = CAST(DATEADD(WEEK,-12,DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) AS DATE)
	--LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = d.DateKey --DATEADD(WEEK,-13,d.DateKey)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (29,30))
	 AND cf1.DateKey BETWEEN DATEADD(WEEK,-12,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) AND DATEADD(WEEK,DATEDIFF(WEEK,-1,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)),-1) 
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		,pm.ProductKey
		,dc.DemandClassID
		,dc.DemandClassKey
		,cf1.DateID
		,cf2.DateID
		--,cf3.DateID
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
		,mov.StartDate
		,mov.EndDate
GO
