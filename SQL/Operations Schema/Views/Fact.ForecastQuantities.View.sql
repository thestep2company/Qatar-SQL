USE [Operations]
GO
/****** Object:  View [Fact].[ForecastQuantities]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Fact].[ForecastQuantities] AS
WITH Methods AS (
	SELECT 1 AS MethodID, 'Forecast Input' AS MethodName UNION --forcast provided
	SELECT 2 AS MethodID, 'Shipped Early' AS MethodName UNION --scheduled to ship this month, shipped last month
	SELECT 3 AS MethodID, 'Shipped This Month' AS MethodName UNION --scheduled and shipped this month
	SELECT 4 AS MethodID, 'Shipped Late' AS MethodName UNION --sheculed to to ship last month, shipped this month
	SELECT 5 AS MethodID, 'Open Prior' AS MethodName UNION --scheduled to ship last month
	SELECT 6 AS MethodID, 'Open Current' AS MethodName UNION --scheduled to ship in current month
	SELECT 7 AS MethodID, 'Forecast Forward' AS MethodName UNION --next month available for forward consumption
	SELECT 8 AS MethodID, 'Overshipped' AS MethodName UNION --calc if shipped more this month than (forecast input - shipped early) and forward forecast is available.  Not sure if goes beyond this month + next month quantity.
	SELECT 9 AS MethodID, 'Forecast Output' AS MethodName UNION --retain forecast if this month shipments and open orders has not been met.  Otherwise this month shipments and open orders + overshipped
	SELECT 10 AS MethodID, 'Forecast Variance' AS MethodName 
)
,Variance AS ( 
	SELECT 1 AS MethodID, cf.MonthID AS DateID, 0 AS LocationID, pm.ProductID, dc.DemandClassID, 1 AS ORDER_TYPE, -CAST(Quantity AS INT) AS Quantity
	FROM Step2.Forecast sf
		LEFT JOIN dbo.DimProductMaster pm ON sf.Item_Num = pm.ProductKey 
		LEFT JOIN dbo.DimDemandClass dc ON sf.[Demand_Class] = dc.DemandClassKey
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(sf.[Start Date] AS DATE) = cf.DateKey 
	WHERE CurrentRecord = 1
	UNION ALL
	SELECT 2 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 5 AS ORDER_TYPE, oo.QUANTITY
	FROM Fact.SalesForecastShippedEarly oo --consume forward forecast
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
		--InventorySKU IS NULL
	UNION ALL
	--any shipments must be deducted from plan
	SELECT 3 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 4 AS ORDER_TYPE, oo.QUANTITY
	FROM Fact.SalesForecastShippedCurrent  oo --current shipments must be deducted from remaining forecast
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	UNION ALL
	SELECT 4 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 6 AS ORDER_TYPE, -oo.QUANTITY
	FROM Fact.SalesForecastShippedLate oo  --shipments from prior months
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	UNION ALL
	SELECT 5 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 8 AS ORDER_TYPE, -oo.QUANTITY
	FROM Fact.SalesForecastOpenStill oo
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	UNION ALL
	--any open orders are deducted if it is a kit/combo SKU
	SELECT 6 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 7 AS ORDER_TYPE, oo.QUANTITY
	FROM Fact.SalesForecastOpenCurrent oo 
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
)
,ForecastOutput AS ( 
	SELECT 1 AS MethodID, cf.MonthID AS DateID, 0 AS LocationID, pm.ProductID, dc.DemandClassID, 1 AS ORDER_TYPE, CAST(Quantity AS INT) AS Quantity
	FROM Step2.Forecast sf
		LEFT JOIN dbo.DimProductMaster pm ON sf.Item_Num = pm.ProductKey 
		LEFT JOIN dbo.DimDemandClass dc ON sf.[Demand_Class] = dc.DemandClassKey
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(sf.[Start Date] AS DATE) = cf.DateKey 
	WHERE sf.CurrentRecord = 1
	--UNION ALL
	--SELECT 2 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 5 AS ORDER_TYPE, -oo.QUANTITY
	--FROM Fact.SalesForecastShippedEarly oo --consume forward forecast
	--	LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	--	--InventorySKU IS NULL
	--UNION ALL
	--SELECT 4 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 6 AS ORDER_TYPE, oo.QUANTITY
	--FROM Fact.SalesForecastShippedLate oo  --shipments from prior months
	--	LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	----UNION ALL
	----SELECT 5 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 8 AS ORDER_TYPE, oo.QUANTITY
	----FROM Fact.SalesForecastOpenStill oo
	----	LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
)
, Data AS (
	SELECT 1 AS MethodID, cf.MonthID AS DateID, pm.ProductID, dc.DemandClassID, 1 AS ORDER_TYPE, Quantity
	FROM Step2.Forecast sf
		LEFT JOIN dbo.DimProductMaster pm ON sf.Item_Num = pm.ProductKey 
		LEFT JOIN dbo.DimDemandClass dc ON sf.[Demand_Class] = dc.DemandClassKey
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(sf.[Start Date] AS DATE) = cf.DateKey
	WHERE sf.CurrentRecord = 1
	UNION ALL
	SELECT 2 AS MethodID, oo.DateID, oo.ProductID, oo.DemandClassID, 4 AS ORDER_TYPE, oo.QUANTITY
	FROM Fact.SalesForecastShippedEarly oo --consume forward forecast
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
		--InventorySKU IS NULL
	UNION ALL
	--any shipments must be deducted from plan
	SELECT 3 AS MethodID, oo.DateID, oo.ProductID, oo.DemandClassID, 3 AS ORDER_TYPE, oo.QUANTITY
	FROM Fact.SalesForecastShippedCurrent  oo --current shipments must be deducted from remaining forecast
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	UNION ALL
	SELECT 4 AS MethodID, oo.DateID, oo.ProductID, oo.DemandClassID, 5 AS ORDER_TYPE, oo.QUANTITY
	FROM Fact.SalesForecastShippedLate oo  --shipments from prior months
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	UNION ALL
	SELECT 5 AS MethodID, oo.DateID, oo.ProductID, oo.DemandClassID, 7 AS ORDER_TYPE, oo.QUANTITY
	FROM Fact.SalesForecastOpenStill oo
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	UNION ALL
	SELECT 6 AS MethodID, oo.DateID, oo.ProductID, oo.DemandClassID, 6 AS ORDER_TYPE, oo.QUANTITY
	FROM Fact.SalesForecastOpenCurrent oo 
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	UNION ALL
	SELECT 9 AS Method, DateID, ProductID, DemandClassID, 2 AS ORDER_TYPE, SUM(QUANTITY) AS QUANTITY 
	FROM ForecastOutput
	WHERE DateID >= (SELECT MAX(CurrentMonthID) FROM dbo.DimCalendarFiscal)
	GROUP BY DateID, ProductID, DemandClassID
	UNION ALL
	SELECT 10 AS Method, DateID, ProductID, DemandClassID, 2 AS ORDER_TYPE, SUM(QUANTITY) AS QUANTITY 
	FROM Variance
	WHERE DateID = (SELECT MAX(CurrentMonthID) FROM dbo.DimCalendarFiscal)
	GROUP BY DateID, ProductID, DemandClassID
)
SELECT cf.DateID, d.ProductID, d.DemandClassID, MethodName, m.MethodID, d.Quantity
FROM Data d
	LEFT JOIN (SELECT MonthID, MIN(DateID) AS DateID FROM dbo.DimCalendarFiscal GROUP BY MonthID) cf ON cf.MonthID = d.DateID
	LEFT JOIN Methods m ON d.MethodID = m.MethodID
WHERE m.MethodID = 9
GO
