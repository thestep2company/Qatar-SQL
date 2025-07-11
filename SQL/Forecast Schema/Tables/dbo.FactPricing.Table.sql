USE [Forecast]
GO
/****** Object:  Table [dbo].[FactPricing]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPricing](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[DemandClassID] [bigint] NULL,
	[InvoicePrice] [money] NULL,
	[ForecastPrice] [money] NULL,
	[OraclePrice] [money] NULL,
	[Price] [money] NULL,
	[LastInvoiceDate] [datetime] NULL
) ON [PRIMARY]
GO
