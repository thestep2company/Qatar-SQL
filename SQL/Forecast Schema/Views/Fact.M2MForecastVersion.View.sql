USE [Forecast]
GO
/****** Object:  View [Fact].[M2MForecastVersion]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[M2MForecastVersion] AS 
WITH CurrentMonth AS (
	SELECT MAX(CurrentMonthID) CurrentMonthID 
	FROM dbo.DimCalendarFiscal
)
, Offset AS ( --if the previous forecast matches the demand setting, do not offset
	 SELECT ISNULL(CASE WHEN fp.[ForecastMonth] IS NOT NULL THEN 0 END,-1) AS Offset
	 FROM dbo.DimCalendarFiscal cf
		LEFT JOIN dbo.ForecastPeriod fp ON cf.[Month Sort] = fp.[ForecastMonth]
		LEFT JOIN dbo.ForecastVersion fv ON fv.BudgetID = -1
	 WHERE cf.DateKey = fv.ForecastDate
)
SELECT DISTINCT 
	BudgetID
	, ForecastVersion
	, ForecastName
	, fv.Year
	, cm.CurrentMonthID + CASE WHEN BudgetID > 0 THEN 0 ELSE BudgetID END AS AcutalMonths
	, [Month Sort]
	, cf.MonthID
	, cf.DateID
FROM dbo.ForecastVersion fv
	CROSS JOIN CurrentMonth cm
	CROSS JOIN Offset
	INNER JOIN dbo.DimCalendarFiscal cf ON fv.Year = cf.Year 
	AND (cf.MonthID <= cm.CurrentMonthID + CASE WHEN BudgetID > 0 THEN -1 ELSE BudgetID + Offset END ) 
WHERE (BudgetID < 0 OR BudgetID >= 13)
	

GO
