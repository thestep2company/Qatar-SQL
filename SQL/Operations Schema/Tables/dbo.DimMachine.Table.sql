USE [Operations]
GO
/****** Object:  Table [dbo].[DimMachine]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimMachine](
	[MachineID] [int] IDENTITY(1,1) NOT NULL,
	[LocationKey] [varchar](50) NULL,
	[MachineKey] [varchar](50) NULL,
	[MachineName] [varchar](50) NULL,
	[MachineDesc] [varchar](50) NULL,
	[MachineSort] [varchar](50) NULL,
	[MachineModel] [varchar](3) NULL,
	[MachineNumber] [varchar](50) NULL,
	[MachineCell] [int] NOT NULL,
	[CellPosition] [int] NOT NULL,
	[RoundsPerShift] [int] NULL,
	[CapacityRoundsPerShift] [int] NULL,
 CONSTRAINT [PK_DimMachine] PRIMARY KEY CLUSTERED 
(
	[MachineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
