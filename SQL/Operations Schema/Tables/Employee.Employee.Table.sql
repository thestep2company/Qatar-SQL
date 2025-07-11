USE [Operations]
GO
/****** Object:  Table [Employee].[Employee]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Employee].[Employee](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[INDEX_ID] [int] NOT NULL,
	[FIRST_NAME] [varchar](50) NULL,
	[LAST_NAME] [varchar](50) NULL,
	[SITE] [varchar](25) NULL,
	[LOCATION] [varchar](25) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NULL,
 CONSTRAINT [PK_Employee_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Employee].[Employee] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Employee].[Employee] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
