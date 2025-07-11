USE [Operations]
GO
/****** Object:  Table [dbo].[FactInvoicePriceVariance]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactInvoicePriceVariance](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[POID] [int] NULL,
	[INVOICEID] [numeric](15, 0) NULL,
	[DateID] [int] NULL,
	[LocationID] [int] NULL,
	[ProductID] [int] NULL,
	[INVOICE_PRICE] [float] NULL,
	[QUANTITY_INVOICED] [float] NULL,
	[VarCost] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
