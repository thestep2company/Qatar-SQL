USE [Forecast]
GO
/****** Object:  Table [dbo].[DimOrderCurveProductGroup]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimOrderCurveProductGroup](
	[Year] [int] NOT NULL,
	[Week Seasonality] [varchar](7) NULL,
	[Week Seasonality Sort] [varchar](2) NULL,
	[ProductCount] [int] NULL,
	[WeekCount] [int] NULL,
	[WeeksRemaining] [int] NULL,
	[Category] [nvarchar](240) NOT NULL,
	[Product Group] [varchar](250) NULL,
	[WeeklySales] [money] NOT NULL,
	[SubcategorySales] [money] NULL,
	[Value] [numeric](38, 18) NULL
) ON [PRIMARY]
GO
