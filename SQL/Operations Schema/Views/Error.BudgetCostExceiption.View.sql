USE [Operations]
GO
/****** Object:  View [Error].[BudgetCostExceiption]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Error].[BudgetCostExceiption] AS
SELECT b.Part
	, CAST(CASE WHEN b.[TOtal Units] <> 0 THEN b.[Total COGS]/b.[Total Units] END AS MONEY) AS COGS
	, CAST(s.ItemCost AS MONEY) AS StandardCost
	,  CAST(CASE WHEN b.[TOtal Units] <> 0 THEN b.[Total COGS]/b.[Total Units] END - s.ItemCost AS MONEY) AS Difference
	, ProductSort
	, SUM(b.[TOtal Units]) AS Units
	,  CAST(CASE WHEN b.[TOtal Units] <> 0 THEN b.[Total COGS]/b.[Total Units] END - s.ItemCost AS MONEY) * SUM(b.[Total Units]) AS Impact
FROM xref.SalesBudget b 
	LEFT JOIN dbo.DimProductMaster pm ON b.Part = pm.ProductKey
	LEFT JOIN dbo.FactStandard s ON pm.ProductID = s.ProductID AND GETDATE() BETWEEN s.StartDate AND s.EndDate
WHERE ABS(ISNULL(CASE WHEN b.[TOtal Units] <> 0 THEN b.[Total COGS]/b.[Total Units] END,0) - ISNULL(s.ItemCost,0)) > .01
GROUP BY 
	b.Part
	, CAST(CASE WHEN b.[TOtal Units] <> 0 THEN b.[Total COGS]/b.[Total Units] END AS MONEY) 
	, CAST(s.ItemCost AS MONEY)
	,  CAST(CASE WHEN b.[TOtal Units] <> 0 THEN b.[Total COGS]/b.[Total Units] END - s.ItemCost AS MONEY) 
	, ProductSort
--ORDER BY ProductSort
GO
