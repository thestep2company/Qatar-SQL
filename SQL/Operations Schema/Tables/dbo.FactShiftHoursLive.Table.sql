USE [Operations]
GO
/****** Object:  Table [dbo].[FactShiftHoursLive]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactShiftHoursLive](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CurrentShiftID] [int] NULL,
	[LocationID] [int] NULL,
	[ShiftOffsetID] [int] NOT NULL,
	[ShiftID] [int] NULL,
	[Start_Date_Time] [datetime] NULL,
	[End_Date_Time] [datetime] NULL,
	[DateID] [int] NULL,
	[TransDate] [date] NULL,
	[Hours] [numeric](30, 17) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
