USE [Operations]
GO
/****** Object:  Table [dbo].[FactShiftLength]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactShiftLength](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateID] [int] NULL,
	[DateKey] [date] NULL,
	[PlantID] [int] NULL,
	[ShiftID] [int] NULL,
	[ShiftOffsetID] [int] NOT NULL,
	[MachineID] [int] NULL,
	[MachineTime] [numeric](29, 12) NULL,
	[Start_Date_Time] [datetime] NULL,
	[End_Date_Time] [datetime] NULL,
	[ShiftLength] [int] NULL,
	[Breaks] [int] NOT NULL,
	[Holiday] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
