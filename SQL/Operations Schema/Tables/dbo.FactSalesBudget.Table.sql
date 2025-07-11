USE [Operations]
GO
/****** Object:  Table [dbo].[FactSalesBudget]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactSalesBudget](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ForecastID] [int] NULL,
	[DateID] [int] NULL,
	[DemandClassID] [bigint] NULL,
	[ProductID] [int] NULL,
	[CustomerID] [int] NULL,
	[SaleTypeID] [int] NOT NULL,
	[Sales] [money] NOT NULL,
	[COGS] [money] NULL,
	[GP] [money] NULL,
	[Units] [float] NOT NULL,
	[Coop] [money] NULL,
	[DIF Returns] [money] NULL,
	[Invoiced Freight] [money] NULL,
	[Freight Allowance] [money] NULL,
	[Cash Discounts] [money] NULL,
	[Markdown] [money] NULL,
	[Other] [money] NULL,
	[Freight Out] [money] NULL,
	[Royalty] [money] NULL,
	[Surcharge] [money] NULL,
	[Commission] [money] NULL,
	[MAPP] [money] NULL,
	[UnitPriceID] [int] NULL,
 CONSTRAINT [PK_FactSalesBudget] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
