USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Merge_SalesGridBySKU]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [xref].[Merge_SalesGridBySKU] AS BEGIN

	INSERT INTO xref.SalesGridBySKU
	SELECT sgc.[Account Number]
      ,sgc.[Account Name]
      ,sgc.[SKU]
      ,sgc.[Description]
      ,sgc.[Year]
      ,sgc.[Month]
      ,sgc.[Other]
      ,sgc.[Freight Allowance]
      ,sgc.[DIF Returns]
      ,sgc.[Cash Discounts]
      ,sgc.[Markdown]
      ,sgc.[CoOp]
      ,sgc.[Total Program %]
	FROM XREF.dbo.[CustomerGridBySKU] sgc
	LEFT JOIN xref.SalesGridBySKU sg ON sgc.[Account Number] = sg.[Account Number] AND sgc.[SKU] = sg.[SKU] AND sgc.[Year] = sg.[Year] AND ISNULL(sgc.[Month],0) = ISNULL(sg.[Month],0)
	WHERE sg.[ACCOUNT NUMBER] IS NULL AND sg.SKU IS NULL

	UPDATE sg
	SET
       [Other] = sgc.Other
      ,[Freight Allowance] = sgc.[Freight Allowance]
      ,[DIF Returns] = sgc.[DIF Returns]
      ,[Cash Discounts] = sgc.[Cash Discounts]
      ,[Markdown] = sgc.[Markdown]
      ,[CoOp] = sgc.[CoOp]
      ,[Total Program %] = sgc.[Total Program %]
	FROM XREF.dbo.[CustomerGridBySKU] sgc
		LEFT JOIN xref.SalesGridBySKU sg ON sgc.[Account Number] = sg.[Account Number] AND sgc.[SKU] = sg.[SKU] AND sgc.[Year] = sg.[Year] AND ISNULL(sgc.[Month],0) = ISNULL(sg.[Month],0)
	WHERE (sg.[Other] <> sgc.[Other]
		OR sg.[Freight Allowance] <> sgc.[Freight Allowance]
		OR sg.[DIF Returns] <> sgc.[DIF Returns]
		OR sg.[Cash Discounts] <> sgc.[Cash Discounts]
		OR sg.[Markdown] <> sgc.[Markdown]
		OR sg.[CoOP] <> sgc.[Coop]
		OR sg.[Total Program %] = sgc.[Total Program %]
	)

END
GO
