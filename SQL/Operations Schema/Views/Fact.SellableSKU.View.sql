USE [Operations]
GO
/****** Object:  View [Fact].[SellableSKU]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[SellableSKU] AS
WITH SellableSKU AS (
	SELECT SOURCE.*, TARGET.ProductID AS InventorySKU --TARGET.QUANTITY-SOURCE.QUANTITY
	FROM Fact.GlobalPlan Source 
		LEFT JOIN Fact.ASCPPlan Target 
	ON  Source.ProductID = TARGET.ProductID 
		AND Source.ORDER_TYPE = Target.ORDER_TYPE 
		AND SOURCE.DemandClassID = TARGET.DemandClassID 
		AND SOURCE.DateID = TARGET.DateID 
		AND SOURCE.LocationID = TARGET.LocationID
)
, ActivePlan AS (SELECT DISTINCT ProductID FROM Fact.GlobalPlan)
, Data AS ( 
	--reverses the forecast of the child SKUs
	--SELECT 1 AS MethodID, ss.DateID, ss.LocationID, pm2.ProductID, ss.DemandClassID, ss.ORDER_TYPE, SUM(ss.QUANTITY*-COMPONENT_QUANTITY) AS QUANTITY
	--FROM SellableSKU ss
	--	LEFT JOIN dbo.DimProductMaster pm ON ss.ProductID = pm.ProductID
	--	INNER JOIN dbo.DimBillOfMaterial bom ON bom.PARENT_SKU = pm.ProductKey AND Level = 1
	--	LEFT JOIN dbo.DimProductMaster pm2 ON bom.CHILD_SKU = pm2.ProductKey
	--WHERE InventorySKU IS NULL
	--GROUP BY ss.DateID, ss.LocationID, pm2.ProductID, ss.DemandClassID, ss.ORDER_TYPE
	--UNION ALL
	--retains forecast of the parent SKUs
	SELECT 2 AS MethodID, ss.DateID, ss.LocationID, ss.ProductID, ss.DemandClassID, ss.ORDER_TYPE, SUM(ss.QUANTITY) AS QUANTITY
	FROM SellableSKU ss
		LEFT JOIN dbo.DimProductMaster pm ON ss.ProductID = pm.ProductID
	WHERE InventorySKU IS NULL
	GROUP BY ss.DateID, ss.LocationID, ss.ProductID, ss.DemandClassID, ss.ORDER_TYPE, ss.ProductID, ss.InventorySKU
	UNION ALL
	--retains all non child inventory SKUs
	SELECT 3 AS MethodID, ss.DateID, ss.LocationID, ss.ProductID, ss.DemandClassID, ss.ORDER_TYPE, SUM(ss.QUANTITY) AS QUANTITY
	FROM SellableSKU ss
		LEFT JOIN dbo.DimProductMaster pm ON ss.ProductID = pm.ProductID
		LEFT JOIN dbo.DimBillOfMaterial bom ON bom.CHILD_SKU = pm.ProductKey AND Level = 1
		LEFT JOIN dbo.DimProductMaster pm2 ON bom.PARENT_SKU = pm2.ProductKey
		LEFT JOIN ActivePlan ap ON pm2.ProductID = ap.ProductID 
	WHERE --(ap.ProductID IS NULL AND pm.ProductDesc NOT LIKE '%(Box%of%)%') --
		(ap.ProductID IS NULL OR pm2.ProductDesc LIKE '%COMBO%' OR pm2.ProductDesc LIKE '%(%/%)%') AND InventorySKU IS NOT NULL
	GROUP BY ss.DateID, ss.LocationID, ss.ProductID, ss.DemandClassID, ss.ORDER_TYPE
	--order from prior months with current month ship dates or beyond
	UNION ALL
	--any shipments must be deducted from plan
	SELECT 4 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 4 AS ORDER_TYPE, -oo.QUANTITY
	FROM Fact.SalesForecastShippedCurrent  oo
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	WHERE pm.[Item Type] <> 'STEP2 FG KIT' --AND pm.[Item Type] = 'FINISHED GOODS'
	UNION ALL
	SELECT 5 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 5 AS ORDER_TYPE, -oo.QUANTITY
	FROM Fact.SalesForecastShippedEarly oo
		--LEFT JOIN SellableSKU ss ON ss.DateID = oo.DateID AND ss.LocationID = oo.LocationID AND ss.ProductID = oo.ProductID AND ss.DemandClassID = oo.DemandClassID
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	WHERE pm.[Item Type] <> 'STEP2 FG KIT' --AND pm.[Item Type] = 'FINISHED GOODS'
		--InventorySKU IS NULL
	UNION ALL
	SELECT 6 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 6 AS ORDER_TYPE, -oo.QUANTITY
	FROM Fact.SalesForecastShippedLate oo
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	WHERE pm.[Item Type] <> 'STEP2 FG KIT' --AND pm.[Item Type] = 'FINISHED GOODS'
	UNION ALL
	--any open orders are deducted if it is a kit/combo SKU
	SELECT 7 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 7 AS ORDER_TYPE, -oo.QUANTITY
	FROM Fact.SalesForecastOpenCurrent oo 
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	WHERE pm.[Item Type] <> 'STEP2 FG KIT' --AND pm.[Item Type] = 'FINISHED GOODS'
	UNION ALL
	SELECT 8 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 8 AS ORDER_TYPE, -oo.QUANTITY
	FROM Fact.SalesForecastOpenStill oo
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	WHERE pm.[Item Type] <> 'STEP2 FG KIT' --AND pm.[Item Type] = 'FINISHED GOODS'
	UNION ALL
	SELECT 9 AS MethodID, oo.DateID, oo.LocationID, oo.ProductID, oo.DemandClassID, 9 AS ORDER_TYPE, -oo.QUANTITY
	FROM Fact.SalesForecastOpenFuture oo
		LEFT JOIN dbo.DimProductMaster pm ON oo.ProductID = pm.ProductID 
	WHERE pm.[Item Type] <> 'STEP2 FG KIT' --AND pm.[Item Type] = 'FINISHED GOODS'	
)
SELECT cf.DateID, d.LocationID, d.ProductID, d.DemandClassID, d.Order_TYPE, d.MethodID, SUM(d.Quantity) AS Quantity 
FROM Data d
	LEFT JOIN (SELECT MonthID, MIN(DateID) AS DateID FROM dbo.DimCalendarFiscal GROUP BY MonthID) cf ON cf.MonthID = d.DateID
--WHERE d.ProductID = 35176 AND d.DemandClassID = 8
GROUP BY cf.DateID, d.LocationID, d.ProductID, d.DemandClassID, d.Order_TYPE, d.MethodID
GO
