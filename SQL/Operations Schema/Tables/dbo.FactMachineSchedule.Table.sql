USE [Operations]
GO
/****** Object:  Table [dbo].[FactMachineSchedule]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactMachineSchedule](
	[MachineScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[DateID] [int] NOT NULL,
	[ShiftID] [int] NOT NULL,
	[MachineID] [int] NOT NULL,
	[LocationID] [int] NOT NULL,
 CONSTRAINT [PK_FactMachineSchedule] PRIMARY KEY CLUSTERED 
(
	[MachineScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
