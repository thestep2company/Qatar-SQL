USE [Operations]
GO
/****** Object:  Table [Oracle].[POExpense]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[POExpense](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PO_HEADER_ID] [float] NOT NULL,
	[PO_NUMBER] [nvarchar](20) NOT NULL,
	[PO_TYPE] [nvarchar](25) NOT NULL,
	[PO_STATUS] [nvarchar](25) NULL,
	[CREATION_DATE] [datetime2](7) NULL,
	[SUPPLIER_NAME] [nvarchar](240) NULL,
	[SUPPLIER_SITE] [nvarchar](15) NULL,
	[LINE_NUM] [float] NOT NULL,
	[LINE_LOCATION] [float] NOT NULL,
	[ITEM_DESCRIPTION] [nvarchar](240) NULL,
	[SHIPMENT_QUANTITY] [float] NULL,
	[DIST_ORDERED_QUANTITY] [float] NULL,
	[DESTINATION_TYPE_CODE] [nvarchar](25) NULL,
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
ALTER TABLE [Oracle].[POExpense] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[POExpense] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
