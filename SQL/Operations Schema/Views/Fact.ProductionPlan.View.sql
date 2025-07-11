USE [Operations]
GO
/****** Object:  View [Fact].[ProductionPlan]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--155215
CREATE VIEW [Fact].[ProductionPlan] AS
WITH CTE AS (
	--firm and non firm production
  	SELECT RIGHT([ORGANIZATION_CODE],3) AS ORG_CODE
		  ,[ITEM_SEGMENTS]
		  ,[DEMAND_CLASS]
		  ,CAST(START_OF_WEEK AS DATE) AS START_OF_WEEK
		  ,[FIRM_PLANNED_TYPE]
		  ,[ORDER_TYPE_TEXT]
		  ,[PLANNER_CODE]
		  ,SUM([QUANTITY]) AS Quantity
	FROM Oracle.ProductionPlan
	WHERE START_OF_WEEK <= (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal) 
	GROUP BY RIGHT([ORGANIZATION_CODE],3)
		,[ITEM_SEGMENTS]
		,[DEMAND_CLASS]
		,CAST(START_OF_WEEK AS DATE)
		,[FIRM_PLANNED_TYPE]
		,[ORDER_TYPE_TEXT]
		,[PLANNER_CODE]
	UNION ALL
	--sales and forecast
	SELECT RIGHT([ORGANIZATION_CODE],3)
		  ,[ITEM_SEGMENTS]
		  ,[DEMAND_CLASS]
		  ,CAST(START_OF_WEEK AS DATE) AS START_OF_WEEK
		  ,[FIRM_PLANNED_TYPE]
		  ,[ORDER_TYPE_TEXT]
		  ,[PLANNER_CODE]
		  ,SUM([QUANTITY]) AS Quantity
	FROM Oracle.ForecastOpenOrdersOnHand
	WHERE START_OF_WEEK <= (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal) 
	GROUP BY RIGHT([ORGANIZATION_CODE],3)
		,[ITEM_SEGMENTS]
		,[DEMAND_CLASS]
		,CAST(START_OF_WEEK AS DATE)
		,[FIRM_PLANNED_TYPE]
		,[ORDER_TYPE_TEXT]
		,[PLANNER_CODE]
	--components on hand
	UNION ALL
	SELECT RIGHT([ORGANIZATION_CODE],3)
		  ,[ITEM_SEGMENTS]
		  ,[DEMAND_CLASS]
		  ,CAST(START_OF_WEEK AS DATE) AS START_OF_WEEK
		  ,[FIRM_PLANNED_TYPE]
		  ,[ORDER_TYPE_TEXT]
		  ,[PLANNER_CODE]
		  ,SUM([QUANTITY]) AS Quantity
	FROM Oracle.ComponentsOnHand
	WHERE START_OF_WEEK <= (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal) 
	GROUP BY RIGHT([ORGANIZATION_CODE],3)
		,[ITEM_SEGMENTS]
		,[DEMAND_CLASS]
		,CAST(START_OF_WEEK AS DATE)
		,[FIRM_PLANNED_TYPE]
		,[ORDER_TYPE_TEXT]
		,[PLANNER_CODE]
	UNION ALL
	--purchase/work order
	SELECT RIGHT([ORGANIZATION_CODE],3)
		  ,[ITEM_SEGMENTS]
		  ,[DEMAND_CLASS]
		  ,CAST(START_OF_WEEK AS DATE) AS START_OF_WEEK
		  ,[FIRM_PLANNED_TYPE]
		  ,[ORDER_TYPE_TEXT]
		  ,[PLANNER_CODE]
		  ,SUM([QUANTITY]) AS Quantity
	FROM Oracle.PurchaseOrders
	WHERE START_OF_WEEK <= (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal)
	GROUP BY RIGHT([ORGANIZATION_CODE],3)
		,[ITEM_SEGMENTS]
		,[DEMAND_CLASS]
		,CAST(START_OF_WEEK AS DATE)
		,[FIRM_PLANNED_TYPE]
		,[ORDER_TYPE_TEXT]
		,[PLANNER_CODE]
	UNION ALL
	--component demand
	SELECT 
		o.ORGANIZATION_CODE AS Org_Code
		,cd.item_name AS [ITEM_SEGMENTS]
		,cd.Demand_Class
		,CAST(DATEADD(week, DATEDIFF(week, -1, cd.Using_ASSEMBLY_DEMAND_DATE ), -1) AS DATE) AS START_OF_WEEK
		,demand_type
		,'SKU Demand'
		, NULL AS PLANNER_CODE
		,-cd.Using_Requirement_Quantity AS Quantity
	FROM Oracle.ComponentDemand cd
		LEFT JOIN dbo.DimProductMaster pm ON cd.Item_Name = pm.ProductKey
		LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS o ON cd.organization_ID = o.ORGANIZATION_ID
	WHERE DATEADD(week, DATEDIFF(week, -1, cd.Using_ASSEMBLY_DEMAND_DATE ), -1) --move to start of week
		<= (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal)
)
SELECT    o.ID AS PlantID
		, im.ProductID
		, dc.DemandClassID
		, 0 AS InventoryCodeID
		, c.DateID
		, i.InventoryTypeID
		, SUM(Quantity) AS Quantity
		, SUM(ISNULL(ItemCost,0)*Quantity) AS Cost
		, SUM(ISNULL(MachineHours,0)*Quantity) AS MachineHours
		, o.ID * 1000 + s.Machine AS MachineID
		, CASE WHEN ISNUMERIC(cte.PLANNER_CODE) = 1 AND O.ID <= 3 THEN o.ID * 1000 + CAST(cte.PLANNER_CODE AS INT) END AS PlanMachineID
FROM CTE 
	LEFT JOIN dbo.DimProductMaster im ON cte.ITEM_SEGMENTS = im.ProductKey
	LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS o ON cte.Org_Code = o.ORGANIZATION_CODE AND o.CurrentRecord = 1
	LEFT JOIN dbo.DimCalendarFiscal c ON cte.START_OF_WEEK = c.DateKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = cte.Demand_Class
	LEFT JOIN dbo.DimLocation l ON o.ID = l.LocationID
	LEFT JOIN dbo.FactStandard s ON im.ProductID = s.ProductID AND l.COGSLocationID = s.LocationID AND c.DateKey BETWEEN s.StartDate AND s.EndDate
	LEFT JOIN Dim.InventoryType i ON CASE WHEN ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1 THEN 'Production'
			   WHEN ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE <> 1 THEN 'Production Non Firm'
			   WHEN ORDER_TYPE_TEXT = 'On Hand' THEN 'Total On Hand'
			   ELSE ORDER_TYPE_TEXT
		END = i.InventoryTypeName
GROUP BY o.ID
		, im.ProductID
		, dc.DemandClassID
		, c.DateID
		, i.InventoryTypeID
		, cte.PLANNER_CODE
		, s.Machine
		 
GO
