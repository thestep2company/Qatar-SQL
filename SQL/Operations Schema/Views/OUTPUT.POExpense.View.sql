USE [Operations]
GO
/****** Object:  View [OUTPUT].[POExpense]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [OUTPUT].[POExpense] AS 
SELECT [PO_NUMBER]
	  ,[LINE_NUM]
      ,[CREATION_DATE]
	  ,[PO_TYPE]
      ,[PO_STATUS]
      ,[SUPPLIER_NAME]
      ,[SUPPLIER_SITE]
      ,[ITEM_DESCRIPTION]
      ,[SHIPMENT_QUANTITY]
      ,[DIST_ORDERED_QUANTITY]
      ,[DESTINATION_TYPE_CODE] 
FROM Oracle.POExpense 
WHERE CurrentRecord = 1
GO
