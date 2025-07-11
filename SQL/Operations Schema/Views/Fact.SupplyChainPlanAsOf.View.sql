USE [Operations]
GO
/****** Object:  View [Fact].[SupplyChainPlanAsOf]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
DROP TABLE IF EXISTS dbo.FactSupplyChainPlanASOf
GO

SELECT * INTO dbo.FactSupplyChainPlanASOf FROM [Fact].[SupplyChainPlanAsOf]
*/


CREATE VIEW [Fact].[SupplyChainPlanAsOf] AS

WITH CTE AS (
	SELECT Row_ID
		, PlanID
		, SOURCE_TABLE
		, PLAN_ID
		, ORDER_TYPE
		, FIRM_PLANNED_TYPE
		, ORDER_TYPE_TEXT
		, RIGHT(ORGANIZATION_CODE,3) AS ORG_CODE
		, RIGHT(Source_ORGANIZATION_CODE,3) AS SOURCE_ORG_CODE
		, ITEM_SEGMENTS
		, START_OF_WEEK
		, DEMAND_CLASS
		, PLANNER_CODE
		, QUANTITY
		,REPLACE(
			CASE WHEN (mov.quantity <> 0 and mov.plan_id = 4  AND mov.order_type in (1,3,24) AND mov.source_table = 'MSC_DEMANDS') THEN ORDER_TYPE_TEXT
				WHEN (mov.quantity <> 0 and mov.plan_id = 4  AND mov.order_type = 30 AND mov.source_table = 'MSC_DEMANDS') THEN ORDER_TYPE_TEXT + ' Demand'
				WHEN (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5) AND FIRM_PLANNED_TYPE = 1 THEN 'Production'
				WHEN (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5) AND FIRM_PLANNED_TYPE = 2 THEN 'Production Non Firm'
				WHEN (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (18, 29, 30))  THEN ORDER_TYPE_TEXT
				WHEN (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 18 and FIRM_PLANNED_TYPE = 2)  THEN 'On Hand'
				WHEN (mov.quantity <> 0 and mov.plan_id = 4 and mov.order_type = 3 and mov.source_table = 'MSC_SUPPLIES') THEN ORDER_TYPE_TEXT --excluding 22 because it is doubled up
				WHEN (mov.quantity <> 0 and mov.plan_id IN (4,22) and mov.order_type = 1 and mov.source_table = 'MSC_SUPPLIES') THEN ORDER_TYPE_TEXT
			END,'On Hand', 'Total On Hand'
		) AS InventoryType
		, StartDate
		, EndDate
	FROM Oracle.MSC_ORDERS_V mov 
		LEFT JOIN dbo.DimLocation  l ON RIGHT(ORGANIZATION_CODE,3) = l.LocationKey
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(mov.START_OF_WEEK AS DATE)  = cf.DateKey
	WHERE '2024-05-17 12:00:00.000' BETWEEN StartDate AND ISNULL(EndDate,'9999-12-31')
		AND NOT (FIRM_PLANNED_TYPE = 2 AND RIGHT(ORGANIZATION_CODE,3) IN ('140') AND mov.plan_id = 4 AND mov.order_Type = 5)
		--AND mov.ITEM_SEGMENTS = '8746VA'
		AND cf.[Month Sort] <> '202405'
		--AND DEMAND_CLASS = 'A04727'
		AND START_OF_WEEK < '2024-12-29'
)
SELECT    
	  o.ID AS PlantID
	, im.ProductID
	, dc.DemandClassID
	, 0 AS InventoryCodeID
	, c.DateID
	, CASE WHEN i.InventoryTypeID = 15 AND SOURCE_ORG_CODE <> ORG_CODE THEN 17 ELSE i.InventoryTypeID END AS InventoryTypeID
	, cte.ORDER_TYPE_TEXT
	, SUM(Quantity) AS Quantity
	, SUM(ISNULL(ItemCost,0)*Quantity) AS Cost
	, SUM(ISNULL(MachineHours,0)*Quantity) AS MachineHours
	, o.ID * 1000 + s.Machine AS MachineID
	, CASE WHEN ISNUMERIC(cte.PLANNER_CODE) = 1 AND O.ID <= 3 THEN o.ID * 1000 + CAST(cte.PLANNER_CODE AS INT) END AS PlanMachineID
FROM CTE 
	LEFT JOIN dbo.DimProductMaster im ON cte.ITEM_SEGMENTS = im.ProductKey
	LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS o ON cte.Org_Code = o.ORGANIZATION_CODE AND o.CurrentRecord = 1
	LEFT JOIN dbo.DimCalendarFiscal c ON CAST(cte.START_OF_WEEK AS DATE) = c.DateKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = cte.Demand_Class
	LEFT JOIN dbo.DimLocation l ON o.ID = l.LocationID
	LEFT JOIN dbo.FactStandard s ON im.ProductID = s.ProductID AND l.COGSLocationID = s.LocationID AND c.DateKey BETWEEN s.StartDate AND s.EndDate
	LEFT JOIN dbo.DimInventoryType i ON cte.InventoryType = i.InventoryTypeName
GROUP BY o.ID
	, im.ProductID
	, dc.DemandClassID
	, c.DateID
	,  CASE WHEN i.InventoryTypeID = 15 AND SOURCE_ORG_CODE <> ORG_CODE THEN 17 ELSE i.InventoryTypeID END 
	, cte.ORDER_TYPE_TEXT
	, cte.PLANNER_CODE
	, s.Machine
GO
