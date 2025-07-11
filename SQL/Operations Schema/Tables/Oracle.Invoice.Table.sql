USE [Operations]
GO
/****** Object:  Table [Oracle].[Invoice]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[Invoice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[REVENUE_TYPE] [nvarchar](15) NULL,
	[CUSTOMER_TRX_ID] [nvarchar](15) NULL,
	[CUSTOMER_TRX_LINE_ID] [nvarchar](15) NULL,
	[SALES_CHANNEL_CODE] [nvarchar](30) NULL,
	[CUST_GROUP] [nvarchar](150) NULL,
	[DEM_CLASS] [nvarchar](30) NULL,
	[BUSINESS_SEGMENT] [nvarchar](150) NULL,
	[FINANCE_CHANNEL] [nvarchar](150) NULL,
	[ACCT_NUM] [nvarchar](30) NULL,
	[ACCT_NAME] [nvarchar](240) NULL,
	[SHIP_TO_ADDRESS1] [nvarchar](240) NULL,
	[SHIP_TO_ADDRESS2] [nvarchar](240) NULL,
	[SHIP_TO_ADDRESS3] [nvarchar](240) NULL,
	[SHIP_TO_ADDRESS4] [nvarchar](240) NULL,
	[SHIP_TO_CITY] [nvarchar](60) NULL,
	[SHIP_TO_STATE] [nvarchar](60) NULL,
	[SHIP_TO_POSTAL_CODE] [nvarchar](60) NULL,
	[SHIP_TO_COUNTRY] [nvarchar](60) NULL,
	[SHIP_TO_PROVINCE] [nvarchar](60) NULL,
	[CUST_PO_NUM] [nvarchar](50) NULL,
	[ORDER_NUM] [int] NULL,
	[SO_LINE_NUM] [int] NULL,
	[AR_TYPE] [nvarchar](30) NULL,
	[CONSOL_INV] [int] NULL,
	[TRX_NUMBER] [nvarchar](20) NULL,
	[SKU] [nvarchar](30) NULL,
	[INV_DESCRIPTION] [nvarchar](240) NULL,
	[ITEM_TYPE] [nvarchar](30) NULL,
	[SIOP_FAMILY] [nvarchar](30) NULL,
	[CATEGORY] [nvarchar](30) NULL,
	[SUBCATEGORY] [nvarchar](30) NULL,
	[INVENTORY_ITEM_STATUS_CODE] [nvarchar](30) NULL,
	[WH_CODE] [nvarchar](3) NULL,
	[ITEM_FROZEN_COST] [money] NULL,
	[GL_PERIOD] [nvarchar](30) NULL,
	[PERIOD_NUM] [int] NULL,
	[PERIOD_YEAR] [int] NULL,
	[GL_DATE] [datetime] NULL,
	[QTY_INVOICED] [int] NULL,
	[UOM] [nvarchar](15) NULL,
	[GL_REVENUE_DISTRIBUTION] [nvarchar](30) NULL,
	[ENTERED_AMOUNT] [money] NULL,
	[CURRENCY] [nvarchar](15) NULL,
	[ACCTD_USD] [money] NULL,
	[GL_COGS_DISTRIBUTION] [nvarchar](30) NULL,
	[COGS_AMOUNT] [money] NULL,
	[MARGIN_USD] [money] NULL,
	[MARGIN_PCT] [float] NULL,
	[SO_LINE_ID] [varchar](150) NULL,
	[FRZ_COST] [float] NULL,
	[FRZ_MAT_COST] [float] NULL,
	[FRZ_MAT_OH] [float] NULL,
	[FRZ_RESOUCE] [float] NULL,
	[FRZ_OUT_PROC] [float] NULL,
	[FRZ_OH] [float] NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
	[REPORTING_REVENUE_TYPE] [varchar](50) NULL,
	[COGS] [money] NULL,
 CONSTRAINT [PK_Invoice] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Invoice_DemandClass]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Invoice_DemandClass] ON [Oracle].[Invoice]
(
	[CurrentRecord] ASC,
	[DEM_CLASS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Invoice_Geography]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Invoice_Geography] ON [Oracle].[Invoice]
(
	[CurrentRecord] ASC
)
INCLUDE([SHIP_TO_STATE],[SHIP_TO_POSTAL_CODE],[SHIP_TO_COUNTRY],[SHIP_TO_PROVINCE]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Invoice_GL_Date]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Invoice_GL_Date] ON [Oracle].[Invoice]
(
	[GL_DATE] ASC,
	[StartDate] ASC
)
INCLUDE([CUSTOMER_TRX_LINE_ID],[ENTERED_AMOUNT],[ACCTD_USD],[COGS_AMOUNT]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Invoice_OrderNumLine]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Invoice_OrderNumLine] ON [Oracle].[Invoice]
(
	[REVENUE_TYPE] ASC,
	[ORDER_NUM] ASC,
	[SO_LINE_NUM] ASC,
	[CurrentRecord] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Invoice_RevenueType]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Invoice_RevenueType] ON [Oracle].[Invoice]
(
	[CurrentRecord] ASC
)
INCLUDE([REVENUE_TYPE]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[Invoice] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[Invoice] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
