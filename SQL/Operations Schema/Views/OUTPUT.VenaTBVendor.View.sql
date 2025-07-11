USE [Operations]
GO
/****** Object:  View [OUTPUT].[VenaTBVendor]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[VenaTBVendor] AS

WITH JECB AS (
	SELECT DISTINCT JE_HDR_ID, JE_HDR_CREATED_BY FROM Oracle.TrialBalance WHERE CurrentRecord = 1
)
, SubledgerDetail AS (
	SELECT DISTINCT JE_BATCH_ID, JE_HEADER_ID, JE_LINE_NUM, SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4 
	FROM Oracle.XLA_AP_DIST ap 
		LEFT JOIN dbo.DimCalendarFiscal cf ON ap.ACCOUNTING_DATE = cf.DateKey
	WHERE [Month Sort] >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-63,GETDATE()) AS DATE))
	UNION
	SELECT DISTINCT JE_BATCH_ID, JE_HEADER_ID, JE_LINE_NUM, SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4 
	FROM Oracle.XLA_RCV rcv
		LEFT JOIN dbo.DimCalendarFiscal cf ON rcv.ACCOUNTING_DATE = cf.DateKey
	WHERE [Month Sort] >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-63,GETDATE()) AS DATE))
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
		  ,'Actual' AS _Scenario	
		  ,'Local' AS _Currency	
		  ,'Value' AS _Measure
		  ,CASE WHEN ap.[SEGMENT4] >= 3000
			THEN SUM((ISNULL([DEBIT],0) - ISNULL([CREDIT],0)) * CASE WHEN SUBSTRING(ap.[SEGMENT4],1,1) = 3 THEN -1 ELSE 1 END) 
			ELSE 0 
		  END AS _Value
		  ,SUM((ISNULL([DEBIT],0) - ISNULL([CREDIT],0))) AS _Activity
	FROM Oracle.XLA_AP_Dist ap
		LEFT JOIN JECB ON ap.JE_HEADER_ID = JECB.JE_HDR_ID
		LEFT JOIN dbo.DimCalendarFiscal cf ON ap.ACCOUNTING_DATE = cf.DateKey
		LEFT JOIN Oracle.PurchaseOrder po ON ap.PO_HEADER_ID = po.PO_HEADER_ID AND ap.PO_LINE_ID = po.PO_LINE_ID AND ap.LINE_LOCATION_ID = po.LINE_LOCATION_ID
		LEFT JOIN Oracle.PO_VENDORS pov ON ap.[VENDOR_ID] = pov.VENDOR_ID AND pov.CurrentRecord = 1
	WHERE [Month Sort] >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-63,GETDATE()) AS DATE)) --AND JE_HDR_ID = '9021194'
	GROUP BY 
		   ap.[SEGMENT1]
		  ,ap.[SEGMENT2]
		  ,ap.[SEGMENT3]
		  ,ap.[SEGMENT4]
		  ,pov.SEGMENT1
		  ,LEFT(cf.[Month Sort],4) 
		  ,RIGHT(cf.[Month Sort],2)
	UNION ALL
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
		  ,CASE WHEN rcv.[SEGMENT4] >= 3000
			THEN SUM((ISNULL([DEBIT],0) - ISNULL([CREDIT],0)) * CASE WHEN SUBSTRING(rcv.[SEGMENT4],1,1) = 3 THEN -1 ELSE 1 END) 
			ELSE 0 
		  END AS _Value
		  ,SUM((ISNULL([DEBIT],0) - ISNULL([CREDIT],0))) AS _Activity
	FROM Oracle.XLA_RCV rcv
		LEFT JOIN JECB ON rcv.JE_HEADER_ID = JECB.JE_HDR_ID
		LEFT JOIN dbo.DimCalendarFiscal cf ON rcv.ACCOUNTING_DATE = cf.DateKey
		LEFT JOIN Oracle.PO_VENDORS pov ON rcv.[VENDOR_NUM] = pov.SEGMENT1 AND pov.CurrentRecord = 1
	WHERE [Month Sort] >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-63,GETDATE()) AS DATE)) --AND JE_HDR_ID = '9021194'
	GROUP BY 
		   rcv.[SEGMENT1]
		  ,rcv.[SEGMENT2]
		  ,rcv.[SEGMENT3]
		  ,rcv.[SEGMENT4]
		  ,pov.SEGMENT1
		  ,LEFT(cf.[Month Sort],4) 
		  ,RIGHT(cf.[Month Sort],2)
	UNION ALL
	SELECT
		SUBSTRING(tb.CODE_COMBINATION,1,2) AS [SEGMENT1]
	   ,SUBSTRING(tb.CODE_COMBINATION,4,2) AS [SEGMENT2]
	   ,SUBSTRING(tb.CODE_COMBINATION,7,3) AS [SEGMENT3]
	   ,SUBSTRING(tb.CODE_COMBINATION,11,4) AS [SEGMENT4]
	   ,ISNULL(tb.VENDOR_NUM,'UNDEFINED') AS [VENDOR]
	   ,'No Placeholder 3' AS [_PLACEHOLDER 3]
	   ,'No Placeholder 4' AS [_PLACEHOLDER 4]
	   ,LEFT(cf.[Month Sort],4) AS _YEAR
	   ,RIGHT(cf.[Month Sort],2) AS _PERIOD
	   ,'Actual' AS _SCENARIO
	   ,'Local' AS _CURRENCY
	   ,'Value' AS _MEASURE
	   ,CASE WHEN SUBSTRING(tb.CODE_COMBINATION,11,4) >= 3000
		 THEN SUM((ISNULL(ACCT_DEBIT,0) - ISNULL(ACCT_CREDIT,0)) * CASE WHEN SUBSTRING([CODE_COMBINATION],11,1) = 3 THEN -1 ELSE 1 END) 
		 ELSE 0 
	   END AS _Value
	   ,SUM((ISNULL(ACCT_DEBIT,0) - ISNULL(ACCT_CREDIT,0))) AS _Activity
	FROM Oracle.TrialBalance tb
		LEFT JOIN SubledgerDetail sl 
	ON tb.JE_BATCH_ID = sl.JE_BATCH_ID
		AND tb.JE_HDR_ID = sl.JE_HEADER_ID
		AND tb.LINE_NUMBER = sl.JE_LINE_NUM
		AND LEFT(tb.CODE_COMBINATION,14) = sl.SEGMENT1 + '.' + sl.SEGMENT2 + '.' + sl.SEGMENT3 + '.' + sl.SEGMENT4 --+ '.00.000.000.'
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(CASE WHEN JE_HDR_POSTED_DATE < JE_HDR_EFF_DATE THEN JE_HDR_POSTED_DATE ELSE JE_HDR_EFF_DATE END AS DATE) = cf.DateKey
	WHERE tb.CurrentRecord = 1 AND sl.JE_HEADER_ID IS NULL 
		--AND SUBSTRING(tb.CODE_COMBINATION,1,2) = '10'
		AND [Month Sort] >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-63,GETDATE()) AS DATE))
	GROUP BY SUBSTRING(tb.CODE_COMBINATION,1,2)
	   ,SUBSTRING(tb.CODE_COMBINATION,4,2)
	   ,SUBSTRING(tb.CODE_COMBINATION,7,3)
	   ,SUBSTRING(tb.CODE_COMBINATION,11,4)
	   ,tb.VENDOR_NUM
	   ,LEFT(cf.[Month Sort],4)
	   ,RIGHT(cf.[Month Sort],2)
	UNION
	SELECT

			  SEGMENT1 AS _Entity
			, SEGMENT2 AS _Location
			, SEGMENT3 AS _Department
			, SEGMENT4 AS _Account
			,'UNDEFINED' AS [_Vendor]
			,'No Placeholder 3' AS [_Placeholder 3]
			,'No Placeholder 4' AS [_Placeholder 4]
			, PERIOD_YEAR AS _Year
			, PERIOD_NUM AS _Period
			

			,'Actual' AS _Scenario	
			,'Local' AS _Currency	
			,'Value' AS _Measure
			,SUM(Ending_Balance * CASE WHEN LEFT(SEGMENT4,1) = 2 THEN -1 ELSE 1 END) AS _Value
			, 0 AS _Activity
	FROM Oracle.TrialBalanceEndingBalance eb
	WHERE CurrentRecord = 1
		--AND SEGMENT1 = '10'
		AND eb.[PERIOD_YEAR]*100+PERIOD_NUM  >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-63,GETDATE()) AS DATE) AND Year >= 2019)  ---60
		AND PERIOD_NUM <> 13
	GROUP BY SEGMENT4
			, SEGMENT1
			, SEGMENT3
			, SEGMENT2
			, PERIOD_YEAR
			, PERIOD_NUM
)
SELECT _ENTITY
	, _LOCATION
	, _DEPARTMENT
	, _ACCOUNT
	, _VENDOR
	, [_PLACEHOLDER 3]
	, [_PLACEHOLDER 4]
	, _YEAR
	, _PERIOD
	, _SCENARIO
	, _CURRENCY
	, _MEASURE
	, SUM(_VALUE) AS _VALUE
	, SUM(_ACTIVITY) AS _ACTIVITY 
FROM Data WHERE _YEAR >= 2019 AND _ENTITY = '10'
GROUP BY _ENTITY
	, _LOCATION
	, _DEPARTMENT
	, _ACCOUNT
	, _VENDOR
	, [_PLACEHOLDER 3]
	, [_PLACEHOLDER 4]
	, _YEAR
	, _PERIOD
	, _SCENARIO
	, _CURRENCY
	, _MEASURE
--ORDER BY _YEAR DESC, _PERIOD DESC, _ACCOUNT ASC
GO
