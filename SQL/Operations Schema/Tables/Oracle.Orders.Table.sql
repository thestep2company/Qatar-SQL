USE [Operations]
GO
/****** Object:  Table [Oracle].[Orders]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[Orders](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ORD_LINE_ID] [float] NOT NULL,
	[ORD_HEADER_ID] [float] NOT NULL,
	[CUSTOMER_NAME] [nvarchar](240) NULL,
	[CUSTOMER_NUM] [nvarchar](30) NOT NULL,
	[SALES_CHANNEL_CODE] [nvarchar](30) NULL,
	[DEMAND_CLASS] [nvarchar](30) NULL,
	[ORDER_DATE] [nvarchar](19) NULL,
	[ORDER_NUM] [float] NOT NULL,
	[PART] [nvarchar](40) NULL,
	[ORDERED_ITEM] [nvarchar](2000) NULL,
	[PART_DESC] [nvarchar](240) NULL,
	[FLOW_STATUS_CODE] [nvarchar](30) NULL,
	[QTY] [float] NULL,
	[SELL_DOLLARS] [float] NULL,
	[LIST_DOLLARS] [float] NULL,
	[DATE_REQUESTED] [nvarchar](10) NULL,
	[SCH_SHIP_DATE] [nvarchar](10) NULL,
	[CANCEL_DATE] [nvarchar](10) NULL,
	[PLANT] [nvarchar](3) NULL,
	[CREATE_DATE] [nvarchar](10) NULL,
	[ORD_LINE_CREATE_DATE] [nvarchar](10) NULL,
	[ORD_LINE_LST_UPDATE_DATE] [nvarchar](10) NULL,
	[SHIP_TO_ADDRESS1] [nvarchar](240) NULL,
	[SHIP_TO_ADDRESS2] [nvarchar](240) NULL,
	[SHIP_TO_ADDRESS3] [nvarchar](240) NULL,
	[SHIP_TO_ADDRESS4] [nvarchar](240) NULL,
	[SHIP_TO_CITY] [nvarchar](60) NULL,
	[SHIP_TO_STATE] [nvarchar](60) NULL,
	[SHIP_TO_POSTAL_CODE] [nvarchar](60) NULL,
	[SHIP_TO_COUNTRY] [nvarchar](60) NULL,
	[SHIP_TO_PROVINCE] [nvarchar](60) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
	[ACTUAL_SHIPMENT_DATE] [nvarchar](10) NULL,
	[ORDER_LINE_NUM] [float] NULL,
	[SHIPPING_METHOD_CODE] [nvarchar](30) NULL,
	[Currency] [nvarchar](15) NULL,
	[CUST_PO_NUMBER] [varchar](50) NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [CUSTOMER_NUM_CurrentRecord_Includes]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [CUSTOMER_NUM_CurrentRecord_Includes] ON [Oracle].[Orders]
(
	[CUSTOMER_NUM] ASC,
	[CurrentRecord] ASC
)
INCLUDE([ORDER_DATE]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Orders_DemandClass]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Orders_DemandClass] ON [Oracle].[Orders]
(
	[CurrentRecord] ASC,
	[DEMAND_CLASS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Orders_FlowStatusCode]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Orders_FlowStatusCode] ON [Oracle].[Orders]
(
	[ORD_LINE_ID] ASC,
	[FLOW_STATUS_CODE] ASC,
	[CurrentRecord] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[Orders] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[Orders] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
