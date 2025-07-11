USE [Operations]
GO
/****** Object:  Table [dbo].[FactSalesForecastAdditions]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactSalesForecastAdditions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Order_Num] [float] NULL,
	[Order_Line] [float] NULL,
	[SaleTypeID] [int] NULL,
	[RevenueID] [int] NULL,
	[AccountID] [int] NULL,
	[CustomerID] [int] NULL,
	[GeographyID] [int] NULL,
	[ProductID] [int] NOT NULL,
	[LocationID] [int] NULL,
	[DemandClassID] [bigint] NULL,
	[DateID] [int] NULL,
	[HourID] [int] NULL,
	[ACCTD_USD] [money] NULL,
	[ENTERED_AMOUNT] [money] NULL,
	[ITEM_FROZEN_COST] [money] NULL,
	[COGS_AMOUNT] [money] NULL,
	[QTY] [float] NOT NULL,
	[COOP] [int] NOT NULL,
	[DIF RETURNS] [int] NOT NULL,
	[Invoiced Freight] [int] NOT NULL,
	[Frieght Allowance] [int] NOT NULL,
	[Cash Discounts] [int] NOT NULL,
	[Markdown] [int] NOT NULL,
	[Other] [int] NOT NULL,
	[FREIGHT OUT] [int] NOT NULL,
	[ROYALTY] [int] NOT NULL,
	[SURCHARGE] [int] NOT NULL,
	[COMMISSION] [int] NOT NULL,
	[MAPP] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
