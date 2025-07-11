USE [XREF]
GO
/****** Object:  Table [dbo].[CycleReason]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CycleReason](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReasonKey] [varchar](10) NULL,
	[ReasonName] [varchar](50) NULL,
	[ReasonCategory] [varchar](250) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
