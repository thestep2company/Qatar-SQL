USE [Forecast]
GO
/****** Object:  Table [dbo].[FactForecastQuantites]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactForecastQuantites](
	[DateID] [int] NULL,
	[ProductID] [int] NULL,
	[DemandClassID] [bigint] NULL,
	[Quantity] [float] NULL
) ON [PRIMARY]
GO
