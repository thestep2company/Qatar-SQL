USE [Operations]
GO
/****** Object:  Table [dbo].[CalendarFiscal]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CalendarFiscal](
	[ID] [int] NOT NULL,
	[DateKey] [date] NOT NULL,
	[Year] [int] NOT NULL,
	[Quarter] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Week] [int] NOT NULL,
	[Day] [int] NOT NULL,
	[LYDate] [date] NULL,
	[LYDay] [int] NULL,
	[2LYDate] [date] NULL,
	[2LYDay] [int] NULL,
	[Holiday] [bit] NULL,
	[WeekID] [int] NULL,
	[MonthID] [int] NULL,
 CONSTRAINT [PK_CalendarFiscal] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
