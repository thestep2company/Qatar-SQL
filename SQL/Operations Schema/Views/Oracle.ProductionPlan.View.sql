USE [Operations]
GO
/****** Object:  View [Oracle].[ProductionPlan]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Oracle].[ProductionPlan] AS
SELECT [ID]
	  ,[SOURCE_TABLE]
      ,[ITEM_SEGMENTS]
      ,[DESCRIPTION]
      ,[DEMAND_CLASS]
      ,[NEW_ORDER_DATE]
      ,[FIRM_PLANNED_TYPE]
      ,[FIRM_DATE]
      ,[QUANTITY]
      ,[ORDER_TYPE_TEXT]
      ,[ORDER_TYPE]
      ,[NEW_DUE_DATE]
      ,[PLANNER_CODE]
      ,[ORGANIZATION_CODE]
      ,[PLAN_ID]
      ,[START_OF_WEEK] 
FROM Oracle.MSC_ORDERS_V_STAGING mov
WHERE (mov.plan_id = 4  and mov.order_type = 5)
	AND START_OF_WEEK >= DATEADD(week, DATEDIFF(week, -1, GETDATE()), -1) 
	AND NOT (FIRM_PLANNED_TYPE = 2 AND RIGHT(ORGANIZATION_CODE,3) = '140')
GO
