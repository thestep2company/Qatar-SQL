USE [Operations]
GO
/****** Object:  View [Fact].[PriorOpenOrders]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[PriorOpenOrders] AS
SELECT cf.[MonthID] AS DateID, l.LocationID, pm.ProductID, dc.DemandClassID, -SUM(oo.QTY) AS QUANTITY
FROM Oracle.Orders oo
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = oo.SCH_SHIP_DATE
	LEFT JOIN dbo.DimCalendarFiscal pcf ON pcf.DateKey = oo.ORDER_DATE
	LEFT JOIN dbo.DimLocation l ON oo.Plant = l.LocationKey
	LEFT JOIN dbo.DimProductMaster pm ON oo.PART = pm.ProductKey
	LEFT JOIN dbo.DimDemandClass dc ON oo.DEMAND_CLASS = dc.DemandClassKey
WHERE cf.[MonthID] = (SELECT DateID + 1 FROM dbo.DimForecastPeriod)
	--AND pcf.[MonthID] <= (SELECT DateID + 1 FROM dbo.DimForecastPeriod)
	--AND @sku = pm.ProductKey AND @demandClass = dc.DemandClassKey
	AND '2024-06-07 11:00.000' BETWEEN oo.StartDate AND ISNULL(oo.EndDate,'9999-12-31')
	AND ACTUAL_SHIPMENT_DATE IS NULL
GROUP BY cf.[MonthID], l.LocationID, pm.ProductID, dc.DemandClassID
GO
