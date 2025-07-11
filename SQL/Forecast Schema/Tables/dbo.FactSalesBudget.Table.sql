USE [Forecast]
GO
/****** Object:  Table [dbo].[FactSalesBudget]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactSalesBudget](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
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
	[Base Currency] [varchar](30) NULL,
	[Price Type] [varchar](34) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
