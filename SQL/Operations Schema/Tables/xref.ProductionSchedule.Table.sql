USE [Operations]
GO
/****** Object:  Table [xref].[ProductionSchedule]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[ProductionSchedule](
	[ID] [int] NOT NULL,
	[RowID] [int] NULL,
	[Priority] [int] NULL,
	[Current Machine] [varchar](50) NULL,
	[WIPBF] [varchar](50) NULL,
	[12Hr 8Hr] [int] NULL,
	[Mach #] [int] NULL,
	[Product No] [varchar](50) NULL,
	[Desc] [varchar](250) NULL,
	[Type] [int] NULL,
	[Tools] [int] NULL,
	[Sets] [int] NULL,
	[Cumulative # Tools] [int] NULL,
	[Shift Goal] [int] NULL,
	[Comments This Week] [varchar](250) NULL,
	[Comments Next Week] [varchar](250) NULL,
	[Machine] [int] NULL,
	[NSP / Unit] [money] NULL,
	[Wkly Prod @ NSP] [money] NULL,
	[Est Wkly NSP Output / Machine] [money] NULL,
	[File Date] [datetime] NULL
) ON [PRIMARY]
GO
