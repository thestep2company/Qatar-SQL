USE [Operations]
GO
/****** Object:  View [Fact].[SalesForecastShippedEarly]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[SalesForecastShippedEarly] AS
SELECT cf.[MonthID] AS DateID
	--, o.SCH_SHIP_DATE
	--, o.ACTUAL_SHIPMENT_DATE
	, l.LocationID
	, pm.ProductID
	, dc.DemandClassID
	, SUM(o.QTY) AS QUANTITY
	, SUM(o.LIST_DOLLARS*ISNULL(cc.CONVERSION_RATE,1)) AS Sales
FROM Oracle.Orders o
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = o.SCH_SHIP_DATE
	LEFT JOIN dbo.DimCalendarFiscal pcf ON pcf.DateKey = o.ACTUAL_SHIPMENT_DATE
	LEFT JOIN dbo.DimLocation l ON o.Plant = l.LocationKey
	LEFT JOIN dbo.DimProductMaster pm ON o.PART = pm.ProductKey
	LEFT JOIN dbo.DimDemandClass dc ON o.DEMAND_CLASS = dc.DemandClassKey
	LEFT JOIN Oracle.GL_DAILY_RATES cc ON CAST(o.ORDER_DATE AS DATE) = cc.CONVERSION_DATE AND o.Currency = cc.FROM_CURRENCY
WHERE cf.[MonthID] >= (SELECT DateID FROM dbo.DimForecastPeriod)
	AND cf.[MonthID] > pcf.[MonthID]
	AND o.CurrentRecord = 1
	AND FLOW_STATUS_CODE = 'CLOSED'
	AND [Step2 Custom] = 'TOYS'
	AND pm.[Part Type] = 'FINISHED GOODS'
	AND o.[DEMAND_CLASS] <> 'Missing'
GROUP BY 
	  cf.[MonthID]
	--, o.SCH_SHIP_DATE
	--, o.ACTUAL_SHIPMENT_DATE
	, l.LocationID
	, pm.ProductID
	, dc.DemandClassID
--cf.[MonthID], l.LocationID, pm.ProductID, dc.DemandClassID
GO
