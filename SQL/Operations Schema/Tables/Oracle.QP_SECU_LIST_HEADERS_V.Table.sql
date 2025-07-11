USE [Operations]
GO
/****** Object:  Table [Oracle].[QP_SECU_LIST_HEADERS_V]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[QP_SECU_LIST_HEADERS_V](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ROW_ID] [varchar](50) NULL,
	[CONTEXT] [nvarchar](30) NULL,
	[ATTRIBUTE1] [nvarchar](240) NULL,
	[ATTRIBUTE2] [nvarchar](240) NULL,
	[ATTRIBUTE3] [nvarchar](240) NULL,
	[ATTRIBUTE4] [nvarchar](240) NULL,
	[ATTRIBUTE5] [nvarchar](240) NULL,
	[ATTRIBUTE6] [nvarchar](240) NULL,
	[ATTRIBUTE7] [nvarchar](240) NULL,
	[ATTRIBUTE8] [nvarchar](240) NULL,
	[ATTRIBUTE9] [nvarchar](240) NULL,
	[ATTRIBUTE10] [nvarchar](240) NULL,
	[ATTRIBUTE11] [nvarchar](240) NULL,
	[ATTRIBUTE12] [nvarchar](240) NULL,
	[ATTRIBUTE13] [nvarchar](240) NULL,
	[ATTRIBUTE14] [nvarchar](240) NULL,
	[ATTRIBUTE15] [nvarchar](240) NULL,
	[CURRENCY_CODE] [nvarchar](30) NULL,
	[SHIP_METHOD_CODE] [nvarchar](30) NULL,
	[FREIGHT_TERMS_CODE] [nvarchar](30) NULL,
	[LIST_HEADER_ID] [float] NOT NULL,
	[CREATION_DATE] [datetime2](7) NOT NULL,
	[START_DATE_ACTIVE] [datetime2](7) NULL,
	[END_DATE_ACTIVE] [datetime2](7) NULL,
	[AUTOMATIC_FLAG] [nvarchar](1) NULL,
	[LIST_TYPE_CODE] [nvarchar](30) NOT NULL,
	[TERMS_ID] [float] NULL,
	[ROUNDING_FACTOR] [float] NULL,
	[REQUEST_ID] [float] NULL,
	[CREATED_BY] [float] NOT NULL,
	[LAST_UPDATE_DATE] [datetime2](7) NOT NULL,
	[LAST_UPDATED_BY] [float] NOT NULL,
	[LAST_UPDATE_LOGIN] [float] NULL,
	[PROGRAM_APPLICATION_ID] [float] NULL,
	[PROGRAM_ID] [float] NULL,
	[PROGRAM_UPDATE_DATE] [datetime2](7) NULL,
	[DISCOUNT_LINES_FLAG] [nvarchar](1) NULL,
	[NAME] [nvarchar](240) NOT NULL,
	[DESCRIPTION] [nvarchar](2000) NULL,
	[COMMENTS] [nvarchar](2000) NULL,
	[GSA_INDICATOR] [nvarchar](1) NULL,
	[PRORATE_FLAG] [nvarchar](30) NULL,
	[SOURCE_SYSTEM_CODE] [nvarchar](30) NULL,
	[VERSION_NO] [nvarchar](30) NULL,
	[ACTIVE_FLAG] [nvarchar](1) NULL,
	[MOBILE_DOWNLOAD] [nvarchar](1) NULL,
	[CURRENCY_HEADER_ID] [float] NULL,
	[PTE_CODE] [nvarchar](30) NULL,
	[LIST_SOURCE_CODE] [nvarchar](30) NULL,
	[ORIG_SYSTEM_HEADER_REF] [nvarchar](50) NULL,
	[GLOBAL_FLAG] [nvarchar](1) NULL,
	[ORIG_ORG_ID] [float] NULL,
	[VIEW_FLAG] [nchar](1) NULL,
	[UPDATE_FLAG] [nchar](1) NULL,
	[SHAREABLE_FLAG] [nvarchar](1) NULL,
	[SOLD_TO_ORG_ID] [float] NULL,
	[LIMIT_EXISTS_FLAG] [nvarchar](1) NULL,
	[LOCKED_FROM_LIST_HEADER_ID] [float] NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_QP_SECU_LIST_HEADERS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[QP_SECU_LIST_HEADERS_V] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[QP_SECU_LIST_HEADERS_V] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
