USE [Operations]
GO
/****** Object:  View [xref].[POMinOrderQuantity]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [xref].[POMinOrderQuantity] AS
SELECT 
       [ITEM]
      ,[ITEM_DESCRIPTION]
      ,[ITEM_TYPE]
      ,MIN([UNIT_PRICE]) AS UNIT_PRICE
	  ,MIN([PO_CREATE_DATE]) AS FirstDate
	  ,MAX([PO_CREATE_DATE]) AS LastDate
      ,MIN([ORDER_QUANTITY]) AS Min_ORDER_QUANTITY
	  ,MAX([ORDER_QUANTITY]) AS Max_ORDER_QUANTITY
FROM  Oracle.PurchaseOrder
WHERE CurrentRecord = 1
GROUP BY 
       [ITEM]
      ,[ITEM_DESCRIPTION]
      ,[ITEM_TYPE]
GO
