USE [Operations]
GO
/****** Object:  View [Dim].[ShiftTiming]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Dim].[ShiftTiming] AS 
SELECT DISTINCT 
       [Org]
      ,CAST(DATEPART(HOUR,[Start_Date_Time]) AS INT) AS StartHour
      ,CAST(DATEPART(HOUR,[End_Date_Time]) AS INT) AS EndHour
	  ,CAST(DATEDIFF(HOUR,[Start_Date_Time],[End_Date_Time]) AS INT) AS Length
      ,[Shift]
      ,[Day_Of_Week]
  FROM [Manufacturing].[Shift]
  WHERE [Start_Date_Time] >= '2019-01-01'
GO
