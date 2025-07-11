USE [Operations]
GO
/****** Object:  View [Fact].[Purchase]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Fact].[Purchase] AS
SELECT po.POID
	,ISNULL(v.VendorID,0) AS VendorID
	,cf2.DateID
	,pm.ProductID --ITEM
	,CASE WHEN ORDER_QUANTITY - QUANTITY_CANCELLED <> 0 THEN ISNULL(ISNULL(cf6.DateID,cf7.DateID),cf8.DateID) - cf2.DateID END AS LINE_AGE
	--,ORDER_QUANTITY - QUANTITY_CANCELLED 
	--,cf7.DateID AS TODAY
	,a.AgeID
	,CASE WHEN ORDER_QUANTITY - QUANTITY_CANCELLED = 0 THEN 1 ELSE 0 END AS PO_LINE_CANCEL_FLAG
	,CASE WHEN REMAINING_QUANTITY > 0 THEN 1 ELSE 0 END AS PO_LINE_OPEN_FLAG
	,UNIT_PRICE
	,ORDER_QUANTITY
	,QUANTITY_RECEIVED
	,QUANTITY_CANCELLED
	,REMAINING_QUANTITY
	,ORDER_TOTAL
FROM Oracle.PurchaseOrder p
	LEFT JOIN dbo.DimPurchaseOrder po ON po.PO_NUMBER = p.PO_NUMBER AND po.LINE_NUMBER = p.LINE_NUMBER AND po.SHIPMENT_LINE_NUMBER = p.SHIPMENT_LINE_NUMBER
	LEFT JOIN dbo.DimProductMaster pm ON p.ITEM = pm.ProductKey
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON p.PO_CREATE_DATE = cf1.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON p.PO_LINE_CREATE_DATE = cf2.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON p.NEED_BY_DATE = cf3.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf4 ON p.PROMISED_DATE = cf4.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf5 ON p.PO_LINE_CANCEL_DATE = cf5.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf7 ON p.PO_LINE_CANCEL_DATE = cf7.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf8 ON cf8.DateKey = CAST(GETDATE() AS DATE)
	LEFT JOIN (
		SELECT PO_HEADER_ID, PO_LINE_ID, LINE_LOCATION_ID, MAX(CAST(TRANSACTION_DATE AS DATE)) AS [ReceiptDate]
		FROM Oracle.QualityReceiving 
		WHERE CurrentRecord = 1 AND TRANSACTION_TYPE IN ('Receive','Return to Supplier')
		GROUP BY PO_HEADER_ID, PO_LINE_ID, LINE_LOCATION_ID
	) r ON r.PO_HEADER_ID = po.PO_HEADER_ID AND r.PO_LINE_ID = po.PO_LINE_ID AND r.LINE_LOCATION_ID = po.LINE_LOCATION_ID
	LEFT JOIN dbo.DimCalendarFiscal cf6 ON r.ReceiptDate = cf6.DateKey

	LEFT JOIN Dim.Aging a ON ISNULL(ISNULL(cf6.DateID,cf7.DateID),cf8.DateID) - cf2.DateID BETWEEN a.Floor AND a.Ceiling
	LEFT JOIN dbo.DimVendor v ON p.VENDOR_ID = v.VendorKey
WHERE p.CurrentRecord = 1
GO
