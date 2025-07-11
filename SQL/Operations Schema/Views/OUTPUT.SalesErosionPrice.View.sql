USE [Operations]
GO
/****** Object:  View [OUTPUT].[SalesErosionPrice]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[SalesErosionPrice] AS
WITH Pricing AS (
	SELECT Year, CustomerID, ProductID, UnitPriceID, SUM(b.Units) AS Units, SUM(b.Sales) AS Sales
	FROM dbo.FactPBISalesBudget b
			LEFT JOIN dbo.DimCalendarFiscal cf ON b.DateID = cf.DateID
	WHERE SaleTypeID = 0
	GROUP BY Year, CustomerID, ProductID, UnitPriceID 

)
,
 Sales AS (
	SELECT Year, CustomerID, ProductID, UnitPriceID, [Month Sort]
		, SUM(Sales) AS Sales
		, SUM(s.Qty) AS Units
	FROM dbo.FactPBISales s
		LEFT JOIN dbo.DimCalendarFiscal cf ON s.DateID = cf.DateID 	
	GROUP BY Year, CustomerID, ProductID, UnitPriceID, [Month Sort]
)
SELECT s.Year
	, cm.CustomerDesc, pm.ProductDesc
	, s.Units AS SalesUnits
	, CAST(s.UnitPriceID/100.0 AS MONEY) AS SalePrice
	, CAST(p.UnitPriceID/100.0 AS MONEY) AS BudgetPrice
	, s.Sales
	, s.Units*CAST(p.UnitPriceID/100.0 AS MONEY) AS ExpectedSales@Budget
	, s.Sales - s.Units*CAST(p.UnitPriceID/100.0 AS MONEY) AS SalesErosion
FROM Sales s
	INNER JOIN Pricing p ON s.ProductID = p.ProductID AND s.CustomerID = p.CustomerID AND s.Year = p.Year
	LEFT JOIN dbo.DimProductMaster pm ON s.ProductID = pm.ProductID 
	LEFT JOIN dbo.DimCustomerMaster cm ON s.CustomerID = cm.CustomerID
WHERE s.UnitPriceID <> p.UnitPriceID
--ORDER BY SalesErosion ASC
GO
