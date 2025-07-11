USE [Operations]
GO
/****** Object:  View [Fact].[TrialBalanceEndingBalance]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[TrialBalanceEndingBalance] AS
WITH Data AS (
	SELECT DISTINCT MAX(cf2.DateKey) OVER (PARTITION BY PERIOD_YEAR, PERIOD_NUM, CODE_COMBINATION,PERIOD_NUM)  AS TransDate
		, CODE_COMBINATION
		, SEGMENT1 AS Company
		, SEGMENT2 AS Location
		, SEGMENT3 AS CostCenter
		, SEGMENT4 AS Account
		, Starting_Balance
		, Ending_Balance
	FROM Oracle.TrialBalanceEndingBalance eb
		LEFT JOIN Dim.CalendarFiscal cf1 ON CAST(CAST(PERIOD_YEAR*10000+PERIOD_NUM*100+15 AS VARCHAR(10)) AS DATE) = cf1.DateKey
		LEFT JOIN Dim.CalendarFiscal cf2 ON cf1.Month = cf2.Month
	WHERE CurrentRecord = 1 --DATEADD(MINUTE,-55,DATEADD(HOUR,1,DATEADD(week, DATEDIFF(week, -1, GETDATE()),-1))) BETWEEN StartDate AND ISNULL(EndDate,'9999-12-31')
		AND PERIOD_YEAR >= '2016' AND PERIOD_NUM BETWEEN 1 AND 12 
		AND SEGMENT1 = '10' --Step2
)
SELECT TransDate, CODE_COMBINATION, Company, Location, CostCenter, Account, DateID, ISNULL(LocationID,1) AS LocationID, Starting_Balance, Ending_Balance 
FROM Data d
	LEFT JOIN Dim.CalendarFiscal cf ON d.TransDate = cf.DateKey
	LEFT JOIN dbo.DimLocation l ON d.Location = l.GLLocationID

GO
