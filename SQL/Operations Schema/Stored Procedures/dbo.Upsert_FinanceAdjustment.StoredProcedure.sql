USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FinanceAdjustment]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_FinanceAdjustment] AS BEGIN

  INSERT INTO [dbo].[FinanceAdjustment]
  SELECT s.* FROM [Xref].[dbo].[FinanceAdjustment] s 
	LEFT JOIN [dbo].[FinanceAdjustment] t ON s.[Year] = t.[Year] AND s.[Month] = t.[Month] AND s.[ForecastVersion] = t.[ForecastVersion]
  WHERE S.[ForecastVersion] IS NULL
 
  UPDATE t
  SET t.[Gross Sales Manufactured] = ISNULL(s.[Gross Sales Manufactured],0)
	, t.[Add: Invoiced Freight] = ISNULL(s.[Add: Invoiced Freight],0)
	, t.[Less: Deductions] = ISNULL(s.[Less: Deductions],0)
	, t.[Standard COGS - Manuf FG] = ISNULL(s.[Standard COGS - Manuf FG],0)
	, t.[Standard COGS - Labor] = ISNULL(s.[Standard COGS - Labor],0)
  FROM [Xref].[dbo].[FinanceAdjustment] s 
	LEFT JOIN [dbo].[FinanceAdjustment] t ON s.[Year] = t.[Year] AND s.[Month] = t.[Month] AND s.[ForecastVersion] = t.[ForecastVersion] 
  WHERE ISNULL(s.[Gross Sales Manufactured],0) <> ISNULL(t.[Gross Sales Manufactured],0)
		OR ISNULL(s.[Add: Invoiced Freight],0) <> ISNULL(t.[Add: Invoiced Freight],0)
		OR ISNULL(s.[Less: Deductions],0) <> ISNULL(t.[Less: Deductions],0)
		OR ISNULL(s.[Standard COGS - Manuf FG],0) <> ISNULL(t.[Standard COGS - Manuf FG],0)
		OR ISNULL(s.[Standard COGS - Labor],0) <> ISNULL(t.[Standard COGS - Labor],0)

END 

GO
