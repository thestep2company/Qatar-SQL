USE [Operations]
GO
/****** Object:  View [Fact].[PlannedProduction]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[PlannedProduction] AS

WITH StartDates AS (
	SELECT DateKey, DateID
	FROM Dim.CalendarFiscal 
	WHERE [Day of Week Sort] = 1
		AND DateKey >= DATEADD(YEAR,-1,GETDATE())
		--AND DateKey = '2023-11-26' -->= DATEADD(YEAR,-1,GETDATE())
)
, SnapshotDates AS (
	SELECT '111' AS ORG_CODE, DateKey FROM dbo.DimCalendarFiscal WHERE SBSnapshot = 1 UNION
	SELECT '122' AS ORG_CODE, DateKey FROM dbo.DimCalendarFiscal WHERE PVSnapshot = 1
)
--next week outlook
SELECT	1 AS ForecastID
		,l.LocationID
		,pm.ProductID
		,cf1.DateID AS ProductionDateID
		,cf2.DateID AS SnapshotDateID
		,cf3.DateID AS PlanDateID
		,d.DateID AS PostDateID
		,SUM([QUANTITY]) AS Quantity 
		,0 AS ProductionQty
		,(d.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM([MachineHours]*QUANTITY) AS MachineHoursPlan
		,0 AS MachineHoursRan
		,fs.Machine AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN StartDates d ON CAST(START_OF_WEEK AS DATE) = DATEADD(WEEK,-1,d.DateKey)
	INNER JOIN SnapshotDates s ON s.ORG_CODE = RIGHT([ORGANIZATION_CODE],3) AND d.DateKey > DATEADD(WEEK,1,s.DateKey) AND d.DateKey < DATEADD(WEEK,2,s.DateKey) AND DATEADD(HOUR,11,CAST(s.DateKey AS DATETIME)) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) 
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.DateKey = s.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = DATEADD(WEEK,-1,d.DateKey)
	LEFT JOIN dbo.FactStandard fs ON fs.ProductID = pm.ProductID AND fs.LocationID = l.LocationID AND cf1.DateKey BETWEEN fs.StartDate AND fs.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
GROUP BY l.LocationID
		,pm.ProductID
		,d.DateID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,fs.Machine
UNION ALL
--4 week outlook
SELECT 4 AS ForecastID
		,l.LocationID
		,pm.ProductID
		,cf1.DateID AS ProductionDateID
		,cf2.DateID AS SnapshotDateID
		,cf3.DateID AS PlanDate
		,d.DateID AS PostDateID
		,SUM([QUANTITY]) AS Quantity 
		,0 AS ProductionQty
		,(d.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM([MachineHours]*QUANTITY) AS MachineHoursPlan
		,0 AS MachineHoursRan
		,fs.Machine AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN StartDates d ON CAST(START_OF_WEEK AS DATE) >= DATEADD(WEEK,-4,d.DateKey) AND CAST(START_OF_WEEK AS DATE) <= DATEADD(WEEK,-1,d.DateKey) --4 weeks of snapshots
	INNER JOIN SnapshotDates s ON s.ORG_CODE = RIGHT([ORGANIZATION_CODE],3) AND d.DateKey >= DATEADD(WEEK,4,s.DateKey) AND d.DateKey < DATEADD(WEEK,5,s.DateKey) AND DATEADD(HOUR,11,CAST(s.DateKey AS DATETIME)) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --4 weeks prior
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.DateKey = s.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = DATEADD(WEEK,-4,d.DateKey)
	LEFT JOIN dbo.FactStandard fs ON fs.ProductID = pm.ProductID AND fs.LocationID = l.LocationID AND cf1.DateKey BETWEEN fs.StartDate AND fs.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
GROUP BY l.LocationID
		,pm.ProductID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,d.DateID
		,fs.Machine
-- 8 week
UNION ALL
SELECT 8 AS ForecastID
		,l.LocationID
		,pm.ProductID
		,cf1.DateID AS ProductionDateID
		,cf2.DateID AS SnapshotDateID
		,cf3.DateID AS PlanDate
		,d.DateID AS PostDateID
		,SUM([QUANTITY]) AS Quantity 
		,0 AS ProductionQty
		,(d.DateID-cf1.DateID)/7 AS PlanOffset
		,SUM([MachineHours]*QUANTITY) AS MachineHoursPlan
		,0 AS MachineHoursRan
		,fs.Machine AS MachineSize
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN StartDates d ON CAST(START_OF_WEEK AS DATE) >= DATEADD(WEEK,-8,d.DateKey) AND CAST(START_OF_WEEK AS DATE) <= DATEADD(WEEK,-1,d.DateKey) --8 weeks of snapshots
	INNER JOIN SnapshotDates s ON s.ORG_CODE = RIGHT([ORGANIZATION_CODE],3) AND d.DateKey >= DATEADD(WEEK,8,s.DateKey) AND d.DateKey < DATEADD(WEEK,9,s.DateKey) AND DATEADD(HOUR,11,CAST(s.DateKey AS DATETIME)) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) --8 weeks prior
	LEFT JOIN dbo.DimProductMaster pm ON ITEM_SEGMENTS = pm.ProductKey 
	LEFT JOIN dbo.DimLocation l ON RIGHT([ORGANIZATION_CODE],3) = l.LocationKey
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.DateKey = s.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON cf3.DateKey = DATEADD(WEEK,-8,d.DateKey)
	LEFT JOIN dbo.FactStandard fs ON fs.ProductID = pm.ProductID AND fs.LocationID = l.LocationID AND cf1.DateKey BETWEEN fs.StartDate AND fs.EndDate
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
GROUP BY l.LocationID
		,pm.ProductID
		,cf1.DateID
		,cf2.DateID
		,cf3.DateID
		,d.DateID
		,fs.Machine
UNION ALL
--production
SELECT 1 AS ForecastID
	, p.PlantID
	, p.ProductID
	, cf1.DateID AS ProductionDateID
	, NULL AS SnapshotDateID
	, cf2.DateID AS PlanDateID
	, d.DateID AS PostDateID
	, 0 AS Quantity
	, SUM(p.[Production Qty]) AS ProductionQty
	, 0 AS PlanOffset
	, 0 AS MachineHours
	, SUM(p.[Total Machine Hours]) AS MachinesHoursRan
	, m.MachineModel
FROM dbo.FactProduction p
	LEFT JOIN dbo.DimCalendarFiscal cf ON p.DateID = cf.DateID 
	INNER JOIN StartDates d ON cf.DateKey >= DATEADD(WEEK,-1,d.DateKey) AND cf.DateKey < d.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = dateadd(week, datediff(week, -1, cf.DateKey), -1)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.DateKey = DATEADD(WEEK,-1,d.DateKey)
	LEFT JOIN dbo.DimMachine m ON p.MachineID = m.MachineID
WHERE ShiftOffsetID = 1
GROUP BY p.PlantID	
	,p.ProductID
	,cf1.DateID
	,cf2.DateID
	,d.DateID
	,m.MachineModel
UNION ALL
--production
SELECT 4 AS ForecastID
	, p.PlantID
	, p.ProductID
	, cf1.DateID AS ProductionDateID
	, NULL AS SnapshotDateID
	, cf2.DateID AS PlanDateID
	, d.DateID AS PostDateID
	, 0 AS Quantity
	, SUM(p.[Production Qty]) AS ProductionQty
	, 0 AS PlanOffset
	, 0 AS MachineHours
	, SUM(p.[Total Machine Hours]) AS MachinesHoursRan
	,m.MachineModel
FROM dbo.FactProduction p
	LEFT JOIN dbo.DimCalendarFiscal cf ON p.DateID = cf.DateID 
	INNER JOIN StartDates d ON cf.DateKey >= DATEADD(WEEK,-4,d.DateKey) AND cf.DateKey < d.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = dateadd(week, datediff(week, -1, cf.DateKey), -1)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.DateKey = DATEADD(WEEK,-4,d.DateKey)
	LEFT JOIN dbo.DimMachine m ON p.MachineID = m.MachineID
WHERE ShiftOffsetID = 1
GROUP BY p.PlantID	
	,p.ProductID
	,cf1.DateID
	,cf2.DateID
	,d.DateID
	,m.MachineModel
UNION ALL
SELECT 8 AS ForecastID
	, p.PlantID
	, p.ProductID
	, cf1.DateID AS ProductionDateID
	, NULL AS SnapshotDateID
	, cf2.DateID AS PlanDateID
	, d.DateID AS PostDateID
	, 0 AS Quantity
	, SUM(p.[Production Qty]) AS ProductionQty
	, 0 AS PlanOffset
	, 0 AS MachineHours
	, SUM(p.[Total Machine Hours]) AS MachinesHoursRan
	, m.MachineModel
FROM dbo.FactProduction p
	LEFT JOIN dbo.DimCalendarFiscal cf ON p.DateID = cf.DateID 
	INNER JOIN StartDates d ON cf.DateKey >= DATEADD(WEEK,-8,d.DateKey) AND cf.DateKey < d.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON cf1.DateKey = dateadd(week, datediff(week, -1, cf.DateKey), -1)
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf2.DateKey = DATEADD(WEEK,-8,d.DateKey)
	LEFT JOIN dbo.DimMachine m ON p.MachineID = m.MachineID
WHERE ShiftOffsetID = 1
GROUP BY p.PlantID	
	,p.ProductID
	,cf1.DateID
	,cf2.DateID
	,d.DateID
	,m.MachineModel
GO
