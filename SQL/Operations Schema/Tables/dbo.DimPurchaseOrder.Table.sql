USE [Operations]
GO
/****** Object:  Table [dbo].[DimPurchaseOrder]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimPurchaseOrder](
	[POID] [int] IDENTITY(1,1) NOT NULL,
	[PO_NUMBER] [nvarchar](20) NOT NULL,
	[LINE_NUMBER] [float] NOT NULL,
	[SHIPMENT_LINE_NUMBER] [float] NULL,
	[PO_HEADER_ID] [float] NOT NULL,
	[PO_LINE_ID] [float] NOT NULL,
	[LINE_LOCATION_ID] [float] NULL,
	[BuyerID] [bigint] NULL,
	[VendorDesc] [varchar](100) NULL,
	[POStatusID] [bigint] NULL,
	[POTypeID] [bigint] NULL,
	[HEADER_CLOSED_CODE] [bigint] NULL,
	[LINE_CLOSED_CODE] [bigint] NULL,
	[CLOSED_CODE] [bigint] NULL,
	[SHIP_TO] [nvarchar](60) NULL,
	[BILL_TO] [nvarchar](60) NULL,
	[NOTE_TO_VENDOR] [nvarchar](480) NULL,
	[PO_CREATE_DATE] [date] NULL,
	[PO_LINE_CREATE_DATE] [date] NULL,
	[NEED_BY_DATE] [date] NULL,
	[PROMISED_DATE] [date] NULL,
	[PO_LINE_CANCEL_DATE] [date] NULL,
	[CANCEL_DATE] [date] NULL,
	[POCodeID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[POID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
