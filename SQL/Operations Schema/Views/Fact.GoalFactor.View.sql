USE [Operations]
GO
/****** Object:  View [Fact].[GoalFactor]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE VIEW [Fact].[GoalFactor] AS
	SELECT 
		   c2.DateID
		  ,l.LocationID AS PlantID
		  ,s.ShiftID
		  ,sh.ShiftOffsetID
		  ,MAX(ISNULL((sh.Hours*1.0 / 
			DATEDIFF(HOUR,
				CASE WHEN CAST(sh.Start_Date_Time  AS DATE) < CAST(sh.End_Date_time AS DATE) AND CAST(sh.Start_Date_Time  AS DATE) <> sh.TransDate THEN CAST(sh.End_Date_Time AS DATE)
					ELSE  sh.Start_Date_Time
				END,
				CASE WHEN CAST(sh.Start_Date_Time  AS DATE) < CAST(sh.End_Date_time AS DATE) AND CAST(sh.Start_Date_Time  AS DATE) = sh.TransDate THEN CAST(sh.End_Date_Time AS DATE) 
					 ELSE sh.End_Date_Time 
				END)),1))
			- MAX(CASE WHEN CASE WHEN sh.ShiftOffsetID = 1 THEN DATEADD(HOUR,-6,GETDATE()) ELSE GETDATE() END BETWEEN sh.Start_Date_Time AND sh.End_Date_Time THEN 1- DATEPART(MINUTE,GETDATE())/60.0 ELSE 0 END)/MAX(DATEDIFF(HOUR,sh.Start_Date_Time,sh.End_Date_Time))--to the minute	
			AS [Percent]
	FROM Manufacturing.Forecast g
		LEFT JOIN dbo.CalendarFiscal c1 ON g.Year = c1.Year  AND g.Week = c1.Week
		INNER JOIN xref.ProductionForecast pf ON g.PlantKey = pf.Org AND pf.Date = c1.DateKey
		LEFT JOIN dbo.DimLocation l ON g.PlantKey = l.LocationKey
		LEFT JOIN dbo.DimShift s ON pf.Shift = s.ShiftKey
		INNER JOIN dbo.FactShiftHoursLive sh ON s.ShiftID = sh.ShiftID AND l.LocationID = sh.LocationID AND c1.Datekey = CAST(Start_Date_Time AS DATE)
		LEFT JOIN dbo.DimCalendarFiscal c2 ON sh.TransDate = c2.DateKey
	--WHERE c2.DateKey = '2021-12-16' AND l.LocationKey = '133' --AND s.ShiftKey = 'A'
	GROUP BY 
		   c2.DateID
		  ,l.LocationID
		  ,s.ShiftID
		  ,sh.ShiftOffsetID
GO
