USE [Operations]
GO
/****** Object:  View [Fact].[PlannedProductionFWOS]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[PlannedProductionFWOS] AS
WITH Dates AS (
	SELECT [Week Sort], DateKey, MIN(DateID) AS DateID
	FROM dbo.DimCalendarFiscal 
	WHERE (DateKey >= DATEADD(WEEK,-13,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) AND DateKey <= DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) --prior 13 week ship days
		OR (DateKey >= CAST(GETDATE() AS DATE))
	GROUP BY [Week Sort], DateKey, DATEADD(WEEK,DATEDIFF(WEEK,-1,DateKey),-1)
)

SELECT	0 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf2.DateID AS ProductionDateID
		,cf3.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM([QUANTITY])/COUNT(CASE WHEN cf2.SBHoliday = 0 THEN cf2.DateKey ELSE NULL END) OVER(PARTITION BY cf2.[Week Sort], pm.ProductID, dc.DemandClassID, l.LocationID) AS ProductionQuantity 
		,SUM([QUANTITY]*fs111.ItemCost)/COUNT(cf2.DateKey) OVER(PARTITION BY cf2.[Week Sort], pm.ProductID, dc.DemandClassID, l.LocationID) AS Cost
		--,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(fs111.[MachineHours]*QUANTITY) AS MachineHoursPlan
		,fs111.Machine AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = cf1.[Week Sort]
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = CAST(GETDATE() AS DATE)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	--LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
	AND ORGANIZATION_CODE LIKE '%111%' --data was purged for non saturday dates
	aND mov.CurrentRecord = 1
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
		--,dc.DemandClassKey
		--,d.DateID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,cf2.[Week Sort]
		,fs111.Machine
		,cf2.SBHoliday
		,cf2.DateKey
UNION
SELECT	0 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf2.DateID AS ProductionDateID
		,cf3.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
--		,SUM([QUANTITY]) AS QtyRef
--		,COUNT(CASE WHEN cf2.PVHoliday = 0 THEN cf2.DateKey ELSE NULL END) OVER(PARTITION BY cf2.[Week Sort], pm.ProductID, dc.DemandClassID, l.LocationID) AS DateCount
		,SUM([QUANTITY])/COUNT(CASE WHEN cf2.PVHoliday = 0 THEN cf2.DateKey ELSE NULL END) OVER(PARTITION BY cf2.[Week Sort], pm.ProductID, dc.DemandClassID, l.LocationID) AS ProductionQuantity 
		,SUM([QUANTITY]*fs111.ItemCost)/COUNT(cf2.DateKey) OVER(PARTITION BY cf2.[Week Sort], pm.ProductID, dc.DemandClassID, l.LocationID) AS Cost
		--,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(fs111.[MachineHours]*QUANTITY) AS MachineHoursPlan
		,fs111.Machine AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = cf1.[Week Sort]
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = CAST(GETDATE() AS DATE)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	--LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
	AND ORGANIZATION_CODE LIKE '%122%' --data was purged for non saturday dates
	AND mov.CurrentRecord = 1
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
		--,dc.DemandClassKey
		--,d.DateID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,cf2.[Week Sort]
		,fs111.Machine
		,cf2.PVHoliday
		,cf2.DateKey
UNION
SELECT	13 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf2.DateID AS ProductionDateID
		,cf3.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM([QUANTITY])/COUNT(CASE WHEN cf2.SBHoliday = 0 THEN cf2.DateKey ELSE NULL END) OVER(PARTITION BY cf2.[Week Sort], pm.ProductID, dc.DemandClassID, l.LocationID) AS ProductionQuantity 
		,SUM([QUANTITY]*fs111.ItemCost)/COUNT(cf2.DateKey) OVER(PARTITION BY cf2.[Week Sort], pm.ProductID, dc.DemandClassID, l.LocationID) AS Cost
		--,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(fs111.[MachineHours]*QUANTITY) AS MachineHoursPlan
		,fs111.Machine AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey AND GETDATE() BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --current snapshots
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = cf1.[Week Sort]
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = CAST(GETDATE() AS DATE)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	--LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
	AND ORGANIZATION_CODE LIKE '%111%' --data was purged for non saturday dates
	AND cf2.DateKey >= CAST(GETDATE() AS DATE) AND cf2.DateKey < DATEADD(WEEK,13,CAST(GETDATE() AS DATE))
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
		--,dc.DemandClassKey
		--,d.DateID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,cf2.[Week Sort]
		,fs111.Machine
		,cf2.SBHoliday
		,cf2.DateKey
UNION
SELECT	13 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf2.DateID AS ProductionDateID
		,cf3.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
--		,SUM([QUANTITY]) AS QtyRef
--		,COUNT(CASE WHEN cf2.PVHoliday = 0 THEN cf2.DateKey ELSE NULL END) OVER(PARTITION BY cf2.[Week Sort], pm.ProductID, dc.DemandClassID, l.LocationID) AS DateCount
		,SUM([QUANTITY])/COUNT(CASE WHEN cf2.PVHoliday = 0 THEN cf2.DateKey ELSE NULL END) OVER(PARTITION BY cf2.[Week Sort], pm.ProductID, dc.DemandClassID, l.LocationID) AS ProductionQuantity 
		,SUM([QUANTITY]*fs111.ItemCost)/COUNT(cf2.DateKey) OVER(PARTITION BY cf2.[Week Sort], pm.ProductID, dc.DemandClassID, l.LocationID) AS Cost
		--,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(fs111.[MachineHours]*QUANTITY) AS MachineHoursPlan
		,fs111.Machine AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey AND GETDATE() BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --current snapshots
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = cf1.[Week Sort]
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = CAST(GETDATE() AS DATE)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	--LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
	AND ORGANIZATION_CODE LIKE '%122%' --data was purged for non saturday dates
	AND cf2.DateKey >= CAST(GETDATE() AS DATE) AND cf2.DateKey < DATEADD(WEEK,13,CAST(GETDATE() AS DATE))
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
		--,dc.DemandClassKey
		--,d.DateID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,cf2.[Week Sort]
		,fs111.Machine
		,cf2.PVHoliday
		,cf2.DateKey
UNION
SELECT	-1 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf2.DateID AS ProductionDateID
		,cf3.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM([QUANTITY])/7 AS ProductionQuantity 
		,(SUM([QUANTITY])/7)*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		--,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey AND DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshots
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = cf1.[Week Sort] 
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = CAST(DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1))) AS DATE)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
	AND (ORGANIZATION_CODE LIKE '%111%') --data was purged for non saturday dates
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
		,cf3.DateID
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
UNION
SELECT	-4 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf2.DateID AS ProductionDateID
		,cf3.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM([QUANTITY])/7 AS ProductionQuantity 
		,(SUM([QUANTITY])/7)*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		--,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey AND DATEADD(WEEK,-3,DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshots
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = cf1.[Week Sort] 
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = CAST(DATEADD(WEEK,-3,DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) AS DATE)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
	AND (ORGANIZATION_CODE LIKE '%111%') --data was purged for non saturday dates
	AND cf1.DateKey >= DATEADD(WEEK,-3,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) AND cf1.DateKey <= DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1) 
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		,pm.ProductKey
		,dc.DemandClassID
		,dc.DemandClassKey
		--,d.DateID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
UNION
SELECT	-8 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf2.DateID AS ProductionDateID
		,cf3.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM([QUANTITY])/7 AS ProductionQuantity 
		,(SUM([QUANTITY])/7)*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		--,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey AND DATEADD(WEEK,-7,DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshots
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = cf1.[Week Sort] 
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = CAST(DATEADD(WEEK,-7,DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) AS DATE)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
	AND (ORGANIZATION_CODE LIKE '%111%') --data was purged for non saturday dates
	AND cf1.DateKey >= DATEADD(WEEK,-7,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) AND cf1.DateKey <= DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1) 
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		,pm.ProductKey
		,dc.DemandClassID
		,dc.DemandClassKey
		--,d.DateID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
UNION
SELECT	-13 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf2.DateID AS ProductionDateID
		,cf3.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM([QUANTITY])/7 AS ProductionQuantity 
		,(SUM([QUANTITY])/7)*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		--,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey AND DATEADD(WEEK,-12,DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshots
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = cf1.[Week Sort] 
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = CAST(DATEADD(WEEK,-12,DATEADD(DAY,-1,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) AS DATE)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
	AND (ORGANIZATION_CODE LIKE '%111%' ) --data was purged for non saturday dates
	AND cf1.DateKey >= DATEADD(WEEK,-12,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) AND cf1.DateKey <= DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1) 
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		,pm.ProductKey
		,dc.DemandClassID
		,dc.DemandClassKey
		--,d.DateID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
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
		,cf2.DateID AS ProductionDateID
		,cf3.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM([QUANTITY])/7 AS ProductionQuantity 
		,(SUM([QUANTITY])/7)*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		--,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey AND DATEADD(DAY,-2,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshots
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = cf1.[Week Sort] 
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = CAST(DATEADD(DAY,-2,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1))) AS DATE)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
	AND (ORGANIZATION_CODE LIKE '%122%') --data was purged for non saturday dates
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
		,cf3.DateID
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
UNION
SELECT	-4 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf2.DateID AS ProductionDateID
		,cf3.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM([QUANTITY])/7 AS ProductionQuantity 
		,(SUM([QUANTITY])/7)*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		--,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey AND DATEADD(WEEK,-3,DATEADD(DAY,-2,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshots
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = cf1.[Week Sort] 
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = CAST(DATEADD(WEEK,-3,DATEADD(DAY,-2,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) AS DATE)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
	AND (ORGANIZATION_CODE LIKE '%122%') --data was purged for non saturday dates
	AND cf1.DateKey >= DATEADD(WEEK,-3,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) AND cf1.DateKey <= DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1) 
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		,pm.ProductKey
		,dc.DemandClassID
		,dc.DemandClassKey
		--,d.DateID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
UNION
SELECT	-8 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf2.DateID AS ProductionDateID
		,cf3.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM([QUANTITY])/7 AS ProductionQuantity 
		,(SUM([QUANTITY])/7)*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		--,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey AND DATEADD(WEEK,-7,DATEADD(DAY,-2,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshots
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = cf1.[Week Sort] 
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = CAST(DATEADD(WEEK,-7,DATEADD(DAY,-2,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) AS DATE)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
	AND (ORGANIZATION_CODE LIKE '%122%') --data was purged for non saturday dates
	AND cf1.DateKey >= DATEADD(WEEK,-7,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) AND cf1.DateKey <= DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1) 
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		,pm.ProductKey
		,dc.DemandClassID
		,dc.DemandClassKey
		--,d.DateID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
UNION
SELECT	-13 AS ForecastID
		,l.LocationID
		--,l.LocationKey
		,pm.ProductID
		--,pm.ProductKey
		,dc.DemandClassID
--		,dc.DemandClassKey
		,cf2.DateID AS ProductionDateID
		,cf3.DateID AS SnapshotDateID
		--,cf3.DateID AS PlanDateID
		,cf1.DateID AS PostDateID
		,SUM([QUANTITY])/7 AS ProductionQuantity 
		,(SUM([QUANTITY])/7)*ISNULL(fs111.ItemCost,fs122.ItemCost) AS Cost
		--,(cf2.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM(ISNULL(fs111.[MachineHours],fs122.[MachineHours])*QUANTITY) AS MachineHoursPlan
		,ISNULL(fs111.Machine,fs122.Machine) AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey AND DATEADD(WEEK,-12,DATEADD(DAY,-2,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --saturday snapshots
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = mov.DEMAND_CLASS
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.[Week Sort] = cf1.[Week Sort] 
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = CAST(DATEADD(WEEK,-12,DATEADD(DAY,-2,DATEADD(HOUR,10,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)))) AS DATE)
	LEFT JOIN dbo.FactStandard fs111 ON fs111.ProductID = pm.ProductID AND fs111.LocationID = 3 AND mov.StartDate BETWEEN fs111.StartDate AND fs111.EndDate
	LEFT JOIN dbo.FactStandard fs122 ON fs122.ProductID = pm.ProductID AND fs122.LocationID = 2 AND mov.StartDate BETWEEN fs122.StartDate AND fs122.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
	AND (ORGANIZATION_CODE LIKE '%122%') --data was purged for non saturday dates
	AND cf1.DateKey >= DATEADD(WEEK,-12,DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1)) AND cf1.DateKey <= DATEADD(WEEK,DATEDIFF(WEEK,-1,GETDATE()),-1) 
GROUP BY l.LocationID
		,l.LocationKey
		,pm.ProductID
		,pm.ProductKey
		,dc.DemandClassID
		,dc.DemandClassKey
		--,d.DateID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,ISNULL(fs111.ItemCost,fs122.ItemCost)
		,ISNULL(fs111.Machine,fs122.Machine)
--ORDER BY ForecastID, ProductionDateID, ProductID


GO
