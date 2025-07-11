USE [Operations]
GO
/****** Object:  Table [Oracle].[BOM_CST_ITEM_COST_DETAILS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[BOM_CST_ITEM_COST_DETAILS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[INVENTORY_ITEM_ID] [float] NOT NULL,
	[ORGANIZATION_ID] [float] NOT NULL,
	[COST_TYPE_ID] [float] NOT NULL,
	[LAST_UPDATE_DATE] [datetime2](7) NOT NULL,
	[LAST_UPDATED_BY] [float] NOT NULL,
	[CREATION_DATE] [datetime2](7) NOT NULL,
	[CREATED_BY] [float] NOT NULL,
	[LAST_UPDATE_LOGIN] [float] NULL,
	[OPERATION_SEQUENCE_ID] [float] NULL,
	[OPERATION_SEQ_NUM] [float] NULL,
	[DEPARTMENT_ID] [float] NULL,
	[LEVEL_TYPE] [float] NOT NULL,
	[ACTIVITY_ID] [float] NULL,
	[RESOURCE_SEQ_NUM] [float] NULL,
	[RESOURCE_ID] [float] NULL,
	[RESOURCE_RATE] [float] NULL,
	[ITEM_UNITS] [float] NULL,
	[ACTIVITY_UNITS] [float] NULL,
	[USAGE_RATE_OR_AMOUNT] [float] NOT NULL,
	[BASIS_TYPE] [float] NOT NULL,
	[BASIS_RESOURCE_ID] [float] NULL,
	[BASIS_FACTOR] [float] NOT NULL,
	[NET_YIELD_OR_SHRINKAGE_FACTOR] [float] NOT NULL,
	[ITEM_COST] [float] NOT NULL,
	[COST_ELEMENT_ID] [float] NULL,
	[ROLLUP_SOURCE_TYPE] [float] NOT NULL,
	[ACTIVITY_CONTEXT] [nvarchar](30) NULL,
	[REQUEST_ID] [float] NULL,
	[PROGRAM_APPLICATION_ID] [float] NULL,
	[PROGRAM_ID] [float] NULL,
	[PROGRAM_UPDATE_DATE] [datetime2](7) NULL,
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
	[YIELDED_COST] [float] NULL,
	[SOURCE_ORGANIZATION_ID] [numeric](15, 0) NULL,
	[VENDOR_ID] [numeric](15, 0) NULL,
	[ALLOCATION_PERCENT] [float] NULL,
	[VENDOR_SITE_ID] [numeric](15, 0) NULL,
	[SHIP_METHOD] [nvarchar](30) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_BOM_CST_ITEM_COST_DETAILS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[BOM_CST_ITEM_COST_DETAILS] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[BOM_CST_ITEM_COST_DETAILS] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
