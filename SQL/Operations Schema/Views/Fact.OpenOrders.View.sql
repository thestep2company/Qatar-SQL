USE [Operations]
GO
/****** Object:  View [Fact].[OpenOrders]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[OpenOrders] AS
SELECT cf.DateID, l.LocationID, pm.ProductID, dc.DemandClassID, SUM(oo.QTY) AS QUANTITY
FROM Output.OpenOrders oo
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = oo.ESTIMATED_SHIP_DATE
	LEFT JOIN dbo.DimLocation l ON oo.Plant = l.LocationKey
	LEFT JOIN dbo.DimProductMaster pm ON oo.PART = pm.ProductKey
	LEFT JOIN dbo.DimDemandClass dc ON oo.DEMAND_CLASS = dc.DemandClassKey
WHERE [MonthID] >= (SELECT DateID FROM dbo.DimForecastPeriod)
GROUP BY cf.DateID, l.LocationID, pm.ProductID, dc.DemandClassID
GO
