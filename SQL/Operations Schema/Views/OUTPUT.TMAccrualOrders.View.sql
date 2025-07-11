USE [Operations]
GO
/****** Object:  View [OUTPUT].[TMAccrualOrders]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [OUTPUT].[TMAccrualOrders] AS 
SELECT t.[PERIOD_YEAR]
      ,t.[PERIOD_NUM]
      ,t.[UTILIZATION_TYPE]
      ,t.[AR_ACCOUNT]
      ,t.[CUSTOMER_NUM]
      ,t.[CUSTOMER_NAME]
      ,t.[ORDER_LINE_ID]
      ,t.[ACCT_AMT]
      ,t.[FUND_NAME]
      ,t.[FUND_DESC]
	  ,o.[ORD_HEADER_ID] 
	  ,o.[SALES_CHANNEL_CODE]
	  ,o.[DEMAND_CLASS]
	  ,o.[ORDER_DATE]
	  ,o.[PART]
	  ,o.[ORDERED_ITEM]
      ,o.[PART_DESC]
      ,o.[FLOW_STATUS_CODE]
      ,o.[QTY]
      ,o.[SELL_DOLLARS]
      ,o.[LIST_DOLLARS]
      ,o.[DATE_REQUESTED]
      ,o.[SCH_SHIP_DATE]
      ,o.[CANCEL_DATE]
      ,o.[PLANT]
      ,o.[CREATE_DATE]
      ,o.[ORD_LINE_CREATE_DATE]
      ,o.[ORD_LINE_LST_UPDATE_DATE]
      ,o.[SHIP_TO_ADDRESS1]
      ,o.[SHIP_TO_ADDRESS2]
      ,o.[SHIP_TO_ADDRESS3]
      ,o.[SHIP_TO_ADDRESS4]
      ,o.[SHIP_TO_CITY]
      ,o.[SHIP_TO_STATE]
      ,o.[SHIP_TO_POSTAL_CODE]
      ,o.[SHIP_TO_COUNTRY]
      ,o.[SHIP_TO_PROVINCE]
FROM Oracle.TMAccrualOrders t
	LEFT JOIN Oracle.Orders o ON t.ORDER_LINE_ID = o.ORD_LINE_ID AND o.CurrentRecord = 1
WHERE PERIOD_YEAR*100+PERIOD_NUM >= '202207'
--= (SELECT DISTINCT [Month Sort] FROM Dim.CalendarFiscal WHERE [MonthID] = (SELECT [MonthID] - 1 FROM Dim.CalendarFiscal WHERE DateKey = CAST(GETDATE() AS DATE)))
GO
