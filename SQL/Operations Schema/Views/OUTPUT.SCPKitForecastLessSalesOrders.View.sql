USE [Operations]
GO
/****** Object:  View [OUTPUT].[SCPKitForecastLessSalesOrders]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [OUTPUT].[SCPKitForecastLessSalesOrders] AS
SELECT [SOURCE_TABLE]
      ,[ITEM_SEGMENTS]
      ,[DESCRIPTION]
      ,[DEMAND_CLASS]
      ,[NEW_ORDER_DATE]
      ,2 AS [FIRM_PLANNED_TYPE]
      ,[FIRM_DATE]
      ,-[QUANTITY] AS QUANTITY
      ,'Forecast' AS [ORDER_TYPE_TEXT]
      ,29 AS [ORDER_TYPE]
      ,[NEW_DUE_DATE]
      ,[PLANNER_CODE]
      ,[ORGANIZATION_CODE]
      ,[PLAN_ID]
      ,[START_OF_WEEK]
      ,[RowID]
      ,[StartDate]
      ,[EndDate]
      ,[CurrentRecord]
      ,[SOURCE_ORGANIZATION_CODE]
  FROM [Operations].[OUTPUT].[SCPKitSalesOrders]
  UNION ALL
  SELECT [SOURCE_TABLE]
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
      ,[ROW_ID]
      ,[StartDate]
      ,[EndDate]
      ,[CurrentRecord]
      ,[SOURCE_ORGANIZATION_CODE]
  FROM [Operations].[OUTPUT].[SCPKitForecast]
  --ORDER BY ITEM_SEGMENTS, DEMAND_CLASS, ORGANIZATION_CODE, START_OF_WEEK
GO
