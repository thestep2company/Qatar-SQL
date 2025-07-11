USE [Operations]
GO
/****** Object:  View [Dim].[ShiftControl]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Dim].[ShiftControl] 
WITH SCHEMABINDING
AS 
SELECT ROW_NUMBER() OVER (PARTITION BY LocationKey ORDER BY Start_Date_Time DESC, [Shift_ID] ASC) AS ShiftControlID
	  ,LocationID
	 ,[Shift_ID] AS CurrentShiftID
	 ,LEFT(Day_Of_Week,3) + ' - ' + Shift + ' Shift' AS ShiftName
	 ,CASE  WHEN l.LocationKey = '111' AND DATEPART(HOUR,Start_Date_Time) = 6 THEN '6-8' 
		    WHEN l.LocationKey = '111' AND DATEPART(HOUR,Start_Date_Time) = 18 THEN '6-8' 
			WHEN Shift = 'A' THEN '6-8'
			WHEN Shift = 'B' THEN '2-4'
			WHEN Shift = 'C' THEN '10-12'
	 END ShiftHourBlock1
	 ,CASE  WHEN l.LocationKey = '111' AND DATEPART(HOUR,Start_Date_Time) = 6 THEN '8-10' 
		    WHEN l.LocationKey = '111' AND DATEPART(HOUR,Start_Date_Time) = 18 THEN '8-10' 
			WHEN Shift = 'A' THEN '8-10'
			WHEN Shift = 'B' THEN '4-6'
			WHEN Shift = 'C' THEN '12-2'
	 END ShiftHourBlock2
	 ,CASE  WHEN l.LocationKey = '111' AND DATEPART(HOUR,Start_Date_Time) = 6 THEN '10-12' 
		    WHEN l.LocationKey = '111' AND DATEPART(HOUR,Start_Date_Time) = 18 THEN '10-12' 
			WHEN Shift = 'A' THEN '10-12'
			WHEN Shift = 'B' THEN '6-8'
			WHEN Shift = 'C' THEN '2-4'
	 END ShiftHourBlock3
	 ,CASE  WHEN l.LocationKey = '111' AND DATEPART(HOUR,Start_Date_Time) = 6 THEN '12-2' 
		    WHEN l.LocationKey = '111' AND DATEPART(HOUR,Start_Date_Time) = 18 THEN '12-2' 
			WHEN Shift = 'A' THEN '12-2'
			WHEN Shift = 'B' THEN '8-10'
			WHEN Shift = 'C' THEN '4-6'
	 END ShiftHourBlock4
	 ,CASE WHEN l.LocationKey = '111' AND DATEPART(HOUR,Start_Date_Time) = 6 THEN '2-4' 
		   WHEN l.LocationKey = '111' AND DATEPART(HOUR,Start_Date_Time) = 18 THEN '2-4' 
	 END ShiftHourBlock5
	 ,CASE WHEN l.LocationKey = '111' AND DATEPART(HOUR,Start_Date_Time) = 6 THEN '4-6' 
		   WHEN l.LocationKey = '111' AND DATEPART(HOUR,Start_Date_Time) = 18 THEN '4-6' 
	 END ShiftHourBlock6
FROM Manufacturing.Shift s
	LEFT JOIN dbo.DimLocation l ON s.Org = l.LocationKey
WHERE (DATEADD(minute,-10,GETDATE()) BETWEEN Start_Date_Time AND End_Date_Time 
	OR Start_Date_Time BETWEEN 
		--DATEADD(day,-15,GETDATE()) 
		(
		SELECT MIN(DateKey) AS DateKey
			FROM dbo.DimM2MTimeSeries m2m
			LEFT JOIN dbo.DimTimeSeries ts ON m2m.TimeSeriesID = ts.TimeSeriesID
			LEFT JOIN dbo.DimCalendarFiscal cf ON m2m.DateID = cf.DateID
		WHERE ts.TimeSeriesKey = 'PW'
		)
		AND DATEADD(minute,-10,GETDATE()))
	AND CurrentRecord = 1

GO
