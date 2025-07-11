USE [Forecast]
GO
/****** Object:  View [dbo].[M2MFactForecastVersion20250402]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[M2MFactForecastVersion20250402] AS 
WITH CTE AS (
	SELECT BudgetID
		, ForecastVersion
		, LEFT(ForecastName,4) AS Year
		, SUBSTRING(ForecastVersion,1,CHARINDEX('+',ForecastVersion)-1) AS XMonths
		, LEFT(SUBSTRING(ForecastVersion,CHARINDEX('+',ForecastVersion)+1,100),2) AS YMonths
	FROM dbo.ForecastVersion
)
SELECT 1 AS X, CAST(NULL AS INT) AS Y, CTE.BudgetID, DateID 
FROM CTE 
	INNER JOIN dbo.DimCalendarFiscal cf ON CTE.YEAR = cf.YEAR AND CTE.XMonths >= CAST([Month Seasonality Sort] AS INT)
UNION
SELECT NULL AS X, 1 AS Y, CTE.BudgetID, DateID  
FROM CTE 
	INNER JOIN dbo.DimCalendarFiscal cf ON CTE.YEAR = cf.YEAR AND CTE.XMonths < CAST([Month Seasonality Sort] AS INT)
GO
