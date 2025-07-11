USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FinanceAdjustment]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Upsert_FinanceAdjustment]
AS BEGIN 

	TRUNCATE TABLE dbo.FinanceAdjustment

	SET IDENTITY_INSERT dbo.FinanceAdjustment ON 

	INSERT INTO dbo.FinanceAdjustment (
	   [ID]
      ,[ForecastVersion]
      ,[Year]
      ,[Month]
      ,[Gross Sales Manufactured]
      ,[Add: Invoiced Freight]
      ,[Less: Deductions]
      ,[Standard COGS - Manuf FG]
      ,[Standard COGS - Labor]
	)
	SELECT [ID]
      ,[ForecastVersion]
      ,[Year]
      ,[Month]
      ,[Gross Sales Manufactured]
      ,[Add: Invoiced Freight]
      ,[Less: Deductions]
      ,[Standard COGS - Manuf FG]
      ,[Standard COGS - Labor] 
	FROM Operations.dbo.FinanceAdjustment

END
GO
