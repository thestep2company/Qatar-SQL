USE [Operations]
GO
/****** Object:  StoredProcedure [Error].[ProductID]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Error].[ProductID] AS BEGIN

	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactSalesBudget b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL


	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactOrderCurve b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL


	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactPurchase b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL


	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactPurchasePriceVariance b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL


	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactReceipt b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL


	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactSales b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL



	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactSalesBudget b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL


	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactSalesForecastAdditions b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL


	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactSalesForecastPrior b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL


	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactSalesReclass b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL


	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactStandard b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL


	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactStandards b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL

	SELECT * 
	--UPDATE b SET b.ProductID = pm2.ProductID
	FROM dbo.FactStandardsHistory b
		LEFT JOIN dbo.DimProductMaster pm ON b.ProductID = pm.ProductID 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON b.ProductID = msib.ID
		LEFT JOIN dbo.DimProductMaster pm2 ON msib.Segment1 = pm2.ProductKey
	WHERE pm.ProductID IS NULL AND b.ProductID IS NOT NULL

END
GO
