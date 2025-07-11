USE [Forecast]
GO
/****** Object:  Table [dbo].[FactPriceList]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPriceList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[ProductID] [int] NULL,
	[PriceList] [nvarchar](240) NOT NULL,
	[Price] [float] NULL,
	[CURRENCY] [nvarchar](30) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
