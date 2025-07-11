USE [Operations]
GO
/****** Object:  View [Error].[InvoiceDuplicateKey]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[InvoiceDuplicateKey] AS 
SELECT [CUSTOMER_TRX_LINE_ID], COUNT(*) AS RecordCount
FROM Oracle.Invoice WITH(NOLOCK) WHERE CurrentRecord = 1 GROUP BY [CUSTOMER_TRX_LINE_ID] HAVING COUNT(*) > 1
GO
