USE [Operations]
GO
/****** Object:  StoredProcedure [OUTPUT].[InvoiceAsOf]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [OUTPUT].[InvoiceAsOf] 
  	@period VARCHAR(25)
AS BEGIN

--EXEC Output.InvoiceAsOf '2022-06-03', 'May-22'  
--{Call Output.InvoiceAsOf (?), (?)} 

SELECT --[ID]
       [REVENUE_TYPE]
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
      --,[Fingerprint]
      --,[StartDate]
      --,[EndDate]
      --,[CurrentRecord]
  FROM [Oracle].[Invoice]
  WHERE CurrentRecord = 1 --@effectiveDate BETWEEN StartDate AND ISNULL(EndDate,'9999-12-31')
	AND GL_Period = @period
END
GO
