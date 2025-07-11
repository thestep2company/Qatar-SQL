USE [Operations]
GO
/****** Object:  View [Fact].[MRPComponentDemand]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[MRPComponentDemand] AS 
SELECT cd.ITEM_NAME
	, msib.DESCRIPTION
	, cd.DEMAND_CLASS
	, cd.USING_ASSEMBLY_DEMAND_DATE AS NEW_ORDER_DATE 
	, cd.DEMAND_TYPE AS FIRM_PLANNED_TYPE
	, cd.FIRM_DATE
	, cd.USING_REQUIREMENT_QUANTITY AS QUANTITY
	, 'Demand' AS ORDER_TYPE_TEXT
	, 1 AS ORDER_TYPE
	, cd.USING_ASSEMBLY_DEMAND_DATE AS NEW_DUE_DATE
	, msib.PLANNER_CODE
	, cd.ORGANIZATION_ID
	, cd.PLAN_ID
	, cd.START_OF_WEEK
	, cd.SOURCE_ORGANIZATION_ID
	, cd.DEMAND_TYPE
	, cd.ORIGINATION_TYPE
	, cd.DEMAND_PRIORITY
	, cd.PROMISE_DATE
FROM [Oracle].[ComponentDemand] cd 
	LEFT JOIN Oracle.INV_MTL_SYSTEM_ITEMS_B msib ON cd.ITEM_NAME = msib.SEGMENT1 AND cd.ORGANIZATION_ID = msib.ORGANIZATION_ID AND msib.CurrentRecord = 1
WHERE Plan_ID = 4 

GO
