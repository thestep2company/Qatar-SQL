USE [Operations]
GO
/****** Object:  Table [xref].[DiscontinuedSKU]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[DiscontinuedSKU](
	[Part] [varchar](25) NULL,
	[Description] [varchar](100) NULL,
	[Comments] [varchar](250) NULL,
	[Status] [varchar](250) NULL,
	[Year] [int] NULL,
	[DiscontinuedDate] [date] NULL
) ON [PRIMARY]
GO
