USE [Operations]
GO
/****** Object:  Table [dbo].[DimHour]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimHour](
	[HourID] [int] NOT NULL,
	[HourName] [varchar](4) NOT NULL,
	[HourDesc] [varchar](15) NOT NULL,
	[HourSort] [varchar](2) NOT NULL,
	[HourBlock] [varchar](9) NOT NULL,
	[HourBlockSort] [varchar](2) NOT NULL,
	[ShiftBlock12Hour] [int] NOT NULL,
	[ShiftBlock8Hour] [int] NOT NULL,
	[CurrentHourtoDate] [bit] NULL,
 CONSTRAINT [PK_DimHour] PRIMARY KEY CLUSTERED 
(
	[HourID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
