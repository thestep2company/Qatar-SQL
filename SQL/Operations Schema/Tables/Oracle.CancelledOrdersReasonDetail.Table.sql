USE [Operations]
GO
/****** Object:  Table [Oracle].[CancelledOrdersReasonDetail]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[CancelledOrdersReasonDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CUST_NO] [nvarchar](30) NOT NULL,
	[CUST] [nvarchar](360) NOT NULL,
	[ORDNUM] [float] NOT NULL,
	[LINEID] [float] NULL,
	[ORD_DATE] [datetime2](7) NULL,
	[AMOUNT] [float] NULL,
	[PART] [nvarchar](40) NULL,
	[NAME] [nvarchar](240) NULL,
	[INVENTORY_ITEM_ID] [float] NULL,
	[ORDERED_QTY] [float] NULL,
	[CANCELLED_QTY] [float] NULL,
	[UNIT1] [nvarchar](3) NULL,
	[CANCEL_REASON] [nvarchar](80) NOT NULL,
	[CANDATE] [datetime2](7) NULL,
	[USERNAME] [nvarchar](100) NOT NULL,
	[ITEM_IDENTIFIER_TYPE] [nvarchar](25) NULL,
	[ORDERED_ITEM_ID] [float] NULL,
	[ORDERED_ITEM] [nvarchar](2000) NULL,
	[CONVERSION_RATE] [float] NULL,
	[CONVERSION_TYPE_CODE] [nvarchar](30) NULL,
	[CURRENCY_CODE] [nvarchar](15) NULL,
	[CAT_CODE] [nvarchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
