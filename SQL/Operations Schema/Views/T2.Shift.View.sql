USE [Operations]
GO
/****** Object:  View [T2].[Shift]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [T2].[Shift] AS 
	WITH CTE AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY [ORG], [SHIFT], [Day_Of_Week] ORDER BY [START_DATE_TIME]) AS Row_Number
		  ,[SHIFT_ID]
		  ,[ORG]
		  ,[START_DATE_TIME]
		  ,[END_DATE_TIME]
		  ,[SHIFT]
		  ,DATEPART(WEEKDAY,[START_DATE_TIME]) AS [Day_Of_Week]
		  ,DATEPART(HOUR,[START_DATE_TIME]) AS StartHour
		  ,DATEPART(HOUR,[END_DATE_TIME]) AS EndHour
	  FROM Manufacturing.Shift
	  WHERE CurrentRecord = 1
	)
	, Changes AS (
		SELECT 
		  a.[ORG]
		  ,a.[START_DATE_TIME]
		  ,a.[END_DATE_TIME]
		  ,a.[SHIFT]
		  ,a.[DAY_OF_WEEK]
		  ,a.StartHour
		  ,a.EndHour
		FROM CTE a
		WHERE a.Row_Number = 1
		UNION
		SELECT 
		   a.[ORG]
		  ,a.[START_DATE_TIME]
		  ,a.[END_DATE_TIME]
		  ,a.[SHIFT]
		  ,a.[DAY_OF_WEEK]
		  ,a.StartHour
		  ,a.EndHour
		FROM CTE a
			LEFT JOIN CTE b ON a.Org = b.Org AND a.Shift = b.Shift AND a.[Day_Of_Week] = b.[Day_Of_Week] AND a.Row_Number = b.Row_Number + 1
		WHERE a.StartHour <> b.StartHour OR a.EndHour <> b.EndHour
	)
	, Ranking AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY Org, Shift, Day_Of_Week ORDER BY Start_Date_Time) AS Row_Number
			,a.*
		FROM Changes a
	)
	SELECT a.Org, a.Shift, a.StartHour, a.EndHour, a.Day_Of_Week
		, a.Start_Date_Time AS StartDate, ISNULL(b.Start_Date_Time,'9999-12-31') AS EndDate
		, CASE WHEN b.Start_Date_Time IS NULL THEN 1 ELSE 0 END AS CurrentRecord
	FROM Ranking a
		LEFT JOIN Ranking b ON a.Org = b.Org AND a.Shift = b.Shift AND a.Day_Of_Week = b.Day_Of_Week AND a.Row_Number = b.Row_Number - 1
	--ORDER BY a.Org, a.Shift, a.Day_Of_Week, a.Start_Date_Time
GO
