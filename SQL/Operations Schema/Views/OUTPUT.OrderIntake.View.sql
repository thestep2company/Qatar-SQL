USE [Operations]
GO
/****** Object:  View [OUTPUT].[OrderIntake]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[OrderIntake] AS
SELECT TOP (1000) [ID]
      ,[ORD_LINE_ID]
      ,[ORD_HEADER_ID]
      ,[CUSTOMER_NAME]
      ,[CUSTOMER_NUM]
      ,[SALES_CHANNEL_CODE]
      ,[DEMAND_CLASS]
      ,[ORDER_DATE]
      ,[ORDER_NUM]
      ,[PART]
      ,[ORDERED_ITEM]
      ,[PART_DESC]
      ,[FLOW_STATUS_CODE]
      ,[QTY]
      ,[SELL_DOLLARS]
      ,[LIST_DOLLARS]
      ,[DATE_REQUESTED]
      ,[SCH_SHIP_DATE]
      ,[CANCEL_DATE]
      ,[PLANT]
      ,[CREATE_DATE]
      ,[ORD_LINE_CREATE_DATE]
      ,[ORD_LINE_LST_UPDATE_DATE]
      ,[SHIP_TO_ADDRESS1]
      ,[SHIP_TO_ADDRESS2]
      ,[SHIP_TO_ADDRESS3]
      ,[SHIP_TO_ADDRESS4]
      ,[SHIP_TO_CITY]
      ,[SHIP_TO_STATE]
      ,[SHIP_TO_POSTAL_CODE]
      ,[SHIP_TO_COUNTRY]
      ,[SHIP_TO_PROVINCE]
      ,[Fingerprint]
      ,[StartDate]
      ,[EndDate]
      ,[CurrentRecord]
      ,[ACTUAL_SHIPMENT_DATE]
      ,[ORDER_LINE_NUM]
      ,[SHIPPING_METHOD_CODE]
      ,[Currency]
  FROM [Oracle].[Orders]
  WHERE CAST(ORDER_DATE AS DATETIME) >= DATEADD(HOUR, -2, GETDATE())
	AND CurrentRecord = 1 
GO
