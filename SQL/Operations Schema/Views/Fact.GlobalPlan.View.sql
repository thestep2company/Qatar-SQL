USE [Operations]
GO
/****** Object:  View [Fact].[GlobalPlan]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[GlobalPlan] AS 
SELECT cf.[MonthID] AS DateID, LocationID, ProductID, DemandClassID, ORDER_TYPE, SUM(QUANTITY) AS QUANTITY
FROM Oracle.MSC_ORDERS_V_FORECAST mov --20240528 mov
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = CAST(START_OF_WEEK AS DATE)
	LEFT JOIN dbo.DimLocation l ON RIGHT(mov.ORGANIZATION_CODE,3) = l.LocationKey
	LEFT JOIN dbo.DimProductMaster pm ON mov.ITEM_SEGMENTS = pm.ProductKey
	LEFT JOIN dbo.DimDemandClass dc ON mov.DEMAND_CLASS = dc.DemandClassKey
WHERE (mov.quantity <> 0 and mov.plan_id = 21 and mov.order_type in (29, 30)) 
	AND CAST(cf.DateKey AS DATE) < '2024-12-29' 
	--AND GETDATE() BETWEEN mov.StartDate AND ISNULL(mov.EndDate,'9999-12-31') 
	AND CASE WHEN DATEPART(HOUR,GETDATE()) >= 18 THEN DATEADD(HOUR,11,DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)) ELSE DATEADD(HOUR,4,DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)) END BETWEEN StartDate AND ISNULL(EndDate, '9999-12-31') --o.CurrentRecord = 1
GROUP BY MonthID, LocationID, ProductID, DemandClassID, ORDER_TYPE
GO
