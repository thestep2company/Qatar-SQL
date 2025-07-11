USE [Operations]
GO
/****** Object:  View [Fact].[M2MForecastVersion]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[M2MForecastVersion] AS 
WITH CurrentMonth AS (
	SELECT MAX(CurrentMonthID) CurrentMonthID 
	FROM dbo.DimCalendarFiscal
)
SELECT DISTINCT BudgetID, ForecastVersion, ForecastName, fv.Year, cm.CurrentMonthID + CASE WHEN BudgetID > 0 THEN 0 ELSE BudgetID END AS AcutalMonths, [Month Sort], cf.MonthID, cf.DateID
FROM Forecast.ForecastVersion fv
	CROSS JOIN CurrentMonth cm
	INNER JOIN dbo.DimCalendarFiscal cf ON fv.Year = cf.Year AND (cf.MonthID < cm.CurrentMonthID + CASE WHEN BudgetID > 0 THEN 0 ELSE BudgetID END - (YEAR(GETDATE()) - cf.Year))
WHERE (BudgetID < 0 OR BudgetID = 13)
--ORDER BY BudgetID, [Month Sort]
GO
