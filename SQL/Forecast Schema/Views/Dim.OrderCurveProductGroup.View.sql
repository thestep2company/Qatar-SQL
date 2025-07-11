USE [Forecast]
GO
/****** Object:  View [Dim].[OrderCurveProductGroup]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Dim].[OrderCurveProductGroup] AS
WITH ForecastWeeks AS (
	SELECT DISTINCT YEAR, [Week Seasonality]
	FROM dbo.DimCalendarFiscal cf
	WHERE ('F' = (SELECT [Mode] FROM dbo.ForecastPeriod)
			AND [Month Sort] >= (SELECT ForecastMonth FROM dbo.ForecastPeriod)
			--AND YEAR(DateKey) = (SELECT LEFT(ForecastMonth,4) FROM dbo.ForecastPeriod)
			AND UseForecast = 1
		)
		OR 
		('B' = (SELECT [Mode] FROM dbo.ForecastPeriod)
			AND [Month Sort] >= (SELECT BudgetMonth FROM dbo.ForecastPeriod)
			--AND YEAR(DateKey) = (SELECT LEFT(BudgetMonth,4) FROM dbo.ForecastPeriod)
		)
)
, WeeksRemaining AS (
	SELECT YEAR, COUNT(DISTINCT [Week Seasonality]) AS WeekCount
	FROM dbo.DimCalendarFiscal cf
	WHERE ('F' = (SELECT [Mode] FROM dbo.ForecastPeriod)
			AND [Month Sort] >= (SELECT ForecastMonth FROM dbo.ForecastPeriod)
			--AND YEAR(DateKey) = (SELECT LEFT(ForecastMonth,4) FROM dbo.ForecastPeriod)
			AND UseForecast = 1
		)
		OR 
		('B' = (SELECT [Mode] FROM dbo.ForecastPeriod)
			AND [Month Sort] >= (SELECT BudgetMonth FROM dbo.ForecastPeriod)
			--AND YEAR(DateKey) = (SELECT LEFT(BudgetMonth,4) FROM dbo.ForecastPeriod)
		)
	GROUP BY YEAR
)
, Data AS (
  SELECT 
	  wr.Year
	, cf2.[Week Seasonality]
	, [Category]
	, [ProductGroup]
	, SUM(Sales) AS Sales
	, COUNT(cf2.[Week Seasonality]) OVER (PARTITION BY wr.Year, [Category], [ProductGroup]) AS [WeekCount]
	, wr.WeekCount AS WeeksRemaining
	--, SUM(Sales) OVER (PARTITION BY Category) AS CategorySales
  FROM dbo.FactPBISales s
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON s.DateID = cf1.DateID 
	LEFT JOIN (SELECT DISTINCT [Week Seasonality] FROM dbo.DimCalendarFiscal) cf2 ON cf1.[Week Seasonality] = cf2.[Week Seasonality]
	LEFT JOIN dbo.DimProductMaster pm ON s.ProductID = pm.ProductID
	INNER JOIN ForecastWeeks fw ON cf2.[Week Seasonality] = fw.[Week Seasonality]-- AND cf.YEAR = fw.YEAR
	LEFT JOIN WeeksRemaining wr ON wr.YEAR = fw.YEAR
  WHERE pm.[Part Type] = 'FINISHED GOODS' 
	--only use full weeks when determining the curve
	AND cf1.DateKey >= DATEADD(MONTH,-3*12,DATEADD(DAY,-1,DATEADD(week, DATEDIFF(week, 0, GETDATE()), 0)))
	AND cf1.DateKey < DATEADD(DAY,-1,DATEADD(week, DATEDIFF(week, 0, GETDATE()), 0))
  GROUP BY wr.Year, cf2.[Week Seasonality], [Category], [ProductGroup], wr.WeekCount
)
SELECT cf.Year
	, cf.[Week Seasonality]
	, [Week Seasonality Sort]
	, [ProductCount]
	, [WeekCount]
	, [WeeksRemaining]
	, ISNULL(d.[Category],pm.[Category]) AS Category
	, ISNULL(d.[ProductGroup],pm.[ProductGroup]) AS [Product Group]
	, ISNULL(Sales,0) AS WeeklySales
	, SUM(ISNULL(Sales,0)) OVER (PARTITION BY pm.Category, pm.ProductGroup, cf.Year) AS SubcategorySales
	, CASE WHEN SUM(Sales) OVER (PARTITION BY d.Category, d.ProductGroup, cf.Year) <> 0 THEN ISNULL(Sales,0)/SUM(Sales*1.0) OVER (PARTITION BY d.Category, d.ProductGroup, cf.Year) ELSE 0 END AS Value
FROM (SELECT DISTINCT [Year], [Week Seasonality], [Week Seasonality Sort] FROM dbo.DimCalendarFiscal) cf 
	CROSS JOIN (SELECT [Category], [ProductGroup], COUNT(DISTINCT pm.ProductID) AS ProductCount FROM dbo.DimProductMaster pm WHERE pm.[Part Type] = 'FINISHED GOODS' GROUP BY [Category], [ProductGroup]) pm 
	LEFT JOIN Data d ON cf.[Week Seasonality] = d.[Week Seasonality] AND pm.Category = d.[Category] AND pm.[ProductGroup] = d.[ProductGroup] AND cf.[Year] = d.[Year]
WHERE Sales <> 0 AND WeekCount/(WeeksRemaining*1.0) >= .5
GROUP BY cf.Year, cf.[Week Seasonality], cf.[Week Seasonality Sort]	,d.[WeeksRemaining], pm.[ProductCount], [WeekCount], d.[Category] ,pm.[Category], d.[ProductGroup], pm.[ProductGroup], Sales
GO
