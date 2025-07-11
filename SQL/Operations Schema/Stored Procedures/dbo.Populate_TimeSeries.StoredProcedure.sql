USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Populate_TimeSeries]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Populate_TimeSeries] AS BEGIN

	DECLARE @toDate DATE, @today DATE

	SELECT @today = GETDATE()
	SELECT @toDate = DATEADD(DAY,-1,@today)

	UPDATE dbo.DimCalendarFiscal SET CurrentYear = ''
	UPDATE dbo.DimCalendarFiscal SET CurrentYear = 'Last Year' WHERE YEAR(DateKey) = YEAR(@toDate)-1
	UPDATE dbo.DimCalendarFiscal SET CurrentYear = 'Current Year' WHERE YEAR(DateKey) = YEAR(@toDate)
	UPDATE dbo.DimCalendarFiscal SET CurrentYear = 'Next Year' WHERE YEAR(DateKey) = YEAR(@toDate)+1
	UPDATE dbo.DimCalendarFiscal SET CurrentYear = 'Current Year'  WHERE CAST(DATEPART(YEAR,@today) AS VARCHAR(4)) + '-01-01' = DateKey --keep 1st of the year as "current" to retain TY LY reporting on 1/1/20XX

	TRUNCATE TABLE dbo.M2MTimeSeries

	;
	WITH YTD AS (
		SELECT DISTINCT Year
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, DateID
	FROM Dim.CalendarFiscal c
		INNER JOIN YTD d ON c.Year = d.Year AND c.DateKey <= @toDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YTD'

	;
	WITH YTD AS (
		SELECT DISTINCT Year
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM Dim.CalendarFiscal c
			INNER JOIN YTD d ON c.Year = d.Year AND c.DateKey <= @toDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YTD'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' +  CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
		,TimeSeriesType = 'Year to Date'
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'YTD'

	;
	WITH YTDLY AS (
		SELECT DISTINCT Year
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN YTDLY d ON c.Year = d.Year AND c.DateKey <= @toDate
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YTDLY'

	;
	WITH YTDLY AS (
		SELECT DISTINCT Year
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN YTDLY d ON c.Year = d.Year  AND c.DateKey <= @toDate
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YTDLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'YTDLY'

	;
	WITH YTD2LY AS (
		SELECT DISTINCT Year
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN YTD2LY d ON c.Year = d.Year AND c.DateKey <= @toDate
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YTD2LY'

	;
	WITH YTD2LY AS (
		SELECT DISTINCT Year
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN YTD2LY d ON c.Year = d.Year  AND c.DateKey <= @toDate
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YTD2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'YTD2LY'

	;
	WITH CY AS (
		SELECT DISTINCT Year
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, DateID
	FROM Dim.CalendarFiscal c
		INNER JOIN CY d ON c.Year = d.Year 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CY'
	
	;
	WITH CY AS (
		SELECT DISTINCT Year
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM Dim.CalendarFiscal c
			INNER JOIN CY d ON c.Year = d.Year
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'CY'

	;
	WITH CYLY AS (
		SELECT DISTINCT Year
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN CYLY d ON c.Year = d.Year 
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CYLY'

	;
	WITH CYLY AS (
		SELECT DISTINCT Year
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN CYLY d ON c.Year = d.Year  
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CYLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'CYLY'

	;
	WITH CY2LY AS (
		SELECT DISTINCT Year
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN CY2LY d ON c.Year = d.Year 
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CY2LY'

	;
	WITH CY2LY AS (
		SELECT DISTINCT Year
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN CY2LY d ON c.Year = d.Year  
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CY2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'CY2LY'

	;
	WITH QTD AS (
		SELECT DISTINCT Year, Quarter
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN QTD d ON c.Year = d.Year AND c.Quarter = d.Quarter AND c.DateKey <= @toDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'QTD'

	;
	WITH QTD AS (
		SELECT DISTINCT Year, Quarter
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN QTD d ON c.Year = d.Year AND c.Quarter = d.Quarter AND c.DateKey <= @toDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'QTD'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'QTD'

	;
	WITH QTDLY AS (
		SELECT DISTINCT Year, Quarter
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN QTDLY d ON c.Year = d.Year AND c.Quarter = d.Quarter AND c.DateKey <= @toDate
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'QTDLY'

	;
	WITH QTDLY AS (
		SELECT DISTINCT Year, Quarter
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN QTDLY d ON c.Year = d.Year  AND c.Quarter = d.Quarter AND c.DateKey <= @toDate
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'QTDLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'QTDLY'

	;
	WITH QTD2LY AS (
		SELECT DISTINCT Year, Quarter
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN QTD2LY d ON c.Year = d.Year AND c.Quarter = d.Quarter AND c.DateKey <= @toDate
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'QTD2LY'

	;
	WITH QTD2LY AS (
		SELECT DISTINCT Year, Quarter
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN QTD2LY d ON c.Year = d.Year  AND c.Quarter = d.Quarter AND c.DateKey <= @toDate
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'QTD2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'QTD2LY'

	;
	WITH CQ AS (
		SELECT DISTINCT Year, Quarter
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN CQ d ON c.Year = d.Year AND c.Quarter = d.Quarter 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CQ'

	;
	WITH CQ AS (
		SELECT DISTINCT Year, Quarter
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN CQ d ON c.Year = d.Year AND c.Quarter = d.Quarter 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CQ'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'CQ'

	;
	WITH CQLY AS (
		SELECT DISTINCT Year, Quarter
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN CQLY d ON c.Year = d.Year AND c.Quarter = d.Quarter  
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CQLY'

	;
	WITH CQLY AS (
		SELECT DISTINCT Year, Quarter
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN CQLY d ON c.Year = d.Year AND c.Quarter = d.Quarter  
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CQLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'CQLY'

	;
	WITH CQ2LY AS (
		SELECT DISTINCT Year, Quarter
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN CQ2LY d ON c.Year = d.Year AND c.Quarter = d.Quarter  
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CQ2LY'

	;
	WITH CQ2LY AS (
		SELECT DISTINCT Year, Quarter
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN CQ2LY d ON c.Year = d.Year AND c.Quarter = d.Quarter  
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CQ2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'CQ2LY'

	;
	WITH MTD AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN MTD d ON c.Year = d.Year AND c.Month = d.Month AND c.DateKey <= @toDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'MTD'

	;
	WITH MTD AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN MTD d ON c.Year = d.Year AND c.Month = d.Month AND c.DateKey <= @toDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'MTD'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'MTD'

	;
	WITH MTDLY AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN MTDLY d ON c.Year = d.Year AND c.Month = d.Month AND c.DateKey <= @toDate
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'MTDLY'

	;
	WITH MTDLY AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN MTDLY d ON c.Year = d.Year AND c.Month = d.Month AND c.DateKey <= @toDate
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'MTDLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'MTDLY'

	;
	WITH MTD2LY AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN MTD2LY d ON c.Year = d.Year AND c.Month = d.Month AND c.DateKey <= @toDate
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'MTD2LY'

	;
	WITH MTD2LY AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN MTD2LY d ON c.Year = d.Year AND c.Month = d.Month AND c.DateKey <= @toDate
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'MTD2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'MTD2LY'

	;
	WITH CM AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN CM d ON c.Year = d.Year AND c.Month = d.Month 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CM'

	;
	WITH CM AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN CM d ON c.Year = d.Year AND c.Month = d.Month 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CM'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'CM'

	;
	WITH CMLY AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT 
		TimeSeriesID, ly.ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN CMLY d ON c.Year = d.Year AND c.Month = d.Month  --AND c.DateKey <= @toDate
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CMLY'

	;
	WITH CMLY AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN CMLY d ON c.Year = d.Year AND c.Month = d.Month  --AND c.DateKey <= @toDate
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CMLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'CMLY'

	;
	WITH CM2LY AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN CM2LY d ON c.Year = d.Year AND c.Month = d.Month  --AND c.DateKey <= @toDate
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CM2LY'

	;
	WITH CM2LY AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN CM2LY d ON c.Year = d.Year AND c.Month = d.Month  --AND c.DateKey <= @toDate
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CM2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'CM2LY'

	;
	WITH PM AS (
		SELECT MonthID --DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN PM d ON c.MonthID = d.MonthID - 1
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PM'

	;
	WITH PM AS (
		SELECT MonthID --DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN PM d ON c.MonthID = d.MonthID - 1 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PM'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'PM'

	;
	WITH PMLY AS (
		SELECT MonthID --DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN PMLY d ON c.MonthID = d.MonthID - 1 
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PMLY'

	;
	WITH PMLY AS (
		SELECT MonthID --DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN PMLY d ON c.MonthID = d.MonthID - 1 
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PMLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'PMLY'

	;
	WITH PM2LY AS (
		SELECT MonthID --DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN PM2LY d ON c.MonthID = d.MonthID - 1  
		INNER JOIN dbo.CalendarFiscal ly1 ON ly1.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly1.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PM2LY'

	;
	WITH PM2LY AS (
		SELECT MonthID --DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN PM2LY d ON  c.MonthID = d.MonthID - 1 
			INNER JOIN dbo.CalendarFiscal ly1 ON ly1.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly1.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PM2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'PM2LY'


	;
	WITH NM AS (
		SELECT MonthID
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN NM d ON c.MonthID = d.MonthID + 1
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'NM'

	;
	WITH NM AS (
		SELECT MonthID
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN NM d ON c.MonthID = d.MonthID + 1
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'NM'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'NM'

	;
	WITH WTD AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DateKey), 0)) AS StartDate
			,DateKey AS EndDate
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN WTD d ON c.DateKey BETWEEN d.StartDate AND d.EndDate 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'WTD'


	;
	WITH WTD AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DateKey), 0)) AS StartDate
			,DateKey AS EndDate
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(c.DateKey) AS StartDate, MAX(c.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN WTD d ON c.DateKey BETWEEN d.StartDate AND d.EndDate 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'WTD'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'WTD'

	;
	WITH WTDLY AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*1,DateKey)), 0)) AS StartDate
			,DATEADD(DAY,-364*1,DateKey) AS EndDate
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate	
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, c.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN WTDLY d ON c.DateKey BETWEEN d.StartDate AND d.EndDate 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'WTDLY'

	;
	WITH WTDLY AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*1,DateKey)), 0)) AS StartDate
			,DATEADD(DAY,-364*1,DateKey) AS EndDate
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(c.DateKey) AS StartDate, MAX(c.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN WTDLY d ON c.DateKey BETWEEN d.StartDate AND d.EndDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'WTDLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'WTDLY'

	;
	WITH WTD2LY AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*2,DateKey)), 0)) AS StartDate
			,DATEADD(DAY,-364*2,DateKey) AS EndDate
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, c.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN WTD2LY d ON c.DateKey BETWEEN d.StartDate AND d.EndDate 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'WTD2LY'

	;
	WITH WTD2LY AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*2,DateKey)), 0)) AS StartDate
			,DATEADD(DAY,-364*1,DateKey) AS EndDate
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(c.DateKey) AS StartDate, MAX(c.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN WTD2LY d ON c.DateKey BETWEEN d.StartDate AND d.EndDate 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'WTD2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'WTD2LY'

	;
	WITH PW AS (
		SELECT DISTINCT WeekID --Year, Week
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = DATEADD(Week,-1,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN PW d ON c.WeekID = d.WeekID 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PW'

	;
	WITH PW AS (
		SELECT DISTINCT WeekID --Year, Week
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = DATEADD(Week,-1,@today)
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN PW d ON c.WeekID = d.WeekID 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PW'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'PW'

	;
	WITH PWLY AS (
		SELECT DISTINCT DATEADD(WEEK,-1,DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*1,DateKey)), 0))) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, c.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN PWLY d ON c.DateKey BETWEEN d.DateKey AND DATEADD(DAY,6,d.DateKey) 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWLY'

	;
	WITH PWLY AS (
		SELECT DISTINCT DATEADD(WEEK,-1,DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*1,DateKey)), 0))) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	, Dates AS (
		SELECT MIN(c.DateKey) AS StartDate, MAX(c.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN PWLY d ON c.DateKey BETWEEN d.DateKey AND DATEADD(DAY,6,d.DateKey) 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'PWLY'


	;
	WITH PW2LY AS (
		SELECT DISTINCT DATEADD(WEEK,-1,DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*2,DateKey)), 0))) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, c.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN PW2LY d ON c.DateKey BETWEEN d.DateKey AND DATEADD(DAY,6,d.DateKey) 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PW2LY'

	;
	WITH PW2LY AS (
		SELECT DISTINCT DATEADD(WEEK,-1,DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*2,DateKey)), 0))) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	, Dates AS (
		SELECT MIN(c.DateKey) AS StartDate, MAX(c.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN PW2LY d ON c.DateKey BETWEEN d.DateKey AND DATEADD(DAY,6,d.DateKey) 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PW2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'PW2LY'

	;
	WITH PWE AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DateKey), 0)) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, MAX(ID)-2 AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN PWE d ON c.DateKey = d.DateKey
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWE'
	GROUP BY TimeSeriesID
	UNION
	SELECT TimeSeriesID, MAX(ID)-1 AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN PWE d ON c.DateKey = d.DateKey
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWE'
	GROUP BY TimeSeriesID
	UNION
	SELECT TimeSeriesID, MAX(ID) AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN PWE d ON  c.DateKey = d.DateKey
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWE'
	GROUP BY TimeSeriesID


	;
	WITH PWE AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DateKey), 0)) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	, Dates AS (
		SELECT DATEADD(DAY,-2,MAX(c.DateKey)) AS StartDate, MAX(c.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN PWE d ON c.DateKey = d.DateKey
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWE'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'PWE'


	;
	WITH PWELY AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*1,DateKey)), 0)) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	,Dates AS (
		SELECT TimeSeriesID, MAX(ID)-2 AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN PWELY d ON c.DateKey = d.DateKey
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWELY'
		GROUP BY TimeSeriesID
		UNION
		SELECT TimeSeriesID, MAX(ID)-1 AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN PWELY d ON c.DateKey = d.DateKey
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWELY'
		GROUP BY TimeSeriesID
		UNION
		SELECT TimeSeriesID, MAX(ID) AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN PWELY d ON c.DateKey = d.DateKey
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWELY'
		GROUP BY TimeSeriesID
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT d.TimeSeriesID, c.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dates d ON c.ID = d.DateID 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWELY'

	;
	WITH PWELY AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*1,DateKey)), 0)) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	,Dates AS (
		SELECT TimeSeriesID, MAX(ID)-2 AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN PWELY d ON c.DateKey = d.DateKey
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWELY'
		GROUP BY TimeSeriesID
		UNION
		SELECT TimeSeriesID, MAX(ID)-1 AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN PWELY d ON c.DateKey = d.DateKey
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWELY'
		GROUP BY TimeSeriesID
		UNION
		SELECT TimeSeriesID, MAX(ID) AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN PWELY d ON c.DateKey = d.DateKey
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWELY'
		GROUP BY TimeSeriesID
	)
	, MinMax AS (
		SELECT MIN(c.DateKey) AS StartDate, MAX(c.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dates d ON c.ID = d.DateID 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWELY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN MinMax
	WHERE t.TimeSeriesKey = 'PWELY'


	;
	WITH PWE2LY AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*2,DateKey)), 0)) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	,Dates AS (
		SELECT TimeSeriesID, MAX(ID)-2 AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN PWE2LY d ON c.DateKey = d.DateKey
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWE2LY'
		GROUP BY TimeSeriesID
		UNION
		SELECT TimeSeriesID, MAX(ID)-1 AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN PWE2LY d ON c.DateKey = d.DateKey
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWE2LY'
		GROUP BY TimeSeriesID
		UNION
		SELECT TimeSeriesID, MAX(ID) AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN PWE2LY d ON c.DateKey = d.DateKey
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWE2LY'
		GROUP BY TimeSeriesID
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT d.TimeSeriesID, c.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dates d ON c.ID = d.DateID
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWE2LY'

	;
	WITH PWE2LY AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*2,DateKey)), 0)) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	,Dates AS (
		SELECT TimeSeriesID, MAX(ID)-2 AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN PWE2LY d ON c.DateKey = d.DateKey
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWE2LY'
		GROUP BY TimeSeriesID
		UNION
		SELECT TimeSeriesID, MAX(ID)-1 AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN PWE2LY d ON c.DateKey = d.DateKey
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWE2LY'
		GROUP BY TimeSeriesID
		UNION
		SELECT TimeSeriesID, MAX(ID) AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN PWE2LY d ON c.DateKey = d.DateKey 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWE2LY'
		GROUP BY TimeSeriesID
	)
	, MinMax AS (
		SELECT MIN(c.DateKey) AS StartDate, MAX(c.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dates d ON c.ID = d.DateID 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'PWE2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN MinMax
	WHERE t.TimeSeriesKey = 'PWE2LY'


	;
	WITH CW AS (
		SELECT DISTINCT WeekID --Year, Week
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN CW d ON c.WeekID = d.WeekID 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CW'

	;
	WITH CW AS (
		SELECT DISTINCT WeekID --Year, Week
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN CW d ON c.WeekID = d.WeekID 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CW'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'CW'

	;
	WITH CWLY AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*1,DateKey)), 0)) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, c.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN CWLY d ON c.DateKey BETWEEN d.DateKey AND DATEADD(DAY,6,d.DateKey) 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CWLY'

	;
	WITH CWLY AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*1,DateKey)), 0)) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	, Dates AS (
		SELECT MIN(c.DateKey) AS StartDate, MAX(c.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN CWLY d ON c.DateKey BETWEEN d.DateKey AND DATEADD(DAY,6,d.DateKey)
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CWLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'CWLY'


	;
	WITH CW2LY AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*2,DateKey)), 0)) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, c.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN CW2LY d ON c.DateKey BETWEEN d.DateKey AND DATEADD(DAY,6,d.DateKey) 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CW2LY'

	;
	WITH CW2LY AS (
		SELECT DISTINCT DATEADD(DAY,-1,DATEADD(wk, DATEDIFF(wk,0,DATEADD(DAY,-364*2,DateKey)), 0)) AS DateKey
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @today
	)
	, Dates AS (
		SELECT MIN(c.DateKey) AS StartDate, MAX(c.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN CW2LY d ON c.DateKey BETWEEN d.DateKey AND DATEADD(DAY,6,d.DateKey) 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'CW2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'CW2LY'




	;
	WITH CW AS (
		SELECT DISTINCT WeekID
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = DATEADD(WEEK,1,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TOP 7 TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN CW d ON c.WeekID = d.WeekID 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'NW'

	;
	WITH CW AS (
		SELECT DISTINCT WeekID --Year, Week
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = DATEADD(WEEK,1,@today)
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN CW d ON c.WeekID = d.WeekID 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'NW'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'NW'


	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'Y'
	WHERE c.DateKey = @toDate

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'Y'
		WHERE c.DateKey = @toDate
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'Y'

	;
	WITH YLY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'Y'
		WHERE c.DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT t.TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN YLY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YLY'

	;
	WITH YLY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'Y'
		WHERE c.DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN YLY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'YLY'

	
	;
	WITH Y2LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'Y'
		WHERE c.DateKey = @toDate
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT t.TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN Y2LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'Y2LY'

	;
	WITH Y2LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'Y'
		WHERE c.DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Y2LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'Y2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'Y2LY'


	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T'
	WHERE c.DateKey = @today

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T'
		WHERE c.DateKey = @today
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T'

	;
	WITH TLY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T'
		WHERE c.DateKey = @today
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT t.TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN TLY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'TLY'

	;
	WITH TLY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T'
		WHERE c.DateKey = @today
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN TLY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'TLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'TLY'

	;
	WITH T2LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T'
		WHERE c.DateKey = @today
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT t.TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN T2LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T2LY'

	;
	WITH T2LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T'
		WHERE c.DateKey = @today
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN T2LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T2LY'


	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N7'
	WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,7,@today)

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N7'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,7,@today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N7'

	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N30'
	WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,30,@today)

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N30'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,30,@today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N30'


	;
	WITH N30LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N30'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,30,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT  t.TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN N30LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N30LY'
	
	;
	WITH N30LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey =  'N30'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,30,@today)
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN N30LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N30LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N30LY'

	;
	WITH N302LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N30'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,30,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT t.TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN N302LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N302LY'

	;
	WITH N302LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N30'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,30,@today)
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN N302LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N302LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N302LY'


	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N60'
	WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,60,@today)

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N60'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,60,@today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N60'


	;
	WITH N60LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N60'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,60,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT  t.TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN N60LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N60LY'
	
	;
	WITH N60LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey =  'N60'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,60,@today)
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN N60LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N60LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N60LY'



	;
	WITH N602LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N60'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,60,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT t.TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN N602LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N602LY'

	;
	WITH N602LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N60'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,60,@today)
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN N602LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N602LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N602LY'

	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N90'
	WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,90,@today)

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N90'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,90,@today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N90'


	;
	WITH N90LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N90'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,90,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT  t.TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN N90LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N90LY'
	
	;
	WITH N90LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey =  'N90'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,90,@today)
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN N90LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N90LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N90LY'

	;
	WITH N902LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N90'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,90,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT t.TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN N902LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N902LY'

	;
	WITH N902LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N90'
		WHERE c.DateKey > @today AND c.DateKey <= DATEADD(DAY,90,@today)
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN N902LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N902LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N902LY'


	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T14'
	WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-14,@today)

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T14'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-14,@today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T14'


	;
	WITH T14LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T14'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-14,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT  t.TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN T14LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T14LY'
	
	;
	WITH T14LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey =  'T14'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-14,@today)
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN T14LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T14LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T14LY'

	;
	WITH T142LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T14'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-14,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT t.TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN T142LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T142LY'

	;
	WITH T142LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T14'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-14,@today)
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN T142LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T142LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T142LY'


	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T7'
	WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-7,@today)

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T7'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-7,@today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T7'


	;
	WITH T7LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T7'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-7,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT  t.TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN T7LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T7LY'
	
	;
	WITH T7LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey =  'T7'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-7,@today)
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN T7LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T14LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T7LY'

	;
	WITH T72LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T7'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-7,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT t.TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN T72LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T72LY'

	;
	WITH T72LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T7'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-7,@today)
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN T72LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T72LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T72LY'


	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T30'
	WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-30,@today)

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T30'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-30,@today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T30'

	;
	WITH T30LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T30'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-30,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT  t.TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN T30LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T30LY'
	
	;
	WITH T30LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey =  'T30'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-30,@today)
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN T30LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T30LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T30LY'

	;
	WITH T302LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T30'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-30,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT t.TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN T302LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T302LY'

	;
	WITH T302LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T30'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-30,@today)
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN T302LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T302LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T302LY'


	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T60'
	WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-60,@today)

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T60'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-60,@today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T60'

	;
	WITH T60LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T60'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-60,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT  t.TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN T60LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T60LY'
	
	;
	WITH T60LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey =  'T60'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-60,@today)
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN T60LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T60LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T60LY'



	;
	WITH T602LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T60'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-60,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT t.TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN T602LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T602LY'

	;
	WITH T602LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T60'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-60,@today)
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN T602LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T602LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T602LY'

	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T90'
	WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-90,@today)

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T90'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-90,@today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T90'

	;
	WITH T90LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T90'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-90,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT  t.TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN T90LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T90LY'
	
	;
	WITH T90LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey =  'T90'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-90,@today)
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN T90LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T90LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T90LY'



	;
	WITH T902LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T90'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-90,@today)
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT t.TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN T902LY d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T902LY'

	;
	WITH T902LY AS (
		SELECT TimeSeriesID, ID AS DateID
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T90'
		WHERE c.DateKey < @today AND c.DateKey >= DATEADD(DAY,-90,@today)
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN T902LY d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T902LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15)) 
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T902LY'




	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T12M'
	WHERE c.MonthID > (SELECT MonthID - 12 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.MonthID <= (SELECT MonthID FROM dbo.CalendarFiscal WHERE DateKey = @today)

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T12M'
	WHERE c.MonthID > (SELECT MonthID - 12 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.MonthID <= (SELECT MonthID FROM dbo.CalendarFiscal WHERE DateKey = @today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T12M'


	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T26W'
	WHERE c.WeekID >= (SELECT WeekID - 26 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID < (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)


	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T26W'
	WHERE c.WeekID >= (SELECT WeekID - 26 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID < (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T26W'

	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T4W'
	WHERE c.WeekID >= (SELECT WeekID - 4 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID < (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)


	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T4W'
	WHERE c.WeekID >= (SELECT WeekID - 4 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID < (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T4W'

	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T4WLY'
	WHERE c.WeekID >= (SELECT WeekID - 4 - 52 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID < (SELECT WeekID - 52 FROM dbo.CalendarFiscal WHERE DateKey = @today)


	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T4WLY'
		WHERE c.WeekID >= (SELECT WeekID - 4 - 52 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID < (SELECT WeekID - 52 FROM dbo.CalendarFiscal WHERE DateKey = @today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T4WLY'

	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T4W2LY'
	WHERE c.WeekID >= (SELECT WeekID - 4 - 52*2 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID < (SELECT WeekID - 52*2 FROM dbo.CalendarFiscal WHERE DateKey = @today)


	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'T4W2LY'
		WHERE c.WeekID >= (SELECT WeekID - 4 - 52*2 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID < (SELECT WeekID - 52*2 FROM dbo.CalendarFiscal WHERE DateKey = @today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'T4W2LY'

	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N2W'
	WHERE c.WeekID <= (SELECT WeekID + 2 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID > (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N2W'
	WHERE c.WeekID <= (SELECT WeekID + 2 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID > (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N2W'

	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N4W'
	WHERE c.WeekID <= (SELECT WeekID + 4 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID > (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)


	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N4W'
	WHERE c.WeekID <= (SELECT WeekID + 4 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID > (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N4W'

	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N8W'
	WHERE c.WeekID <= (SELECT WeekID + 8 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID > (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)


	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N8W'
		WHERE c.WeekID <= (SELECT WeekID + 8 FROM dbo.CalendarFiscal WHERE DateKey = @today)
			AND c.WeekID > (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N8W'

	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N13W'
	WHERE c.WeekID <= (SELECT WeekID + 13 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID > (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)


	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N13W'
		WHERE c.WeekID <= (SELECT WeekID + 13 FROM dbo.CalendarFiscal WHERE DateKey = @today)
			AND c.WeekID > (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N13W'

	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N26W'
	WHERE c.WeekID <= (SELECT WeekID + 26 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID > (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)


	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N26W'
		WHERE c.WeekID <= (SELECT WeekID + 26 FROM dbo.CalendarFiscal WHERE DateKey = @today)
			AND c.WeekID > (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N26W'


	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N52W'
	WHERE c.WeekID <= (SELECT WeekID + 52 FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.WeekID > (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)


	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N52W'
		WHERE c.WeekID <= (SELECT WeekID + 52 FROM dbo.CalendarFiscal WHERE DateKey = @today)
			AND c.WeekID > (SELECT WeekID FROM dbo.CalendarFiscal WHERE DateKey = @today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N52W'


	;
	WITH MTDPW AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
			
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN MTDPW d ON c.Year = d.Year AND c.Month = d.Month
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'MTDPW'
	WHERE c.DateKey < (SELECT DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6))

	;
	WITH MTDPW AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN MTDPW d ON c.Year = d.Year AND c.Month = d.Month 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'MTDPW'
		WHERE c.DateKey < (SELECT DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6))
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'MTDPW'

		;
	WITH MTDPW AS (
		SELECT DateID 
		FROM dbo.M2MTimeSeries m2m
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesID = m2m.TimeSeriesID 
		WHERE t.TimeSeriesKey = 'MTDPW'
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN MTDPW d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'MTDPWLY'

	;
	WITH MTDPW AS (
		SELECT DateID 
		FROM dbo.M2MTimeSeries m2m
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesID = m2m.TimeSeriesID 
		WHERE t.TimeSeriesKey = 'MTDPW'
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN MTDPW d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'MTDPWLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'MTDPWLY'

	;
	WITH MTDPW AS (
		SELECT DateID 
		FROM dbo.M2MTimeSeries m2m
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesID = m2m.TimeSeriesID 
		WHERE t.TimeSeriesKey = 'MTDPW'
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN MTDPW d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'MTDPW2LY'

	;
	WITH MTDPW AS (
		SELECT DateID 
		FROM dbo.M2MTimeSeries m2m
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesID = m2m.TimeSeriesID 
		WHERE t.TimeSeriesKey = 'MTDPW'
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN MTDPW d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'MTDPW2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'MTDPW2LY'

	;
	WITH YTDPW AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
			
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN YTDPW d ON c.Year = d.Year 
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YTDPW'
	WHERE c.DateKey < (SELECT DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6))

	;
	WITH YTDPW AS (
		SELECT DISTINCT Year, Month
		FROM [dbo].[CalendarFiscal]
		WHERE DateKey = @toDate
	)
	, Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN YTDPW d ON c.Year = d.Year 
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YTDPW'
		WHERE c.DateKey < (SELECT DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6))
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'YTDPW'


	;
	WITH YTDPW AS (
		SELECT DateID 
		FROM dbo.M2MTimeSeries m2m
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesID = m2m.TimeSeriesID 
		WHERE t.TimeSeriesKey = 'YTDPW'
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN YTDPW d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YTDPWLY'

	;
	WITH YTDPW AS (
		SELECT DateID 
		FROM dbo.M2MTimeSeries m2m
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesID = m2m.TimeSeriesID 
		WHERE t.TimeSeriesKey = 'YTDPW'
	)
	, Dates AS (
		SELECT MIN(ly.DateKey) AS StartDate, MAX(ly.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN YTDPW d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YTDPWLY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'YTDPWLY'

	;
	WITH YTDPW AS (
		SELECT DateID 
		FROM dbo.M2MTimeSeries m2m
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesID = m2m.TimeSeriesID 
		WHERE t.TimeSeriesKey = 'YTDPW'
	)
	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ly2.ID
	FROM dbo.CalendarFiscal c
		INNER JOIN YTDPW d ON c.ID = d.DateID
		INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
		INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YTDPW2LY'

	;
	WITH YTDPW AS (
		SELECT DateID 
		FROM dbo.M2MTimeSeries m2m
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesID = m2m.TimeSeriesID 
		WHERE t.TimeSeriesKey = 'YTDPW'
	)
	, Dates AS (
		SELECT MIN(ly2.DateKey) AS StartDate, MAX(ly2.DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN YTDPW d ON c.ID = d.DateID
			INNER JOIN dbo.CalendarFiscal ly ON ly.DateKey = c.LYDate
			INNER JOIN dbo.CalendarFiscal ly2 ON ly2.DateKey = ly.LYDate
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'YTDPW2LY'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'YTDPW2LY'


	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, ID AS DateID
	FROM dbo.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N12M'
	WHERE c.MonthID > (SELECT MonthID FROM dbo.CalendarFiscal WHERE DateKey = @today)
		AND c.MonthID <= (SELECT MonthID + 12 FROM dbo.CalendarFiscal WHERE DateKey = @today)

	;WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM dbo.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'N12M'
	    WHERE c.MonthID > (SELECT MonthID FROM dbo.CalendarFiscal WHERE DateKey = @today)
			AND c.MonthID <= (SELECT MonthID + 12 FROM dbo.CalendarFiscal WHERE DateKey = @today)
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' + CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'N12M'


	INSERT INTO dbo.M2MTimeSeries
	SELECT TimeSeriesID, DateID
	FROM Dim.CalendarFiscal c
		INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'F'
	WHERE c.DateKey > @toDate

	;
	WITH Dates AS (
		SELECT MIN(DateKey) AS StartDate, MAX(DateKey) AS EndDate
		FROM Dim.CalendarFiscal c
			INNER JOIN Dim.TimeSeries t ON t.TimeSeriesKey = 'F'
	)
	UPDATE t
	SET TimeSeriesDesc = TimeSeriesName + ' ' +  CAST(StartDate AS VARCHAR(15)) + ' - ' + CAST(EndDate AS VARCHAR(15))
		,TimeSeriesType = 'Future'
	FROM Dim.TimeSeries t
		CROSS JOIN Dates
	WHERE t.TimeSeriesKey = 'F'

	UPDATE cf  
	SET cf.Future = CASE WHEN m2m.DateID IS NOT NULL THEN 'Future' ELSE NULL END
	FROM  dbo.DimCalendarFiscal cf
		INNER JOIN dbo.M2MTimeSeries m2m ON m2m.DateID = cf.DateID AND (TimeSeriesID = 82 OR TimeSeriesID = 7)


	
END
GO
