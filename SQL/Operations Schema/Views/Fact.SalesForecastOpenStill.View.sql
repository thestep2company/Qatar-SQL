USE [Operations]
GO
/****** Object:  View [Fact].[SalesForecastOpenStill]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [Fact].[SalesForecastOpenStill] AS
SELECT (SELECT DateID+1 FROM dbo.DimForecastPeriod) AS DateID, l.LocationID, pm.ProductID, dc.DemandClassID, SUM(o.QTY) AS QUANTITY, SUM(o.LIST_DOLLARS*ISNULL(cc.CONVERSION_RATE,1)) AS SALES
FROM Oracle.Orders o
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = o.ACTUAL_SHIPMENT_DATE
	LEFT JOIN dbo.DimCalendarFiscal pcf ON pcf.DateKey = o.SCH_SHIP_DATE
	LEFT JOIN dbo.DimLocation l ON o.Plant = l.LocationKey
	LEFT JOIN dbo.DimProductMaster pm ON o.PART = pm.ProductKey
	LEFT JOIN dbo.DimDemandClass dc ON o.DEMAND_CLASS = dc.DemandClassKey
	LEFT JOIN Oracle.GL_DAILY_RATES cc ON CAST(o.ORDER_DATE AS DATE) = cc.CONVERSION_DATE AND o.Currency = cc.FROM_CURRENCY
WHERE 
	--AND @sku = pm.ProductKey AND @demandClass = dc.DemandClassKey AND cf.[Month Sort] = '202406'
	--AND '2024-06-07 11:00.000' BETWEEN StartDate AND ISNULL(EndDate, '9999-12-31')
	CASE WHEN DATEPART(HOUR,GETDATE()) >= 18 THEN DATEADD(HOUR,11,DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)) ELSE DATEADD(MINUTE,15,DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)) END BETWEEN StartDate AND ISNULL(EndDate, '9999-12-31')--o.CurrentRecord = 1
	AND ACTUAL_SHIPMENT_DATE IS NULL
	AND pm.[Step2 Custom] = 'TOYS'
	AND pm.[Part Type] = 'FINISHED GOODS'
	AND FLOW_STATUS_CODE NOT IN ('CLOSED', 'CANCELLED','DELETED', 'ENTERED')
	AND pcf.[MonthID] < (SELECT DISTINCT CurrentMonthID FROM dbo.DimCalendarFiscal WHERE CurrentMonthID IS NOT NULL)
GROUP BY pcf.[MonthID], l.LocationID, pm.ProductID, dc.DemandClassID
GO
