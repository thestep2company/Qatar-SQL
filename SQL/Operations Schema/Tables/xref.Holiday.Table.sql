USE [Operations]
GO
/****** Object:  Table [xref].[Holiday]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[Holiday](
	[DateKey] [date] NULL,
	[SBHoliday] [bit] NULL,
	[PVHoliday] [bit] NULL,
	[CorporateHoliday] [bit] NULL,
	[HolidayName] [varchar](50) NULL
) ON [PRIMARY]
GO
