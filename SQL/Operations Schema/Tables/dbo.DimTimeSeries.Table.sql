USE [Operations]
GO
/****** Object:  Table [dbo].[DimTimeSeries]    Script Date: 7/10/2025 11:43:41 AM ******/
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
	[TimeSeriesTypeSort] [varchar](5) NULL,
PRIMARY KEY CLUSTERED 
(
	[TimeSeriesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
