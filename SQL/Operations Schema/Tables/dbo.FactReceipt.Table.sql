USE [Operations]
GO
/****** Object:  Table [dbo].[FactReceipt]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactReceipt](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[POID] [int] NOT NULL,
	[LocationID] [int] NULL,
	[ProductID] [int] NULL,
	[DateID] [int] NULL,
	[BuyerID] [int] NULL,
	[VendorID] [int] NULL,
	[QUANTITY] [float] NULL,
	[PACKING_SLIP] [nvarchar](25) NULL,
	[DOCUMENT_NUMBER] [nvarchar](143) NULL,
	[PRICE] [float] NULL,
	[RECEIPT_NUMBER] [nvarchar](30) NULL,
	[RECEIVER] [nvarchar](240) NULL,
	[DELIVER_TO] [nvarchar](240) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
