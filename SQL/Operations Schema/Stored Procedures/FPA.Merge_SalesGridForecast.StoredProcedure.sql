USE [Operations]
GO
/****** Object:  StoredProcedure [FPA].[Merge_SalesGridForecast]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [FPA].[Merge_SalesGridForecast] AS BEGIN

	SELECT 'Do not update the original sales grid by demand class.  Last used in 2021.  Use the customer grid going forward.'
	
	/*

	INSERT INTO xref.SalesGrid
	SELECT sgf.[Demand_Class_Code], sgf.[Other], sgf.[Freight_Allowance], sgf.[DIF_Returns], sgf.[Cash_Discounts], sgf.[Markdown], sgf.COOP, 0 AS Total
	FROM XREF.dbo.[Customer Grid - Forecast] sgf
		LEFT JOIN xref.SalesGridByCustomer sg ON sgf.[Demand_Class_Code] = sg.[Demand Class Code]
	WHERE sg.[Demand Class Code] IS NULL
	
	UPDATE sg
	SET [CoOP] = sgf.[Coop]
		,[DIF Returns] = sgf.[DIF_Returns]
		--D&A is now 4 variables
		,[Markdown] = sgf.[Markdown]--Markdown
		,[Freight Allowance] = sgf.[Freight_Allowance]
		,[Cash Discounts] = sgf.[Cash_Discounts]
		,[Other] = sgf.Other --D&A Misc
	FROM XREF.dbo.[Customer Grid - Forecast] sgf
		LEFT JOIN xref.SalesGrid sg ON sgf.[Demand_Class_Code] = sg.[Demand  Class]
	WHERE Year = YEAR(GETDATE())
		AND (sg.[Markdown] <> sgf.[Markdown]
		OR sg.[Freight Allowance] <> sgf.[Freight_Allowance]
		OR sg.[DIF Returns] <> sgf.[DIF_Returns]
		OR sg.[Cash Discounts] <> sgf.[Cash_Discounts]
		OR sg.[CoOP] <> sgf.[Coop]
		OR sg.[Other] <> sgf.[Other])
	*/
END
GO
