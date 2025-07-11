USE [Forecast]
GO
/****** Object:  View [Error].[ForecastCostingExceptions]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Error].[ForecastCostingExceptions] AS
SELECT pm.ProductKey, cf.DateKey AS Date, Cogs - ([Material Cost] + [Material Overhead Cost] + [Resource Cost] + [Outside Processing Cost] + [Overhead Cost]) AS Checksum, s.*
FROM dbo.FactSalesBudget s
	LEFT JOIN dbo.DimProductMaster pm ON s.ProductID = pm.ProductID
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = s.DateID
WHERE (ABS(Cogs - ([Material Cost] + [Material Overhead Cost] + [Resource Cost] + [Outside Processing Cost] + [Overhead Cost])) >= .02
	OR ISNULL(Cogs,0) = 0)
	AND BudgetID = 13
	AND Sales <> 0
	AND Units <> 0
	AND ProductKey >= '400000' AND ProductKey < '999999'
	AND [Month Sort] >= (SELECT ForecastMonth FROM dbo.ForecastPeriod)

GO
