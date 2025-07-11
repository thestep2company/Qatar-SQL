USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimCalendarFiscal]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Reload_DimCalendarFiscal] 
AS BEGIN
	

	;WITH CTE AS (
		SELECT MonthID FROM dbo.DimCalendarFiscal WHERE dateKey = CAST(GETDATE() AS DATE)
	)
	UPDATE cf 
	SET CurrentMonthID = cte.MonthID 
	FROM dbo.DimCalendarFiscal cf
		LEFT JOIN CTE ON cte.MonthID = cf.MonthID


  	;WITH CTE AS (
		SELECT WeekID FROM dbo.DimCalendarFiscal WHERE dateKey = CAST(GETDATE() AS DATE)
	)
	UPDATE cf 
	SET CurrentWeekID = cte.WeekID 
	FROM dbo.DimCalendarFiscal cf
		LEFT JOIN CTE ON cte.WeekID = cf.WeekID

	UPDATE dbo.DimCalendarFiscal SET CurrentYear = 'Current Year' WHERE Year = YEAR(GETDATE())

	--TRUNCATE TABLE dbo.DimCalendarFiscal	INSERT INTO dbo.DimCalendarFiscal SELECT * FROM Dim.CalendarFiscal

	----not sure why the view does not persist properly
	----also why does this clear itself every night
	--UPDATE cf 
	--SET cf.UseActual = cf2.UseActual
	--	,cf.UseForecast = cf2.UseForecast
	--	,cf.UseActualPrior = cf2.UseActualPrior
	--	,cf.UseForecastPrior = cf2.UseForecastPrior
	--FROM [dbo].[DimCalendarFiscal] cf
	--	LEFT JOIN Dim.CalendarFiscal cf2 ON cf.DateID = cf2.DateID
	--WHERE (ISNULL(cf.UseActual,0) <> cf2.UseActual OR ISNULL(cf.UseForecast,0) <> cf2.UseForecast)
END
GO
