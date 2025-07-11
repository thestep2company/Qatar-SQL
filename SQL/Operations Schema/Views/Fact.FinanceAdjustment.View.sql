USE [Operations]
GO
/****** Object:  View [Fact].[FinanceAdjustment]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Fact].[FinanceAdjustment] AS
WITH Calendar AS ( --common table expression to group data by year, period and min(dateID)
	SELECT YEAR, [Month Seasonality] AS [Month], DateKey, DateID --MIN(DateKey) AS DateKey, MIN(DateID) AS DateID 
	FROM dbo.DimCalendarFiscal cf 
	WHERE [Day of Week] <> 'Sat' AND [Day of Week] <> 'Sun'
	GROUP BY YEAR, [Month Seasonality], DateKey, DateID
)
,DateCount AS(
	SELECT Year,
	Month,
	COUNT(DateID) AS [WeekdayCount]
	FROM Calendar
	GROUP BY Year, Month
	)
SELECT pm.ProductID
	, cm.CustomerID
	, dc.DemandClassID
	, BudgetID AS ForecastID
	, DateID
	, ct.WeekdayCount
	,[Gross Sales Manufactured] / ct.WeekdayCount AS [Gross Sales Manufactured]
	,[Add: Invoiced Freight] / ct.WeekdayCount AS [Add: Invoiced Freight]
	,[Less: Deductions] / ct.WeekdayCount AS [Less: Deductions]
	,[Standard COGS - Manuf FG] / ct.WeekdayCount  AS [Standard COGS - Manuf FG]
	,[Standard COGS - Labor] / ct.WeekdayCount AS [Standard COGS - Labor]
FROM dbo.FinanceAdjustment a
	LEFT JOIN Forecast.ForecastVersion v ON v.ForecastVersion = a.ForecastVersion AND a.Year = v.Year
	LEFT JOIN Calendar c ON a.Year = c.Year AND a.Month = c.Month
	LEFT JOIN DateCount ct ON a.Year = ct.Year AND a.Month = ct.Month
	LEFT JOIN dbo.DimCustomerMaster cm ON cm.CustomerKey = 'Adjustment'
	LEFT JOIN dbo.DimProductMaster pm ON pm.ProductKey = 'Adjustment'
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = 'Adjustment'
GO
