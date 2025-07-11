USE [Operations]
GO
/****** Object:  View [Dim].[Vendor]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Dim].[Vendor] AS
SELECT DISTINCT 
	ID AS VendorID
	, VENDOR_ID AS VendorKey
	, VENDOR_NAME AS VendorName
	, CAST(CAST(VENDOR_ID AS INT) AS VARCHAR(10)) + ': ' + VENDOR_NAME AS VendorDesc
	, VENDOR_TYPE_LOOKUP_CODE AS VendorType
FROM Oracle.AP_SUPPLIERS
WHERE CurrentRecord = 1

GO
