USE [Operations]
GO
/****** Object:  View [PIM].[Carton]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [PIM].[Carton] AS 

WITH SKUs AS (
		SELECT DISTINCT pm.ProductKey,  pm.ProductKey + '-BOX1' AS BoxSKU, pm.PlaceholderType
		FROM dbo.DimProductMaster pm
			LEFT JOIN dbo.DimBillOfMaterial bom ON bom.CHILD_SKU = pm.ProductKey AND bom.CHILD_SKU <> bom.PARENT_SKU AND bom.PARENT_SKU IS NOT NULL
		WHERE pm.[Part Type] = 'FINISHED GOODS'
			AND pm.[Item Type] <> 'STEP2 FG KIT'
			AND bom.CHILD_SKU IS NULL --is not part of a kit
			AND LEN(pm.ProductKey) < 25
			AND pm.ProductKey NOT LIKE 'Placeholder%'
			AND pm.ProductKey NOT LIKE 'Roll%'
			AND pm.[Inventory Status Code] <> 'Inactive'
		UNION
		SELECT DISTINCT pm.ProductKey,  pm.ProductKey + '-BOX1' AS BoxSKU, pm.PlaceholderType
		FROM dbo.DimProductMaster pm
			LEFT JOIN dbo.DimBillOfMaterial bom ON bom.CHILD_SKU = pm.ProductKey AND bom.CHILD_SKU <> bom.PARENT_SKU AND bom.PARENT_SKU IS NOT NULL
		WHERE pm.[Part Type] = 'FINISHED GOODS'
			AND pm.[Item Type] = 'STEP2 FG KIT'
			AND bom.CHILD_SKU IS NULL --is not part of a kit
			AND LEN(pm.ProductKey) < 25
			AND pm.ProductKey NOT LIKE 'Placeholder%'
			AND pm.ProductKey NOT LIKE 'Roll%'
			AND pm.[Inventory Status Code] <> 'Inactive'
		UNION
		SELECT DISTINCT pm2.ProductKey, pm2.ProductKey + '-BOX' + CAST(ROW_NUMBER() OVER (PARTITION BY pm1.ProductKey ORDER BY ITEM_NUM) AS VARCHAR(2)) AS BoxSKU, pm1.PlaceholderType
		FROM dbo.DimProductMaster pm1 
			LEFT JOIN dbo.DimBillOfMaterial bom ON bom.PARENT_SKU = pm1.ProductKey
			LEFT JOIN dbo.DimProductMaster pm2 ON bom.CHILD_SKU = pm2.ProductKey AND pm2.[Part Type] = 'FINISHED GOODS'
		WHERE pm1.[Item Type] = 'STEP2 FG KIT'
			AND pm2.[Part Type] = 'FINISHED GOODS'
			AND '|' + bom.PARENT_SKU = bom.PARENT_PATH
			AND LEN(pm1.ProductKey) < 25
			AND pm1.ProductKey NOT LIKE 'Placeholder%'
			AND pm1.ProductKey NOT LIKE 'Roll%'
			AND pm1.[Inventory Status Code] <> 'Inactive'
		GROUP BY pm1.ProductKey , pm2.ProductKey,  bom.ITEM_NUM, pm1.PlaceholderType
			
		--UNION
		--SELECT DISTINCT ProductKey, pm.ProductKey + '-BOX1' AS BoxSKU, pm.PlaceholderType
		--FROM dbo.DimProductMaster pm
		--	LEFT JOIN dbo.DimBillOfMaterial bom ON bom.CHILD_SKU = pm.ProductKey AND bom.CHILD_SKU <> bom.PARENT_SKU AND bom.PARENT_SKU IS NOT NULL
		--WHERE pm.[Part Type] = 'FINISHED GOODS'
		--	AND pm.[Item Type] <> 'STEP2 FG KIT'
		--	AND bom.CHILD_SKU IS NULL --is not part of a kit
		--	AND LEN(pm.ProductKey) < 25
		--	AND pm.ProductKey NOT LIKE 'Placeholder%'
		--	AND pm.ProductKey NOT LIKE 'Roll%'
		--UNION
		--SELECT pm2.ProductKey, pm2.ProductKey + '-BOX' + CAST(ROW_NUMBER() OVER (PARTITION BY pm1.ProductKey ORDER BY ITEM_NUM) AS VARCHAR(2)) AS BoxSKU, pm2.PlaceholderType
		--FROM dbo.DimProductMaster pm1 
		--	LEFT JOIN dbo.DimBillOfMaterial bom ON bom.PARENT_SKU = pm1.ProductKey
		--	LEFT JOIN dbo.DimProductMaster pm2 ON bom.CHILD_SKU = pm2.ProductKey AND pm2.[Part Type] = 'FINISHED GOODS'
		--WHERE  pm1.[Item Type] = 'STEP2 FG KIT'
		--	AND pm2.[Part Type] = 'FINISHED GOODS'
		--	AND '|' + bom.PARENT_SKU = bom.PARENT_PATH
		--	AND LEN(pm1.ProductKey) < 25	
		--	AND pm1.ProductKey NOT LIKE 'Placeholder%'
		--	AND pm1.ProductKey NOT LIKE 'Roll%'
		--GROUP BY pm2.ProductKey, pm2.ProductKey,  bom.ITEM_NUM, pm1.ProductKey, pm2.PlaceholderType
		--UNION
		----budget		
		--SELECT DISTINCT ProductKey, pm.ProductKey + '-BOX1' AS BoxSKU, pm.PlaceholderType
		--FROM dbo.DimProductMaster pm 
		--	LEFT JOIN dbo.DimBillOfMaterial bom ON bom.CHILD_SKU = pm.ProductKey AND bom.CHILD_SKU <> bom.PARENT_SKU AND bom.PARENT_SKU IS NOT NULL
		--WHERE pm.[Part Type] = 'FINISHED GOODS'
		--	AND pm.[Item Type] <> 'STEP2 FG KIT'
		--	AND bom.CHILD_SKU IS NULL --is not part of a kit
		--	AND pm.PlaceholderType <> 'PLACEHOLDER'		
		--	AND LEN(pm.ProductKey) < 25
		--	AND pm.ProductKey NOT LIKE 'Placeholder%'
		--	AND pm.ProductKey NOT LIKE 'Roll%'
		--UNION 
		--SELECT pm2.ProductKey, pm2.ProductKey + '-BOX' + CAST(ROW_NUMBER() OVER (PARTITION BY pm1.ProductKey ORDER BY ITEM_NUM) AS VARCHAR(2)) AS BoxSKU, pm1.PlaceholderType
		--FROM dbo.DimProductMaster pm1 
		--	LEFT JOIN dbo.DimBillOfMaterial bom ON bom.PARENT_SKU = pm1.ProductKey
		--	LEFT JOIN dbo.DimProductMaster pm2 ON bom.CHILD_SKU = pm2.ProductKey AND pm2.[Part Type] = 'FINISHED GOODS'
		--WHERE pm1.[Item Type] = 'STEP2 FG KIT'
		--	AND pm2.[Part Type] = 'FINISHED GOODS'
		--	AND '|' + bom.PARENT_SKU = bom.PARENT_PATH
		--	AND pm2.PlaceholderType <> 'PLACEHOLDER'
		--	AND LEN(pm1.ProductKey) < 25
		--	AND pm1.ProductKey NOT LIKE 'Placeholder%'
		--	AND pm1.ProductKey NOT LIKE 'Roll%'
		--GROUP BY pm2.ProductKey, pm2.ProductKey,  bom.ITEM_NUM, pm1.ProductKey, pm1.PlaceholderType		
)
, CartonData AS (
	SELECT BoxSKU AS [Box SKU]
		, mcr.Cross_reference AS UPC
		, msib.UNIT_LENGTH AS [Master Carton: Packaged Length (in)]
		, msib.UNIT_WIDTH AS [Master Carton: Packaged Width (in)]
		, msib.UNIT_HEIGHT AS [Master Carton: Packaged Height (in)]
		, msib.[DIMENSION_UOM_CODE]
		, msib.unit_volume AS [Master Carton: Cube (sq ft)]		
		, msib.UNIT_WEIGHT AS [Master Carton: Packaged Weight (lbs)]
		, msib.[WEIGHT_UOM_CODE]
		,CASE WHEN msib.UNIT_LENGTH >= msib.UNIT_WIDTH AND msib.UNIT_LENGTH >= msib.UNIT_HEIGHT THEN msib.UNIT_LENGTH
				WHEN msib.UNIT_WIDTH >= msib.UNIT_LENGTH AND msib.UNIT_WIDTH >= msib.UNIT_HEIGHT THEN msib.UNIT_WIDTH
				WHEN msib.UNIT_HEIGHT >= msib.UNIT_LENGTH AND msib.UNIT_HEIGHT >= msib.UNIT_WIDTH THEN msib.UNIT_HEIGHT
		 END AS LongestSide
	FROM SKus 
		LEFT JOIN Oracle.inv_mtl_system_items_b msib ON msib.Segment1 = SKUs.ProductKey AND msib.organization_id = 85 AND msib.CurrentRecord = 1 
		--LEFT JOIN Oracle.inv_mtl_system_items_tl msit ON msib.ORGANIZATION_ID = msit.ORGANIZATION_ID AND msib.INVENTORY_ITEM_ID = msit.INVENTORY_ITEM_ID AND msit.CurrentRecord = 1
		--LEFT JOIN PIM.CustomerPrice pp ON msib.Segment1 = pp.SKU
		LEFT JOIN Oracle.APPS_MTL_CROSS_REFERENCES mcr on msib.INVENTORY_ITEM_ID = mcr.INVENTORY_ITEM_ID and mcr.cross_reference_type = 'UPC' AND mcr.CurrentRecord = 1
)
SELECT * 
	  ,CASE 
		WHEN LongestSide > 108
		OR CASE WHEN LongestSide = [Master Carton: Packaged Length (in)] THEN [Master Carton: Packaged Length (in)] + [Master Carton: Packaged Width (in)]*2+[Master Carton: Packaged Height (in)]*2
			WHEN LongestSide = [Master Carton: Packaged Width (in)]  THEN [Master Carton: Packaged Width (in)]  + [Master Carton: Packaged Length (in)]*2+[Master Carton: Packaged Height (in)]*2
			WHEN LongestSide = [Master Carton: Packaged Height (in)] THEN [Master Carton: Packaged Height (in)] + [Master Carton: Packaged Width (in)]*2+[Master Carton: Packaged Length (in)]*2
		END > 165
		OR [Master Carton: Packaged Weight (lbs)] > 150 THEN 'LTL'
	   WHEN LongestSide > 96 
		OR CASE WHEN LongestSide = [Master Carton: Packaged Length (in)] THEN [Master Carton: Packaged Length (in)] + [Master Carton: Packaged Width (in)]*2+[Master Carton: Packaged Height (in)]*2
			WHEN LongestSide = [Master Carton: Packaged Width (in)]  THEN [Master Carton: Packaged Width (in)]  + [Master Carton: Packaged Length (in)]*2+[Master Carton: Packaged Height (in)]*2
			WHEN LongestSide = [Master Carton: Packaged Height (in)] THEN [Master Carton: Packaged Height (in)] + [Master Carton: Packaged Width (in)]*2+[Master Carton: Packaged Length (in)]*2
		END > 130
		OR [Master Carton: Packaged Weight (lbs)] > 90 THEN 'Large Parcel' ELSE 'Parcel' 
	   END AS [Shipment Type]
FROM CartonData
GO
