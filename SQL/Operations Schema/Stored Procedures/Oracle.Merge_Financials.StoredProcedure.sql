USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Financials]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_Financials] AS BEGIN
	
	EXEC [Oracle].[Merge_TrialBalance] --:06
	EXEC [Oracle].[Merge_TrialBalanceEndingBalance] --:03
END
GO
