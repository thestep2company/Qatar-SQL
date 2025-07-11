USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[AccountOrphans]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AccountOrphans] AS BEGIN
	;--match on full department code
	WITH CTE AS (
		SELECT ROW_NUMBER() OVER(ORDER BY AccountID) AS RecordID, AccountID, AccountCombo
		FROM Dim.Account WHERE AccountName = 'Orphan'
	)
	INSERT INTO xref.Account
	SELECT DISTINCT a.AccountID, AccountName, cte.AccountCombo, [Level1], Level2, Level3, Level4, Level2Sort, ReportSign, Sign, Level3Sort, Level4Sort
	FROM xref.Account a
		INNER JOIN CTE ON CTE.AccountID = a.AccountID AND SUBSTRING(cte.AccountCombo,7,3) = SUBSTRING(a.AccountCombo,7,3)
	WHERE a.AccountName <> 'Orphan'

	;--match on first digit of department code
	WITH CTE AS (
		SELECT ROW_NUMBER() OVER(ORDER BY AccountID) AS RecordID, AccountID, AccountCombo
		FROM Dim.Account WHERE AccountName = 'Orphan'
	)
	INSERT INTO xref.Account
	SELECT DISTINCT a.AccountID, AccountName, cte.AccountCombo, [Level1], Level2, Level3, Level4, Level2Sort, ReportSign, Sign, Level3Sort, Level4Sort
	FROM xref.Account a
		INNER JOIN CTE ON CTE.AccountID = a.AccountID AND SUBSTRING(cte.AccountCombo,7,1) = SUBSTRING(a.AccountCombo,7,1)
	WHERE a.AccountName <> 'Orphan'

END
GO
