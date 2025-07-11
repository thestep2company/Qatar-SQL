USE [Operations]
GO
/****** Object:  Table [dbo].[FactPurchasePriceVariance]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPurchasePriceVariance](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[POID] [bigint] NULL,
	[DateID] [int] NULL,
	[VendorID] [float] NULL,
	[LocationID] [int] NULL,
	[ProductID] [int] NULL,
	[QTY] [float] NULL,
	[MaterialCost] [float] NULL,
	[OverheadCost] [float] NULL,
	[POCost] [float] NULL,
	[StandardCost] [float] NULL,
	[VarCost] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
