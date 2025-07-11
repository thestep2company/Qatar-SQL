USE [Operations]
GO
/****** Object:  View [Fact].[Pricing]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Fact].[Pricing] AS 

/*

SELECT pm.ProductKey, dc.DemandClassKey, p.InvoicePrice, p.ForecastPrice, p.OraclePrice, p.Price, 1-InvoicePrice/ForecastPrice AS Discount
FROM [Fact].[Pricing] p
	LEFT JOIN dbo.DimProductMaster pm ON p.ProductID = pm.ProductID
	LEFT JOIN dbo.DimDemandClass dc ON p.DemandClassID = dc.DemandClassID
WHERE InvoicePrice < ForecastPrice *.95
ORDER BY ProductKey, DemandClassKey

*/


WITH LastPrice AS (

	SELECT DISTINCT DENSE_RANK() OVER (PARTITION BY fs.ProductID, fs.DemandClassID ORDER BY fs.DateKey DESC, fs.UnitPriceID) AS Rank, ProductKey AS SKU, DemandClassKey AS DemandClass, UnitPriceID/100.0 AS SalePrice, DateKey AS GL_DATE
	FROM dbo.FactPBISales fs
		LEFT JOIN dbo.DimProductMaster pm ON fs.ProductID = pm.ProductID 
		LEFT JOIN dbo.DimDemandClass dc ON fs.DemandClassID = dc.DemandClassID
	WHERE DATEADD(YEAR,-2,GETDATE()) < DateKey AND ISNULL(UnitPriceID,0) <> 0

	/*
		SELECT ROW_NUMBER() OVER (PARTITION BY SKU, Dem_Class ORDER BY GL_DATE DESC) AS Rank
			, SKU, Dem_Class AS DemandClass, ACCTD_USD/QTY_INVOICED AS SalePrice, GL_DATE
		FROM Oracle.Invoice i WHERE CurrentRecord =1 AND QTY_INVOICED > 0 AND SKU IS NOT NULL 
			AND REPORTING_REVENUE_TYPE IN ('AAA-SALES','ALLOWANCE','S2C_ADJ_OTHER','FRTMBS','TPI')
	*/
	/*
		SELECT ROW_NUMBER() OVER (PARTITION BY ProductKey, DemandClassKey ORDER BY i.DateKey DESC) AS Rank
			, ProductKey AS SKU, DemandClassKey AS DemandClass, Sales/QTY AS SalePrice, i.DateKey AS GL_DATE
		FROM dbo.FactPBISales i
			INNER JOIN dbo.DimProductMaster pm ON i.ProductID = pm.ProductID
			LEFT JOIN dbo.DimDemandClass dc ON i.DemandClassID = dc.DemandClassID 
			LEFT JOIN dbo.DimRevenueType rt ON i.RevenueID = rt.RevenueID
		WHERE QTY > 0 AND RevenueName <> 'SHIPPING' AND i.DateKey >= DATEADD(MONTH,-24,GETDATE())
	*/
)
, ForecastPrice AS (
	SELECT ROW_NUMBER() OVER (PARTITION BY ProductKey, DemandClassKey ORDER BY SUM(Sales)/SUM(Units) DESC) AS Rank, ProductKey AS Part, DemandClassKey AS [Demand Class], SUM(Sales)/SUM(Units) AS CustomerPrice
	FROM dbo.FactPBISalesBudget pbi
		LEFT JOIN dbo.DimProductMaster pm ON pbi.ProductID = pm.ProductID 
		LEFT JOIN dbo.DimCalendarFiscal cf ON pbi.DateID = cf.DateID 
		LEFT JOIN dbo.DimDemandClass dc ON pbi.DemandClassID = dc.DemandClassID
	WHERE CurrentYear = 'Current Year' AND BudgetID IN (0,13)
	GROUP BY ProductKey, DemandClassKey 
	HAVING SUM(Units) <> 0

	--SELECT ROW_NUMBER() OVER (PARTITION BY Part, [Demand Class] ORDER BY CustomerPrice DESC) AS Rank, Part, [Demand Class], CustomerPrice--, SUM(CustomerPrice)/COUNT(*) AS AveragePrice
	--FROM xref.SalesForecast WHERE Part IS NOT NULL AND Part <> '(blank)'
	--GROUP BY  Part, [Demand Class], CustomerPrice
)
, AveragePrice AS (
	SELECT ProductKey AS Part, DemandClassKey AS [Demand Class], SUM(Sales)/SUM(Units) AS AveragePrice
	FROM dbo.FactPBISalesBudget pbi
		LEFT JOIN dbo.DimProductMaster pm ON pbi.ProductID = pm.ProductID 
		LEFT JOIN dbo.DimCalendarFiscal cf ON pbi.DateID = cf.DateID 
		LEFT JOIN dbo.DimDemandClass dc ON pbi.DemandClassID = dc.DemandClassID
	WHERE CurrentYear = 'Current Year' AND BudgetID IN (0,13)
	GROUP BY ProductKey, DemandClassKey 
	HAVING SUM(Units) <> 0

	--SELECT Part, [Demand Class], SUM(CustomerPrice)/COUNT(*) AS AveragePrice
	--FROM xref.SalesForecast WHERE Part IS NOT NULL AND Part <> '(blank)'
	--GROUP BY  Part, [Demand Class]
)
, ListPrice AS (
	SELECT ProductKey, List_Less_7 AS Price FROM Fact.ProductPricing WHERE CurrentRecord = 1
)
, Data AS (
	SELECT ProductID
		, DemandClassID
		, CAST(lp.SalePrice AS MONEY) AS InvoicePrice
		, CAST(ap.AveragePrice AS MONEY) AS ForecastPrice
		, CAST(0 AS MONEY)  AS OraclePrice
		, GL_DATE AS LastInvoiceDate
	FROM (SELECT * FROM LastPrice WHERE Rank = 1) lp
		FULL OUTER JOIN (SELECT * FROM ForecastPrice WHERE Rank = 1) fp  ON Part = SKU AND fp.[Demand Class] = lp.DemandClass
		LEFT JOIN AveragePrice ap ON fp.Part = ap.Part AND fp.[Demand Class] = ap.[Demand Class]
		LEFT JOIN dbo.DimProductMaster pm ON pm.ProductKey = ISNULL(lp.SKU,ap.Part)
		LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = ISNULL(lp.DemandClass,ap.[Demand Class])
	UNION
	SELECT pm.ProductID
		, NULL AS DemandClassKey
		, CAST(0 AS MONEY)
		, CAST(0 AS MONEY) 
		, CAST(List_Less_7 AS MONEY) AS OraclePrice
		, '1900-01-01' AS LastInvoiceDate
	FROM Fact.ProductPricing pp
		LEFT JOIN dbo.DimProductMaster pm ON pm.ProductKey = pp.ProductKey
	WHERE CurrentRecord = 1 
)
SELECT ProductID
	, DemandClassID
	, AVG(InvoicePrice) AS InvoicePrice
	, AVG(ForecastPrice) AS ForecastPrice
	, AVG(OraclePrice) AS OraclePrice 
	, CASE WHEN ISNULL(AVG(InvoicePrice),0) <> 0 THEN AVG(InvoicePrice) 
		   WHEN ISNULL(AVG(ForecastPrice),0) <> 0 THEN AVG(ForecastPrice)
		   ELSE AVG(OraclePrice)
	END AS Price
	,MAX(LastInvoiceDate) AS LastInvoiceDate
FROM Data 
WHERE ProductID IS NOT NULL
GROUP BY ProductID
	, DemandClassID


GO
