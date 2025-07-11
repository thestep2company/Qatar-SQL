USE [Operations]
GO
/****** Object:  View [Oracle].[ForecastOpenOrdersOnHand]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Oracle].[ForecastOpenOrdersOnHand] AS
SELECT * FROM Oracle.MSC_ORDERS_V_STAGING mov
WHERE (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (18, 29, 30)) 
GO
