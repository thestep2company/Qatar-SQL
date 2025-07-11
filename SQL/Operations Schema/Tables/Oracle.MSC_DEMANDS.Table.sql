USE [Operations]
GO
/****** Object:  Table [Oracle].[MSC_DEMANDS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[MSC_DEMANDS](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[DEMAND_ID] [float] NOT NULL,
	[ITEM_NAME] [nvarchar](250) NULL,
	[DESCRIPTION] [nvarchar](240) NULL,
	[START_OF_WEEK] [datetime2](7) NULL,
	[USING_ASSEMBLY_DEMAND_DATE] [datetime2](7) NOT NULL,
	[USING_REQUIREMENT_QUANTITY] [float] NOT NULL,
	[ORGANIZATION_ID] [float] NOT NULL,
	[SOURCE_ORGANIZATION_ID] [float] NULL,
	[DEMAND_TYPE] [float] NOT NULL,
	[ORIGINATION_TYPE] [float] NULL,
	[DEMAND_PRIORITY] [float] NULL,
	[PLAN_ID] [float] NOT NULL,
	[PROMISE_DATE] [datetime2](7) NULL,
	[DEMAND_CLASS] [nvarchar](34) NULL,
	[FIRM_DATE] [datetime2](7) NULL,
	[ROW_ID] [varchar](50) NOT NULL,
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
ALTER TABLE [Oracle].[MSC_DEMANDS] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[MSC_DEMANDS] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
