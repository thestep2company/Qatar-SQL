USE [Operations]
GO
/****** Object:  View [Fact].[InvoicePriceVariance]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[InvoicePriceVariance] AS 
SELECT po.POID
	, api.INVOICE_ID AS INVOICEID
	, cf.DateID
	--, ISNULL(v.VendorID,0) AS VendorID
	, l.LocationID
	, pm.ProductID--, ppv.*
	, ipv.INVOICE_PRICE
	, SUM(ipv.QUANTITY_INVOICED) AS QUANTITY_INVOICED
	--, SUM((POL_UNIT_PRICE)*TX_QTY) AS MaterialCost, SUM((MOH_UNIT_COST)*TX_QTY) AS OverheadCost
	--, SUM((POL_UNIT_PRICE+MOH_UNIT_COST)*TX_QTY) AS POCost
	--, SUM(STD_COST*TX_QTY) AS StandardCost
	, SUM(BASE_PRICE_VARI) AS VarCost
FROM Oracle.InvoicePriceVariance ipv 
	LEFT JOIN dbo.DimPurchaseOrder po ON po.PO_HEADER_ID = ipv.PO_HEADER_ID AND po.PO_LINE_ID = ipv.PO_LINE_ID AND po.LINE_LOCATION_ID= ipv.LINE_LOCATION_ID
	LEFT JOIN dbo.DimLocation l ON ipv.ORGANIZATION_CODE = l.LocationKey
	--LEFT JOIN dbo.DimVendor v ON ppv.VENDOR_NAME = v.VendorName
	LEFT JOIN dbo.DimCalendarFiscal cf ON ipv.ACCOUNTING_DATE = cf.DateKey
	LEFT JOIN dbo.DimProductMaster pm ON pm.ProductKey = ipv.ITEM
	LEFT JOIN dbo.DimAPInvoice api ON api.INVOICE_NUM = ipv.INVOICE_NUM
--WHERE CurrentRecord = 1
GROUP BY po.POID
	, api.INVOICE_ID
	, cf.DateID
	--, v.VendorID
	, l.LocationID
	, pm.ProductID
	, ipv.INVOICE_PRICE
GO
