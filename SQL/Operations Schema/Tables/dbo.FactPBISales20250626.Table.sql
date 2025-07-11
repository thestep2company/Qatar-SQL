USE [Operations]
GO
/****** Object:  Table [dbo].[FactPBISales20250626]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPBISales20250626](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ORDER_NUM] [int] NULL,
	[ORDER_LINE] [int] NULL,
	[AR_TYPE] [nvarchar](30) NULL,
	[INV_DESCRIPTION] [nvarchar](240) NULL,
	[CUST_PO_NUM] [nvarchar](50) NULL,
	[RevenueID] [bigint] NOT NULL,
	[AccountID] [nvarchar](4) NULL,
	[CustomerID] [int] NOT NULL,
	[GeographyID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[LocationID] [int] NOT NULL,
	[DemandClassID] [bigint] NOT NULL,
	[DateID] [int] NOT NULL,
	[DateKey] [datetime] NULL,
	[UnitPriceID] [int] NULL,
	[UnitCOGSID] [int] NULL,
	[Sales] [money] NULL,
	[COGS] [money] NULL,
	[MaterialCost] [money] NULL,
	[MaterialOHCost] [money] NULL,
	[ResourceCost] [money] NULL,
	[OutsideProcessingCost] [money] NULL,
	[OverheadCost] [money] NULL,
	[QTY] [int] NULL,
	[COOP] [float] NULL,
	[DIF RETURNS] [float] NULL,
	[Invoiced Freight] [float] NULL,
	[Frieght Allowance] [float] NULL,
	[Cash Discounts] [float] NULL,
	[Markdown] [float] NULL,
	[Other] [float] NULL,
	[FREIGHT OUT] [float] NULL,
	[ROYALTY] [float] NULL,
	[SURCHARGE] [float] NULL,
	[COMMISSION] [float] NULL,
	[TermID] [int] NULL
) ON [PRIMARY]
GO
