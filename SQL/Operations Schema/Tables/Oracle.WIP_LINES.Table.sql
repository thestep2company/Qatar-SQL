USE [Operations]
GO
/****** Object:  Table [Oracle].[WIP_LINES]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[WIP_LINES](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LINE_ID] [float] NOT NULL,
	[ORGANIZATION_ID] [float] NOT NULL,
	[LAST_UPDATE_DATE] [datetime2](7) NOT NULL,
	[LAST_UPDATED_BY] [float] NOT NULL,
	[CREATION_DATE] [datetime2](7) NOT NULL,
	[CREATED_BY] [float] NOT NULL,
	[LAST_UPDATE_LOGIN] [float] NULL,
	[LINE_CODE] [nvarchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](240) NULL,
	[DISABLE_DATE] [datetime2](7) NULL,
	[MINIMUM_RATE] [float] NOT NULL,
	[MAXIMUM_RATE] [float] NOT NULL,
	[FIXED_THROUGHPUT] [float] NULL,
	[LINE_SCHEDULE_TYPE] [float] NOT NULL,
	[SCHEDULING_METHOD_ID] [float] NULL,
	[START_TIME] [float] NOT NULL,
	[STOP_TIME] [float] NOT NULL,
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
	[ATP_RULE_ID] [float] NULL,
	[EXCEPTION_SET_NAME] [nvarchar](10) NULL,
	[SEQ_DIRECTION] [float] NULL,
	[SEQ_CONNECT_FLAG] [nvarchar](1) NULL,
	[SEQ_FIX_SEQUENCE_TYPE] [float] NULL,
	[SEQ_FIX_SEQUENCE_AMOUNT] [float] NULL,
	[SEQ_DEFAULT_RULE_ID] [float] NULL,
	[SEQ_COMBINE_SCHEDULE_FLAG] [nvarchar](1) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_WIP_Lines] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[WIP_LINES] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[WIP_LINES] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
