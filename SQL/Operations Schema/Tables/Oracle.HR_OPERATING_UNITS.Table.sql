USE [Operations]
GO
/****** Object:  Table [Oracle].[HR_OPERATING_UNITS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[HR_OPERATING_UNITS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BUSINESS_GROUP_ID] [numeric](15, 0) NOT NULL,
	[ORGANIZATION_ID] [numeric](15, 0) NOT NULL,
	[NAME] [nvarchar](240) NOT NULL,
	[DATE_FROM] [datetime2](7) NOT NULL,
	[DATE_TO] [datetime2](7) NULL,
	[SHORT_CODE] [nvarchar](150) NULL,
	[SET_OF_BOOKS_ID] [nvarchar](150) NULL,
	[DEFAULT_LEGAL_CONTEXT_ID] [nvarchar](150) NULL,
	[USABLE_FLAG] [nvarchar](150) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_Operating_Units] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[HR_OPERATING_UNITS] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[HR_OPERATING_UNITS] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
