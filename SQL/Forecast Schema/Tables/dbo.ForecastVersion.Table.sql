USE [Forecast]
GO
/****** Object:  Table [dbo].[ForecastVersion]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ForecastVersion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BudgetID] [int] NOT NULL,
	[ForecastVersion] [varchar](15) NULL,
	[ForecastDate] [date] NULL,
	[ForecastName] [varchar](50) NULL,
	[Year] [int] NULL
) ON [PRIMARY]
GO
