USE [Operations]
GO
/****** Object:  View [OUTPUT].[VenaTBwDecPeriod]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [OUTPUT].[VenaTBwDecPeriod] AS 

WITH Data AS (
	SELECT 
		   SUBSTRING([CODE_COMBINATION],11,4) AS _Account
		  ,SUBSTRING([CODE_COMBINATION],1,2) AS _Entity
		  ,SUBSTRING([CODE_COMBINATION],7,3) AS _Department
		  ,SUBSTRING([CODE_COMBINATION],4,2) AS _Location
		  ,LEFT(c.[Month Sort],4) AS _Year
		  ,RIGHT(c.[Month Sort],2) AS _Period
		  ,'No Placeholder 2' AS [_Placeholder 2]
		  ,'No Placeholder 3' AS [_Placeholder 3]
		  ,'No Placeholder 4' AS [_Placeholder 4]
		  ,'Actual' AS _Scenario	
		  ,'Local' AS _Currency	
		  ,'Value' AS _Measure
		  ,SUM((ISNULL(ACCT_DEBIT,0) - ISNULL(ACCT_CREDIT,0)) * CASE WHEN SUBSTRING([CODE_COMBINATION],11,1) = 3 THEN -1 ELSE 1 END) AS _Value
		  ,SUM((ISNULL(ACCT_DEBIT,0) - ISNULL(ACCT_CREDIT,0))) AS _Activity
	  FROM [Oracle].[TrialBalance] tb
		INNER JOIN (SELECT DISTINCT [Month Seasonality]+'-'+RIGHT(Year,2) AS [Period], [Month Sort] FROM dbo.DimCalendarFiscal WHERE Year >= 2019) c ON tb.Period  = c.[Period]
	  WHERE CurrentRecord = 1 
		AND ([Month Sort] >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-30,GETDATE()) AS DATE)) OR [Month Sort] = '202412')
		AND Account >= 3000
	  GROUP BY  SUBSTRING([CODE_COMBINATION],11,4)
		  ,SUBSTRING([CODE_COMBINATION],1,2)
		  ,SUBSTRING([CODE_COMBINATION],7,3)
		  ,SUBSTRING([CODE_COMBINATION],4,2)
		  ,LEFT(c.[Month Sort],4)
		  ,RIGHT(c.[Month Sort],2)
	  UNION
	  SELECT 
		   SUBSTRING([CODE_COMBINATION],11,4) AS _Account
		  ,SUBSTRING([CODE_COMBINATION],1,2) AS _Entity
		  ,SUBSTRING([CODE_COMBINATION],7,3) AS _Department
		  ,SUBSTRING([CODE_COMBINATION],4,2) AS _Location
		  ,LEFT(c.[Month Sort],4) AS _Year
		  ,RIGHT(c.[Month Sort],2) AS _Period
		  ,'No Placeholder 2' AS [_Placeholder 2]
		  ,'No Placeholder 3' AS [_Placeholder 3]
		  ,'No Placeholder 4' AS [_Placeholder 4]
		  ,'Actual' AS _Scenario	
		  ,'Local' AS _Currency	
		  ,'Value' AS _Measure
		  ,0 AS _Value
		  ,SUM((ISNULL(ACCT_DEBIT,0) - ISNULL(ACCT_CREDIT,0))) AS _Activity
	  FROM [Oracle].[TrialBalance] tb
		INNER JOIN (SELECT DISTINCT [Month Seasonality]+'-'+RIGHT(Year,2) AS [Period], [Month Sort] FROM dbo.DimCalendarFiscal WHERE Year >= 2019) c ON tb.Period  = c.[Period]
	  WHERE CurrentRecord = 1 
		AND ([Month Sort] >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-30,GETDATE()) AS DATE)) OR [Month Sort] = '202412')
		AND Account < 3000
	  GROUP BY SUBSTRING([CODE_COMBINATION],11,4)
		  ,SUBSTRING([CODE_COMBINATION],1,2)
		  ,SUBSTRING([CODE_COMBINATION],7,3)
		  ,SUBSTRING([CODE_COMBINATION],4,2)
		  ,LEFT(c.[Month Sort],4)
		  ,RIGHT(c.[Month Sort],2)
	  UNION
		SELECT
  			  SEGMENT4 AS _Account
			, SEGMENT1 AS _Entity
			, SEGMENT3 AS _Department
			, SEGMENT2 AS _Location
			, PERIOD_YEAR AS _Year
			, PERIOD_NUM AS _Period
			,'No Placeholder 2' AS [_Placeholder 2]
			,'No Placeholder 3' AS [_Placeholder 3]
			,'No Placeholder 4' AS [_Placeholder 4]
			,'Actual' AS _Scenario	
			,'Local' AS _Currency	
			,'Value' AS _Measure
			,SUM(Ending_Balance * CASE WHEN LEFT(SEGMENT4,1) = 2 THEN -1 ELSE 1 END) AS _Value
			, 0 AS _Activity
		FROM Oracle.TrialBalanceEndingBalance eb
		WHERE CurrentRecord = 1
			AND (eb.[PERIOD_YEAR]*100+PERIOD_NUM  >= (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-30,GETDATE()) AS DATE) AND Year >= 2019)  ---60
				OR  eb.[PERIOD_YEAR]*100+PERIOD_NUM = '202412')
			AND PERIOD_NUM <> 13
		GROUP BY SEGMENT4
			, SEGMENT1
			, SEGMENT3
			, SEGMENT2
			, PERIOD_YEAR
			, PERIOD_NUM


	----uncomment remainder of CTE to send adjustment periods
	--UNION
	--SELECT 
	--	   SUBSTRING([CODE_COMBINATION],11,4) AS _Account
	--	  ,SUBSTRING([CODE_COMBINATION],1,2) AS _Entity
	--	  ,SUBSTRING([CODE_COMBINATION],7,3) AS _Department
	--	  ,SUBSTRING([CODE_COMBINATION],4,2) AS _Location
	--	  ,LEFT(c.[Month Sort],4) AS _Year
	--	  ,RIGHT(c.[Month Sort],2) AS _Period
	--	  ,'No Placeholder 2' AS [_Placeholder 2]
	--	  ,'No Placeholder 3' AS [_Placeholder 3]
	--	  ,'No Placeholder 4' AS [_Placeholder 4]
	--	  ,'Actual' AS _Scenario	
	--	  ,'Local' AS _Currency	
	--	  ,'Value' AS _Measure
	--	  ,SUM((ISNULL(ACCT_DEBIT,0) - ISNULL(ACCT_CREDIT,0)) * CASE WHEN SUBSTRING([CODE_COMBINATION],11,1) = 3 THEN -1 ELSE 1 END) AS _Value
	--	  ,SUM((ISNULL(ACCT_DEBIT,0) - ISNULL(ACCT_CREDIT,0))) AS _Activity
	--  FROM [Output].[VenaTBAdj] tb
	--	INNER JOIN (SELECT DISTINCT [Month Seasonality]+'-'+RIGHT(Year,2) AS [Period], [Month Sort] FROM dbo.DimCalendarFiscal WHERE Year >= 2019) c ON CASE WHEN LEFT(tb.Period,3) = 'Adj' THEN 'Dec' + RIGHT(tb.Period,3) ELSE tb.Period END  = c.[Period]
	--  WHERE Account >= 3000
	--  GROUP BY SUBSTRING([CODE_COMBINATION],11,4)
	--	  ,SUBSTRING([CODE_COMBINATION],1,2)
	--	  ,SUBSTRING([CODE_COMBINATION],7,3)
	--	  ,SUBSTRING([CODE_COMBINATION],4,2)
	--	  ,LEFT(c.[Month Sort],4)
	--	  ,RIGHT(c.[Month Sort],2)
	--  UNION
	--  SELECT 
	--	   SUBSTRING([CODE_COMBINATION],11,4) AS _Account
	--	  ,SUBSTRING([CODE_COMBINATION],1,2) AS _Entity
	--	  ,SUBSTRING([CODE_COMBINATION],7,3) AS _Department
	--	  ,SUBSTRING([CODE_COMBINATION],4,2) AS _Location
	--	  ,LEFT(c.[Month Sort],4) AS _Year
	--	  ,RIGHT(c.[Month Sort],2) AS _Period
	--	  ,'No Placeholder 2' AS [_Placeholder 2]
	--	  ,'No Placeholder 3' AS [_Placeholder 3]
	--	  ,'No Placeholder 4' AS [_Placeholder 4]
	--	  ,'Actual' AS _Scenario	
	--	  ,'Local' AS _Currency	
	--	  ,'Value' AS _Measure
	--	  ,0 AS _Value
	--	  ,SUM(ISNULL(ACCT_DEBIT,0) - ISNULL(ACCT_CREDIT,0)) AS _Activity
	--  FROM [Output].[VenaTBAdj] tb
	--	INNER JOIN (SELECT DISTINCT [Month Seasonality]+'-'+RIGHT(Year,2) AS [Period], [Month Sort] FROM dbo.DimCalendarFiscal WHERE Year >= 2019) c ON CASE WHEN LEFT(tb.Period,3) = 'Adj' THEN 'Dec' + RIGHT(tb.Period,3) ELSE tb.Period END  = c.[Period]
	--  WHERE Account < 3000
	--  GROUP BY SUBSTRING([CODE_COMBINATION],11,4)
	--	  ,SUBSTRING([CODE_COMBINATION],1,2)
	--	  ,SUBSTRING([CODE_COMBINATION],7,3)
	--	  ,SUBSTRING([CODE_COMBINATION],4,2)
	--	  ,LEFT(c.[Month Sort],4)
	--	  ,RIGHT(c.[Month Sort],2)
	--  UNION
	--	SELECT
 -- 			  SEGMENT4 AS _Account
	--		, SEGMENT1 AS _Entity
	--		, SEGMENT3 AS _Department
	--		, SEGMENT2 AS _Location
	--		, PERIOD_YEAR AS _Year
	--		, PERIOD_NUM AS _Period
	--		,'No Placeholder 2' AS [_Placeholder 2]
	--		,'No Placeholder 3' AS [_Placeholder 3]
	--		,'No Placeholder 4' AS [_Placeholder 4]
	--		,'Actual' AS _Scenario	
	--		,'Local' AS _Currency	
	--		,'Value' AS _Measure
	--		, SUM(Ending_Balance * CASE WHEN LEFT(SEGMENT4,1) = 2 THEN -1 ELSE 1 END) AS _Value
	--		, 0 AS _Activity
	--	FROM  [Output].[VenaTBEndingBalanceAdj] eb
	--	GROUP BY SEGMENT4
	--		, SEGMENT1
	--		, SEGMENT3
	--		, SEGMENT2
	--		, PERIOD_YEAR
	--		, PERIOD_NUM

)
SELECT _Account
	,_Entity
	,_Department
	,_Location
	,_Year
	,_Period
	,[_Placeholder 2]
	,[_Placeholder 3]
	,[_Placeholder 4]
	,_Scenario
	,_Currency
	,_Measure
	,SUM(CAST(_Value AS MONEY)) AS _Value
	,SUM(CAST(_Activity AS MONEY)) AS _Activity
FROM Data
WHERE _Entity = '10'
GROUP BY 
	_Account
	,_Entity
	,_Department
	,_Location
	,_Year
	,_Period
	,[_Placeholder 2]
	,[_Placeholder 3]
	,[_Placeholder 4]
	,_Scenario
	,_Currency
	,_Measure
--HAVING SUM([_Value]) <> 0 OR SUM([_Activity]) <> 0
GO
