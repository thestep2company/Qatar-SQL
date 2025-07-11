USE [Forecast]
GO
/****** Object:  Table [dbo].[FactSalesGrid]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactSalesGrid](
	[BudgetID] [int] NULL,
	[DateID] [int] NULL,
	[DemandClassID] [bigint] NULL,
	[ProductID] [int] NULL,
	[CustomerID] [int] NULL,
	[SaleTypeID] [int] NOT NULL,
	[Sales] [float] NULL,
	[Cogs] [float] NULL,
	[Material Cost] [float] NULL,
	[Material Overhead Cost] [float] NULL,
	[Resource Cost] [float] NULL,
	[Outside Processing Cost] [float] NULL,
	[Overhead Cost] [float] NULL,
	[GP] [int] NOT NULL,
	[Units] [float] NULL,
	[InvoicePriceID] [numeric](17, 6) NULL,
	[CurrentForecastPriceID] [int] NULL,
	[LastForecastPriceID] [int] NULL,
	[BudgetPriceID] [int] NULL,
	[LastBudgetPriceID] [int] NULL,
	[Sales Invoice Price] [money] NULL,
	[Sales Forecast Price] [money] NULL,
	[Sales Budget Price] [money] NULL,
	[Sales Budget LY Price] [money] NULL,
	[Coop] [float] NULL,
	[DIF Returns] [float] NULL,
	[InvoicedFreight] [float] NULL,
	[Freight Allowance] [float] NULL,
	[Markdown] [float] NULL,
	[Cash Discounts] [float] NULL,
	[Other] [float] NULL,
	[Surcharge] [float] NULL,
	[Commission] [float] NULL,
	[Royalty] [float] NULL,
	[Freight Out] [float] NULL,
	[BaseCurrency] [nvarchar](30) NULL,
	[PriceType] [varchar](34) NULL
) ON [PRIMARY]
GO
