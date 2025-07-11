USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[ForecastPrep03CalendarSettings]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/


CREATE PROCEDURE [dbo].[ForecastPrep03CalendarSettings] AS BEGIN

	DECLARE @currentPeriod INT, @priorPeriod INT, @priorPeriod2 INT, @priorPeriod3 INT

	SELECT @currentPeriod = [MonthID], @priorPeriod = [MonthID] - 1, @priorPeriod2 = [MonthID] - 2, @priorPeriod3 = [MonthID] - 3
	FROM dbo.ForecastPeriod fp
		INNER JOIN dbo.DimCalendarFiscal cf ON fp.[ForecastMonth] = cf.[Month Sort] 
	GROUP BY [MonthID]

	--current forecast
	UPDATE cf SET UseForecast = 1, UseActual = NULL
	--SELECT * 
	FROM dbo.DimCalendarFiscal cf 
	WHERE [MonthID] >= @currentPeriod AND (UseForecast IS NULL OR UseActual = 1)

	UPDATE cf SET UseForecast = NULL, UseActual = 1
	--SELECT * 
	FROM dbo.DimCalendarFiscal cf 
	WHERE [MonthID] < @currentPeriod AND (UseForecast = 1 OR UseActual IS NULL)

	--prior forecast 1
	UPDATE cf SET UseForecastPrior = 1, UseActualPrior = NULL
	--SELECT * 
	FROM dbo.DimCalendarFiscal cf 
	WHERE [MonthID] >= @priorPeriod AND (UseForecastPrior IS NULL OR UseActualPrior = 1)

	UPDATE cf SET UseForecastPrior = NULL, UseActualPrior = 1
	--SELECT * 
	FROM dbo.DimCalendarFiscal cf 
	WHERE [MonthID] < @priorPeriod AND (UseForecastPrior = 1 OR UseActualPrior IS NULL)

	--prior forecast 2
	UPDATE cf SET UseForecastPrior2 = 1, UseActualPrior2 = NULL
	--SELECT * 
	FROM dbo.DimCalendarFiscal cf 
	WHERE [MonthID] >= @priorPeriod2 AND (UseForecastPrior2 IS NULL OR UseActualPrior2 = 1)

	UPDATE cf SET UseForecastPrior2 = NULL, UseActualPrior2 = 1
	--SELECT * 
	FROM dbo.DimCalendarFiscal cf 
	WHERE [MonthID] < @priorPeriod2 AND (UseForecastPrior2 = 1 OR UseActualPrior2 IS NULL)

	--prior forecast 3
	UPDATE cf SET UseForecastPrior3 = 1, UseActualPrior3 = NULL
	--SELECT * 
	FROM dbo.DimCalendarFiscal cf 
	WHERE [MonthID] >= @priorPeriod3 AND (UseForecastPrior3 IS NULL OR UseActualPrior3 = 1)

	UPDATE cf SET UseForecastPrior3 = NULL, UseActualPrior3 = 1
	--SELECT * 
	FROM dbo.DimCalendarFiscal cf 
	WHERE [MonthID] < @priorPeriod3 AND (UseForecastPrior3 = 1 OR UseActualPrior3 IS NULL)

END
GO
