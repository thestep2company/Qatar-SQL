USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Upsert_FinanceAdjustment]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [xref].[Upsert_FinanceAdjustment] AS BEGIN

	INSERT INTO [dbo].[FinanceAdjustment] (
		   [ForecastVersion]
		  ,[Year]
		  ,[Month]
		  ,[Gross Sales Manufactured]
		  ,[Add: Invoiced Freight]
		  ,[Less: Deductions]
		  ,[Standard COGS - Manuf FG]
		  ,[Standard COGS - Labor]
	)
	SELECT 
		   s.[ForecastVersion]
		  ,s.[Year]
		  ,s.[Month]
		  ,s.[Gross Sales Manufactured]
		  ,s.[Add: Invoiced Freight]
		  ,s.[Less: Deductions]
		  ,s.[Standard COGS - Manuf FG]
		  ,s.[Standard COGS - Labor]
	FROM [XREF].[dbo].[FinanceAdjustment] s
		LEFT JOIN [dbo].[FinanceAdjustment] t
	ON s.[ForecastVersion] = t.[ForecastVersion] AND s.Year = t.Year AND s.Month = t.Month
	WHERE t.ForecastVersion IS NULL

	UPDATE t
	SET
		   t.[Gross Sales Manufactured] = s.[Gross Sales Manufactured]
		  ,t.[Add: Invoiced Freight] = s.[Add: Invoiced Freight]
		  ,t.[Less: Deductions] = s.[Less: Deductions]
		  ,t.[Standard COGS - Manuf FG] = s.[Standard COGS - Manuf FG]
		  ,t.[Standard COGS - Labor] = s.[Standard COGS - Labor]
	FROM [dbo].[FinanceAdjustment] t
		LEFT JOIN [XREF].[dbo].[FinanceAdjustment] s
	ON s.[ForecastVersion] = t.[ForecastVersion] AND s.Year = t.Year AND s.Month = t.Month
	WHERE s.[Gross Sales Manufactured] <> t.[Gross Sales Manufactured]
		  OR s.[Add: Invoiced Freight] <> t.[Add: Invoiced Freight]
		  OR s.[Less: Deductions] <> t.[Less: Deductions]
		  OR s.[Standard COGS - Manuf FG] <> t.[Standard COGS - Manuf FG]
		  OR s.[Standard COGS - Labor] <> t.[Standard COGS - Labor]
END
GO
