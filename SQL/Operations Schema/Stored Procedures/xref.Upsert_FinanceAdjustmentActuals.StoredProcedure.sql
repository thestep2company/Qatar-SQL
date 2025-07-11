USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Upsert_FinanceAdjustmentActuals]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [xref].[Upsert_FinanceAdjustmentActuals] AS BEGIN

	INSERT INTO [dbo].[FinanceAdjustmentActuals] (
	   [Year]
      ,[Month]
      ,[Total Gross Sales - Product]
      ,[Invoiced Freight]
      ,[Programs & Allowances]
	)
	SELECT 
	   s.[Year]
      ,s.[Month]
      ,s.[Total Gross Sales - Product]
      ,s.[Invoiced Freight]
      ,s.[Programs & Allowances]
	FROM [XREF].[dbo].[FinanceAdjustmentActuals] s
		LEFT JOIN [dbo].[FinanceAdjustmentActuals] t
	ON s.Year = t.Year AND s.Month = t.Month
	WHERE t.Year IS NULL

	UPDATE t
	SET
       t.[Total Gross Sales - Product] = s.[Total Gross Sales - Product]
      ,t.[Invoiced Freight] = s.[Invoiced Freight]
      ,t.[Programs & Allowances] = s.[Programs & Allowances] 
	FROM [dbo].[FinanceAdjustmentActuals] t
		LEFT JOIN [XREF].[dbo].[FinanceAdjustmentActuals] s
	ON s.Year = t.Year AND s.Month = t.Month
	WHERE t.[Total Gross Sales - Product] <> s.[Total Gross Sales - Product]
      OR t.[Invoiced Freight] <> s.[Invoiced Freight]
      OR t.[Programs & Allowances] <> s.[Programs & Allowances] 
END
GO
