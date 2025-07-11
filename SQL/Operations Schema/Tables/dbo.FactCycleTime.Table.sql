USE [Operations]
GO
/****** Object:  Table [dbo].[FactCycleTime]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactCycleTime](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RecNum] [int] NULL,
	[DateID] [int] NULL,
	[HourID] [int] NULL,
	[PlantID] [int] NULL,
	[ComponentID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ShiftID] [int] NULL,
	[MachineID] [int] NULL,
	[OperatorID] [bigint] NULL,
	[ReasonID] [bigint] NULL,
	[ShiftOffsetID] [int] NOT NULL,
	[CurrentShiftID] [int] NULL,
	[MISSED_CYCLE] [int] NULL,
	[EMPTY_CYCLE] [int] NULL,
	[CYCLE_COUNT] [int] NULL,
	[MISSED_TIME] [numeric](20, 7) NULL,
	[CYCLE_TIME] [numeric](20, 7) NULL,
	[INDEX_TIME] [numeric](38, 6) NULL,
	[CAPACITY] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
