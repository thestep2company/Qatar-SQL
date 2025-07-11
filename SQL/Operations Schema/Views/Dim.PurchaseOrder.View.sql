USE [Operations]
GO
/****** Object:  View [Dim].[PurchaseOrder]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[PurchaseOrder] AS 
SELECT DISTINCT 
	 --ROW_NUMBER() OVER(ORDER BY PO_HEADER_ID, PO_LINE_ID, LINE_LOCATION_ID) AS POID
	 po.ID AS POID
    ,PO_NUMBER
	,LINE_NUMBER
	,SHIPMENT_LINE_NUMBER
	,PO_HEADER_ID
	,PO_LINE_ID
	,LINE_LOCATION_ID
	,BuyerID
	,VENDORDesc AS VendorDesc
	,pos.POStatusID
	,pot.POTypeID
	,poc3.POCodeID
	,poc1.POCodeID AS HEADER_CLOSED_CODE
	,poc2.POCodeID AS LINE_CLOSED_CODE
	,poc3.POCodeID AS CLOSED_CODE
	,SHIP_TO
	,BILL_TO
	,NOTE_TO_VENDOR
	,cf1.DateKey AS PO_CREATE_DATE
	,cf2.DateKey AS PO_LINE_CREATE_DATE
	,cf3.DateKey AS NEED_BY_DATE
	,cf4.DateKey AS PROMISED_DATE
	,cf5.DateKey AS PO_LINE_CANCEL_DATE
	,cf7.DateKey AS CANCEL_DATE
FROM Oracle.PurchaseOrder po
	LEFT JOIN Dim.Buyer b ON b.Buyer_NAME = po.BUYER_NAME
	LEFT JOIN Dim.POStatus pos ON po.PO_STATUS = pos.PO_STATUS
	LEFT JOIN Dim.POType pot ON po.PO_TYPE = pot.PO_TYPE
	LEFT JOIN Dim.POCode poc1 ON po.HEADER_CLOSED_CODE = poc1.PO_CODE
	LEFT JOIN Dim.POCode poc2 ON po.LINE_CLOSED_CODE = poc2.PO_CODE
	LEFT JOIN Dim.POCode poc3 ON po.CLOSED_CODE = poc3.PO_CODE
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON po.PO_CREATE_DATE = cf1.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON po.PO_LINE_CREATE_DATE = cf2.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf3 ON po.NEED_BY_DATE = cf3.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf4 ON po.PROMISED_DATE = cf4.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf5 ON po.PO_LINE_CANCEL_DATE = cf5.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf7 ON po.PO_LINE_CANCEL_DATE = cf7.DateKey
	LEFT JOIN dbo.DimVendor v ON po.Vendor_ID = v.VendorKey
WHERE CurrentRecord = 1 
GO
