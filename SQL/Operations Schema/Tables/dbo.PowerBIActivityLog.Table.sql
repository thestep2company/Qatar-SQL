USE [Operations]
GO
/****** Object:  Table [dbo].[PowerBIActivityLog]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PowerBIActivityLog](
	[GUID] [varchar](50) NULL,
	[CreationTime] [datetime] NULL,
	[Workload] [varchar](50) NULL,
	[UserID] [varchar](50) NULL,
	[Activity] [varchar](50) NULL,
	[ItemName] [varchar](255) NULL,
	[WorkSpaceName] [varchar](255) NULL,
	[DatasetName] [varchar](500) NULL,
	[ReportName] [varchar](500) NULL,
	[WorkspaceId] [varchar](50) NULL,
	[ObjectId] [varchar](500) NULL,
	[DatasetId] [varchar](50) NULL,
	[ReportId] [varchar](50) NULL,
	[ReportType] [varchar](50) NULL,
	[DistributionMethod] [varchar](50) NULL,
	[ConsumptionMethod] [varchar](50) NULL,
	[Import_Timestamp] [datetime] NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PowerBIActivityLog] ADD  DEFAULT (getdate()) FOR [Import_Timestamp]
GO
