USE [Operations]
GO
/****** Object:  Table [OUTPUT].[OrdersTest]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [OUTPUT].[OrdersTest](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RevenueID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[LocationID] [int] NOT NULL,
	[DemandClassID] [bigint] NOT NULL,
	[DateID] [int] NOT NULL,
	[DateKey] [date] NULL,
	[HourID] [int] NULL,
	[SELL_DOLLARS] [float] NULL,
	[ORIGINAL_LIST_DOLLARS] [float] NULL,
	[LIST_DOLLARS] [float] NULL,
	[COGSSB] [float] NULL,
	[COGSPV] [float] NULL,
	[Qty] [float] NULL,
	[IsOpen] [int] NOT NULL,
	[IsInvoiced] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
