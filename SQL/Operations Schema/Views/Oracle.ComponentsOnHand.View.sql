USE [Operations]
GO
/****** Object:  View [Oracle].[ComponentsOnHand]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Oracle].[ComponentsOnHand] AS
SELECT * FROM Oracle.MSC_ORDERS_V mov
WHERE (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 18 and mov.item_segments < '400000' )
	AND CurrentRecord = 1
GO
