USE [Operations]
GO
/****** Object:  Table [xref].[MachineCell]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[MachineCell](
	[MachineNumber] [varchar](25) NULL,
	[Cell] [int] NULL,
	[Position] [int] NULL,
	[Plant] [varchar](5) NULL
) ON [PRIMARY]
GO
