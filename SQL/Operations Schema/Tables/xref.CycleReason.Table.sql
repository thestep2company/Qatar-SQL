USE [Operations]
GO
/****** Object:  Table [xref].[CycleReason]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[CycleReason](
	[ReasonKey] [varchar](10) NULL,
	[ReasonName] [varchar](50) NULL,
	[ReasonCategory] [varchar](250) NULL
) ON [PRIMARY]
GO
