USE [Operations]
GO
/****** Object:  Table [dbo].[FactSales]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactSales](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[ORDER_NUM] [float] NULL,
	[ORDER_LINE] [float] NULL,
	[SaleTypeID] [int] NOT NULL,
	[RevenueID] [bigint] NOT NULL,
	[AccountID] [bigint] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[GeographyID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[LocationID] [int] NOT NULL,
	[DemandClassID] [bigint] NOT NULL,
	[DateID] [int] NOT NULL,
	[HourID] [int] NULL,
	[ACCTD_USD] [float] NULL,
	[ENTERED_AMOUNT] [money] NULL,
	[ITEM_FROZEN_COST] [money] NULL,
	[COGS_AMOUNT] [float] NULL,
	[QTY] [float] NULL,
	[COOP] [float] NULL,
	[DIF RETURNS] [float] NULL,
	[Invoiced Freight] [float] NULL,
	[Freight Allowance] [float] NULL,
	[Cash Discounts] [float] NULL,
	[Markdown] [float] NULL,
	[Other] [float] NULL,
	[FREIGHT OUT] [float] NULL,
	[ROYALTY] [float] NULL,
	[SURCHARGE] [float] NULL,
	[COMMISSION] [float] NULL,
	[MAPP] [float] NULL,
 CONSTRAINT [PK_FactSales] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
