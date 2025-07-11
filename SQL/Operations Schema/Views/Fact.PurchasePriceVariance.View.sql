USE [Operations]
GO
/****** Object:  View [Fact].[PurchasePriceVariance]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[PurchasePriceVariance] AS 
SELECT po.POID, cf.DateID, ISNULL(v.VendorID,0) AS VendorID, l.LocationID, pm.ProductID--, ppv.*
	, SUM(TX_QTY) AS QTY, SUM((POL_UNIT_PRICE)*TX_QTY) AS MaterialCost, SUM((MOH_UNIT_COST)*TX_QTY) AS OverheadCost, SUM((POL_UNIT_PRICE+MOH_UNIT_COST)*TX_QTY) AS POCost, SUM(STD_COST*TX_QTY) AS StandardCost, SUM(COST_VARIANCE*TX_QTY) AS VarCost--, SUM(TX_EXT_VAR) AS TX_EXT_VAR
FROM Oracle.PurchasePriceVariance ppv 
	LEFT JOIN dbo.DimPurchaseOrder po ON po.PO_NUMBER = ppv.PO_NUMBER AND po.LINE_NUMBER = ppv.PO_LINE_NUMBER AND po.SHIPMENT_LINE_NUMBER = ppv.SHIPMENT_LINE_NUMBER
	LEFT JOIN dbo.DimLocation l ON ppv.ORG_CODE = l.LocationKey
	LEFT JOIN dbo.DimVendor v ON ppv.VENDOR_NAME = v.VendorName
	LEFT JOIN dbo.DimCalendarFiscal cf ON ppv.TX_DATE = cf.DateKey
	LEFT JOIN dbo.DimProductMaster pm ON pm.ProductKey = ppv.ITEM
WHERE CurrentRecord = 1
GROUP BY po.POID, cf.DateID, v.VendorID, l.LocationID, pm.ProductID

GO
