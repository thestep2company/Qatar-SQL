USE [Operations]
GO
/****** Object:  View [Oracle].[PurchaseOrders]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Oracle].[PurchaseOrders] AS
SELECT * FROM Oracle.MSC_ORDERS_V_STAGING mov
WHERE (mov.quantity <> 0 
	and (
		   (ORDER_TYPE_TEXT = 'Purchase Order' AND mov.plan_id IN (4,22)) 
		OR (ORDER_TYPE_TEXT = 'Work Order' AND mov.Plan_id = 4)
	)
	and mov.order_type IN (1, 3) and mov.source_table = 'MSC_SUPPLIES')
GO
