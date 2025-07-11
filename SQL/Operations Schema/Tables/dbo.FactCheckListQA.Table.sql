USE [Operations]
GO
/****** Object:  Table [dbo].[FactCheckListQA]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactCheckListQA](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LocationID] [int] NULL,
	[MachineID] [int] NULL,
	[ProductID] [int] NULL,
	[DateID] [int] NULL,
	[SaveDate] [date] NULL,
	[TEST_NUMBER] [int] NOT NULL,
	[CHECK_NUMBER] [varchar](10) NULL,
	[Test] [varchar](max) NULL,
	[CHECK_VALUE] [varchar](20) NULL,
	[INSPECTOR] [varchar](50) NULL,
	[RESULTS_COMMENTS] [varchar](max) NULL,
 CONSTRAINT [PK_FactCheckListQA] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
