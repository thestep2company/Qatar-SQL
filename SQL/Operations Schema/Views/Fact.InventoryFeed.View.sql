USE [Operations]
GO
/****** Object:  View [Fact].[InventoryFeed]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[InventoryFeed] AS
SELECT 
	 c.CustomerID
	,dc.DemandClassID
	,p.ProductID
	,fc.DateID AS DateID
    ,CASE WHEN ISNULL(UseManualQty,'Y') = 'Y' THEN Quantity ELSE ForecastQty END AS [Quantity]
    ,CAST([UnitPrice] * 100  AS INT) AS UnitPriceID
    ,CAST(CASE WHEN [Discontinued] = 'Y' THEN 1 ELSE 0 END AS BIT) AS Discontinued
FROM [EDI].[CustomerInventory] i
	INNER JOIN dbo.DimCalendarFiscal fc ON DATEADD(HOUR,8,CAST(fc.DateKey AS DATETIME)) BETWEEN i.StartDate AND ISNULL(i.EndDate,'9999-12-31')
	LEFT JOIN dbo.DimProductMaster p ON i.PartID = p.ProductKey 
	LEFT JOIN dbo.DimCustomerMaster c ON i.AccountNumber = c.CustomerKey
	LEFT JOIN dbo.DimDemandClass dc ON c.DEMAND_CLASS_CODE = dc.DemandClassKey
WHERE CASE WHEN ISNULL(UseManualQty,'Y') = 'Y' THEN Quantity ELSE ForecastQty END <> 0
UNION
SELECT c.CustomerID
	,dc.DemandClassID
	,p.ProductID
	,fc.DateID AS DateID
	,[Feed] AS Qty
	,0 AS UnitPrice
	,NULL AS Discontinued
FROM Oracle.InventoryFeed i
	INNER JOIN dbo.DimCalendarFiscal fc ON fc.DateKey = i.FeedDate
	LEFT JOIN dbo.DimProductMaster p ON i.SKU = p.ProductKey 
	LEFT JOIN dbo.DimCustomerMaster c ON i.AccountNumber = c.CustomerKey
	LEFT JOIN dbo.DimDemandClass dc ON i.DemandClassID = dc.DemandClassKey
WHERE i.FeedDate < '2021-03-25'
GO
