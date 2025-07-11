USE [Operations]
GO
/****** Object:  View [xref].[ProductSeason]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [xref].[ProductSeason] AS
WITH CTE AS (
	SELECT 
		  [SIOP Family]
		, CASE WHEN DATEPART(MONTH,CAST([Order_Date] AS DATE)) = 12 OR DATEPART(MONTH,CAST([Order_Date] AS DATE)) IN (1,2) THEN 'Winter'
			 WHEN DATEPART(MONTH,CAST([Order_Date] AS DATE)) BETWEEN 3 AND 5 THEN 'Spring'
			 WHEN DATEPART(MONTH,CAST([Order_Date] AS DATE)) BETWEEN 6 AND 8 THEN 'Summer'
			 ELSE 'Fall'
		END AS Quarter
		, SUM(CAST([SELL_DOLLARS] AS MONEY)) AS [Sales]
	FROM Oracle.Orders o
		LEFT JOIN dbo.DimProductMaster pm ON o.Part = pm.ProductKey
	WHERE EndDate IS NULL AND CAST([Order_Date] AS DATE) >= DATEADD(YEAR,-2,GETDATE())
	GROUP BY [SIOP Family]
		, CASE WHEN DATEPART(MONTH,CAST([Order_Date] AS DATE)) = 12 OR DATEPART(MONTH,CAST([Order_Date] AS DATE)) IN (1,2) THEN 'Winter'
			 WHEN DATEPART(MONTH,CAST([Order_Date] AS DATE)) BETWEEN 3 AND 5 THEN 'Spring'
			 WHEN DATEPART(MONTH,CAST([Order_Date] AS DATE)) BETWEEN 6 AND 8 THEN 'Summer'
			 ELSE 'Fall'
		END
)
, Data AS (
	SELECT ROW_NUMBER() OVER (PARTITION BY [SIOP Family] ORDER BY Sales DESC) QuarterRank
		,CASE WHEN SUM(Sales) OVER (PARTITION BY [SIOP Family] ORDER BY Sales) <> 0 THEN Sales/SUM(Sales) OVER (PARTITION BY [SIOP Family]) END AS PercentOfSales
		, * 
	FROM CTE
)
SELECT * FROM Data WHERE QuarterRank = 1
GO
