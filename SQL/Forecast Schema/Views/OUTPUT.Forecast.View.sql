USE [Forecast]
GO
/****** Object:  View [OUTPUT].[Forecast]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[Forecast] AS
SELECT [Month Sort], SUM(ISNULL(Sales,0)+ISNULL([Invoiced Freight],0)) AS [Gross Sales], SUM(Units) AS Units
FROM dbo.FactSalesBudget sb
	LEFT JOIN dbo.DimCalendarFiscal cf ON sb.DateID = cf.DateID
	LEFT JOIN dbo.DimCustomerMaster cm ON sb.CustomerID = cm.CustomerID
WHERE (BudgetID = 13 AND cf.Year >= (SELECT LEFT(ForecastMonth,4) FROM dbo.ForecastPeriod) AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod))
	OR (BudgetID = 0 AND cf.Year >= (SELECT LEFT(BudgetMonth,4) FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod))
GROUP BY [Month Sort]
--ORDER BY [Month Sort]
GO
