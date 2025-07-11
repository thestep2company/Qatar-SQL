USE [Operations]
GO
/****** Object:  View [OUTPUT].[D2UAAA-Sales]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[D2UAAA-Sales] AS
--YTD AAA-Sales and Freight for Accounting - JT 7.22.24

--1000375: Step2Direct
--1015792: Direct Replacement Parts
--1014692: Kingsley Park
--1000020: Wayfair
--1020832: Big Daddy Garden Cart Inc
--1016652: Coop
--1004093: Discount School Supply

SELECT 
      i.[REVENUE_TYPE]
      ,i.[CUSTOMER_TRX_ID]
      ,i.[CUSTOMER_TRX_LINE_ID]
      ,i.[SALES_CHANNEL_CODE]
      ,i.[CUST_GROUP]
      ,i.[DEM_CLASS]
      ,i.[BUSINESS_SEGMENT]
      ,i.[FINANCE_CHANNEL]
      ,i.[ACCT_NUM]
      ,i.[ACCT_NAME]
      ,i.[SHIP_TO_ADDRESS1]
      ,i.[SHIP_TO_ADDRESS2]
      ,i.[SHIP_TO_ADDRESS3]
      ,i.[SHIP_TO_ADDRESS4]
      ,i.[SHIP_TO_CITY]
      ,i.[SHIP_TO_STATE]
      ,i.[SHIP_TO_POSTAL_CODE]
      ,i.[SHIP_TO_COUNTRY]
      ,i.[SHIP_TO_PROVINCE]
      ,i.[CUST_PO_NUM]
      ,i.[ORDER_NUM]
      ,i.[SO_LINE_NUM]
      ,i.[AR_TYPE]
      ,i.[CONSOL_INV]
      ,i.[TRX_NUMBER]
      ,i.[SKU]
      ,i.[INV_DESCRIPTION]
      ,i.[ITEM_TYPE]
      ,i.[SIOP_FAMILY]
      ,i.[CATEGORY]
      ,i.[SUBCATEGORY]
      ,i.[INVENTORY_ITEM_STATUS_CODE]
      ,i.[WH_CODE]
      ,i.[ITEM_FROZEN_COST]
      ,i.[GL_PERIOD]
      ,i.[PERIOD_NUM]
      ,i.[PERIOD_YEAR]
      ,i.[GL_DATE]
      ,i.[QTY_INVOICED]
      ,i.[UOM]
      ,i.[GL_REVENUE_DISTRIBUTION]
      ,i.[ENTERED_AMOUNT]
      ,i.[CURRENCY]
      ,i.[ACCTD_USD]
      ,i.[GL_COGS_DISTRIBUTION]
      ,i.[COGS_AMOUNT]
      ,i.[MARGIN_USD]
      ,i.[MARGIN_PCT]
      ,i.[SO_LINE_ID]
      ,i.[FRZ_COST]
      ,i.[FRZ_MAT_COST]
      ,i.[FRZ_MAT_OH]
      ,i.[FRZ_RESOUCE]
      ,i.[FRZ_OUT_PROC]
      ,i.[FRZ_OH]
      ,i.[REPORTING_REVENUE_TYPE]
      ,i.[COGS]
	  ,cf.[Month Sort]
FROM Oracle.Invoice i
	LEFT JOIN dbo.DimCalendarFiscal cf ON i.GL_DATE = cf.DateKey
	LEFT JOIN dbo.DimCustomerMaster cm ON i.ACCT_NUM = cm.CustomerKey
	LEFT JOIN dbo.DimRevenueType r ON i.REVENUE_TYPE = r.RevenueKey
WHERE i.CurrentRecord = 1 
	AND cf.CurrentYear = 'Current Year' 
	AND REPORTING_REVENUE_TYPE <> 'ZTAX'
	AND (i.GL_REVENUE_DISTRIBUTION LIKE '%3000%' OR i.GL_REVENUE_DISTRIBUTION LIKE '%3200%' OR i.GL_REVENUE_DISTRIBUTION LIKE '%3250%') --115122
	AND i.ACCT_NUM IN ('1016652',
'1020832',
'1000375',
'1014692',
'1015792',
'1004093',
'1000020')




GO
