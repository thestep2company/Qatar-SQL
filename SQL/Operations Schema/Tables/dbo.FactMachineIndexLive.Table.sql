USE [Operations]
GO
/****** Object:  Table [dbo].[FactMachineIndexLive]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactMachineIndexLive](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateID] [int] NULL,
	[HourID] [int] NULL,
	[PlantID] [int] NULL,
	[ProductAID] [int] NOT NULL,
	[ProductBID] [int] NOT NULL,
	[ShiftID] [int] NULL,
	[MachineID] [int] NULL,
	[OperatorID] [int] NOT NULL,
	[ReasonID] [bigint] NULL,
	[ShiftOffsetID] [int] NOT NULL,
	[CycleCount] [int] NULL,
	[MissedCycle] [int] NULL,
	[EmptyCycle] [int] NULL,
	[CycleTime] [numeric](17, 6) NULL,
	[IndexTime] [numeric](38, 6) NULL,
	[MissedTime] [numeric](17, 6) NULL,
	[MadeTime] [numeric](17, 6) NULL,
	[OvenTime] [numeric](17, 6) NULL,
	[TotalTime] [numeric](38, 6) NULL,
	[CurrentShiftID] [int] NULL,
 CONSTRAINT [PK_FactMachineIndexLive] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
