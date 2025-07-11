USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FinanceAdjustmentActuals]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_FinanceAdjustmentActuals] AS BEGIN

  INSERT INTO [dbo].[FinanceAdjustmentActuals]
  SELECT s.* 
  FROM [Xref].[dbo].[FinanceAdjustmentActuals] s 
	LEFT JOIN [dbo].[FinanceAdjustmentActuals] t ON s.[Year] = t.[Year] AND s.[Month] = t.[Month] 
  WHERE s.[Month] IS NULL
 
  UPDATE t  
  SET t.[Total Gross Sales - Product] = ISNULL(s.[Total Gross Sales - Product],0)
	, t.[Invoiced Freight] = ISNULL(s.[Invoiced Freight],0)
	, t.[Programs & Allowances] = ISNULL(s.[Programs & Allowances],0)
  FROM [Xref].[dbo].[FinanceAdjustmentActuals] s 
	LEFT JOIN [dbo].[FinanceAdjustmentActuals] t ON s.[Year] = t.[Year] AND s.[Month] = t.[Month] 
  WHERE ISNULL(s.[Total Gross Sales - Product],0) <> ISNULL(t.[Total Gross Sales - Product],0)
		OR ISNULL(s.[Invoiced Freight],0) <> ISNULL(t.[Invoiced Freight],0)
		OR ISNULL(s.[Programs & Allowances],0) <> ISNULL(t.[Programs & Allowances],0)

END 
GO
