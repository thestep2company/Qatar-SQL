USE [Operations]
GO
/****** Object:  Table [Oracle].[PurchaseOrder]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[PurchaseOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PO_HEADER_ID] [float] NOT NULL,
	[PO_LINE_ID] [float] NOT NULL,
	[LINE_NUMBER] [float] NOT NULL,
	[SHIPMENT_LINE_NUMBER] [float] NULL,
	[LINE_LOCATION_ID] [float] NULL,
	[SUPPLIER_NAME] [nvarchar](240) NULL,
	[VENDOR_SITE] [nvarchar](45) NULL,
	[VENDOR_ID] [float] NULL,
	[PO_NUMBER] [nvarchar](20) NOT NULL,
	[PO_TYPE] [nvarchar](25) NOT NULL,
	[PO_CREATE_DATE] [datetime2](7) NULL,
	[PO_LINE_CREATE_DATE] [datetime2](7) NULL,
	[PO_STATUS] [nvarchar](25) NULL,
	[BUYER_NAME] [nvarchar](240) NULL,
	[SHIP_TO] [nvarchar](60) NULL,
	[BILL_TO] [nvarchar](60) NULL,
	[ITEM] [nvarchar](40) NULL,
	[ITEM_DESCRIPTION] [nvarchar](240) NULL,
	[ITEM_TYPE] [nvarchar](30) NULL,
	[UNIT_PRICE] [float] NULL,
	[ORDER_QUANTITY] [float] NULL,
	[QUANTITY_RECEIVED] [float] NULL,
	[QUANTITY_CANCELLED] [float] NULL,
	[REMAINING_QUANTITY] [float] NULL,
	[NEED_BY_DATE] [datetime2](7) NULL,
	[PROMISED_DATE] [datetime2](7) NULL,
	[HEADER_CLOSED_CODE] [nvarchar](25) NULL,
	[LINE_CLOSED_CODE] [nvarchar](25) NULL,
	[NOTE_TO_VENDOR] [nvarchar](480) NULL,
	[ORDER_TOTAL] [float] NULL,
	[CLOSED_CODE] [nvarchar](30) NULL,
	[PO_LINE_CANCEL_FLAG] [nvarchar](1) NULL,
	[PO_LINE_CANCEL_DATE] [datetime2](7) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_PurchaseOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[PurchaseOrder] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[PurchaseOrder] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
