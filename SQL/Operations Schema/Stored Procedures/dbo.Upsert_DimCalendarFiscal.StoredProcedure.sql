USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimCalendarFiscal]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Upsert_DimCalendarFiscal] 
AS BEGIN	

	INSERT INTO dbo.DimCalendarFiscal (
		 [DateID]
		,[DateKey]
		,[Year]
		,[Half]
		,[Half Seasonlity]
		,[Quarter]
		,[Quarter Sort]
		,[Quarter Seasonality]
		,[Month]
		,[Month Sort]
		,[Month Seasonality]
		,[Month Seasonality Sort]
		,[Week]
		,[Week Sort]
		,[Week Seasonality]
		,[Week Seasonality Sort]
		,[WeekNum]
		,[Day]
		,[Day Sort]
		,[Day Seasonality]
		,[Day Seasonality Sort]
		,[Day of Week]
		,[Day of Week Sort]
		,[TYDay]
		,[LYDay]
		,[2LYDay]
		,[Holiday]
		,[WeekID]
		,[CurrentYear]
		,[MonthID]
		,[CurrentMonthID]
		,[CurrentWeekID]
		,[UseActual]
		,[UseForecast]
		,[UseActualPrior]
		,[UseForecastPrior]
		,[UseActualPrior2]
		,[UseForecastPrior2]
		,[UseActualPrior3]
		,[UseForecastPrior3]
		,[SBHoliday]
		,[PVHoliday]
		,[CorporateHoliday]
		,[ShipDay]
		,[SBSnapshot]
		,[PVSnapshot]
		,[Future]
		,[History]
		,[HolidayName]
	)
	SELECT cf.[DateID]
		  ,cf.[DateKey]
		  ,cf.[Year]
		  ,cf.[Half]
		  ,cf.[Half Seasonlity]
		  ,cf.[Quarter]
		  ,cf.[Quarter Sort]
		  ,cf.[Quarter Seasonality]
		  ,cf.[Month]
		  ,cf.[Month Sort]
		  ,cf.[Month Seasonality]
		  ,cf.[Month Seasonality Sort]
		  ,cf.[Week]
		  ,cf.[Week Sort]
		  ,cf.[Week Seasonality]
		  ,cf.[Week Seasonality Sort]
		  ,cf.[WeekNum]
		  ,cf.[Day]
		  ,cf.[Day Sort]
		  ,cf.[Day Seasonality]
		  ,cf.[Day Seasonality Sort]
		  ,cf.[Day of Week]
		  ,cf.[Day of Week Sort]
		  ,cf.[TYDay]
		  ,cf.[LYDay]
		  ,cf.[2LYDay]
		  ,cf.[Holiday]
		  ,cf.[WeekID]
		  ,cf.[CurrentYear]
		  ,cf.[MonthID]
		  ,cf.[CurrentMonthID]
		  ,cf.[CurrentWeekID]
		  ,cf.[UseActual]
		  ,cf.[UseForecast]
		  ,cf.[UseActualPrior]
		  ,cf.[UseForecastPrior]
		  ,cf.[UseActualPrior2]
		  ,cf.[UseForecastPrior2]
		  ,cf.[UseActualPrior3]
		  ,cf.[UseForecastPrior3]
		  ,cf.[SBHoliday]
		  ,cf.[PVHoliday]
		  ,cf.[CorporateHoliday]
		  ,cf.[ShipDay]
		  ,cf.[SBSnapshot]
		  ,cf.[PVSnapshot]
		  ,cf.[Future]
		  ,cf.[History]
		  ,cf.[HolidayName]
	FROM [Dim].[CalendarFiscal] cf
		LEFT JOIN [dbo].[DimCalendarFiscal] dcf ON cf.DateID = dcf.DateID
	WHERE dcf.DateID IS NULL

	UPDATE t 
	SET  t.[DateKey] = s.[DateKey]
		,t.[Year] = s.[Year]
		,t.[Half] = s.[Half]
		,t.[Half Seasonlity] = s.[Half Seasonlity]
		,t.[Quarter] = s.[Quarter]
		,t.[Quarter Sort] = s.[Quarter Sort]
		,t.[Quarter Seasonality] = s.[Quarter Seasonality]
		,t.[Month] = s.[Month]
		,t.[Month Sort] = s.[Month Sort]
		,t.[Month Seasonality] = s.[Month Seasonality]
		,t.[Month Seasonality Sort] = s.[Month Seasonality Sort]
		,t.[Week] = s.[Week]
		,t.[Week Sort] = s.[Week Sort]
		,t.[Week Seasonality] = s.[Week Seasonality]
		,t.[Week Seasonality Sort] = s.[Week Seasonality Sort]
		,t.[WeekNum] = s.[WeekNum]
		,t.[Day] = s.[Day]
		,t.[Day Sort] = s.[Day Sort]
		,t.[Day Seasonality] = s.[Day Seasonality]
		,t.[Day Seasonality Sort] = s.[Day Seasonality Sort]
		,t.[Day of Week] = s.[Day of Week]
		,t.[Day of Week Sort] = s.[Day of Week Sort]
		,t.[TYDay] = s.[TYDay]
		,t.[LYDay] = s.[LYDay]
		,t.[2LYDay] = s.[2LYDay]
		,t.[Holiday] = s.[Holiday]
		,t.[WeekID] = s.[WeekID]
		,t.[CurrentYear] = s.[CurrentYear]
		,t.[MonthID] = s.[MonthID]
		,t.[CurrentMonthID] = s.[CurrentMonthID]
		,t.[CurrentWeekID] = s.[CurrentWeekID]
		,t.[UseActual] = s.[UseActual]
		,t.[UseForecast] = s.[UseForecast]
		,t.[UseActualPrior] = s.[UseActualPrior]
		,t.[UseForecastPrior] = s.[UseForecastPrior]
		,t.[UseActualPrior2] = s.[UseActualPrior2]
		,t.[UseForecastPrior2] = s.[UseForecastPrior2]
		,t.[UseActualPrior3] = s.[UseActualPrior3]
		,t.[UseForecastPrior3] = s.[UseForecastPrior3]
		,t.[SBHoliday] = s.[SBHoliday]
		,t.[PVHoliday] = s.[PVHoliday]
		,t.[CorporateHoliday] = s.[CorporateHoliday]
		,t.[ShipDay] = s.[ShipDay]
		,t.[SBSnapshot] = s.[SBSnapshot]
		,t.[PVSnapshot] = s.[PVSnapshot]
		,t.[Future] = s.[Future]
		,t.[History] = s.[History]
		,t.[HolidayName] = s.[HolidayName]
	FROM Dim.CalendarFiscal s
		LEFT JOIN dbo.DimCalendarFiscal t ON s.DateID = t.DateID
	WHERE 
		ISNULL(s.DateKey,'1900-01-01') <> ISNULL(t.DateKey,'1900-01-01')
		OR ISNULL(s.Year,0) <> ISNULL(t.Year,0)
		OR ISNULL(s.Half,'') <> ISNULL(t.Half,'')
		OR ISNULL(s.[Half Seasonlity],'') <> ISNULL(t.[Half Seasonlity],'')
		OR ISNULL(s.Quarter,'') <> ISNULL(t.Quarter,'')
		OR ISNULL(s.[Quarter Sort],'') <> ISNULL(t.[Quarter Sort],'')
		OR ISNULL(s.Month,'') <> ISNULL(t.Month,'')
		OR ISNULL(s.[Month Sort],'') <> ISNULL(t.[Month Sort],'')
		OR ISNULL(s.[Month Seasonality],'') <> ISNULL(t.[Month Seasonality],'')
		OR ISNULL(s.[Month Seasonality Sort],'') <> ISNULL(t.[Month Seasonality Sort],'')
		OR ISNULL(s.[Week],'') <> ISNULL(t.[Week],'')
		OR ISNULL(s.[Week Sort],'') <> ISNULL(t.[Week Sort],'')
		OR ISNULL(s.[Week Seasonality],'') <> ISNULL(t.[Week Seasonality],'')
		OR ISNULL(s.[Week Seasonality Sort],'') <> ISNULL(t.[Week Seasonality Sort],'') 
		OR ISNULL(s.[WeekNum],0) <> ISNULL(t.[WeekNum],0)
		OR ISNULL(s.[Day],'') <> ISNULL(t.[Day],'')
		OR ISNULL(s.[Day Sort],'') <> ISNULL(t.[Day Sort],'')
		OR ISNULL(s.[Day Seasonality],'') <> ISNULL(t.[Day Seasonality],'')
		OR ISNULL(s.[Day Seasonality Sort],'') <> ISNULL(t.[Day Seasonality Sort],'')
		OR ISNULL(s.[Day of Week],'') <> ISNULL(t.[Day of Week],'')
		OR ISNULL(s.[Day of Week Sort],0) <> ISNULL(t.[Day of Week Sort],0)
		OR ISNULL(s.[TYDay],0) <> ISNULL(t.[TYDay],0)
		OR ISNULL(s.[LYDay],0) <> ISNULL(t.[LYDay],0)
		OR ISNULL(s.[2LYDay],0) <> ISNULL(t.[2LYDay],0)
		OR ISNULL(s.Holiday,0) <> ISNULL(t.Holiday,0)
		OR ISNULL(s.WeekID,0) <> ISNULL(t.WeekID,0)
		OR ISNULL(s.CurrentYear,'') <> ISNULL(t.CurrentYear,'')
		OR ISNULL(s.MonthID,0) <> ISNULL(t.MonthID,0)
		OR ISNULL(s.CurrentMonthID,0) <> ISNULL(t.CurrentMonthID,0)
		OR ISNULL(s.CurrentWeekID,0) <> ISNULL(t.CurrentWeekID,0)
		OR ISNULL(s.UseActual,0) <> ISNULL(t.UseActual,0)
		OR ISNULL(s.UseActualPrior,0) <> ISNULL(t.UseActualPrior,0)
		OR ISNULL(s.UseActualPrior2,0) <> ISNULL(t.UseActualPrior2,0)
		OR ISNULL(s.UseActualPrior3,0) <> ISNULL(t.UseActualPrior3,0)
		OR ISNULL(s.UseForecast,0) <> ISNULL(t.UseForecast,0)
		OR ISNULL(s.UseForecastPrior,0) <> ISNULL(t.UseForecastPrior,0)
		OR ISNULL(s.UseForecastPrior2,0) <> ISNULL(t.UseForecastPrior2,0)
		OR ISNULL(s.UseForecastPrior3,0) <> ISNULL(t.UseForecastPrior3,0)
		OR ISNULL(s.SBHoliday,0) <> ISNULL(t.SBHoliday,0)
		OR ISNULL(s.PVHoliday,0) <> ISNULL(t.PVHoliday,0)
		OR ISNULL(s.CorporateHoliday,0) <> ISNULL(t.CorporateHoliday,0)
		OR ISNULL(s.ShipDay,0) <> ISNULL(t.ShipDay,0)
		OR ISNULL(s.SBSnapshot,0) <> ISNULL(t.SBSnapshot,0)
		OR ISNULL(s.PVSnapshot,0) <> ISNULL(t.PVSnapshot,0)
		OR ISNULL(s.Future,'') <> ISNULL(t.Future,'')
		OR ISNULL(s.History,'') <> ISNULL(t.History,'')
		OR ISNULL(s.HolidayName,'') <> ISNULL(t.HolidayName,'')
	
END
GO
