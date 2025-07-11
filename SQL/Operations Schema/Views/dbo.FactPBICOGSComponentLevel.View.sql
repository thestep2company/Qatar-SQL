USE [Operations]
GO
/****** Object:  View [dbo].[FactPBICOGSComponentLevel]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FactPBICOGSComponentLevel] AS 
WITH BOM AS (
	SELECT PARENT_SKU, Child_SKU, COUNT(*) OVER (PARTITION BY PARENT_SKU)*1.0 AS COMPONENT_COUNT
	FROM dbo.DimBillOfMaterial bom 
	WHERE bom.Level = 1
)
, KitData AS (
	SELECT  pbi.DateID, pbi.DateKey, pbi.ProductID, pbi.LocationID
		, pm.ProductKey ,pm.[Item Type], bom.CHILD_SKU
		, SUM(Sales) AS Sales, SUM(COGS) AS COGS, SUM(Sales-COGS)/SUM(Sales) AS Margin
		, SUM(Qty) AS Units
		, SUM(Qty)/COMPONENT_COUNT AS SalesMultiplier
		--, (SELECT COUNT(DISTINCT bom.CHILD_SKU) FROM dbo.DimBillOfMaterial bom2 WHERE bom.ProductID = bom2.ProductID AND bom.CHILD_SKU = bom2.CHILD_SKU) AS ComponentUnits
		, SUM(COGS)/SUM(Qty) AS UnitCOGS
		, fs.ItemCost
		, (1/(1-(SUM(Sales-COGS)/SUM(Sales))))*SUM(COGS) AS ComponentSales
	FROM dbo.FactPbiSales pbi 
		LEFT JOIN dbo.DimProductMaster pm ON pbi.ProductID = pm.ProductID
		LEFT JOIN dbo.DimCalendarFiscal cf ON pbi.DateID = cf.DateID
		LEFT JOIN BOM ON pm.ProductKey = bom.PARENT_SKU 
		LEFT JOIN dbo.DimProductMaster pm2 ON bom.CHILD_SKU = pm2.ProductKey
		LEFT JOIN dbo.FactStandard fs ON cf.DateKey BETWEEN fs.StartDate AND fs.EndDate AND pm2.ProductID = fs.ProductID AND fs.LocationID = 3
	WHERE pm.[Item Type] = 'STEP2 FG Kit' --AND [Month Sort] >= '202406'
	GROUP BY pbi.DateID, pbi.DateKey, pbi.ProductID, pbi.LocationID
		, pm.ProductKey ,pm.[Item Type], bom.CHILD_SKU, fs.ItemCost, COMPONENT_COUNT
	--ORDER BY pbi.DateID, pbi.DateKey, pbi.ProductID, pbi.LocationID
)
SELECT DateID, DateKey, ProductID, LocationID, ComponentSales AS Sales, ItemCost AS COGS, SalesMultiplier AS Units FROM KitData
UNION ALL
SELECT  DateID, DateKey, ProductID, LocationID, SUM(Sales) AS Sales, SUM(COGS) AS COGS, SUM(Qty) AS Units
FROM dbo.FactPbiSales GROUP BY DateID, DateKey, ProductID, LocationID
GO
