USE [Forecast]
GO
/****** Object:  View [OUTPUT].[ForecastHistory]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [OUTPUT].[ForecastHistory] AS 
WITH MonthsOfYear AS (
	SELECT DISTINCT [Month Sort], [BudgetID]
	FROM dbo.DimCalendarFiscal 
			CROSS JOIN dbo.ForecastVersion
	WHERE Year = 2023 AND (BudgetID < 0 OR BudgetID = 13)
)
, ForecastMonths AS (
	SELECT moy.BudgetID, [ForecastVersion], moy.[Month Sort], SUM(Sales) AS Sales
	FROM MonthsOfYear moy 
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.[Month Sort] = moy.[Month Sort]
		LEFT JOIN dbo.FactSalesBudget s ON cf.[DateID] = s.[DateID] AND moy.BudgetID = s.[BudgetID] -- AND (s.BudgetID < 0 OR s.BudgetID = 13)
		LEFT JOIN dbo.ForecastVersion fv ON fv.BudgetID = moy.BudgetID 
	WHERE cf.[Year] = 2023
	GROUP BY moy.BudgetID, [ForecastVersion], moy.[Month Sort]
	
)
, ActualMonths AS (
	SELECT BudgetID, ForecastVersion, [Month Sort], SUM(ISNULL(Sales,0)) AS Sales 
	FROM ForecastMonths 
	GROUP BY BudgetID, ForecastVersion, [Month Sort]
	HAVING SUM(ISNULL(Sales,0)) = 0
)
SELECT s.BudgetID, [ForecastVersion], [Month Sort] AS Period
	, [ProductKey], [ProductDesc]
	, SUM(Sales) AS Sales, SUM(Cogs) AS COGS, SUM(Units) AS Units 
FROM dbo.FactSalesBudget s
	LEFT JOIN dbo.DimProductMaster pm ON s.ProductID = pm.ProductID
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = s.DateID
	LEFT JOIN dbo.ForecastVersion fv ON fv.BudgetID = s.BudgetID
GROUP BY s.BudgetID, [ForecastVersion], [Month Sort], [ProductKey], [ProductDesc]
UNION ALL 
SELECT am.BudgetID, am.ForecastVersion, am.[Month Sort] AS Period, ProductKey, ProductDesc
	, SUM(s.Sales) AS Sales, SUM(s.COGS) AS COGS, SUM(s.Qty) AS Units
FROM ActualMonths am
	LEFT JOIN dbo.DimCalendarFiscal cf ON am.[Month Sort] = cf.[Month Sort]
	LEFT JOIN dbo.FactPBISales s ON cf.[DateID] = s.[DateID]
	LEFT JOIN dbo.DimProductMaster pm ON s.[ProductID] = pm.[ProductID]
WHERE RevenueID <> 5
GROUP BY am.BudgetID, am.ForecastVersion, am.[Month Sort], ProductKey, ProductDesc
--ORDER BY am.BudgetID, am.[ForecastVersion], am.[Month Sort]
GO
