USE [Operations]
GO
/****** Object:  View [Fact].[ClosedOrders]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Fact].[ClosedOrders] AS
SELECT cf.[MonthID] AS DateID, l.LocationID, pm.ProductID, dc.DemandClassID, -SUM(oo.QTY) AS QUANTITY
FROM Oracle.Orders oo
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = oo.SCH_SHIP_DATE
	LEFT JOIN dbo.DimCalendarFiscal pcf ON pcf.DateKey = oo.ORDER_DATE
	LEFT JOIN dbo.DimLocation l ON oo.Plant = l.LocationKey
	LEFT JOIN dbo.DimProductMaster pm ON oo.PART = pm.ProductKey
	LEFT JOIN dbo.DimDemandClass dc ON oo.DEMAND_CLASS = dc.DemandClassKey
WHERE cf.[MonthID] = (SELECT DateID + 1 FROM dbo.DimForecastPeriod)
	--AND @sku = pm.ProductKey AND @demandClass = dc.DemandClassKey AND cf.[Month Sort] = '202406'
	AND '2024-06-07 11:00.000' BETWEEN StartDate AND ISNULL(EndDate, '9999-12-31')
	AND FLOW_STATUS_CODE = 'CLOSED'
	--AND pcf.[MonthID] < (SELECT DateID + 1 FROM dbo.DimForecastPeriod)
GROUP BY cf.[MonthID], l.LocationID, pm.ProductID, dc.DemandClassID
GO
