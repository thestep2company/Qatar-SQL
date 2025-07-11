USE [Operations]
GO
/****** Object:  Table [Oracle].[QualityReceiving]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[QualityReceiving](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PO_HEADER_ID] [float] NOT NULL,
	[PO_LINE_ID] [float] NOT NULL,
	[LINE_LOCATION_ID] [float] NULL,
	[ORG_CODE] [nvarchar](3) NULL,
	[ORG_NAME] [nvarchar](240) NOT NULL,
	[ORGANIZATION_ID] [float] NULL,
	[PACKING_SLIP] [nvarchar](25) NULL,
	[ITEM] [nvarchar](40) NULL,
	[PART_CLASS] [nvarchar](240) NULL,
	[QUANTITY] [float] NULL,
	[DOCUMENT_NUMBER] [nvarchar](143) NULL,
	[PRICE] [float] NULL,
	[SUPPLIER] [nvarchar](240) NULL,
	[TRANSACTION_DATE] [nvarchar](19) NULL,
	[UOM] [nvarchar](25) NULL,
	[RECEIPT_NUMBER] [nvarchar](30) NULL,
	[RECEIVER] [nvarchar](240) NULL,
	[BUYER] [nvarchar](240) NULL,
	[DELIVER_TO] [nvarchar](240) NULL,
	[DESTINATION_TYPE] [nvarchar](80) NOT NULL,
	[DESCRIPTION] [nvarchar](240) NULL,
	[TRANSACTION_TYPE] [nvarchar](80) NOT NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_QualityReceiving] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[QualityReceiving] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[QualityReceiving] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
