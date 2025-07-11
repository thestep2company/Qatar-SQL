USE [Operations]
GO
/****** Object:  Table [Oracle].[APInvoice]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[APInvoice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[INVOICE_ID] [numeric](15, 0) NOT NULL,
	[VENDOR_ID] [numeric](15, 0) NULL,
	[INVOICE_NUM] [nvarchar](50) NOT NULL,
	[LINE_NUMBER] [float] NOT NULL,
	[INVOICE_DISTRIBUTION_ID] [numeric](15, 0) NOT NULL,
	[INVOICE_DATE] [datetime2](7) NULL,
	[INVOICE_AMOUNT] [float] NULL,
	[LINE_AMOUNT] [float] NOT NULL,
	[AMOUNT_PAID] [float] NULL,
	[APPROVED_AMOUNT] [float] NULL,
	[LINE_TYPE_LOOKUP_CODE] [nvarchar](25) NOT NULL,
	[LINE_SOURCE] [nvarchar](30) NULL,
	[MATCH_TYPE] [nvarchar](25) NULL,
	[CREATION_DATE] [datetime2](7) NULL,
	[QUANTITY_INVOICED] [float] NULL,
	[UNIT_PRICE] [float] NULL,
	[PO_HEADER_ID] [float] NULL,
	[PO_LINE_ID] [float] NULL,
	[PO_LINE_LOCATION_ID] [float] NULL,
	[PO_DISTRIBUTION_ID] [float] NULL,
	[RCV_TRANSACTION_ID] [float] NULL,
	[RCV_SHIPMENT_LINE_ID] [numeric](15, 0) NULL,
	[ITEM] [nvarchar](40) NULL,
	[ACCOUNTING_DATE] [datetime2](7) NOT NULL,
	[AMOUNT] [float] NULL,
	[DESCRIPTION] [nvarchar](240) NULL,
	[ACCOUNT_COMBO] [nvarchar](181) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[APInvoice] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[APInvoice] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
