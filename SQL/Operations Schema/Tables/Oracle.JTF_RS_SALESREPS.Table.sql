USE [Operations]
GO
/****** Object:  Table [Oracle].[JTF_RS_SALESREPS]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[JTF_RS_SALESREPS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SALESREP_ID] [float] NOT NULL,
	[RESOURCE_ID] [float] NOT NULL,
	[LAST_UPDATE_DATE] [datetime2](7) NOT NULL,
	[LAST_UPDATED_BY] [float] NOT NULL,
	[CREATION_DATE] [datetime2](7) NOT NULL,
	[CREATED_BY] [float] NOT NULL,
	[LAST_UPDATE_LOGIN] [float] NULL,
	[SALES_CREDIT_TYPE_ID] [float] NOT NULL,
	[NAME] [nvarchar](240) NULL,
	[STATUS] [nvarchar](30) NULL,
	[START_DATE_ACTIVE] [datetime2](7) NOT NULL,
	[END_DATE_ACTIVE] [datetime2](7) NULL,
	[GL_ID_REV] [float] NULL,
	[GL_ID_FREIGHT] [float] NULL,
	[GL_ID_REC] [float] NULL,
	[SET_OF_BOOKS_ID] [float] NULL,
	[SALESREP_NUMBER] [nvarchar](30) NULL,
	[ORG_ID] [float] NULL,
	[EMAIL_ADDRESS] [nvarchar](240) NULL,
	[WH_UPDATE_DATE] [datetime2](7) NULL,
	[PERSON_ID] [float] NULL,
	[SALES_TAX_GEOCODE] [nvarchar](30) NULL,
	[SALES_TAX_INSIDE_CITY_LIMITS] [nvarchar](1) NULL,
	[OBJECT_VERSION_NUMBER] [float] NOT NULL,
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
	[SECURITY_GROUP_ID] [float] NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_JTF_RS_SALESREPS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[JTF_RS_SALESREPS] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[JTF_RS_SALESREPS] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
