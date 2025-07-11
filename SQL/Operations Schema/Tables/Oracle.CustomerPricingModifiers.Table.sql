USE [Operations]
GO
/****** Object:  Table [Oracle].[CustomerPricingModifiers]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[CustomerPricingModifiers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ACCOUNT_NUMBER] [nvarchar](30) NOT NULL,
	[PRICE_LIST_ID] [numeric](15, 0) NULL,
	[PART] [nvarchar](40) NULL,
	[MODIFIER_NAME] [nvarchar](240) NOT NULL,
	[MODIFIER_AMOUNT] [float] NULL,
	[ARITHMETIC] [nvarchar](30) NULL,
	[ACTIVE_FLAG] [nvarchar](1) NULL,
	[STARTDATE] [datetime2](7) NULL,
	[ENDDATE] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
