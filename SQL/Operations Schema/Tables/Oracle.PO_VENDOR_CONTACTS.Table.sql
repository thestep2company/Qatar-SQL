USE [Operations]
GO
/****** Object:  Table [Oracle].[PO_VENDOR_CONTACTS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[PO_VENDOR_CONTACTS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VENDOR_CONTACT_ID] [float] NULL,
	[VENDOR_SITE_ID] [float] NULL,
	[LAST_UPDATE_DATE] [datetime2](7) NULL,
	[LAST_UPDATED_BY] [float] NULL,
	[LAST_UPDATE_LOGIN] [float] NULL,
	[CREATION_DATE] [datetime2](7) NULL,
	[CREATED_BY] [float] NULL,
	[FIRST_NAME] [nvarchar](45) NULL,
	[MIDDLE_NAME] [nvarchar](45) NULL,
	[LAST_NAME] [nvarchar](45) NULL,
	[PREFIX] [nvarchar](60) NULL,
	[TITLE] [nvarchar](90) NULL,
	[MAIL_STOP] [nvarchar](60) NULL,
	[AREA_CODE] [nvarchar](10) NULL,
	[PHONE] [nvarchar](40) NULL,
	[REQUEST_ID] [float] NULL,
	[PROGRAM_APPLICATION_ID] [float] NULL,
	[PROGRAM_ID] [float] NULL,
	[PROGRAM_UPDATE_DATE] [datetime2](7) NULL,
	[CONTACT_NAME_ALT] [nvarchar](320) NULL,
	[FIRST_NAME_ALT] [nvarchar](60) NULL,
	[LAST_NAME_ALT] [nvarchar](60) NULL,
	[DEPARTMENT] [nvarchar](60) NULL,
	[EMAIL_ADDRESS] [nvarchar](2000) NULL,
	[URL] [nvarchar](2000) NULL,
	[ALT_AREA_CODE] [nvarchar](10) NULL,
	[ALT_PHONE] [nvarchar](40) NULL,
	[FAX_AREA_CODE] [nvarchar](10) NULL,
	[FAX] [nvarchar](40) NULL,
	[INACTIVE_DATE] [datetime2](7) NULL,
	[PER_PARTY_ID] [numeric](15, 0) NULL,
	[RELATIONSHIP_ID] [numeric](15, 0) NULL,
	[REL_PARTY_ID] [numeric](15, 0) NULL,
	[PARTY_SITE_ID] [numeric](15, 0) NULL,
	[ORG_CONTACT_ID] [numeric](15, 0) NULL,
	[ORG_PARTY_SITE_ID] [numeric](15, 0) NULL,
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
	[VENDOR_ID] [float] NULL,
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
ALTER TABLE [Oracle].[PO_VENDOR_CONTACTS] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[PO_VENDOR_CONTACTS] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
