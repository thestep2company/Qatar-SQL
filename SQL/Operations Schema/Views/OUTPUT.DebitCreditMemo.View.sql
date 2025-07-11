USE [Operations]
GO
/****** Object:  View [OUTPUT].[DebitCreditMemo]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[DebitCreditMemo] AS
SELECT 
	  [ACCOUNT_NUMBER]
      ,[ACCOUNT_NAME]
      ,[INV_TYPE]
      ,[PURCHASE_ORDER]
      ,CAST([GL_POSTED_DATE] AS DATE) AS [GL_POSTED_DATE]
      ,[SPECIAL_INSTR]
      ,[COMMENTS]
      ,[CT_REFERENCE]
      ,[INVOICE_NUMBER]
      ,CAST([INVOICE_DATE] AS DATE) AS [INVOICE_DATE]
      ,[INV_LINE]
      ,[LINE_TYPE]
      ,[DESCRIPTION]
      ,[QUANTITY_CREDITED]
      ,[QUANTITY_INVOICED]
      ,[UNIT_SELLING_PRICE]
      ,[ACCTD_USD]
      ,[GL_ACCOUNT]
      ,[PERCENT]
      ,[CUSTOMER_TRX_LINE_ID]
      ,[USER_NAME]
      ,[FULL_NAME]
FROM Oracle.DebitCreditMemo
WHERE CurrentRecord = 1
	AND YEAR([GL_POSTED_DATE]) >= YEAR(DATEADD(YEAR,-1,GETDATE()))
GO
