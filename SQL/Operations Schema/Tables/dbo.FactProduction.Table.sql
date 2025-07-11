USE [Operations]
GO
/****** Object:  Table [dbo].[FactProduction]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactProduction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlantID] [int] NULL,
	[ShiftID] [int] NULL,
	[MachineID] [int] NULL,
	[ComponentID] [int] NOT NULL,
	[ProductID] [int] NULL,
	[DateID] [int] NULL,
	[HourID] [int] NULL,
	[CurrentShiftID] [int] NULL,
	[WorkDayID] [int] NULL,
	[ShiftOffsetID] [int] NOT NULL,
	[Production Qty] [int] NULL,
	[List Less 7 %] [real] NULL,
	[Total Dollars] [float] NULL,
	[Standard Cost] [float] NULL,
	[Resource Cost] [float] NULL,
	[Earned Overhead Cost] [float] NULL,
	[Material Cost] [float] NULL,
	[Material Overhead Cost] [float] NULL,
	[Outside Processing Cost] [float] NULL,
	[Required Hours] [real] NULL,
	[Machine Hours] [float] NULL,
	[Total Machine Hours] [float] NULL,
	[Optimal Machine Hours] [float] NULL,
	[Optimal Total Machine Hours] [float] NULL,
	[Standard Hours] [float] NULL,
	[Total Standard Hours] [float] NULL,
	[Roto Oper Earned Cost] [float] NULL,
	[Roto Float Earned Cost] [float] NULL,
	[Total Roto Earned Cost] [float] NULL,
	[Assembly Earned Cost] [float] NULL,
	[Assembly Lead Earned Cost] [float] NULL,
	[Total Assembly Earned Cost] [float] NULL,
	[Total Earned Cost] [float] NULL,
	[Machine Earned Cost] [float] NULL,
	[Roto Oper Earned Hours] [float] NULL,
	[Roto Float Earned Hours] [float] NULL,
	[Total Roto Earned Hours] [float] NULL,
	[Assembly Earned Hours] [float] NULL,
	[Assembly Lead Earned Hours] [float] NULL,
	[Total Assembly Earned Hours] [float] NULL,
	[Total Earned Hours] [float] NULL,
	[Machine Earned Hours] [float] NULL,
	[Spiders Ran] [float] NULL,
	[Total Spiders Ran] [float] NULL,
	[Spider Mix] [float] NULL,
	[Effective Spiders] [float] NULL,
	[ProductionGoal] [float] NULL,
	[RoundsPerShift] [numeric](26, 11) NULL,
	[FG Resign Weight] [real] NULL,
	[FG Total Resin] [float] NULL,
	[Unit Cube] [real] NULL,
	[Total Cube] [float] NULL,
	[Piece Count] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
