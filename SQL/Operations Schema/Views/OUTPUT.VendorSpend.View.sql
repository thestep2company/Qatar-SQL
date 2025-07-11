USE [Operations]
GO
/****** Object:  View [OUTPUT].[VendorSpend]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE VIEW [OUTPUT].[VendorSpend] AS 
  SELECT 
	   ap.[VENDOR_ID]
      ,CASE WHEN YEAR(ap.[ACCOUNTING_DATE]) = YEAR(GETDATE()) THEN SUM(ap.[AMOUNT]) ELSE 0 END AS SpendYTD
	  ,CASE WHEN YEAR(ap.[ACCOUNTING_DATE]) <> YEAR(GETDATE()) THEN SUM(ap.[AMOUNT]) ELSE 0 END AS SpendPriorYear
  FROM [Operations].[Oracle].[APInvoice] ap
	INNER JOIN (SELECT DISTINCT VENDOR_ID FROM Oracle.PO_Headers_All WHERE CurrentRecord = 1) poh ON ap.VENDOR_ID = poh.VENDOR_ID
  WHERE ap.CurrentRecord = 1
	AND YEAR(ap.[ACCOUNTING_DATE]) = YEAR(GETDATE()) - 1
  GROUP BY ap.[VENDOR_ID], YEAR(ap.[ACCOUNTING_DATE])
GO
