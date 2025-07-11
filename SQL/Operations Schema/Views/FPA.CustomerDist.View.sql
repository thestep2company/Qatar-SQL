USE [Operations]
GO
/****** Object:  View [FPA].[CustomerDist]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [FPA].[CustomerDist] AS
WITH CTE AS (
	SELECT DemandClassKey AS DEM_CLASS, CustomerKey AS ACCT_NUM, SUM(SALES) AS ACCTD_USD
	FROM dbo.FactPBISales i
		INNER JOIN dbo.DimProductMaster pm ON i.ProductID = pm.ProductID
		LEFT JOIN dbo.DimCustomerMaster cm ON i.CustomerID = cm.CustomerID
		LEFT JOIN dbo.DimDemandClass dc ON i.DemandClassID = dc.DemandClassID 
		LEFT JOIN dbo.DimRevenueType rt ON i.RevenueID = rt.RevenueID
	WHERE QTY > 0 AND RevenueName <> 'SHIPPING' 
		AND i.DateKey >=  DATEADD(MONTH,-12,GETDATE())
		AND DemandClassKey <> 'MISC'
	GROUP BY DemandClassKey, CustomerKey
)
SELECT DEM_CLASS, ACCT_NUM, CAST(ACCTD_USD AS FLOAT)/SUM(CAST(ACCTD_USD AS FLOAT)) OVER (PARTITION BY DEM_CLASS) AS CustomerDist  --windowed functions
FROM CTE
--ORDER BY DEM_CLASS, ACCT_NUM

GO
