USE [Operations]
GO
/****** Object:  Table [OUTPUT].[CancelHistory]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [OUTPUT].[CancelHistory](
	[Cancel_Reason] [nvarchar](80) NOT NULL,
	[Cancelation Category] [varchar](50) NOT NULL,
	[Canceled By] [nvarchar](100) NULL,
	[LINE_ID] [float] NULL,
	[SELLING_PRICE] [float] NULL,
	[LIST_PRICE] [float] NULL,
	[PRICING_QUANTITY] [float] NULL,
	[HIST_TYPE_CODE] [nvarchar](30) NOT NULL,
	[HIST_CREATION_DATE] [datetime2](7) NULL,
	[ORD_LINE_ID] [float] NOT NULL,
	[ORD_HEADER_ID] [float] NOT NULL,
	[CUSTOMER_NAME] [nvarchar](240) NULL,
	[CUSTOMER_NUM] [nvarchar](30) NOT NULL,
	[SALES_CHANNEL_CODE] [nvarchar](30) NULL,
	[DEMAND_CLASS] [nvarchar](30) NULL,
	[ORDER_DATE] [date] NULL,
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
	[SHIPPING_METHOD_CODE] [nvarchar](30) NULL
) ON [PRIMARY]
GO
