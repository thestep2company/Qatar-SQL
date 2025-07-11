USE [Operations]
GO
/****** Object:  StoredProcedure [FPA].[Merge_SalesGrid]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [FPA].[Merge_SalesGrid] AS BEGIN

	INSERT INTO xref.SalesGridByCustomer
	SELECT sgf.[Account Number], sgf.[Account Name], sgf.COOP, sgf.[DIF Returns], 0 AS [Invoiced Freight], sgf.[Markdown], sgf.[Cash Discounts], sgf.[Other], '' AS Comment, 0 AS COmmission, sgf.Year, sgf.Month, sgf.Total
	FROM XREF.dbo.[Customer Grid by Account] sgf
		LEFT JOIN xref.SalesGridByCustomer sg ON sgf.[ACCOUNT NUMBER] = sg.[ACCOUNT NUMBER] AND sgf.[Year] = sg.[Year] AND ISNULL(sgf.[Month],0) = ISNULL(sg.[Month],0)
	WHERE sg.[ACCOUNT NUMBER] IS NULL

	UPDATE sg
	SET [CoOP] = sgf.[Coop]
		,[DIF Returns] = sgf.[DIF Returns]
		--D&A is now 4 variables
		,[Markdown] = sgf.[Markdown]--Markdown
		,[Freight Allowance] = sgf.[Freight Allowance]
		,[Cash Discounts] = sgf.[Cash Discounts]
		,[Other] = sgf.Other --D&A Misc
		,[Commission] = sgf.[Commission]
		,Total = sgf.Total
	FROM XREF.dbo.[Customer Grid by Account] sgf
		LEFT JOIN xref.SalesGridByCustomer sg ON sgf.[ACCOUNT NUMBER] = sg.[ACCOUNT NUMBER] AND sgf.[Year] = sg.[Year] AND ISNULL(sgf.[Month],0) = ISNULL(sg.[Month],0)
	WHERE (sg.[Markdown] <> sgf.[Markdown]
		OR sg.[Freight Allowance] <> sgf.[Freight Allowance]
		OR sg.[DIF Returns] <> sgf.[DIF Returns]
		OR sg.[Cash Discounts] <> sgf.[Cash Discounts]
		OR sg.[CoOP] <> sgf.[Coop]
		OR sg.[Other] <> sgf.[Other]
		OR sg.Commission <> sgf.[Commission]
		OR sg.Total <> sgf.[Total]
	)

END
GO
