USE [Forecast]
GO
/****** Object:  Table [dbo].[FactOrderCurve]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactOrderCurve](
	[BudgetID] [int] NOT NULL,
	[DateID] [int] NULL,
	[DateKey] [date] NULL,
	[HourID] [int] NULL,
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
	[GP] [float] NULL,
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
	[Freight Out] [float] NULL
) ON [PRIMARY]
GO
