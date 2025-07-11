USE [Operations]
GO
/****** Object:  Table [Oracle].[InvoicePriceVariance]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[InvoicePriceVariance](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LEDGER] [nvarchar](30) NULL,
	[PERIOD_NAME] [nvarchar](15) NULL,
	[OPERATING_UNIT] [nvarchar](240) NULL,
	[ORGANIZATION_CODE] [nvarchar](3) NULL,
	[PO_HEADER_ID] [float] NOT NULL,
	[PO_LINE_ID] [float] NOT NULL,
	[LINE_LOCATION_ID] [float] NOT NULL,
	[INVOICE_NUM] [nvarchar](50) NULL,
	[INVOICE_DATE] [datetime2](7) NULL,
	[ACCOUNTING_DATE] [datetime2](7) NULL,
	[CATEGORY] [nvarchar](245) NULL,
	[ITEM] [nvarchar](40) NULL,
	[ITEM_DESCRIPTION] [nvarchar](240) NULL,
	[VARIANCE_ACCOUNT] [nvarchar](181) NULL,
	[CHARGE_ACCOUNT] [nvarchar](181) NULL,
	[INVOICE_RATE] [float] NULL,
	[INVOICE_AMOUNT] [float] NULL,
	[INVOICE_PRICE] [float] NULL,
	[QUANTITY_INVOICED] [float] NULL,
	[PO_RATE] [float] NULL,
	[PO_PRICE] [float] NULL,
	[AMOUNT_BILLED] [float] NULL,
	[RECEIPT_UNIT] [nvarchar](25) NULL,
	[VENDOR] [nvarchar](240) NULL,
	[PO_NUMBER_RELEASE] [nvarchar](63) NULL,
	[CURRENCY] [nvarchar](15) NULL,
	[INVOICE_CURRENCY] [nvarchar](15) NULL,
	[LINE_NUM] [float] NOT NULL,
	[UNIT] [nvarchar](25) NULL,
	[LOCATION] [nvarchar](60) NULL,
	[LINE_AMOUNT] [float] NULL,
	[EX_RATE_VARI] [float] NULL,
	[BASE_PRICE_VARI] [float] NULL,
	[PRICE_VARI] [float] NULL,
	[ITEM_ID] [float] NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_InvoicePriceVariance] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[InvoicePriceVariance] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[InvoicePriceVariance] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
