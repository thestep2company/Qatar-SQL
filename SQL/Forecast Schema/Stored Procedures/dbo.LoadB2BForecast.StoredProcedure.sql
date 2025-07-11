USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[LoadB2BForecast]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LoadB2BForecast] AS BEGIN
	--B2B Rollforward

	INSERT INTO dbo.FactSalesBudget
	SELECT 
	     13 AS [BudgetID]
		,s.[DateID]
		,cf.DateKey
		,s.[DemandClassID]
		,s.[ProductID]
		,s.[CustomerID]
		,s.[SaleTypeID]
		,s.[UnitPriceID]
		,s.[Sales]
		,s.[Cogs]
		,s.[Material Cost]
		,s.[Material Overhead Cost]
		,s.[Resource Cost]
		,s.[Outside Processing Cost]
		,s.[Overhead Cost]
		,ISNULL(s.[GP],0)
		,s.[Units]
		, -ISNULL(sg1.Coop,sg2.Coop)*s.Sales AS Coop
		, -ISNULL(sg1.[DIF Returns],sg2.[DIF Returns])*s.Sales AS [DIF Returns]
		, ISNULL(sg1.[Invoiced Freight],sg2.[Invoiced Freight])*s.Sales AS [Invoiced Freight]
		, -ISNULL(sg1.[Freight Allowance],sg2.[Freight Allowance])*s.Sales AS [Freight Allowance]
		, -ISNULL(sg1.[Markdown],sg2.[Markdown])*s.Sales AS [Markdown]
		, -ISNULL(sg1.[Cash Discounts],sg2.[Cash Discounts])*s.Sales AS [Cash Discounts]
		, -ISNULL(sg1.[Other],sg2.[Other])*s.Sales AS [Other]
		, -0*s.Sales AS [Surcharge]
		, -ISNULL(sg1.[Commission],sg2.[Commission])*s.Sales AS [Commission]
		, -0*s.Sales AS [Royalty]
		, -0*s.Sales AS [Freight Out]
		--added columns
		,s.[Sales Operations]
		,s.[Units Operations]
		,s.[COGS Operations]
		,s.[InvoicePriceID]
		,s.[LastForecastPriceID]
		,s.[BudgetPriceID]
		,s.[LastBudgetPriceID]
		,s.[Sales Invoice Price]
		,s.[Sales Forecast Price]
		,s.[Sales Budget Price]
		,s.[Sales Budget LY Price]
		,'USD' AS [BaseCurrency]
		,'Contract Manufacturing' AS [PriceType]
	FROM dbo.FactSalesBudget s
		LEFT JOIN dbo.DimCalendarFiscal cf ON s.DateID = cf.DateID
		LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassID = s.DemandClassID
		LEFT JOIN dbo.DimCustomerMaster cm ON cm.CustomerID = s.CustomerID
		LEFT JOIN xref.[Customer Grid by Account] sg1 ON dc.DemandClassKey = sg1.[Demand Class Code] AND sg1.[Account Number] = cm.[CustomerKey] AND cf.Year = sg1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sg1.Month
		LEFT JOIN xref.[Customer Grid by Account] sg2 ON dc.DemandClassKey = sg1.[Demand Class Code] AND sg2.[Account Number] = cm.[CustomerKey] AND cf.Year = sg2.Year AND sg1.[Account Number] IS NULL AND sg2.Month IS NULL
	WHERE ((cf.[UseForecast] = 1 AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod) AND cf.[Month Sort] >= (SELECT [ForecastMonth] FROM dbo.ForecastPeriod)) OR 'B' = (SELECT MODE FROM dbo.ForecastPeriod)) 
		AND dc.DemandClassKey = 'B2B' AND s.BudgetID = -1


	IF GETDATE() < '2024-09-29' BEGIN
		DECLARE @placeholderAmount MONEY =  270000.00--in addition to prior forecast already provided
		DECLARE @marginTarget FLOAT = .3
		DECLARE @shipDays INT = 24

		INSERT INTO dbo.FactSalesBudget
		SELECT DISTINCT 
			13 AS BudgetID
			, sb.DateID
			, sb.DateKey
			, 15 AS DemandClassID
			, -3037 AS ProductID
			, 1000459 AS CustomerID
			, 1 AS SaleTypeID
			, 0 AS UnitPriceID 
			, @placeholderAmount/@shipDays AS Sales
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays) AS Cogs
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.50 AS [Material Cost]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.04 AS [Material Overhead Cost]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.24 AS [Resource Cost]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.00 AS [Outside Processing Cost]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.22 AS [Overhead Cost]
			, 0 AS [GP]
			, 0 AS [Units]
			, 0 AS [Coop]
			, 0 AS [DIF Returns]
			, 0 AS [Invoced Freight]
			, 0 AS [Freight Allowance]
			, 0 AS [Markdown]
			, 0 AS [Cash Discounts]
			, 0 AS [Other]
			, 0 AS [Surcharge]
			, 0 AS [Commission]
			, 0 AS [Royalty]
			, 0 AS [Freight Out]
			, @placeholderAmount/@shipDays AS [Sales Operations]
			, 0 AS [Unit Operations]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays) AS [COGS Operations]
			, NULL AS [InvoicePriceID]
			, NULL AS [LastForecatsPriceID]
			, NULL AS [BudgetPriceID]
			, NULL AS [LastBudgetPriceID]
			, NULL AS [Sales Invoice Price]
			, NULL AS [Sales Forecast Price]
			, NULL AS [Sales Budget Price]
			, NULL AS [Sales Budget LY Price]
			, 'USD' AS [Base Currency]
			, 'Contract Manufacturing' AS [Price Type]
		FROM dbo.FactSalesBudget sb
			LEFT JOIN dbo.DimCalendarFiscal cf ON sb.DateID = cf.DateID 
			LEFT JOIN dbo.DimDemandClass dc ON sb.DemandClassID = dc.DemandClassID
		WHERE cf.[Month Sort] = '202409'
			AND DemandClassKey = 'B2B'
			AND BudgetID = 13

	/*
		SET @placeholderAmount = 100000.00
		SET @shipDays = 20

		INSERT INTO dbo.FactSalesBudget
		SELECT DISTINCT 
			13 AS BudgetID
			, sb.DateID
			, sb.DateKey
			, 15 AS DemandClassID
			, -3037 AS ProductID
			, 1000459 AS CustomerID
			, 1 AS SaleTypeID
			, 0 AS UnitPriceID 
			, @placeholderAmount/@shipDays AS Sales
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays) AS Cogs
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.50 AS [Material Cost]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.04 AS [Material Overhead Cost]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.24 AS [Resource Cost]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.00 AS [Outside Processing Cost]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.22 AS [Overhead Cost]
			, 0 AS [GP]
			, 0 AS [Units]
			, 0 AS [Coop]
			, 0 AS [DIF Returns]
			, 0 AS [Invoced Freight]
			, 0 AS [Freight Allowance]
			, 0 AS [Markdown]
			, 0 AS [Cash Discounts]
			, 0 AS [Other]
			, 0 AS [Surcharge]
			, 0 AS [Commission]
			, 0 AS [Royalty]
			, 0 AS [Freight Out]
			, @placeholderAmount/@shipDays AS [Sales Operations]
			, 0 AS [Unit Operations]
			, NULL AS [InvoicePriceID]
			, NULL AS [LastForecatsPriceID]
			, NULL AS [BudgetPriceID]
			, NULL AS [LastBudgetPriceID]
			, NULL AS [Sales Invoice Price]
			, NULL AS [Sales Forecast Price]
			, NULL AS [Sales Budget Price]
			, NULL AS [Sales Budget LY Price]
			, 'USD' AS [Base Currency]
			, 'Contract Manufacturing' AS [Price Type]
		FROM dbo.FactSalesBudget sb
			LEFT JOIN dbo.DimCalendarFiscal cf ON sb.DateID = cf.DateID 
			LEFT JOIN dbo.DimDemandClass dc ON sb.DemandClassID = dc.DemandClassID
		WHERE cf.[Month Sort] = '202410'
			AND DemandClassKey = 'B2B'
			AND BudgetID = 13

		SET @placeholderAmount = -200000.00
		SET @shipDays = 20

		INSERT INTO dbo.FactSalesBudget
		SELECT DISTINCT 
			13 AS BudgetID
			, sb.DateID
			, sb.DateKey
			, 15 AS DemandClassID
			, -3037 AS ProductID
			, 1000459 AS CustomerID
			, 1 AS SaleTypeID
			, 0 AS UnitPriceID 
			, @placeholderAmount/@shipDays AS Sales
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays) AS Cogs
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.50 AS [Material Cost]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.04 AS [Material Overhead Cost]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.24 AS [Resource Cost]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.00 AS [Outside Processing Cost]
			, ((@placeholderAmount*(1.0-@marginTarget))/@shipDays)*0.22 AS [Overhead Cost]
			, 0 AS [GP]
			, 0 AS [Units]
			, 0 AS [Coop]
			, 0 AS [DIF Returns]
			, 0 AS [Invoced Freight]
			, 0 AS [Freight Allowance]
			, 0 AS [Markdown]
			, 0 AS [Cash Discounts]
			, 0 AS [Other]
			, 0 AS [Surcharge]
			, 0 AS [Commission]
			, 0 AS [Royalty]
			, 0 AS [Freight Out]
			, @placeholderAmount/@shipDays AS [Sales Operations]
			, 0 AS [Unit Operations]
			, NULL AS [InvoicePriceID]
			, NULL AS [LastForecatsPriceID]
			, NULL AS [BudgetPriceID]
			, NULL AS [LastBudgetPriceID]
			, NULL AS [Sales Invoice Price]
			, NULL AS [Sales Forecast Price]
			, NULL AS [Sales Budget Price]
			, NULL AS [Sales Budget LY Price]
			, 'USD' AS [Base Currency]
			, 'Contract Manufacturing' AS [Price Type]
		FROM dbo.FactSalesBudget sb
			LEFT JOIN dbo.DimCalendarFiscal cf ON sb.DateID = cf.DateID 
			LEFT JOIN dbo.DimDemandClass dc ON sb.DemandClassID = dc.DemandClassID
		WHERE cf.[Month Sort] = '202411'
			AND DemandClassKey = 'B2B'
			AND BudgetID = 13
	*/
	END
END

GO
