USE [Operations]
GO
/****** Object:  Table [dbo].[FactOrderCurve]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactOrderCurve](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BudgetID] [int] NOT NULL,
	[DateID] [int] NULL,
	[DateKey] [date] NULL,
	[HourID] [int] NULL,
	[DemandClassID] [bigint] NULL,
	[RevenueTypeID] [int] NOT NULL,
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
	[Freight Out] [float] NULL,
 CONSTRAINT [PK_FactOrderCurve] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
