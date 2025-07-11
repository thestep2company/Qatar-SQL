USE [Operations]
GO
/****** Object:  View [OUTPUT].[LastReceiptPrice]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[LastReceiptPrice] AS
WITH LastReceiptDate AS (
	SELECT ProductID, MAX(Receipt_Date) AS Receipt_Date FROM Fact.Purchase GROUP BY ProductID
)
, LastInvoice AS (
	SELECT ROW_NUMBER() OVER (PARTITION BY ProductKey ORDER BY cf.DateKey DESC) AS Rank
		,ProductKey, cf.DateKey, UnitPriceID/100.0 AS LastPrice
	FROM dbo.FactPBISales b
		LEFT JOIN dbo.DimProductMaster pm ON pm.ProductID = b.ProductID
		LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassID = b.DemandClassID
		LEFT JOIN dbo.DimCustomerMaster cm ON cm.CustomerID = b.CustomerID
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = b.DateID
	WHERE b.RevenueID <> 5 AND cf.DateKey >= DATEADD(YEAR,-1,GETDATE())
		AND UnitPriceID/100.0 <> 0
		AND pm.[Part Type] = 'COMPONENTS'
)
, Data AS (
	SELECT pm.ProductKey, ProductName, cf.DateKey AS LastReceiptDate, NULL AS LastInvoiceDate, CAST(p.UNIT_PRICE AS MONEY) AS LastReceipt, 0 AS LastInvoice
	FROM LastReceiptDate CTE
		INNER JOIN Fact.Purchase p ON cte.ProductID = p.ProductID AND cte.Receipt_Date = p.RECEIPT_DATE 
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = cte.Receipt_Date
		LEFT JOIN dbo.DimProductMaster pm ON pm.ProductID = p.ProductID
	WHERE pm.[Part Type] = 'COMPONENTS'
	UNION
	SELECT pm.ProductKey, pm.ProductName, NULL AS LastReceiptDate, cte.DateKey AS LastInvoiceDate, 0 AS LastReceipt, CAST(LastPrice AS MONEY) AS LastInvoice
	FROM LastInvoice cte 
		LEFT JOIN dbo.DimProductMaster pm ON pm.ProductKey = cte.ProductKey
	WHERE Rank = 1
)
SELECT ProductKey, ProductName, MAX(LastReceiptDate) AS LastReceiptDate, MAX(LastInvoiceDate) AS LastInvoiceDate, MAX(LastReceipt) AS LastReceipt, MAX(LastInvoice) AS LastInvoice
FROM Data GROUP BY ProductKey, ProductName
GO
