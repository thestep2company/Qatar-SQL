USE [Operations]
GO
/****** Object:  View [Dim].[AccountOverhead]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[AccountOverhead] AS
SELECT DISTINCT a.AccountID, a.AccountName, a.AccountDescription, a.AccountCombo 
FROM Fact.Overhead b
	LEFT JOIN Dim.Account a ON a.AccountCombo = b.AccountCombo --a.AccountID = b.AccountID AND SUBSTRING(a.AccountCombo,5,1) = b.GLLocationID
GO
