USE [Operations]
GO
/****** Object:  View [OUTPUT].[VendorShipmentTiming]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[VendorShipmentTiming] AS
WITH Data AS (
	SELECT 
		  po.PO_CREATE_DATE
		, po.PO_LINE_CREATE_DATE
		, po.PO_NUMBER
		, po.LINE_NUMBER
		, po.SHIPMENT_LINE_NUMBER
		, po.PO_HEADER_ID
		, po.PO_LINE_ID
		, po.LINE_LOCATION_ID
		, CAST(po.NEED_BY_DATE AS DATE) AS NEED_BY_DATE
		, po.[VENDOR_ID]
		, po.[VENDOR_SITE]
		--do not want to duplicate PO lines for multiple days of receipts.  Not sure how to combine.
		, CAST(qr.TRANSACTION_DATE AS DATE) AS TRANSACTION_DATE
		, po.[ORDER_QUANTITY]
		, po.[QUANTITY_CANCELLED]
		, qr.QUANTITY AS RECEIVE_QUANTITY --combine receipt lines into same day
		, qr.TRANSACTION_TYPE
		, DATEDIFF(DAY,CAST(qr.TRANSACTION_DATE AS DATE),CAST(po.NEED_BY_DATE AS DATE)) AS ReceiptTiming
		--considered on time if it is within 2 days of need by date.  Too early or too late does not pass.
		, CASE WHEN DATEDIFF(DAY,CAST(qr.TRANSACTION_DATE AS DATE),CAST(po.NEED_BY_DATE AS DATE)) BETWEEN 0 AND 2 THEN 1 ELSE 0 END AS OnTime
		, 1.0/COUNT(*) OVER (PARTITION BY po.PO_NUMBER, po.LINE_NUMBER, po.SHIPMENT_LINE_NUMBER) AS ReceiptCount
	FROM [Oracle].[PurchaseOrder] po
		LEFT JOIN [Oracle].[QualityReceiving] qr 
	ON po.PO_HEADER_ID = qr.PO_HEADER_ID 
		AND po.PO_LINE_ID = qr.PO_LINE_ID 
		AND po.LINE_LOCATION_ID = qr.LINE_LOCATION_ID 
		AND qr.CurrentRecord = 1
		AND qr.TRANSACTION_TYPE = 'RECEIVE' --there is a receive side and an inventoroy side of the transaction
		INNER JOIN (
			SELECT DISTINCT VENDOR_ID FROM Oracle.PO_HEADERS_ALL 
			WHERE CurrentRecord = 1
					AND (ATTRIBUTE1 IS NOT NULL
					OR ATTRIBUTE2 IS NOT NULL
					OR ATTRIBUTE3 IS NOT NULL
					OR ATTRIBUTE4 IS NOT NULL
					OR ATTRIBUTE5 IS NOT NULL
					OR ATTRIBUTE6 IS NOT NULL
					OR ATTRIBUTE7 IS NOT NULL)
			) poh ON po.VENDOR_ID = poh.VENDOR_ID
	WHERE po.CurrentRecord = 1
		AND po.PO_LINE_CREATE_DATE >= DATEADD(YEAR,-1,GETDATE()) --R12
		AND po.NEED_BY_DATE < GETDATE() --only score if expecting to have received
		AND po.ORDER_QUANTITY - po.QUANTITY_CANCELLED > 0
)
SELECT VENDOR_ID, SUM(OnTime*ReceiptCount) AS OnTime, SUM(ReceiptCount) AS LineCount, SUM(OnTime*ReceiptCount)/SUM(ReceiptCount) AS ShipmentTiming FROM Data GROUP BY VENDOR_ID



GO
