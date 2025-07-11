USE [Operations]
GO
/****** Object:  Table [MachineData].[MachineIndex]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MachineData].[MachineIndex](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RECNUM] [int] NOT NULL,
	[LogDateTime] [datetime] NULL,
	[DataType] [varchar](6) NULL,
	[MachineLocation] [int] NULL,
	[MachineNumber] [int] NULL,
	[MachineSize] [int] NULL,
	[Operator] [int] NULL,
	[ArmNumber] [int] NULL,
	[SQNumber_A] [varchar](6) NULL,
	[SQNumber_B] [varchar](6) NULL,
	[CycleTimeSetPoint] [varchar](8) NULL,
	[ActualWorkTime] [varchar](8) NULL,
	[ActualTimeInOven] [varchar](8) NULL,
	[CookCount] [int] NULL,
	[DeadArmCount] [int] NULL,
	[MissedCycleCount] [int] NULL,
	[ReasonCodeMissed] [int] NULL,
	[MissTimeTotal] [varchar](8) NULL,
	[Shift] [varchar](1) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
	[SHIFT_ID] [int] NULL,
 CONSTRAINT [PK_Index] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [MachineData].[MachineIndex] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [MachineData].[MachineIndex] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
