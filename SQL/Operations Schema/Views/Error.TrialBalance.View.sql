USE [Operations]
GO
/****** Object:  View [Error].[TrialBalance]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[TrialBalance] AS
SELECT [PERIOD], SUM(ISNULL([ACCT_DEBIT],0)-ISNULL([ACCT_DEBIT],0)) AS Net FROM Oracle.TrialBalance WHERE CurrentRecord = 1 GROUP BY [Period] HAVING SUM(ISNULL([ACCT_DEBIT],0)-ISNULL([ACCT_DEBIT],0)) <> 0
GO
