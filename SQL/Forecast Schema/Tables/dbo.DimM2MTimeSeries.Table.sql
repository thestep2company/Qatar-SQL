USE [Forecast]
GO
/****** Object:  Table [dbo].[DimM2MTimeSeries]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimM2MTimeSeries](
	[TimeSeriesID] [int] NOT NULL,
	[DateID] [int] NOT NULL
) ON [PRIMARY]
GO
