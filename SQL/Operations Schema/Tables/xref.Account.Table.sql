USE [Operations]
GO
/****** Object:  Table [xref].[Account]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[Account](
	[AccountID] [varchar](10) NULL,
	[AccountName] [varchar](50) NULL,
	[AccountCombo] [varchar](50) NULL,
	[Level1] [varchar](50) NULL,
	[Level2] [varchar](50) NULL,
	[Level3] [varchar](50) NULL,
	[Level4] [varchar](50) NULL,
	[Level2Sort] [varchar](10) NULL,
	[ReportSign] [int] NULL,
	[Sign] [int] NULL,
	[Level3Sort] [varchar](10) NULL,
	[Level4Sort] [varchar](10) NULL
) ON [PRIMARY]
GO
