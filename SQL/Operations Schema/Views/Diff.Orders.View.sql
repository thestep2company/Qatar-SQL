USE [Operations]
GO
/****** Object:  View [Diff].[Orders]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Diff].[Orders] AS
WITH LastBatch AS (
	SELECT MAX(StartDate) AS LastBatch FROM Oracle.Orders 
)
, CurrentOrders AS (
	SELECT i.* FROM Oracle.Orders i
		INNER JOIN LastBatch l ON i.STartDate = l.LastBatch
	WHERE i.CurrentRecord = 1
)
, PriorOrders AS (
	SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY ORD_HEADER_ID, ORD_LINE_ID ORDER BY StartDate DESC) AS RowNumber
		, ORDER_DATE, ORD_HEADER_ID, ORD_LINE_ID, i.CANCEL_DATE, i.SELL_DOLLARS, StartDate FROM Oracle.Orders i
		INNER JOIN LastBatch l ON i.StartDate < l.LastBatch
)
--new orders
SELECT co.*, 0 AS NetChange--, po.*
FROM CurrentOrders co
	LEFT JOIN PriorOrders po ON co.ORD_HEADER_ID = po.ORD_HEADER_ID AND co.ORD_LINE_ID = po.ORD_LINE_ID AND po.RowNumber = 1
WHERE po.ORD_HEADER_ID IS NULL 
UNION
--change orders
SELECT co.*, co.SELL_DOLLARS - po.SELL_DOLLARS AS NetChange--, po.*
FROM CurrentOrders co
	LEFT JOIN PriorOrders po ON co.ORD_HEADER_ID = po.ORD_HEADER_ID AND co.ORD_LINE_ID = po.ORD_LINE_ID AND po.RowNumber = 1
WHERE po.ORD_HEADER_ID IS NOT NULL AND co.SELL_DOLLARS - po.SELL_DOLLARS <> 0
GO
