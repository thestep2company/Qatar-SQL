USE [Operations]
GO
/****** Object:  Table [dbo].[FactScrapLive]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactScrapLive](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlantID] [int] NULL,
	[ShiftID] [int] NULL,
	[MachineID] [int] NULL,
	[ComponentID] [int] NULL,
	[ProductID] [int] NULL,
	[RepairID] [int] NULL,
	[RepairReasonID] [int] NULL,
	[DateID] [int] NULL,
	[HourID] [int] NULL,
	[CurrentShiftID] [int] NULL,
	[ShiftOffsetID] [int] NOT NULL,
	[UserName] [nvarchar](100) NOT NULL,
	[ErrorKey] [nvarchar](150) NULL,
	[PigmentKey] [nvarchar](150) NULL,
	[Qty] [float] NULL,
	[Lbs] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
