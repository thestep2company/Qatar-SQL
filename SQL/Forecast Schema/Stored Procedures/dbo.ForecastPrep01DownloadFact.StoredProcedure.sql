USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[ForecastPrep01DownloadFact]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ForecastPrep01DownloadFact] AS BEGIN
	--DROP TABLE IF EXISTS dbo.FactSalesBudget
	--SELECT * INTO dbo.FactSalesBudget FROM QATAR.Operations.dbo.FactPBISalesBudget s 
	--WHERE (SELECT LEFT(ForecastMonth,4) FROM dbo.ForecastPeriod) <= YEAR(DateKey)+1 OR (SELECT LEFT(BudgetMonth,4) FROM dbo.ForecastPeriod) <= YEAR(DateKey)+1

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FactSalesBudget]') AND type in (N'U'))
	DROP TABLE [dbo].[FactSalesBudget]

	CREATE TABLE [dbo].[FactSalesBudget](
		[ID] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
		[BudgetID] [int] NOT NULL,
		[DateID] [int] NULL,
		[DateKey] [date] NULL,
		[DemandClassID] [bigint] NULL,
		[ProductID] [int] NULL,
		[CustomerID] [int] NULL,
		[SaleTypeID] [int] NOT NULL,
		[UnitPriceID] [int] NULL,
		[Sales] [float] NULL,
		[Cogs] [float] NULL,
		[Material Cost] [money] NULL,
		[Material Overhead Cost] [money] NULL,
		[Resource Cost] [money] NULL,
		[Outside Processing Cost] [money] NULL,
		[Overhead Cost] [money] NULL,
		[GP] [int] NOT NULL,
		[Units] [float] NULL,
		[Coop] [float] NULL,
		[DIF Returns] [float] NULL,
		[Invoiced Freight] [float] NULL,
		[Freight Allowance] [float] NULL,
		[Markdown] [float] NULL,
		[Cash Discounts] [float] NULL,
		[Other] [float] NULL,
		[Surcharge] [float] NULL,
		[Commission] [float] NULL,
		[Royalty] [float] NULL,
		[Freight Out] [float] NULL,
		[Sales Operations] [money] NULL,
		[Units Operations] [float] NULL,
		[ForecastSource] [int] NULL,
		[CostTypeID] [int] NULL,
		[COGS Operations] [money] NULL,
		[Coop Operations] [float] NULL,
		[Other Operations] [float] NULL,
		[DIF Returns Operations] [float] NULL,
		[Markdown Operations] [float] NULL,
		[Cash Discounts Operations] [float] NULL,
		[Freight Allowance Operations] [float] NULL,
		[Invoiced Freight Operations] [float] NULL,
		[InvoicePriceID] [int] NULL,
		[LastForecastPriceID] [int] NULL,
		[BudgetPriceID] [int] NULL,
		[LastBudgetPriceID] [int] NULL,
		[Sales Invoice Price] [float] NULL,
		[Sales Forecast Price] [float] NULL,
		[Sales Budget Price] [float] NULL,
		[Sales Budget LY Price] [float] NULL,
		[Base Currency] varchar(30) NULL,
	    [Price Type] varchar(34) NULL
	) ON [PRIMARY]

	SET IDENTITY_INSERT dbo.FactSalesBudget ON

	INSERT INTO dbo.FactSalesBudget (
	   [ID]
      ,[BudgetID]
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
       [ID]
      ,[BudgetID]
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
	FROM Operations.dbo.FactPBISalesBudget s 
	WHERE (SELECT LEFT(ForecastMonth,4) FROM dbo.ForecastPeriod) <= YEAR(DateKey)+1 OR (SELECT LEFT(BudgetMonth,4) FROM dbo.ForecastPeriod) <= YEAR(DateKey)+1

	DROP TABLE IF EXISTS dbo.FactStandard
	SELECT * INTO dbo.FactStandard FROM Operations.dbo.FactStandard WHERE (SELECT COGSDate FROM dbo.ForecastPeriod) BETWEEN StartDate AND ISNULL(EndDate,'9999-12-31')

	DROP TABLE IF EXISTS dbo.FactStandardPending
	SELECT * INTO dbo.FactStandardPending FROM Operations.Fact.StandardPending WHERE (SELECT COGSDate FROM dbo.ForecastPeriod) BETWEEN StartDate AND ISNULL(EndDate,'9999-12-31')

	DROP TABLE IF EXISTS dbo.FactPricing 
	SELECT * INTO dbo.FactPricing FROM Operations.dbo.FactPricing WHERE ISNULL(InvoicePrice,0) + ISNULL(ForecastPrice,0) + ISNULL(OraclePrice,0) + ISNULL(Price,0) <> 0

	DROP TABLE IF EXISTS dbo.FactPBISales
	SELECT * INTO dbo.FactPBISales FROM Operations.dbo.FactPBISales s 
	WHERE  s.DateKey >=  DATEADD(MONTH,-36,(SELECT CustomerSplitDate FROM dbo.ForecastPeriod))
		AND s.DateKey < (SELECT CustomerSplitDate FROM dbo.ForecastPeriod)

	DROP TABLE IF EXISTS dbo.FactPriceList --INTO dbo.FactPriceList
	SELECT * INTO dbo.FactPriceList FROM Operations.dbo.FactPriceList

	DROP TABLE IF EXISTS dbo.FinanceAdjustment
	SELECT * INTO dbo.FinanceAdjustment FROM Operations.dbo.FinanceAdjustment

	DROP TABLE IF EXISTS dbo.FinanceAdjustmentActuals
	SELECT * INTO dbo.FinanceAdjustmentActuals FROM Operations.dbo.FinanceAdjustmentActuals

	DROP TABLE IF EXISTS dbo.FactSalesForecastQuantites 
	SELECT ForecastSource, DateID, ProductID, DemandClassID, SUM(Quantity) AS Quantity 
	INTO dbo.FactSalesForecastQuantites 
	FROM Operations.Fact.SalesForecastQuantities --WHERE Quantity > 0 
	GROUP BY ForecastSource, DateID, ProductID, DemandClassID

	DROP TABLE IF EXISTS dbo.FactConversionRate
	SELECT * INTO dbo.FactConversionRate FROM Operations.Oracle.GL_DAILY_RATES cc 

	--DROP TABLE IF EXISTS dbo.FactGlobalPlan
	--DROP TABLE IF EXISTS dbo.FactASCPPlan
	--DROP TABLE IF EXISTS dbo.FactPriorOpenOrders
	--DROP TABLE IF EXISTS dbo.FactCurrentInvoicedOrders
	--DROP TABLE IF EXISTS dbo.FactClosedOrders

END
GO
