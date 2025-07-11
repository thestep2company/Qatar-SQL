USE [Operations]
GO
/****** Object:  View [Audit].[Invoice]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Audit].[Invoice] AS
WITH LastBatch AS (
	SELECT MIN(GL_Date) AS GL_Date, MAX(StartDate) AS LastBatch 
	FROM Oracle.Invoice 
)
, CurrentOrders AS (
	SELECT i.*
	FROM Oracle.Invoice i
		INNER JOIN LastBatch l ON i.StartDate = l.LastBatch
)
, PriorOrders AS (
	SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY CUSTOMER_TRX_LINE_ID ORDER BY StartDate DESC) AS RowNumber
		,CUSTOMER_TRX_LINE_ID, ENTERED_AMOUNT, ACCTD_USD, COGS_AMOUNT, StartDate 
	FROM Oracle.Invoice i
		INNER JOIN LastBatch l ON i.StartDate < l.LastBatch
	WHERE i.GL_Date >= l.GL_Date --for speed
)
--new invoices
SELECT co.ID, 0 AS NetChange--, po.*
FROM CurrentOrders co
	LEFT JOIN PriorOrders po ON co.CUSTOMER_TRX_LINE_ID = po.CUSTOMER_TRX_LINE_ID AND po.RowNumber = 1
WHERE po.CUSTOMER_TRX_LINE_ID IS NULL 
UNION ALL
--change invoices
SELECT co.ID, co.ACCTD_USD - po.ACCTD_USD AS NetChange--, po.*
FROM CurrentOrders co
	LEFT JOIN PriorOrders po ON co.CUSTOMER_TRX_LINE_ID = po.CUSTOMER_TRX_LINE_ID AND po.RowNumber = 1
WHERE po.CUSTOMER_TRX_LINE_ID IS NOT NULL AND co.ACCTD_USD - po.ACCTD_USD <> 0
GO
