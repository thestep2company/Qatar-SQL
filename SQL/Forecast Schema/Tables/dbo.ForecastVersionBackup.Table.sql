USE [Forecast]
GO
/****** Object:  Table [dbo].[ForecastVersionBackup]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ForecastVersionBackup](
	[BudgetID] [int] NOT NULL,
	[ForecastVersion] [varchar](7) NULL,
	[ForecastDate] [date] NULL,
	[ForecastName] [varchar](50) NULL,
	[Year] [int] NULL
) ON [PRIMARY]
GO
