USE [Operations]
GO
/****** Object:  StoredProcedure [OUTPUT].[CalendarCheck]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [OUTPUT].[CalendarCheck] 
AS BEGIN
	SELECT cf.DateKey
		,cf.UseActual
		,cf2.UseActual
		,cf.UseActualPrior
		,cf2.UseActualPrior
		,cf.UseActualPrior2
		,cf2.UseActualPrior2
		,cf.UseActualPrior3
		,cf2.UseActualPrior3
		,cf.UseForecast
		,cf2.UseForecast
		,cf.UseForecastPrior
		,cf2.UseForecastPrior
		,cf.UseForecastPrior2
		,cf2.UseForecastPrior2
		,cf.UseForecastPrior3
		,cf2.UseForecastPrior3
		,cf.CurrentMonthID
		,cf2.CurrentMonthID
		,cf.CurrentWeekID
		,cf2.CurrentWeekID
	FROM [dbo].[DimCalendarFiscal] cf
		LEFT JOIN Dim.CalendarFiscal cf2 ON cf.DateID = cf2.DateID
	WHERE (ISNULL(cf.UseActual,0) <> cf2.UseActual OR ISNULL(cf.UseForecast,0) <> cf2.UseForecast
		OR ISNULL(cf.UseActualPrior,0) <> cf2.UseActualPrior OR ISNULL(cf.UseForecastPrior,0) <> cf2.UseForecastPrior
		OR ISNULL(cf.UseActualPrior2,0) <> cf2.UseActualPrior2 OR ISNULL(cf.UseForecastPrior2,0) <> cf2.UseForecastPrior2
		OR ISNULL(cf.UseActualPrior3,0) <> cf2.UseActualPrior3 OR ISNULL(cf.UseForecastPrior3,0) <> cf2.UseForecastPrior3
		OR ISNULL(cf.CurrentMonthID,0) <> ISNULL(cf2.CurrentMonthID,0) OR ISNULL(cf.CurrentWeekID,0) <> ISNULL(cf2.CurrentWeekID,0)
		)
	ORDER BY cf.DateID
END

	

GO
