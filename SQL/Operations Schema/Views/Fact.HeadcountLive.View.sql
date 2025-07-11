USE [Operations]
GO
/****** Object:  View [Fact].[HeadcountLive]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




	CREATE VIEW [Fact].[HeadcountLive] AS
	SELECT [EmployeeID]
		, CASE WHEN DATEDIFF(DAY,[Hire Date],GETDATE()) > 30 THEN 1 ELSE 0 END AS HeadcountTypeID
		, [LocationID]
		, [DateID]
		, CASE WHEN [Hire Date] = cf.DateKey THEN [EmployeeID] END AS Hire
		, NULL AS Term
		, DATEDIFF(DAY,[Hire Date],GETDATE()) AS Tenure
	FROM Dim.Employee e
			LEFT JOIN Dim.CalendarFiscal cf ON cf.DateKey >= [Hire Date] AND cf.DateKey <= [Date Terminated]
			LEFT JOIN Dim.Location l ON e.LocationKey = l.LocationKey
	WHERE cf.DateKey >= '2019-01-01' AND cf.DateKey < GETDATE()
		AND ((ISNUMERIC([Employee ID]) = 1 AND cf.DateKey <= '2023-12-31') --Kronos IDs
		 OR (ISNUMERIC([Employee ID]) = 0 AND cf.DateKey > '2023-12-31')) --ADP IDs
		AND cf.DateKey >=
			(
		SELECT MIN(DateKey) AS DateKey
			FROM Dim.M2MTimeSeries m2m
			LEFT JOIN Dim.TimeSeries ts ON m2m.TimeSeriesID = ts.TimeSeriesID
			LEFT JOIN dbo.DimCalendarFiscal cf ON m2m.DateID = cf.DateID
		WHERE ts.TimeSeriesKey = 'T4W'
		)
	GROUP BY [EmployeeID]
		, [LocationID]
		, [DateID]
		, [Hire Date] 
		, cf.DateKey 
	UNION
	SELECT [EmployeeID]
		, CASE WHEN DATEDIFF(DAY,[Hire Date],[Date Terminated]) > 30 THEN 1 ELSE 0 END AS HeadcountTypeID
		, [LocationID]
		, [DateID]
		, NULL AS Hire
		, [EmployeeID] AS Term
		, DATEDIFF(DAY,[Hire Date],[Date Terminated]) AS Tenure
	FROM Dim.Employee e
			LEFT JOIN Dim.CalendarFiscal cf ON cf.DateKey = [Date Terminated]
			LEFT JOIN Dim.Location l ON e.LocationKey = l.LocationKey
	WHERE cf.DateKey >= '2019-01-01' AND cf.DateKey < GETDATE()
		AND ((ISNUMERIC([Employee ID]) = 1 AND cf.DateKey <= '2023-12-31') --Kronos IDs
		 OR (ISNUMERIC([Employee ID]) = 0 AND cf.DateKey > '2023-12-31')) --ADP IDs
		AND cf.DateKey >=
			(
		SELECT MIN(DateKey) AS DateKey
			FROM Dim.M2MTimeSeries m2m
			LEFT JOIN Dim.TimeSeries ts ON m2m.TimeSeriesID = ts.TimeSeriesID
			LEFT JOIN dbo.DimCalendarFiscal cf ON m2m.DateID = cf.DateID
		WHERE ts.TimeSeriesKey = 'T4W'
		)
	GROUP BY [EmployeeID]
		, [LocationID]
		, [DateID]
		, [Hire Date]
		, [Date Terminated]
GO
