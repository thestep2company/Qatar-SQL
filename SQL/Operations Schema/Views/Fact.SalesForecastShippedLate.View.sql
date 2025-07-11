USE [Operations]
GO
/****** Object:  View [Fact].[SalesForecastShippedLate]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[SalesForecastShippedLate] AS
SELECT (SELECT DateID FROM dbo.DimForecastPeriod) AS DateID, pm.ProductID, dc.DemandClassID, SUM(o.QTY) AS QUANTITY, SUM(o.LIST_DOLLARS*ISNULL(cc.CONVERSION_RATE,1)) AS SALES
FROM Oracle.Orders o
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = o.ACTUAL_SHIPMENT_DATE
	LEFT JOIN dbo.DimCalendarFiscal pcf ON pcf.DateKey = o.SCH_SHIP_DATE
	LEFT JOIN dbo.DimLocation l ON o.Plant = l.LocationKey
	LEFT JOIN dbo.DimProductMaster pm ON o.PART = pm.ProductKey
	LEFT JOIN dbo.DimDemandClass dc ON o.DEMAND_CLASS = dc.DemandClassKey
	LEFT JOIN Oracle.GL_DAILY_RATES cc ON CAST(o.ORDER_DATE AS DATE) = cc.CONVERSION_DATE AND o.Currency = cc.FROM_CURRENCY
WHERE 
	o.CurrentRecord = 1
	AND (o.ACTUAL_SHIPMENT_DATE < (SELECT ForecastDate FROM Forecast.ForecastVersion WHERE BudgetID = 13) --shipped before forecast was loaded
	OR (o.ACTUAL_SHIPMENT_DATE < CAST(GETDATE() AS DATE) --forecast has not been loaded yet so use all activity before today
		AND (SELECT YEAR(ForecastDate)*100+MONTH(ForecastDate) FROM Forecast.ForecastVersion WHERE BudgetID = 13)
		<> (SELECT YEAR(GETDATE())*100+MONTH(GETDATE()))))
	AND pm.[Part Type] = 'FINISHED GOODS'
	AND cf.[MonthID] = (SELECT DISTINCT CurrentMonthID FROM dbo.DimCalendarFiscal WHERE CurrentMonthID IS NOT NULL) --shipped in current month
	AND pcf.[MonthID] < (SELECT DISTINCT CurrentMonthID FROM dbo.DimCalendarFiscal WHERE CurrentMonthID IS NOT NULL) --scheduled in prior months
	AND o.DEMAND_CLASS <> 'Missing'
GROUP BY pcf.[MonthID], pm.ProductID, dc.DemandClassID, o.SCH_SHIP_DATE, o.DEMAND_CLASS
GO
