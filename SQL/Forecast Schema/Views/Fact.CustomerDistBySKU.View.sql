USE [Forecast]
GO
/****** Object:  View [Fact].[CustomerDistBySKU]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[CustomerDistBySKU] AS
WITH CTE AS (
	SELECT cm.[DEMAND_CLASS_CODE] AS DEM_CLASS, CustomerKey AS ACCT_NUM, ProductKey AS SKU, SUM(SALES) AS ACCTD_USD
	FROM dbo.FactPBISales i
		INNER JOIN dbo.DimProductMaster pm ON i.ProductID = pm.ProductID
		LEFT JOIN dbo.DimCustomerMaster cm ON i.CustomerID = cm.CustomerID
		--LEFT JOIN dbo.DimDemandClass dc ON i.DemandClassID = dc.DemandClassID 
		LEFT JOIN dbo.DimRevenueType rt ON i.RevenueID = rt.RevenueID
	WHERE QTY > 0 AND RevenueName <> 'SHIPPING' 
		AND i.DateKey >=  DATEADD(MONTH,-12,(SELECT CustomerSplitDate FROM dbo.ForecastPeriod))
		AND i.DateKey < (SELECT CustomerSplitDate FROM dbo.ForecastPeriod)
		AND cm.[DEMAND_CLASS_CODE]  <> 'MISC'
	GROUP BY cm.[DEMAND_CLASS_CODE] , CustomerKey, ProductKey
	HAVING SUM(Sales) <> 0

)
SELECT SKU, DEM_CLASS, ACCT_NUM, CAST(ACCTD_USD AS FLOAT)/SUM(CAST(ACCTD_USD AS FLOAT)) OVER (PARTITION BY SKU, DEM_CLASS) AS CustomerDist
FROM CTE
GO
