USE [Operations]
GO
/****** Object:  View [Fact].[ProductIsVisible]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[ProductIsVisible] AS 
SELECT pm.ProductID, pm.ProductKey, pm.ProductName
	,CASE WHEN sales.ProductID IS NOT NULL THEN 1 ELSE 0 END AS HasSales
	,CASE WHEN Budget.ProductID IS NOT NULL THEN 1 ELSE 0 END AS HasBudget
	,CASE WHEN Inventory.ProductID IS NOT NULL THEN 1 ELSE 0 END AS HasInventory
	,CASE WHEN SCP.ProductID IS NOT NULL OR SCPK.ProductID IS NOT NULL THEN 1 ELSE 0 END AS HasSCP
	,CASE WHEN Prod.ProductID IS NOT NULL THEN 1 ELSE 0 END AS HasProd
	,CASE WHEN Purchase.ProductID IS NOT NULL THEN 1 ELSE 0 END AS HasPurchase
	,CASE WHEN Receipt.ProductID IS NOT NULL THEN 1 ELSE 0 END AS HasReceipt
	,CASE WHEN Feed.ProductID IS NOT NULL THEN 1 ELSE 0 END AS HasFeed
	,CASE WHEN product.ProductID IS NOT NULL THEN 1 ELSE 0 END AS IsNew
FROM dbo.DimProductMaster pm 
	LEFT JOIN (SELECT DISTINCT pm.ProductID, pm.ProductKey, pm.ProductName FROM dbo.DimProductMaster pm INNER JOIN dbo.FactPBISales pbi ON pm.ProductID = pbi.ProductID) sales ON sales.ProductID = pm.ProductID
	LEFT JOIN (SELECT DISTINCT pm.ProductID, pm.ProductKey, pm.ProductName FROM dbo.DimProductMaster pm INNER JOIN dbo.FactPBISalesBudget pbi ON pm.ProductID = pbi.ProductID) budget ON budget.ProductID = pm.ProductID
	LEFT JOIN (SELECT DISTINCT pm.ProductID, pm.ProductKey, pm.ProductName FROM dbo.DimProductMaster pm INNER JOIN dbo.FactInventoryLPN pbi ON pm.ProductID = pbi.ProductID) inventory  ON inventory.ProductID = pm.ProductID
	LEFT JOIN (SELECT DISTINCT pm.ProductID, pm.ProductKey, pm.ProductName FROM dbo.DimProductMaster pm INNER JOIN dbo.FactSupplyChainPlan pbi ON pm.ProductID = pbi.ProductID) scp  ON scp.ProductID = pm.ProductID
	LEFT JOIN (SELECT DISTINCT pm.ProductID, pm.ProductKey, pm.ProductName FROM dbo.DimProductMaster pm INNER JOIN dbo.FactSupplyChainPlanKit pbi ON pm.ProductID = pbi.ProductID) scpk  ON scpk.ProductID = pm.ProductID
	LEFT JOIN (SELECT DISTINCT pm.ProductID, pm.ProductKey, pm.ProductName FROM dbo.DimProductMaster pm INNER JOIN dbo.FactProduction pbi ON pm.ProductID = pbi.ProductID) prod  ON prod.ProductID = pm.ProductID
	LEFT JOIN (SELECT DISTINCT pm.ProductID, pm.ProductKey, pm.ProductName FROM dbo.DimProductMaster pm INNER JOIN dbo.FactPurchase pbi ON pm.ProductID = pbi.ProductID) purchase  ON purchase.ProductID = pm.ProductID
	LEFT JOIN (SELECT DISTINCT pm.ProductID, pm.ProductKey, pm.ProductName FROM dbo.DimProductMaster pm INNER JOIN dbo.FactReceipt pbi ON pm.ProductID = pbi.ProductID) receipt  ON receipt.ProductID = pm.ProductID
	LEFT JOIN (SELECT DISTINCT pm.ProductID, pm.ProductKey, pm.ProductName FROM dbo.DimProductMaster pm INNER JOIN dbo.FactInventoryFeed pbi ON pm.ProductID = pbi.ProductID) feed  ON feed.ProductID = pm.ProductID
	LEFT JOIN (SELECT DISTINCT pm.ProductID, pm.ProductKey, pm.ProductName FROM dbo.DimProductMaster pm INNER JOIN Fact.FinanceAdjustment pbi ON pm.ProductID = pbi.ProductID) adj  ON adj.ProductID = pm.ProductID
	LEFT JOIN (SELECT ID AS ProductID, SEGMENT1 AS ProductKey, DESCRIPTION AS ProductName   FROM Oracle.INV_MTL_SYSTEM_ITEMS_B WHERE ORGANIZATION_ID = 85 AND LAST_UPDATE_DATE > DATEADD(MONTH,-6,GETDATE()) AND CurrentRecord = 1) product ON product.ProductKey = pm.ProductKey
WHERE 
	(sales.ProductID IS NOT NULL 
	OR budget.ProductID IS NOT NULL 
	OR inventory.ProductID IS NOT NULL 
	OR scp.ProductID IS NOT NULL 
	OR scpk.ProductID IS NOT NULL
	OR prod.ProductID IS NOT NULL
	OR purchase.ProductID IS NOT NULL
	OR receipt.ProductID IS NOT NULL
	OR product.ProductID IS NOT NULL
	OR adj.ProductID IS NOT NULL)
GO
