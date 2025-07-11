USE [Operations]
GO
/****** Object:  View [OUTPUT].[VenaTBEndingBalanceAdj]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[VenaTBEndingBalanceAdj] AS
WITH CTE AS (
		SELECT DISTINCT PERIOD_YEAR
		FROM Oracle.TrialBalanceEndingBalance eb
		WHERE CurrentRecord = 1
			AND PERIOD_NUM = 13
			AND PERIOD_YEAR >= 2019
)
SELECT DISTINCT eb.* FROM Oracle.TrialBalanceEndingBalance eb
	INNER JOIN CTE ON eb.PERIOD_YEAR = cte.PERIOD_YEAR AND eb.PERIOD_NUM = 12
WHERE CurrentRecord = 1
UNION ALL
SELECT * 
FROM Oracle.TrialBalanceEndingBalance eb
WHERE CurrentRecord = 1
	AND PERIOD_NUM = 13
	AND PERIOD_YEAR >= 2019
GO
