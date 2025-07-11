USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[LoadSalesBudget]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[LoadSalesBudget] AS BEGIN

	DROP TABLE IF EXISTS #SalesBudget

	--load into temp table to keep precision during margin corrections
	SELECT identity(int,1,1) as ID, * INTO #SalesBudget FROM Fact.SalesForecastY

	--Using average Standard Margin by category to calculate placeholder COGS
	;WITH StandardMarginFixbyCategory AS (
		SELECT b.ID
			, SUM(Sales) AS Sales
			, SUM(COGS) AS COGS
			, SUM(Sales-COGS)/SUM(Sales) AS Margin
			, SUM(Sales+(ISNULL([Coop],0)+ISNULL([Other],0)+ISNULL([DIF Returns],0)+ISNULL([Markdown],0)+ISNULL([Cash Discounts],0)+ISNULL([Freight Allowance],0))+ISNULL([Invoiced Freight],0)) AS SalesAfterPrograms
			, SUM(COGS)*(1+(1/(1-[Net Standard Margin %]) - 1)) AS NewSales
			, SUM(COGS)*(1+(1/(1-[Net Standard Margin %]) - 1)) / SUM(Sales+(ISNULL([Coop],0)+ISNULL([Other],0)+ISNULL([DIF Returns],0)+ISNULL([Markdown],0)+ISNULL([Cash Discounts],0)+ISNULL([Freight Allowance],0))+ISNULL([Invoiced Freight],0)) AS NewSalesRatio
			,([Net Standard Margin %]) as TargetStandardMargin
		FROM #SalesBudget b 
			LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = b.DateID 
			LEFT JOIN dbo.FactStandard s ON b.ProductID = s.ProductID AND cf.DateKey BETWEEN s.StartDate AND S.EndDate
			LEFT JOIN dbo.DimProductMaster pm ON pm.ProductID = b.ProductID
			INNER JOIN dbo.BudgetCategoryMarginLookup cm ON cm.Category = pm.Category --only adjust records that have a lookup
		WHERE ((cf.[Month Sort] >= (SELECT [BudgetMonth] FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 0)
			OR (cf.[Month Sort] >= (SELECT [ForecastMonth] FROM dbo.ForecastPeriod) AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 13))
		GROUP BY b.ID, cm.[Net Standard Margin %]
		HAVING CASE WHEN SUM(Sales) <> 0 THEN SUM(Sales-COGS)/SUM(Sales)  END BETWEEN 0.9899 AND .9909
	)
	UPDATE sb
	SET sb.Sales = smc.NewSalesRatio*sb.Sales
		,sb.[UnitPriceID] = smc.NewSalesRatio*sb.[UnitPriceID]
		,sb.[Coop] = smc.NewSalesRatio*sb.[Coop]
		,sb.[Other] = smc.NewSalesRatio*sb.[Other]
		,sb.[DIF Returns] = smc.NewSalesRatio*sb.[DIF Returns]
		,sb.[Markdown] = smc.NewSalesRatio*sb.[Markdown]
		,sb.[Cash Discounts] = smc.NewSalesRatio*sb.[Cash Discounts]
		,sb.[Freight Allowance] = smc.NewSalesRatio*sb.[Freight Allowance]
		,sb.[Invoiced Freight] = smc.NewSalesRatio*sb.[Invoiced Freight]
		,sb.[Commission] = smc.NewSalesRatio*sb.[Commission]
	FROM #SalesBudget sb 
		INNER JOIN StandardMarginFixbyCategory smc ON sb.ID = smc.ID 
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = sb.DateID 
	WHERE 
		((cf.[Month Sort] >= (SELECT [BudgetMonth] FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 0)
			OR (cf.[Month Sort] >= (SELECT [ForecastMonth] FROM dbo.ForecastPeriod) AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 13))
		AND CASE WHEN sb.Sales <> 0 THEN (sb.Sales-sb.COGS)/sb.Sales END BETWEEN 0.9899 AND .9909


	--operations pass is separate due to the curve moving units out of months
	;WITH StandardMarginFixbyCategory AS (
		SELECT b.ID 
			, SUM([Sales]) AS BaseSales
			, SUM([Sales Operations]) AS Sales
			, SUM([Units]) AS BaseUnits
			, SUM([Units Operations]) AS Units
			, SUM([COGS Operations]) AS COGS
			, SUM([Sales Operations]-[COGS Operations])/SUM([Sales Operations]) AS Margin
			, SUM([Sales Operations]+(ISNULL([Coop Operations],0)+ISNULL([Other Operations],0)+ISNULL([DIF Returns Operations],0)+ISNULL([Markdown Operations],0)+ISNULL([Cash Discounts Operations],0)+ISNULL([Freight Allowance Operations],0))+ISNULL([Invoiced Freight Operations],0)) AS SalesAfterPrograms
			, SUM([COGS Operations])*(1+(1/(1-[Net Standard Margin %]) - 1)) AS NewSales
			, SUM([COGS Operations])*(1+(1/(1-[Net Standard Margin %]) - 1)) / SUM([Sales Operations]+(ISNULL([Coop Operations],0)+ISNULL([Other Operations],0)+ISNULL([DIF Returns Operations],0)+ISNULL([Markdown Operations],0)+ISNULL([Cash Discounts Operations],0)+ISNULL([Freight Allowance Operations],0))+ISNULL([Invoiced Freight Operations],0)) AS NewSalesRatio
			,([Net Standard Margin %]) as TargetStandardMargin
		FROM #SalesBudget b 
			LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = b.DateID 
			LEFT JOIN dbo.FactStandard s ON b.ProductID = s.ProductID AND cf.DateKey BETWEEN s.StartDate AND S.EndDate
			LEFT JOIN dbo.DimProductMaster pm ON pm.ProductID = b.ProductID
			INNER JOIN dbo.BudgetCategoryMarginLookup cm ON cm.Category = pm.Category --only adjust records that have a lookup
		WHERE ((cf.[Month Sort] >= (SELECT [BudgetMonth] FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 0)
			OR (cf.[Month Sort] >= (SELECT [ForecastMonth] FROM dbo.ForecastPeriod) AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 13))
		GROUP BY b.ID, cm.[Net Standard Margin %]
		HAVING CASE WHEN SUM([Sales Operations]) <> 0 THEN SUM([Sales Operations]-[COGS Operations])/SUM([Sales Operations])  END BETWEEN 0.9899 AND .9909
	)
	UPDATE sb
	SET sb.[Sales Operations] = smc.NewSalesRatio*sb.[Sales Operations]
		--,sb.[UnitPriceID] = smc.NewSalesRatio*sb.[UnitPriceID] --do not adjust unitpriceID on operations pass
		,sb.[Coop Operations] = smc.NewSalesRatio*sb.[Coop Operations]
		,sb.[Other Operations] = smc.NewSalesRatio*sb.[Other Operations]
		,sb.[DIF Returns Operations] = smc.NewSalesRatio*sb.[DIF Returns Operations]
		,sb.[Markdown Operations] = smc.NewSalesRatio*sb.[Markdown Operations]
		,sb.[Cash Discounts Operations] = smc.NewSalesRatio*sb.[Cash Discounts Operations]
		,sb.[Freight Allowance Operations] = smc.NewSalesRatio*sb.[Freight Allowance Operations]
		,sb.[Invoiced Freight Operations] = smc.NewSalesRatio*sb.[Invoiced Freight Operations]
	FROM #SalesBudget sb 
		INNER JOIN StandardMarginFixbyCategory smc ON sb.ID = smc.ID 
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = sb.DateID 
	WHERE 
		((cf.[Month Sort] >= (SELECT [BudgetMonth] FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 0)
			OR (cf.[Month Sort] >= (SELECT [ForecastMonth] FROM dbo.ForecastPeriod) AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 13))
		AND CASE WHEN sb.[Sales Operations] <> 0 THEN (sb.[Sales Operations]-sb.[COGS Operations])/sb.[Sales Operations] END BETWEEN 0.9899 AND .9909


	--25% margin for anything remaining
	;WITH StandardMarginFix AS (
		SELECT b.ID
			, COGS*(1+(1/(1-.25) - 1)) / (Sales+(ISNULL([Coop],0)+ISNULL([Other],0)+ISNULL([DIF Returns],0)+ISNULL([Markdown],0)+ISNULL([Cash Discounts],0)+ISNULL([Freight Allowance],0)+ISNULL([Invoiced Freight],0))) AS NewSalesRatio
			,(.25) as TargetStandardMargin
		FROM #SalesBudget b 
			LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = b.DateID 
			LEFT JOIN dbo.FactStandard s ON b.ProductID = s.ProductID AND cf.DateKey BETWEEN s.StartDate AND S.EndDate
			LEFT JOIN dbo.DimProductMaster pm ON pm.ProductID = b.ProductID
		WHERE ((cf.[Month Sort] >= (SELECT [BudgetMonth] FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 0)
			OR (cf.[Month Sort] >= (SELECT [ForecastMonth] FROM dbo.ForecastPeriod) AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 13))
			AND CASE WHEN Sales <> 0 THEN (Sales-COGS)/Sales  END BETWEEN 0.9899 AND .9909
	)
	UPDATE sb
	SET sb.Sales = sm.NewSalesRatio*sb.Sales
		,sb.[UnitPriceID] = sm.NewSalesRatio*sb.[UnitPriceID]
		,sb.[Coop] = sm.NewSalesRatio*sb.[Coop]
		,sb.[Other] = sm.NewSalesRatio*sb.[Other]
		,sb.[DIF Returns] = sm.NewSalesRatio*sb.[DIF Returns]
		,sb.[Markdown] = sm.NewSalesRatio*sb.[Markdown]
		,sb.[Cash Discounts] = sm.NewSalesRatio*sb.[Cash Discounts]
		,sb.[Freight Allowance] = sm.NewSalesRatio*sb.[Freight Allowance]
		,sb.[Invoiced Freight] = sm.NewSalesRatio*sb.[Invoiced Freight]
		,sb.[Commission] = sm.NewSalesRatio*sb.[Commission]
	FROM #SalesBudget sb 
		INNER JOIN StandardMarginFix sm ON sb.ID = sm.ID 
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = sb.DateID 
	WHERE 
		(cf.[Month Sort] >= (SELECT [BudgetMonth] FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 0)
			OR (cf.[Month Sort] >= (SELECT [ForecastMonth] FROM dbo.ForecastPeriod) AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 13)

	--25% margin for demand curve
	;WITH StandardMarginFix AS (
		SELECT b.ID
			, [COGS Operations]*(1+(1/(1-.25) - 1)) / ([Sales Operations]+(ISNULL([Coop Operations],0)+ISNULL([Other Operations],0)+ISNULL([DIF Returns Operations],0)+ISNULL([Markdown Operations],0)+ISNULL([Cash Discounts Operations],0)+ISNULL([Freight Allowance Operations],0)+ISNULL([Invoiced Freight Operations],0))) AS NewSalesRatio
			,(.25) as TargetStandardMargin
		FROM #SalesBudget b 
			LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = b.DateID 
			LEFT JOIN dbo.FactStandard s ON b.ProductID = s.ProductID AND cf.DateKey BETWEEN s.StartDate AND S.EndDate
			LEFT JOIN dbo.DimProductMaster pm ON pm.ProductID = b.ProductID
		WHERE ((cf.[Month Sort] >= (SELECT [BudgetMonth] FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 0)
			OR (cf.[Month Sort] >= (SELECT [ForecastMonth] FROM dbo.ForecastPeriod) AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 13))
			AND CASE WHEN [Sales Operations] <> 0 THEN ([Sales Operations]-[COGS Operations])/[Sales Operations]  END BETWEEN 0.9899 AND .9909
	)
	UPDATE sb
	SET sb.[Sales Operations] = sm.NewSalesRatio*sb.[Sales Operations]
		--,sb.[UnitPriceID] = sm.NewSalesRatio*sb.[UnitPriceID] --do not adjust unitpriceID on operations pass
		,sb.[Coop Operations] = sm.NewSalesRatio*sb.[Coop Operations]
		,sb.[Other Operations] = sm.NewSalesRatio*sb.[Other Operations]
		,sb.[DIF Returns Operations] = sm.NewSalesRatio*sb.[DIF Returns Operations]
		,sb.[Markdown Operations] = sm.NewSalesRatio*sb.[Markdown Operations]
		,sb.[Cash Discounts Operations] = sm.NewSalesRatio*sb.[Cash Discounts Operations]
		,sb.[Freight Allowance Operations] = sm.NewSalesRatio*sb.[Freight Allowance Operations]
		,sb.[Invoiced Freight Operations] = sm.NewSalesRatio*sb.[Invoiced Freight Operations]
	FROM #SalesBudget sb 
		INNER JOIN StandardMarginFix sm ON sb.ID = sm.ID 
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = sb.DateID 
	WHERE 
		(cf.[Month Sort] >= (SELECT [BudgetMonth] FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 0)
			OR (cf.[Month Sort] >= (SELECT [ForecastMonth] FROM dbo.ForecastPeriod) AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod) AND BudgetID = 13)

	--clear existing data
	DELETE 
	FROM dbo.FactSalesBudget 
	WHERE ((BudgetID = 0 AND (SELECT MODE FROM dbo.ForecastPeriod) = 'B') AND DateID >= (SELECT MIN(DateID) FROM dbo.DimCalendarFiscal WHERE [Month Sort] >= (SELECT [BudgetMonth] FROM dbo.ForecastPeriod))) --clear out current budget
		
	DELETE FROM sb 
	FROM dbo.FactSalesBudget sb
		LEFT JOIN dbo.DimCalendarFiscal cf ON sb.DateID = cf.DateID 
	WHERE (BudgetID = 13 AND (SELECT MODE FROM dbo.ForecastPeriod) = 'F')

	--load budget/forecast
	INSERT INTO dbo.FactSalesBudget (
		 [BudgetID]
		,[DateID]
		,[DateKey]
		,[DemandClassID]
		,[ProductID]
		,[CustomerID]
		,[SaleTypeID]
		,[UnitPriceID]
		,[Sales]
		,[Cogs]
		,[Material Cost]
		,[Material Overhead Cost]
		,[Resource Cost]
		,[Outside Processing Cost]
		,[Overhead Cost]
		,[GP]
		,[Units]
		,[Coop]
		,[DIF Returns]
		,[Invoiced Freight]
		,[Freight Allowance]
		,[Markdown]
		,[Cash Discounts]
		,[Other]
		,[Surcharge]
		,[Commission]
		,[Royalty]
		,[Freight Out]
		--added columns
		,[Sales Operations]
		,[Units Operations]
		,[ForecastSource]
		,[CostTypeID]
		,[COGS Operations] 
		,[Coop Operations]
		,[Other Operations]
		,[DIF Returns Operations]
		,[Markdown Operations]
		,[Cash Discounts Operations]
		,[Freight Allowance Operations]
		,[Invoiced Freight Operations]
		,[InvoicePriceID]
		,[LastForecastPriceID]
		,[BudgetPriceID]
		,[LastBudgetPriceID]
		,[Sales Invoice Price]
		,[Sales Forecast Price]
		,[Sales Budget Price]
		,[Sales Budget LY Price]
		,[Base Currency]
		,[Price Type]
	)
	SELECT 
	     s.[BudgetID]
		,s.[DateID]
		,cf.DateKey
		,s.[DemandClassID]
		,s.[ProductID]
		,s.[CustomerID]
		,s.[SaleTypeID]
		,ROUND(s.[UnitPriceID],0) AS UnitPriceID
		,s.[Sales]
		,s.[Cogs]
		,s.[Material Cost]
		,s.[Material Overhead Cost]
		,s.[Resource Cost]
		,s.[Outside Processing Cost]
		,s.[Overhead Cost]
		,ISNULL(s.[GP],0)
		,s.[Units]
		,s.[Coop]
		,s.[DIF Returns]
		,s.[Invoiced Freight]
		,s.[Freight Allowance]
		,s.[Markdown]
		,s.[Cash Discounts]
		,s.[Other]
		,s.[Surcharge]
		,s.[Commission]
		,s.[Royalty]
		,s.[Freight Out]
		--added columns
		,s.[Sales Operations]
		,s.[Units Operations]
		,CASE WHEN s.[ForecastSource] = 'Input' THEN 1 
			WHEN s.[ForecastSource] = 'Prior Open Orders' THEN 2 
			WHEN s.[ForecastSource] = 'Shipped Late' THEN 3 
			WHEN s.[ForecastSource] = 'Shipped Early' THEN 4
		 END AS ForecastSource
		,NULL AS [CostTypeID]
		,s.[COGS Operations] 
		,s.[Coop Operations]
		,s.[Other Operations]
		,s.[DIF Returns Operations]
		,s.[Markdown Operations]
		,s.[Cash Discounts Operations]
		,s.[Freight Allowance Operations]
		,s.[Invoiced Freight Operations]
		,s.[InvoicePriceID]
		,s.[LastForecastPriceID]
		,s.[BudgetPriceID]
		,s.[LastBudgetPriceID]
		,s.[Sales Invoice Price]
		,s.[Sales Forecast Price]
		,s.[Sales Budget Price]
		,s.[Sales Budget LY Price]
		,s.[Base Currency]
		,s.[Price Type]
	FROM #SalesBudget s WITH (NOLOCK)
		LEFT JOIN dbo.DimCalendarFiscal cf ON s.DateID = cf.DateID
	WHERE ((BudgetID = 0 AND (SELECT MODE FROM dbo.ForecastPeriod) = 'B') AND cf.DateID >= (SELECT MIN(DateID) FROM dbo.DimCalendarFiscal WHERE [Month Sort] >= (SELECT [BudgetMonth] FROM dbo.ForecastPeriod)))
		OR ((BudgetID = 13 AND (SELECT MODE FROM dbo.ForecastPeriod) = 'F') AND cf.DateID >= (SELECT MIN(DateID) FROM dbo.DimCalendarFiscal WHERE [Month Sort] >= (SELECT [ForecastMonth] FROM dbo.ForecastPeriod)))
	ORDER BY cf.[Month Sort]

	--Enter actual customer programs for prior month until Vena number is finalized
	INSERT INTO dbo.FinanceAdjustmentActuals (Year, Month, [Programs & Allowances])
	SELECT DISTINCT 
		cf.Year
		, cf.[Month Seasonality]
		,ROUND((SUM(s.[Cash Discounts]) + SUM(s.[Frieght Allowance]) + SUM(s.[Markdown]) + SUM(s.[Other]) + SUM(s.[COOP]) + SUM(s.[DIF RETURNS])),2) 
	FROM dbo.FactPBISales s
		LEFT JOIN dbo.DimCalendarFiscal cf ON s.DateKey = cf.DateKey
		LEFT JOIN [dbo].[FinanceAdjustmentActuals] a ON cf.Year = a.Year AND cf.[Month Seasonality] = a.Month
	WHERE cf.Year > 2022 AND cf.UseActual = 1 AND a.Month IS NULL AND a.Year IS NULL
	GROUP BY cf.Year, cf.[Month Seasonality]	
END




GO
