USE [Operations]
GO
/****** Object:  View [Error].[HourLaborCategory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[HourLaborCategory] AS 

  SELECT *
    FROM Kronos.EmployeeHours
  WHERE --[Labor Category Name (Path)] <> '' AND 
	CAST([Work Date] AS DATE) > '2022-09-01' 
	AND [Labor Category Name] <> '' 
	AND CurrentRecord = 1 AND StartDate > '2022-08-30 06:06:38.900'
GO
