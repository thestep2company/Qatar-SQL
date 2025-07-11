USE [Operations]
GO
/****** Object:  View [Fact].[Receipt]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[Receipt] AS
SELECT po.POID
	  --,po.PO_Number
	  --,po.LINE_NUMBER
	  --,po.SHIPMENT_LINE_NUMBER
	  --,po.LINE_LOCATION_ID
	  ,l.LocationID
	  ,pm.ProductID
	  ,cf.DateID
	  ,b.BuyerID
	  ,v.VendorID
	  ,CASE WHEN TRANSACTION_TYPE = 'Receive' THEN 1 ELSE - 1 END *QUANTITY AS QUANTITY
	  ,qr.[PACKING_SLIP]
      ,qr.[DOCUMENT_NUMBER]
      ,CASE WHEN TRANSACTION_TYPE = 'Receive' THEN 1 ELSE - 1 END *QUANTITY * qr.[PRICE] AS PRICE
      ,qr.[RECEIPT_NUMBER]
	 -- ,qr.*
      ,qr.[RECEIVER]
      ,qr.[DELIVER_TO]
--, SUM(PRICE) AS PRICE--, TRANSACTION_DATE 
FROM dbo.DimPurchaseOrder po
	LEFT JOIN Oracle.QualityReceiving qr ON po.PO_HEADER_ID = qr.PO_HEADER_ID AND po.PO_LINE_ID = qr.PO_LINE_ID AND po.LINE_LOCATION_ID = qr.LINE_LOCATION_ID AND qr.CurrentRecord = 1
	LEFT JOIN dbo.DimProductMaster pm ON qr.ITEM = pm.ProductKey
	LEFT JOIN dbo.DimLocation l ON qr.ORG_CODE = l.LocationKey
	LEFT JOIN dbo.DimCalendarFiscal cf ON qr.TRANSACTION_DATE = cf.DateKey
	LEFT JOIN dbo.DimBuyer b ON qr.Buyer = b.Buyer_Name
	LEFT JOIN dbo.DimVendor v ON qr.SUPPLIER = v.VendorName AND v.VendorKey IS NOT NULL
WHERE TRANSACTION_TYPE IN ('Receive','Return to Supplier') AND ITEM IS NOT NULL AND cf.DateKey >= '2019-01-01' 
GO
