USE [Operations]
GO
/****** Object:  View [OUTPUT].[VendorSKUCount]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  

  CREATE VIEW [OUTPUT].[VendorSKUCount] AS 
  SELECT 
	   po.[VENDOR_ID]
	   ,COUNT(DISTINCT po.ITEM) AS SKUCount
  FROM [Oracle].[PurchaseOrder] po
	INNER JOIN (SELECT DISTINCT VENDOR_ID FROM Oracle.PO_Headers_All WHERE CurrentRecord = 1) poh ON po.VENDOR_ID = poh.VENDOR_ID
  WHERE po.CurrentRecord = 1
	AND YEAR(po.[PO_LINE_CREATE_DATE]) = YEAR(GETDATE()) - 1
  GROUP BY po.[VENDOR_ID]
GO
