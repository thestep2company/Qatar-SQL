USE [Operations]
GO
/****** Object:  Table [xref].[HeadcountTarget]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[HeadcountTarget](
	[PlantID] [varchar](5) NULL,
	[ShiftID] [varchar](5) NULL,
	[Department] [varchar](50) NULL,
	[Headcount] [int] NULL
) ON [PRIMARY]
GO
