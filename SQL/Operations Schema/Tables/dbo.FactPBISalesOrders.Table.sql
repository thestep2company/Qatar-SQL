USE [Operations]
GO
/****** Object:  Table [dbo].[FactPBISalesOrders]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPBISalesOrders](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ORDER_NUM] [float] NOT NULL,
	[ORDER_LINE_NUM] [float] NULL,
	[INV_DESCRIPTION] [nvarchar](2000) NULL,
	[RevenueID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[GeographyID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[LocationID] [int] NOT NULL,
	[DemandClassID] [bigint] NOT NULL,
	[DateID] [int] NOT NULL,
	[DateKey] [datetime] NULL,
	[HourID] [int] NULL,
	[SELL_DOLLARS] [float] NULL,
	[ORIGINAL_LIST_DOLLARS] [float] NULL,
	[LIST_DOLLARS] [float] NULL,
	[COGSSB] [float] NULL,
	[COGSPV] [float] NULL,
	[QTY] [float] NULL,
	[FLOW_STATUS_CODE] [nvarchar](30) NULL,
	[IsOpen] [int] NOT NULL,
	[IsInvoiced] [int] NOT NULL,
	[COOP] [float] NULL,
	[DIF RETURNS] [float] NULL,
	[Freight Allowance] [float] NULL,
	[Cash Discounts] [float] NULL,
	[Markdown] [float] NULL,
	[Other] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
