USE [Operations]
GO
/****** Object:  Table [Oracle].[PriceList]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[PriceList](
	[CUSTOMER_NUMBER] [nvarchar](30) NULL,
	[CUSTOMER_NAME] [nvarchar](360) NULL,
	[SKU] [nvarchar](4000) NULL,
	[SKU_NAME] [nvarchar](240) NULL,
	[Price] [float] NULL
) ON [PRIMARY]
GO
