USE [Operations]
GO
/****** Object:  View [OUTPUT].[SalesInvoiceCheckSum]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[SalesInvoiceCheckSum] AS 
SELECT 
	  cf.[Month Sort] AS [Period]
	  ,SUM([ACCTD_USD]) AS Sales
	  ,SUM([QTY_INVOICED]) AS Qty
	  ,COUNT(*) AS RecordCount
FROM Oracle.Invoice i
	LEFT JOIN dbo.DimCalendarFiscal cf ON i.GL_DATE = cf.DateKey
WHERE i.CurrentRecord = 1 AND cf.DateID >= (43100 + 366) --AND INV_DESCRIPTION NOT LIKE '% PPD %'
	AND cf.[Month Sort] BETWEEN 201901 AND 202108
GROUP BY cf.[Month Sort]

GO
