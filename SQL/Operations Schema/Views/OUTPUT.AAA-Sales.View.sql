USE [Operations]
GO
/****** Object:  View [OUTPUT].[AAA-Sales]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[AAA-Sales] AS
WITH CurrentPeriod AS (
	SELECT DISTINCT GL_PERIOD FROM Oracle.Invoice i 
	WHERE GL_DATE = (
		SELECT DateKey FROM dbo.DimCalendarFiscal
		WHERE DATEADD(WEEK,-1,CAST(GETDATE() AS DATE)) = DateKey
	)
)
SELECT [REVENUE_TYPE]
      ,[CUSTOMER_TRX_ID]
      ,[CUSTOMER_TRX_LINE_ID]
      ,[SALES_CHANNEL_CODE]
      ,[CUST_GROUP]
      ,[DEM_CLASS]
      ,[BUSINESS_SEGMENT]
      ,[FINANCE_CHANNEL]
      ,[ACCT_NUM]
      ,[ACCT_NAME]
      ,[SHIP_TO_ADDRESS1]
      ,[SHIP_TO_ADDRESS2]
      ,[SHIP_TO_ADDRESS3]
      ,[SHIP_TO_ADDRESS4]
      ,[SHIP_TO_CITY]
      ,[SHIP_TO_STATE]
      ,[SHIP_TO_POSTAL_CODE]
      ,[SHIP_TO_COUNTRY]
      ,[SHIP_TO_PROVINCE]
      ,[CUST_PO_NUM]
      ,[ORDER_NUM]
      ,[SO_LINE_NUM]
      ,[AR_TYPE]
      ,[CONSOL_INV]
      ,[TRX_NUMBER]
      ,[SKU]
      ,[INV_DESCRIPTION]
      ,[ITEM_TYPE]
      ,[SIOP_FAMILY]
      ,[CATEGORY]
      ,[SUBCATEGORY]
      ,[INVENTORY_ITEM_STATUS_CODE]
      ,[WH_CODE]
      ,[ITEM_FROZEN_COST]
      ,[GL_PERIOD]
      ,[PERIOD_NUM]
      ,[PERIOD_YEAR]
      ,[GL_DATE]
      ,[QTY_INVOICED]
      ,[UOM]
      ,[GL_REVENUE_DISTRIBUTION]
      ,[ENTERED_AMOUNT]
      ,[CURRENCY]
      ,[ACCTD_USD]
      ,[GL_COGS_DISTRIBUTION]
      ,[COGS_AMOUNT]
      ,[MARGIN_USD]
      ,[MARGIN_PCT]
      ,[SO_LINE_ID]
      ,[FRZ_COST]
      ,[FRZ_MAT_COST]
      ,[FRZ_MAT_OH]
      ,[FRZ_RESOUCE]
      ,[FRZ_OUT_PROC]
      ,[FRZ_OH]
      ,[REPORTING_REVENUE_TYPE]
      ,[COGS] 
FROM Oracle.Invoice i 
WHERE GL_PERIOD = (SELECT GL_PERIOD FROM CurrentPeriod)
	AND CurrentRecord = 1
GO
