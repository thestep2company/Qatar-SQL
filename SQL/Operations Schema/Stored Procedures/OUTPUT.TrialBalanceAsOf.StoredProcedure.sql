USE [Operations]
GO
/****** Object:  StoredProcedure [OUTPUT].[TrialBalanceAsOf]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [OUTPUT].[TrialBalanceAsOf] 
	@effectiveDate DATETIME,
	@period VARCHAR(25)
AS BEGIN

--EXEC Output.TrialBalanceAsOf '2021-07-13', 'Jun-21'  --this works
--{Call Output.TrialBalanceAsOf (?)} --this does not

SELECT [JE_HDR_ID]
      ,[CATEGORY]
      ,[SOURCE]
      ,[PERIOD]
      ,[JE_HDR_NAME]
      ,[JE_HDR_CREATED]
      ,[JE_HDR_CREATED_BY]
      ,[JE_HDR_EFF_DATE]
      ,[JE_HDR_POSTED_DATE]
      ,[JE_BATCH_ID]
      ,[JE_BATCH_NAME]
      ,[JE_BATCH_PERIOD]
      ,[HDR_TOTAL_ACCT_DR]
      ,[HDR_TOTAL_ACCT_CR]
      ,[LINE_NUMBER]
      ,LEFT([CODE_COMBINATION],14) AS CODE_COMBINATION
      ,[ACCOUNT]
      ,[CURRENCY]
      ,[ENTERED_DR]
      ,[ENTERED_CR]
      ,[ACCT_DEBIT]
      ,[ACCT_CREDIT]
      ,[ENDING_BALANCE]
      ,[LINE_DESCRIPTION]
FROM [Oracle].[TrialBalance]
WHERE @effectiveDate BETWEEN StartDate AND ISNULL(EndDate,'9999-12-31')
	AND Period = @period

END
GO
