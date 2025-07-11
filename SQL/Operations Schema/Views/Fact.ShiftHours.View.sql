USE [Operations]
GO
/****** Object:  View [Fact].[ShiftHours]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[ShiftHours] AS
WITH OffsetShift AS (
	SELECT
		Shift_ID
		, Org
		, Shift
		, DATEADD(HOUR,-6,Start_Date_Time) AS Start_Date_Time 
		, DATEADD(HOUR,-6,End_Date_Time) AS End_Date_time
	FROM [Manufacturing].[Shift] s
	WHERE s.CurrentRecord = 1 AND (HasProduction = 1 OR (End_Date_Time > GETDATE() AND End_Date_Time <=  DATEADD(DAY,-1,DATEADD(HOUR,6,DATEADD(week,1,dateadd(week, datediff(week, 0, getdate()), 0))))))  --sunday 6am cutoff for week
)
, CTE AS (
  --no offset, no overnight shifts
  SELECT 
	   0 AS ShiftOffsetID
	  ,1 AS Calc
	  ,s.[Shift_ID]
      ,[Org]
	  ,CAST([Start_Date_Time] AS DATE) AS TransDate 
      ,[Start_Date_Time]
      ,[End_Date_Time]
      ,s.[Shift]
	  ,[HourID]		
  FROM [Manufacturing].[Shift] s
	LEFT JOIN dbo.DimHour h ON HourID >= DATEPART(HOUR,Start_Date_Time) AND HourID < DATEPART(HOUR,End_Date_Time)
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = CAST(s.Start_Date_Time AS DATE)
  WHERE s.CurrentRecord = 1 AND CAST(Start_Date_Time AS DATE) = CAST(End_Date_Time AS DATE)
	AND (HasProduction = 1 OR (End_Date_Time > GETDATE() AND End_Date_Time <=  DATEADD(DAY,-1,DATEADD(HOUR,6,DATEADD(week,1,dateadd(week, datediff(week, 0, getdate()), 0))))))
	AND cf.Year >= 2019 --AND 2021
  GROUP BY 
	   s.[Shift_ID]
      ,[Org]
	  ,CAST([Start_Date_Time] AS DATE) 
      ,[Start_Date_Time]
      ,[End_Date_Time]
      ,s.[Shift]
	  ,[HourID]	
  UNION ALL
  --no offset, overnight shift
  SELECT 0 AS ShiftOffsetID
	  ,2 AS Calc
	  ,s.[Shift_ID]
      ,[Org]
	  ,CAST([Start_Date_Time] AS DATE) AS TransDate 
      ,[Start_Date_Time]
      ,CAST(CAST([End_Date_Time] AS DATE) AS DATETIME) AS End_Date_Time
      ,s.[Shift]
	  ,[HourID]		
  FROM [Manufacturing].[Shift] s
	LEFT JOIN dbo.DimHour h ON HourID >= DATEPART(HOUR,Start_Date_Time) AND HourID <= DATEPART(HOUR,DATEADD(SECOND,-1,DATEADD(HOUR,-6,End_Date_Time)))
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = CAST(s.Start_Date_Time AS DATE)
  WHERE s.CurrentRecord = 1 AND CAST(Start_Date_Time AS DATE) <> CAST(End_Date_Time AS DATE)
  	AND (HasProduction = 1 OR (End_Date_Time > GETDATE() AND End_Date_Time <=  DATEADD(DAY,-1,DATEADD(HOUR,6,DATEADD(week,1,dateadd(week, datediff(week, 0, getdate()), 0))))))
  GROUP BY 
	   s.[Shift_ID]
      ,[Org]
	  ,CAST([Start_Date_Time] AS DATE) 
      ,[Start_Date_Time]
      ,[End_Date_Time]
      ,s.[Shift]
	  ,[HourID]	
  UNION ALL
  --no offset, next day portion of 6pm start
  SELECT 0 AS ShiftOffsetID
	  ,3 AS Calc
	  ,s.[Shift_ID]
      ,[Org]
	  ,CAST([End_Date_Time] AS DATE) AS TransDate 
      ,CAST(CAST([End_Date_Time] AS DATE) AS DATETIME) AS [Start_Date_Time]
      ,[End_Date_Time]
      ,s.[Shift]
	  ,[HourID]		
  FROM [Manufacturing].[Shift] s
	LEFT JOIN dbo.DimHour h ON HourID >= DATEPART(HOUR,DATEADD(HOUR,6,Start_Date_Time)) AND HourID < DATEPART(HOUR,End_Date_Time)
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = CAST(s.Start_Date_Time AS DATE)
  WHERE s.CurrentRecord = 1 AND CAST(Start_Date_Time AS DATE) <> CAST(End_Date_Time AS DATE) AND DATEPART(HOUR,Start_Date_Time) = 18
	  AND (HasProduction = 1 OR (End_Date_Time > GETDATE() AND End_Date_Time <=  DATEADD(DAY,-1,DATEADD(HOUR,6,DATEADD(week,1,dateadd(week, datediff(week, 0, getdate()), 0))))))
  GROUP BY 
	   s.[Shift_ID]
      ,[Org]
	  ,CAST([Start_Date_Time] AS DATE) 
      ,[Start_Date_Time]
      ,[End_Date_Time]
      ,s.[Shift]
	  ,[HourID]	
  UNION ALL
  --no offset, next day portion of 10pm start
  SELECT 0 AS ShiftOffsetID
	  ,4 AS Calc
	  ,s.[Shift_ID]
      ,[Org]
	  ,CAST([End_Date_Time] AS DATE) AS TransDate 
      ,CAST(CAST([End_Date_Time] AS DATE) AS DATETIME) AS [Start_Date_Time]
      ,[End_Date_Time]
      ,s.[Shift]
	  ,[HourID]		
  FROM [Manufacturing].[Shift] s
	LEFT JOIN dbo.DimHour h ON HourID >= DATEPART(HOUR,DATEADD(HOUR,2,Start_Date_Time)) AND HourID < DATEPART(HOUR,End_Date_Time)
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = CAST(s.Start_Date_Time AS DATE)
  WHERE s.CurrentRecord = 1 AND CAST(Start_Date_Time AS DATE) <> CAST(End_Date_Time AS DATE) AND DATEPART(HOUR,Start_Date_Time) = 22
  	  AND (HasProduction = 1 OR (End_Date_Time > GETDATE() AND End_Date_Time <=  DATEADD(DAY,-1,DATEADD(HOUR,6,DATEADD(week,1,dateadd(week, datediff(week, 0, getdate()), 0))))))
  GROUP BY 
	   s.[Shift_ID]
      ,[Org]
	  ,CAST([Start_Date_Time] AS DATE) 
      ,[Start_Date_Time]
      ,[End_Date_Time]
      ,s.[Shift]
	  ,[HourID]	
  UNION ALL
  --offset shifts, same day end date
  SELECT 1 AS ShiftOffsetID
	  ,1 AS Calc
	  ,s.[Shift_ID]
      ,[Org]
	  ,CAST([Start_Date_Time] AS DATE) AS TransDate 
      ,[Start_Date_Time]
      ,[End_Date_Time]
      ,s.[Shift]
	  ,[HourID]		
  FROM OffsetShift s
	LEFT JOIN dbo.DimHour h ON HourID >= DATEPART(HOUR,Start_Date_Time) AND HourID < DATEPART(HOUR,End_Date_Time)
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = CAST(s.Start_Date_Time AS DATE)
  WHERE CAST(Start_Date_Time AS DATE) = CAST(End_Date_Time AS DATE)
	AND cf.Year >= 2019 --AND 2021
  GROUP BY 
	   s.[Shift_ID]
      ,[Org]
	  ,CAST([Start_Date_Time] AS DATE) 
      ,[Start_Date_Time]
      ,[End_Date_Time]
      ,s.[Shift]
	  ,[HourID]	
  UNION ALL
  --offset shifts, different day end date
  SELECT 1 AS ShiftOffsetID
	  ,2 AS Calc
	  ,s.[Shift_ID]
      ,[Org]
	  ,CAST([Start_Date_Time] AS DATE) AS TransDate 
      ,[Start_Date_Time]
      ,[End_Date_Time]
      ,s.[Shift]
	  ,[HourID]		
  FROM OffsetShift s
	LEFT JOIN dbo.DimHour h ON HourID >= DATEPART(HOUR,Start_Date_Time) 
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = CAST(s.Start_Date_Time AS DATE)
  WHERE  CAST(Start_Date_Time AS DATE) <> CAST(End_Date_Time AS DATE)
  GROUP BY 
	   s.[Shift_ID]
      ,[Org]
	  ,CAST([Start_Date_Time] AS DATE) 
      ,[Start_Date_Time] 
      ,[End_Date_Time]
      ,s.[Shift]
	  ,[HourID]	
)
SELECT 
	Shift_ID AS CurrentShiftID, l.LocationID, ShiftOffsetID, s.ShiftID, Start_Date_Time, End_Date_Time, cf.DateID, TransDate
	, CASE WHEN GETDATE() BETWEEN Start_Date_Time AND End_Date_Time THEN DATEDIFF(HOUR,End_Date_Time,GETDATE()) + 1
		   WHEN GETDATE() > End_Date_Time THEN 0
		   WHEN GETDATE() < End_Date_Time THEN -COUNT(*)
	 END
	+ COUNT(*)
	- MAX(CASE WHEN GETDATE() BETWEEN Start_Date_Time AND End_Date_Time 
		THEN 1- DATEPART(MINUTE,GETDATE())/60.0 ELSE 0 END)/MAX(DATEDIFF(HOUR,Start_Date_Time,End_Date_Time)) AS Hours --to the minute	
	--, CASE WHEN DATEADD(HOUR,-6,GETDATE()) BETWEEN Start_Date_Time AND End_Date_Time THEN DATEDIFF(HOUR,End_Date_Time,GETDATE()) + 1
	--	   WHEN DATEADD(HOUR,-6,GETDATE()) > End_Date_Time THEN 0
	--	   WHEN DATEADD(HOUR,-6,GETDATE()) < End_Date_Time THEN -COUNT(*)
	-- END
	--,COUNT(*)
	--,MAX(CASE WHEN DATEADD(HOUR,-6,GETDATE()) BETWEEN Start_Date_Time AND End_Date_Time
	--	THEN 1- DATEPART(MINUTE,GETDATE())/60.0 ELSE 0 END)/MAX(DATEDIFF(HOUR,Start_Date_Time,End_Date_Time)) AS Hours --to the minute	
	--, CASE WHEN GETDATE() BETWEEN Start_Date_Time AND End_Date_Time THEN 1
	--	   WHEN GETDATE() > End_Date_Time THEN 2
	--	   WHEN GETDATE() < End_Date_Time THEN 3
	-- END
FROM CTE
	LEFT JOIN dbo.DimLocation l ON cte.Org = l.LocationKey
	LEFT JOIN dbo.DimShift s ON cte.Shift = s.ShiftKey
	LEFT JOIN dbo.DimCalendarFiscal cf ON cte.TransDate = cf.DateKey
WHERE ShiftOffsetID = 0
--cf.DateKey >= '2021-10-14' AND l.LocationKey = '133' --AND s.ShiftKey = 'A' AND 
GROUP BY Shift_ID,  l.LocationID, ShiftOffsetID,  s.ShiftID, Start_Date_Time, End_Date_Time, cf.DateID, TransDate
UNION
SELECT 
	Shift_ID AS CurrentShiftID, l.LocationID, ShiftOffsetID, s.ShiftID, Start_Date_Time, End_Date_Time, cf.DateID, TransDate
	, CASE WHEN DATEADD(HOUR,-6,GETDATE()) BETWEEN Start_Date_Time AND End_Date_Time THEN DATEDIFF(HOUR,End_Date_Time,DATEADD(HOUR,-6,GETDATE())) + 1
		   WHEN DATEADD(HOUR,-6,GETDATE()) > End_Date_Time THEN 0
		   WHEN DATEADD(HOUR,-6,GETDATE()) < End_Date_Time THEN -COUNT(*)
	 END
	+ COUNT(*)
	- MAX(CASE WHEN DATEADD(HOUR,-6,GETDATE()) BETWEEN Start_Date_Time AND End_Date_Time
		THEN 1- DATEPART(MINUTE,GETDATE())/60.0 ELSE 0 END)/MAX(DATEDIFF(HOUR,Start_Date_Time,End_Date_Time)) AS Hours --to the minute	
	
	--, CASE WHEN DATEADD(HOUR,-6,GETDATE()) BETWEEN Start_Date_Time AND End_Date_Time THEN DATEDIFF(HOUR,End_Date_Time,DATEADD(HOUR,-6,GETDATE())) + 1
	--	   WHEN DATEADD(HOUR,-6,GETDATE()) > End_Date_Time THEN 0
	--	   WHEN DATEADD(HOUR,-6,GETDATE()) < End_Date_Time THEN -COUNT(*)
	-- END
	--,COUNT(*)
	
	--,MAX(CASE WHEN DATEADD(HOUR,-6,GETDATE()) BETWEEN Start_Date_Time AND End_Date_Time
	--	THEN 1- DATEPART(MINUTE,GETDATE())/60.0 ELSE 0 END)/MAX(DATEDIFF(HOUR,Start_Date_Time,End_Date_Time)) AS Hours --to the minute	
	--, CASE WHEN DATEADD(HOUR,-6,GETDATE()) BETWEEN Start_Date_Time AND End_Date_Time THEN 1
	--	   WHEN DATEADD(HOUR,-6,GETDATE()) > End_Date_Time THEN 2
	--	   WHEN DATEADD(HOUR,-6,GETDATE()) < End_Date_Time THEN 3
	-- END
FROM CTE
	LEFT JOIN dbo.DimLocation l ON cte.Org = l.LocationKey
	LEFT JOIN dbo.DimShift s ON cte.Shift = s.ShiftKey
	LEFT JOIN dbo.DimCalendarFiscal cf ON cte.TransDate = cf.DateKey
WHERE ShiftOffsetID = 1
--cf.DateKey >= '2021-10-14' AND l.LocationKey = '133' --AND s.ShiftKey = 'A' AND 
GROUP BY Shift_ID,  l.LocationID, ShiftOffsetID,  s.ShiftID, Start_Date_Time, End_Date_Time, cf.DateID, TransDate
--ORDER BY STart_Date_Time DESC
GO
