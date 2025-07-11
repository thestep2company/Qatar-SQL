USE [Forecast]
GO
/****** Object:  Table [dbo].[DimTimeSeries]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimTimeSeries](
	[TimeSeriesID] [int] NOT NULL,
	[TimeSeriesKey] [varchar](10) NULL,
	[TimeSeriesType] [varchar](25) NULL,
	[TimeSeriesName] [varchar](50) NULL,
	[TimeSeriesDesc] [varchar](100) NULL,
	[TimeSeriesSort] [varchar](5) NULL,
	[TimeSeriesTypeSort] [varchar](5) NULL
) ON [PRIMARY]
GO
