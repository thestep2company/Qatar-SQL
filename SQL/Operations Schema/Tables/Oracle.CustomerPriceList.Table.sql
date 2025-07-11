USE [Operations]
GO
/****** Object:  Table [Oracle].[CustomerPriceList]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[CustomerPriceList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ACCOUNT_NUMBER] [nvarchar](30) NOT NULL,
	[CUSTOMER_NAME] [nvarchar](360) NULL,
	[PRICE_LIST] [nvarchar](240) NOT NULL,
	[PRICE_LIST_ID] [float] NOT NULL,
	[LIST_LINE_ID] [float] NULL,
	[LIST_LINE_TYPE] [nvarchar](4000) NULL,
	[DESCRIPTION] [nvarchar](2000) NULL,
	[PRODUCT_ATTRIBUTE] [nvarchar](30) NULL,
	[CURRENCY] [nvarchar](30) NULL,
	[CURRENCY_NAME] [nvarchar](80) NULL,
	[MULTI_CURRENCY_NAME] [nvarchar](240) NULL,
	[ROUNDING_FACTOR] [float] NULL,
	[START_DATE] [datetime2](7) NULL,
	[END_DATE] [datetime2](7) NULL,
	[PRODUCT_CONTEXT] [nvarchar](30) NULL,
	[UOM] [nvarchar](3) NULL,
	[ITEM] [nvarchar](4000) NULL,
	[ITEM_DESCRIPTION] [nvarchar](240) NULL,
	[VALUE] [float] NULL,
	[PRECEDENCE] [float] NULL,
	[PRICING_TRANSACTION_ENTITY] [nvarchar](30) NULL,
	[SOURCE_SYSTEM_CODE] [nvarchar](30) NULL,
	[LIST_TYPE_CODE] [nvarchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
