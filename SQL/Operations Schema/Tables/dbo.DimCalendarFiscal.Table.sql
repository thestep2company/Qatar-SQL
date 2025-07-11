USE [Operations]
GO
/****** Object:  Table [dbo].[DimCalendarFiscal]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimCalendarFiscal](
	[DateID] [int] NOT NULL,
	[DateKey] [date] NOT NULL,
	[Year] [int] NOT NULL,
	[Half] [varchar](13) NULL,
	[Half Seasonlity] [varchar](8) NOT NULL,
	[Quarter] [varchar](7) NULL,
	[Quarter Sort] [varchar](6) NULL,
	[Quarter Seasonality] [varchar](2) NULL,
	[Month] [nvarchar](8) NULL,
	[Month Sort] [varchar](6) NULL,
	[Month Seasonality] [nvarchar](3) NULL,
	[Month Seasonality Sort] [varchar](2) NULL,
	[Week] [varchar](12) NULL,
	[Week Sort] [varchar](6) NULL,
	[Week Seasonality] [varchar](7) NULL,
	[Week Seasonality Sort] [varchar](2) NULL,
	[WeekNum] [int] NOT NULL,
	[Day] [varchar](25) NULL,
	[Day Sort] [varchar](3) NULL,
	[Day Seasonality] [varchar](7) NULL,
	[Day Seasonality Sort] [varchar](3) NULL,
	[Day of Week] [nvarchar](3) NULL,
	[Day of Week Sort] [int] NULL,
	[TYDay] [int] NOT NULL,
	[LYDay] [int] NULL,
	[2LYDay] [int] NULL,
	[Holiday] [bit] NULL,
	[WeekID] [int] NULL,
	[CurrentYear] [varchar](25) NULL,
	[MonthID] [int] NULL,
	[CurrentMonthID] [int] NULL,
	[CurrentWeekID] [int] NULL,
	[UseActual] [int] NULL,
	[UseForecast] [int] NULL,
	[UseActualPrior] [int] NULL,
	[UseForecastPrior] [int] NULL,
	[UseActualPrior2] [bit] NULL,
	[UseForecastPrior2] [bit] NULL,
	[UseActualPrior3] [bit] NULL,
	[UseForecastPrior3] [bit] NULL,
	[SBHoliday] [bit] NULL,
	[PVHoliday] [bit] NULL,
	[CorporateHoliday] [bit] NULL,
	[ShipDay] [bit] NULL,
	[SBSnapshot] [bit] NULL,
	[PVSnapshot] [bit] NULL,
	[Future] [varchar](50) NULL,
	[History] [varchar](50) NULL,
	[HolidayName] [varchar](50) NULL,
 CONSTRAINT [PK_DimCalendarFiscal] PRIMARY KEY CLUSTERED 
(
	[DateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_DimCalendarFiscal_DateKey]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_DimCalendarFiscal_DateKey] ON [dbo].[DimCalendarFiscal]
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
