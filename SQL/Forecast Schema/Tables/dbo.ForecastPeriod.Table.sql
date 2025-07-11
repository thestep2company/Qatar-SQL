USE [Forecast]
GO
/****** Object:  Table [dbo].[ForecastPeriod]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ForecastPeriod](
	[BudgetMonth] [char](6) NULL,
	[ForecastMonth] [char](6) NULL,
	[COGSDate] [date] NULL,
	[ShiftPriorForecast] [bit] NULL,
	[Mode] [char](1) NULL,
	[ShiftPriorBudget] [bit] NULL,
	[CustomerSplitDate] [date] NULL
) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sets the budget period.  Not used in the forecasting process - only for the budgeting process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForecastPeriod', @level2type=N'COLUMN',@level2name=N'BudgetMonth'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sets the forecast period for the current run.  This will pull in actuals before this period and forecast values after.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForecastPeriod', @level2type=N'COLUMN',@level2name=N'ForecastMonth'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Provide a lookup date for costing that pulls from FactStandard.  We typically set this for the 1st day of the month, but you can set it for a future date for budget/test costing.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForecastPeriod', @level2type=N'COLUMN',@level2name=N'COGSDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Use this to determine if the invoiced sales forecast needs to be shifted into the prior forecast field.  Most of the time, when loading a new forecast, leave this enabled. An example of when to disable woudl be if you are retrying the forecast load and want to leave forecasts as the same version. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForecastPeriod', @level2type=N'COLUMN',@level2name=N'ShiftPriorForecast'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'B = Run budget load for budget month forward.  F Run forecast load for forecast month forward.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForecastPeriod', @level2type=N'COLUMN',@level2name=N'Mode'
GO
EXEC sys.sp_addextendedproperty @name=N'ShiftPriorForecast', @value=N'Use this to determine if the invoiced sales forecast needs to be shifted into the prior forecast field' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForecastPeriod'
GO
