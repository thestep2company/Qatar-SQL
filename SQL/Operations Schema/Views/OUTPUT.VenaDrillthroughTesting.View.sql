USE [Operations]
GO
/****** Object:  View [OUTPUT].[VenaDrillthroughTesting]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [OUTPUT].[VenaDrillthroughTesting] AS

WITH JECB AS (
	SELECT DISTINCT JE_HDR_ID, JE_HDR_CREATED_BY FROM Oracle.TrialBalance WHERE CurrentRecord = 1
)
, SubledgerDetail AS (
	SELECT DISTINCT JE_BATCH_ID, JE_HEADER_ID, JE_LINE_NUM, SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4 
	FROM Oracle.XLA_AP_DIST ap 
		LEFT JOIN dbo.DimCalendarFiscal cf ON ap.ACCOUNTING_DATE = cf.DateKey
	WHERE [Month Sort] >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-162,GETDATE()) AS DATE))
	UNION
	SELECT DISTINCT JE_BATCH_ID, JE_HEADER_ID, JE_LINE_NUM, SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4 
	FROM Oracle.XLA_RCV rcv
		LEFT JOIN dbo.DimCalendarFiscal cf ON rcv.ACCOUNTING_DATE = cf.DateKey
	WHERE [Month Sort] >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-162,GETDATE()) AS DATE))
)
, Data AS (
	SELECT 
		   ap.[SEGMENT1] AS _ENTITY
		  ,ap.[SEGMENT2] AS _LOCATION
		  ,ap.[SEGMENT3] AS _DEPARTMENT
		  ,ap.[SEGMENT4] AS _ACCOUNT
		  ,pov.SEGMENT1 AS [_VENDOR]
		  ,'No Placeholder 3' AS [_PLACEHOLDER 3]
		  ,'No Placeholder 4' AS [_PLACEHOLDER 4]
		  ,LEFT(cf.[Month Sort],4) AS _YEAR
		  ,RIGHT(cf.[Month Sort],2) AS _PERIOD
		  ,'Actual' AS _SCENARIO
		  ,'Local' AS _CURRENCY
		  ,'Value' AS _MEASURE
		  ,ISNULL([DEBIT],0) AS _DEBIT
		  ,ISNULL([CREDIT],0) AS _CREDIT
		  ,ISNULL([DEBIT],0) - ISNULL([CREDIT],0) AS _VALUE
		  ,CAST([ACCOUNTING_DATE] AS DATE) AS _ACCOUNTING_DATE
		  ,[JE_BATCH_ID] AS _JE_BATCH_ID
		  ,[JE_HEADER_ID] AS _JE_HEADER_ID
		  ,[JE_LINE_NUM] AS _JE_LINE_NUM
		  ,JE_HDR_CREATED_BY AS _JE_CREATED_BY
		  ,[AE_LINE_DESCRIPTION] AS _AE_LINE_DESCRIPTION
		  ,[ACCOUNTING_CLASS_CODE] AS _ACCOUNTING_CLASS_CODE
		  ,[JE_CATEGORY_NAME] AS _JE_CATEGORY_NAME
		  --,[PRODUCT_RULE_CODE]
		  --,[AE_HEADER_DESCRIPTION]
		  --,[ENTITY_CODE]
		  --,[TRANSACTION_NUMBER]
		  --,[SOURCE_DISTRIBUTION_TYPE]
		  --,[SOURCE_DISTRIBUTION_ID_NUM_1]
		  --,[ACCOUNTING_LINE_CODE]
		  --,[LINE_DEFINITION_CODE]
		  --,[EVENT_TYPE_CODE]
		  --,[APPLIED_TO_ENTITY_CODE]
		  --,[APPLIED_TO_DISTRIBUTION_TYPE]

		  ,[JE_LINE_DESCRIPTION] AS _JE_LINE_DESCRIPTION
		  ,[JE_HEADER_NAME] AS _JE_HEADER_NAME
		  ,[JE_HEADER_DESCRIPTION] AS _JE_HEADER_DESCRIPTION
		  ,[AE_HEADER_ID] AS _AE_HEADER_ID
		  ,[AE_LINE_NUM] AS _AE_LINE_NUM
		  ,PO_NUMBER AS _PO_NUMBER
		  ,ap.PO_HEADER_ID  AS _PO_HEADER_ID
		  ,ap.VENDOR_ID  AS _VENDOR_NUM
		  ,[INVOICE_ID] AS _INVOICE_ID
		  ,[INVOICE_DISTRIBUTION_DESCRIPTION] AS _INVOICE_DISTRIBUION_DESC
		  ,[INVOICE_LINE_DESCRIPTION] AS _INVOICE_LINE_DESCRIPTION
		  ,[INVOICE_NUM] AS _INVOICE_NUM
		  ,[LINE_SOURCE] AS _LINE_SOURCE
		  ,[WFAPPROVAL_STATUS] AS _WFAPPROVAL_STATUS
		  ,ap.[VENDOR_ID] AS _VENDOR_ID
		  ,[INVOICE_AMOUNT] AS _INVOICE_AMOUNT
		  ,[AMOUNT_PAID] AS _AMOUNT_PAID
		  --,[DISCOUNT_AMOUNT_TAKEN]
		  --,[APPROVED_AMOUNT]
		  --,[GL_DATE]
		  --,[PAYMENT_METHOD_CODE]
		  --,[PARTY_ID]
		  --,[PARTY_SITE_ID]
		  --,[CHECK_ID]
		  --,[INVOICE_PAYMENT_ID]
		  --,[POSTED_FLAG]
		  --,[REMIT_TO_SUPPLIER_NAME]
		  --,[REMIT_TO_SUPPLIER_ID]
		  --,[REMIT_TO_SUPPLIER_SITE]
		  --,[PAY_DIST_LOOKUP_CODE]
		  --,[APS_VENDOR_NAME]
		  --,[VENDOR_NAME]
		  --,[VENDOR_NAME_ALT]
		  --,[SUPPLIER_SEGMENT1]
		  --,[VENDOR_TYPE_LOOKUP_CODE]
		  --,[NUM_1099]
		  --,[ORGANIZATION_TYPE_LOOKUP_CODE]
		  --,[APS_ATTRIBUTE1]
		  --,[TAX_REPORTING_NAME]
		  --,[TCA_SYNC_NUM_1099]
		  --,[TCA_SYNC_VENDOR_NAME]
		  --,[INDIVIDUAL_1099] 
	FROM Oracle.XLA_AP_Dist ap
		LEFT JOIN JECB ON ap.JE_HEADER_ID = JECB.JE_HDR_ID
		LEFT JOIN dbo.DimCalendarFiscal cf ON ap.ACCOUNTING_DATE = cf.DateKey
		LEFT JOIN Oracle.PurchaseOrder po ON ap.PO_HEADER_ID = po.PO_HEADER_ID AND ap.PO_LINE_ID = po.PO_LINE_ID AND ap.LINE_LOCATION_ID = po.LINE_LOCATION_ID
		LEFT JOIN Oracle.PO_VENDORS pov ON ap.[VENDOR_ID] = pov.VENDOR_ID AND pov.CurrentRecord = 1
	WHERE [Month Sort] >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-63,GETDATE()) AS DATE)) --AND JE_HDR_ID = '9021194'
	UNION ALL
	--;WITH JECB AS (SELECT DISTINCT JE_HDR_ID, JE_HDR_CREATED_BY FROM Oracle.TrialBalance WHERE CurrentRecord = 1)
	SELECT 
		   rcv.[SEGMENT1]
		  ,rcv.[SEGMENT2]
		  ,rcv.[SEGMENT3]
		  ,rcv.[SEGMENT4]
		  ,pov.SEGMENT1 AS [_VENDOR]
		  ,'No Placeholder 3' AS [_PLACEHOLDER 3]
		  ,'No Placeholder 4' AS [_PLACEHOLDER 4]
		  ,LEFT(cf.[Month Sort],4) AS _YEAR
		  ,RIGHT(cf.[Month Sort],2) AS _PERIOD
		  ,'Actual' AS _SCENARIO
		  ,'Local' AS _CURRENCY
		  ,'Value' AS _MEASURE
		  ,ISNULL([DEBIT],0) AS _DEBIT
		  ,ISNULL([CREDIT],0) AS _CREDIT
		  ,ISNULL([DEBIT],0) - ISNULL([CREDIT],0) AS _VALUE
		  ,CAST([ACCOUNTING_DATE] AS DATE) AS _ACCOUNTING_DATE
		  ,[JE_BATCH_ID]
		  ,[JE_HEADER_ID]
		  ,[JE_LINE_NUM]
		  ,JE_HDR_CREATED_BY AS JE_CREATED_BY
		  ,[AE_LINE_DESCRIPTION]
		  ,[ACCOUNTING_CLASS_CODE]
		  ,[JE_CATEGORY_NAME]
		  --,[PRODUCT_RULE_CODE]
		  --,[AE_HEADER_DESCRIPTION]
		  --,[ENTITY_CODE]
		  --,[TRANSACTION_NUMBER]
		  --,[SOURCE_DISTRIBUTION_TYPE]
		  --,[SOURCE_DISTRIBUTION_ID_NUM_1]
		  --,[ACCOUNTING_LINE_CODE]
		  --,[LINE_DEFINITION_CODE]
		  --,[EVENT_TYPE_CODE]
		  --,[APPLIED_TO_ENTITY_CODE]
		  --,[APPLIED_TO_DISTRIBUTION_TYPE]
		  ,[JE_LINE_DESCRIPTION]
		  ,[JE_HEADER_NAME]
		  ,[JE_HEADER_DESCRIPTION]
		  ,[AE_HEADER_ID]
		  ,[AE_LINE_NUM]
		  ,[PO_NUM]
		  ,[PO_HEADER_ID]
		  ,[VENDOR_NUM]
		  ,NULL AS [INVOICE_ID]
		  ,NULL AS [INVOICE_DISTRIBUTION_DESCRIPTION]
		  ,NULL AS [INVOICE_LINE_DESCRIPTION]
		  ,NULL AS [INVOICE_NUM]
		  ,NULL AS [LINE_SOURCE]
		  ,NULL AS [WFAPPROVAL_STATUS]
		  ,NULL AS [VENDOR_ID]
		  ,NULL AS [INVOICE_AMOUNT]
		  ,NULL AS [AMOUNT_PAID]
		  --,NULL AS [DISCOUNT_AMOUNT_TAKEN]
		  --,NULL AS [APPROVED_AMOUNT]
		  --,NULL AS [GL_DATE]
		  --,NULL AS [PAYMENT_METHOD_CODE]
		  --,NULL AS [PARTY_ID]
		  --,NULL AS [PARTY_SITE_ID]
		  --,NULL AS [CHECK_ID]
		  --,NULL AS [INVOICE_PAYMENT_ID]
		  --,NULL AS [POSTED_FLAG]
		  --,NULL AS [REMIT_TO_SUPPLIER_NAME]
		  --,NULL AS [REMIT_TO_SUPPLIER_ID]
		  --,NULL AS [REMIT_TO_SUPPLIER_SITE]
		  --,NULL AS [PAY_DIST_LOOKUP_CODE]
		  --,NULL AS [APS_VENDOR_NAME]
		  --,[VENDOR_NAME]
		  --,NULL AS [VENDOR_NAME_ALT]
		  --,NULL AS [SUPPLIER_SEGMENT1]
		  --,[VENDOR_TYPE_LOOKUP_CODE]
		  --,NULL AS [NUM_1099]
		  --,NULL AS [ORGANIZATION_TYPE_LOOKUP_CODE]
		  --,NULL AS [APS_ATTRIBUTE1]
		  --,NULL AS [TAX_REPORTING_NAME]
		  --,NULL AS [TCA_SYNC_NUM_1099]
		  --,NULL AS [TCA_SYNC_VENDOR_NAME]
		  --,NULL AS [INDIVIDUAL_1099] 
	FROM Oracle.XLA_RCV rcv
		LEFT JOIN JECB ON rcv.JE_HEADER_ID = JECB.JE_HDR_ID
		LEFT JOIN dbo.DimCalendarFiscal cf ON rcv.ACCOUNTING_DATE = cf.DateKey
		LEFT JOIN Oracle.PO_VENDORS pov ON rcv.[VENDOR_NUM] = pov.SEGMENT1 AND pov.CurrentRecord = 1
	WHERE [Month Sort] >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-63,GETDATE()) AS DATE)) --AND JE_HDR_ID = '9021194'
	UNION ALL
	SELECT
		SUBSTRING(tb.CODE_COMBINATION,1,2) AS [SEGMENT1]
	   ,SUBSTRING(tb.CODE_COMBINATION,4,2) AS [SEGMENT2]
	   ,SUBSTRING(tb.CODE_COMBINATION,7,3) AS [SEGMENT3]
	   ,SUBSTRING(tb.CODE_COMBINATION,11,4) AS [SEGMENT4]
	   ,'No Vendor' AS [VENDOR]
	   ,'No Placeholder 3' AS [_PLACEHOLDER 3]
	   ,'No Placeholder 4' AS [_PLACEHOLDER 4]
	   ,LEFT(cf.[Month Sort],4) AS _YEAR
	   ,RIGHT(cf.[Month Sort],2) AS _PERIOD
	   ,'Actual' AS _SCENARIO
	   ,'Local' AS _CURRENCY
	   ,'Value' AS _MEASURE
	   ,ISNULL([ACCT_DEBIT],0) AS _DEBIT
	   ,ISNULL([ACCT_CREDIT],0) AS _CREDIT
	   ,ISNULL([ACCT_DEBIT],0) - ISNULL([ACCT_CREDIT],0) AS _VALUE
	   ,CAST(CASE WHEN JE_HDR_POSTED_DATE < JE_HDR_EFF_DATE THEN JE_HDR_POSTED_DATE ELSE JE_HDR_EFF_DATE END AS DATE) AS [_ACCOUNTING_DATE]
	   ,tb.[JE_BATCH_ID]
	   ,[JE_HDR_ID] 
	   ,LINE_NUMBER AS [JE_LINE_NUM]
	   ,JE_HDR_CREATED_BY AS JE_CREATED_BY
	   ,NULL AS [AE_LINE_DESCRIPTION]
	   ,NULL AS [ACCOUNTING_CLASS_CODE]
	   ,CATEGORY AS [JE_CATEGORY_NAME]
	   --,NULL AS [PRODUCT_RULE_CODE]
	   --,NULL AS [AE_HEADER_DESCRIPTION]
	   --,NULL AS [ENTITY_CODE]
	   --,NULL AS [TRANSACTION_NUMBER]
	   --,NULL AS [SOURCE_DISTRIBUTION_TYPE]
	   --,NULL AS [SOURCE_DISTRIBUTION_ID_NUM_1]
	   --,NULL AS [ACCOUNTING_LINE_CODE]
	   --,NULL AS [LINE_DEFINITION_CODE]
	   --,NULL AS [EVENT_TYPE_CODE]
	   --,NULL AS [APPLIED_TO_ENTITY_CODE]
	   --,NULL AS [APPLIED_TO_DISTRIBUTION_TYPE]

	   ,LINE_DESCRIPTION AS [JE_LINE_DESCRIPTION]
	   ,JE_HDR_NAME AS [JE_HEADER_NAME]
	   ,JE_BATCH_NAME AS [JE_HEADER_DESCRIPTION]
	   ,NULL AS [AE_HEADER_ID]
	   ,NULL AS [AE_LINE_NUM]
		,NULL AS [PO_NUM]
		,NULL AS [PO_HEADER_ID]
		,NULL AS [VENDOR_NUM] 
		,NULL AS [INVOICE_ID]
		,NULL AS [INVOICE_DISTRIBUTION_DESCRIPTION]
		,NULL AS [INVOICE_LINE_DESCRIPTION]
		,NULL AS [INVOICE_NUM]
		,NULL AS [LINE_SOURCE]
		,NULL AS [WFAPPROVAL_STATUS]
		,NULL AS [VENDOR_ID]
		,NULL AS [INVOICE_AMOUNT]
		,NULL AS [AMOUNT_PAID]
		--,NULL AS [DISCOUNT_AMOUNT_TAKEN]
		--,NULL AS [APPROVED_AMOUNT]
		--,NULL AS [GL_DATE]
		--,NULL AS [PAYMENT_METHOD_CODE]
		--,NULL AS [PARTY_ID]
		--,NULL AS [PARTY_SITE_ID]
		--,NULL AS [CHECK_ID]
		--,NULL AS [INVOICE_PAYMENT_ID]
		--,NULL AS [POSTED_FLAG]
		--,NULL AS [REMIT_TO_SUPPLIER_NAME]
		--,NULL AS [REMIT_TO_SUPPLIER_ID]
		--,NULL AS [REMIT_TO_SUPPLIER_SITE]
		--,NULL AS [PAY_DIST_LOOKUP_CODE]
		--,NULL AS [APS_VENDOR_NAME]
		--,NULL AS [VENDOR_NAME]
		--,NULL AS [VENDOR_NAME_ALT]
		--,NULL AS [SUPPLIER_SEGMENT1]
		--,NULL AS [VENDOR_TYPE_LOOKUP_CODE]
		--,NULL AS [NUM_1099]
		--,NULL AS [ORGANIZATION_TYPE_LOOKUP_CODE]
		--,NULL AS [APS_ATTRIBUTE1]
		--,NULL AS [TAX_REPORTING_NAME]
		--,NULL AS [TCA_SYNC_NUM_1099]
		--,NULL AS [TCA_SYNC_VENDOR_NAME]
		--,NULL AS [INDIVIDUAL_1099] 
	FROM Oracle.TrialBalance tb
		LEFT JOIN SubledgerDetail sl 
	ON tb.JE_BATCH_ID = sl.JE_BATCH_ID
		AND tb.JE_HDR_ID = sl.JE_HEADER_ID
		AND tb.LINE_NUMBER = sl.JE_LINE_NUM
		AND LEFT(tb.CODE_COMBINATION,14) = sl.SEGMENT1 + '.' + sl.SEGMENT2 + '.' + sl.SEGMENT3 + '.' + sl.SEGMENT4 --+ '.00.000.000.'
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(CASE WHEN JE_HDR_POSTED_DATE < JE_HDR_EFF_DATE THEN JE_HDR_POSTED_DATE ELSE JE_HDR_EFF_DATE END AS DATE) = cf.DateKey
	WHERE tb.CurrentRecord = 1 AND sl.JE_HEADER_ID IS NULL 
		AND SUBSTRING(tb.CODE_COMBINATION,1,2) = '10'
		AND [Month Sort] >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-63,GETDATE()) AS DATE))
)
SELECT * FROM Data WHERE _ACCOUNT >= '3000'
GO
