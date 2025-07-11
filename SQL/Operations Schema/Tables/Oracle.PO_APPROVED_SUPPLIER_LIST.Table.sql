USE [Operations]
GO
/****** Object:  Table [Oracle].[PO_APPROVED_SUPPLIER_LIST]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[PO_APPROVED_SUPPLIER_LIST](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ASL_ID] [float] NOT NULL,
	[USING_ORGANIZATION_ID] [float] NOT NULL,
	[OWNING_ORGANIZATION_ID] [float] NOT NULL,
	[VENDOR_BUSINESS_TYPE] [nvarchar](25) NOT NULL,
	[ASL_STATUS_ID] [float] NOT NULL,
	[LAST_UPDATE_DATE] [datetime2](7) NOT NULL,
	[LAST_UPDATED_BY] [float] NOT NULL,
	[CREATION_DATE] [datetime2](7) NOT NULL,
	[CREATED_BY] [float] NOT NULL,
	[MANUFACTURER_ID] [float] NULL,
	[VENDOR_ID] [float] NULL,
	[ITEM_ID] [float] NULL,
	[CATEGORY_ID] [float] NULL,
	[VENDOR_SITE_ID] [float] NULL,
	[PRIMARY_VENDOR_ITEM] [nvarchar](25) NULL,
	[MANUFACTURER_ASL_ID] [float] NULL,
	[REVIEW_BY_DATE] [datetime2](7) NULL,
	[COMMENTS] [nvarchar](240) NULL,
	[ATTRIBUTE_CATEGORY] [nvarchar](30) NULL,
	[ATTRIBUTE1] [nvarchar](150) NULL,
	[ATTRIBUTE2] [nvarchar](150) NULL,
	[ATTRIBUTE3] [nvarchar](150) NULL,
	[ATTRIBUTE4] [nvarchar](150) NULL,
	[ATTRIBUTE5] [nvarchar](150) NULL,
	[ATTRIBUTE6] [nvarchar](150) NULL,
	[ATTRIBUTE7] [nvarchar](150) NULL,
	[ATTRIBUTE8] [nvarchar](150) NULL,
	[ATTRIBUTE9] [nvarchar](150) NULL,
	[ATTRIBUTE10] [nvarchar](150) NULL,
	[ATTRIBUTE11] [nvarchar](150) NULL,
	[ATTRIBUTE12] [nvarchar](150) NULL,
	[ATTRIBUTE13] [nvarchar](150) NULL,
	[ATTRIBUTE14] [nvarchar](150) NULL,
	[ATTRIBUTE15] [nvarchar](150) NULL,
	[LAST_UPDATE_LOGIN] [float] NULL,
	[REQUEST_ID] [float] NULL,
	[PROGRAM_APPLICATION_ID] [float] NULL,
	[PROGRAM_ID] [float] NULL,
	[PROGRAM_UPDATE_DATE] [datetime2](7) NULL,
	[DISABLE_FLAG] [nvarchar](1) NULL,
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
ALTER TABLE [Oracle].[PO_APPROVED_SUPPLIER_LIST] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[PO_APPROVED_SUPPLIER_LIST] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
