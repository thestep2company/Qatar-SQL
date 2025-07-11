USE [Operations]
GO
/****** Object:  View [Dim].[CalendarFiscal]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[CalendarFiscal] AS

SELECT 
	cf1.ID AS DateID 
	,cf1.DateKey
	,[Year] AS [Year]
	,CASE WHEN [Quarter] > 2 THEN '2nd' ELSE '1st' END + ' Half ' + CAST([Year] AS VARCHAR(4)) AS [Half]
	,CASE WHEN [Quarter] > 2 THEN '2nd' ELSE '1st' END + ' Half' AS [Half Seasonlity]
	,'Q'+CAST([Quarter] AS VARCHAR(1)) + ' ' + CAST([Year] AS VARCHAR(4))  AS [Quarter]
	,CAST([Year] AS VARCHAR(4))+RIGHT('00'+CAST([Quarter] AS VARCHAR(1)),2) AS [Quarter Sort]
	,'Q'+CAST([Quarter] AS VARCHAR(1)) AS [Quarter Seasonality]
	,LEFT(DateName(month , DateAdd( month , [Month] , 0 ) - 1 ),3) + ' ' + CAST([Year] AS VARCHAR(4)) AS [Month]
	,CAST([Year] AS VARCHAR(4))+RIGHT('00'+CAST([Month] AS VARCHAR(2)),2) AS [Month Sort]
	,LEFT(DateName(month , DateAdd( month , [Month] , 0 ) - 1 ),3) AS [Month Seasonality]
	,RIGHT('00'+CAST([Month] AS VARCHAR(2)),2) AS [Month Seasonality Sort]
	,'Week ' + CAST([Week] AS VARCHAR(2)) + ' ' + CAST([Year] AS VARCHAR(4)) AS [Week]
	,CAST([Year] AS VARCHAR(4))+RIGHT('00'+CAST([Week] AS VARCHAR(2)),2) AS [Week Sort]
	,'Week ' + CAST([Week] AS VARCHAR(2)) AS [Week Seasonality]
	,RIGHT('00'+CAST([Week] AS VARCHAR(2)),2) AS [Week Seasonality Sort]
	,Week AS WeekNum
	,CAST(LEFT(DATENAME(MONTH,cf1.[DateKey]),3) + ' ' + CAST(DAY(cf1.[DateKey]) AS VARCHAR(5)) + ' ' + CAST(YEAR(cf1.[DateKey]) AS VARCHAR(5)) AS VARCHAR(25)) AS [Day]
	--,LEFT(DateName(month , DateAdd( month , [Month] , 0 ) - 1 ),3) + ' ' + LTRIM(RIGHT(CONVERT(VARCHAR(12), [DateKey], 109), 8)) AS [Day]
	,RIGHT('000'+CAST([Day]  AS VARCHAR(3)),3) AS [Day Sort]
	,'Day ' + CAST([Day]  AS VARCHAR(3)) AS [Day Seasonality]
	,RIGHT('000'+CAST([Day]  AS VARCHAR(3)),3) AS [Day Seasonality Sort]
	,LEFT(DATENAME(WeekDay,cf1.[DateKey]),3) AS [Day of Week]
	,DATEPART(WEEKDAY,cf1.[DateKey]) AS [Day of Week Sort]
	,Day AS TYDay
	,LYDay
	,[2LYDay]
	,[Holiday]
	,WeekID
	,CASE WHEN YEAR(cf1.DateKey) = YEAR(GETDATE()) THEN 'Current Year' 
		WHEN YEAR(cf1.DateKey) = YEAR(GETDATE())-1 THEN 'Last Year' 
		WHEN YEAR(cf1.DateKey) = YEAR(GETDATE())+1 THEN 'Next Year' 
		ELSE '' 
	END AS CurrentYear
	,MonthID
	,CASE WHEN cf1.MonthID = (SELECT MonthID FROM dbo.DimCalendarFiscal WHERE dateKey = CAST(GETDATE() AS DATE)) THEN MonthID END AS CurrentMonthID
	,CASE WHEN cf1.WeekID = (SELECT WeekID FROM dbo.DimCalendarFiscal WHERE dateKey = CAST(GETDATE() AS DATE)) THEN WeekID END AS CurrentWeekID
	,CASE WHEN cf1.MonthID < (SELECT MonthID FROM Dim.ForecastPeriod) THEN 1 END AS UseActual
	,CASE WHEN cf1.MonthID >= (SELECT MonthID FROM Dim.ForecastPeriod) THEN 1 END AS UseForecast
	,CASE WHEN cf1.MonthID < (SELECT MonthID-1 FROM Dim.ForecastPeriod) THEN 1 END AS UseActualPrior
	,CASE WHEN cf1.MonthID >= (SELECT MonthID-1 FROM Dim.ForecastPeriod) THEN 1 END AS UseForecastPrior
	,CAST(NULL AS BIT) AS UseActualPrior2
	,CAST(NULL AS BIT) AS UseForecastPrior2
	,CAST(NULL AS BIT) AS UseActualPrior3
	,CAST(NULL AS BIT) AS UseForecastPrior3
	,ISNULL(h.SBHoliday,0) AS SBHoliday
	,ISNULL(h.PVHoliday,0) AS PVHoliday
	,ISNULL(h.CorporateHoliday,0) AS CorporateHoliday
	,CASE WHEN DATEPART(WEEKDAY,cf1.[DateKey]) IN (1,7) OR h.CorporateHoliday = 1 THEN 0 ELSE 1 END AS ShipDay
	,CASE WHEN DATEPART(WEEKDAY,cf1.DateKey) = 7 THEN 1 ELSE 0 END AS SBSnapshot
	,CASE WHEN DATEPART(WEEKDAY,cf1.DateKey) = 6 THEN 1 ELSE 0 END AS PVSnapshot
	,CASE WHEN cf1.DateKey > GETDATE() THEN 'Future' END AS Future
	,CASE WHEN cf1.DateKey < CAST(GETDATE() AS DATE) THEN 'History' END AS History
	,h.HolidayName
FROM dbo.CalendarFiscal cf1
	LEFT JOIN xref.Holiday h ON cf1.DateKey = h.DateKey
GO
