USE [Operations]
GO
/****** Object:  View [Dim].[Account]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Dim].[Account] AS
SELECT Segment4 AS AccountID
	, Description AS AccountName
	, Segment4 + ': ' + Description AS AccountDescription
	, Segment1 + '.' + Segment2 + '.' + Segment3 + '.' + Segment4 + '.' + Segment5 + '.' + Segment6 + '.' + Segment7 AS AccountCombo
	, Segment1 AS Company
	, Segment2 AS Location
	, Segment3 AS Department
	, Segment4 AS Account
	, Segment5 AS Intercompany
	, Segment6 AS Addbacks
	, CASE WHEN Segment4 < '1980' OR Segment4 > '3500' THEN 1 ELSE -1 END AS ReportSign 
	, CASE WHEN Segment4 < '3000' THEN 1 ELSE -1 END AS Sign 
	, CASE WHEN Segment4 >= '3000' OR Segment4 IS NULL THEN 1 ELSE 0 END AS IncomeStatment
	, CASE WHEN Segment4 < '3000' THEN 1 ELSE 0 END AS BalanceSheet
	, 1 AS TrialBalance
	, CASE WHEN Segment6  = '099' THEN 1 ELSE 0 END AS Addback
FROM Oracle.GL_GL_CODE_COMBINATIONS
WHERE CurrentRecord = 1 
GO
