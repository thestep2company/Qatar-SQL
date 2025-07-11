USE [Operations]
GO
/****** Object:  View [PIM].[ProductMasterTest]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [PIM].[ProductMasterTest] AS 
	WITH SKUs AS (
		--actual
		SELECT DISTINCT ProductKey, pm.[Part Type], pm.[MakeBuy], pm.ProductKey + '-BOX1' AS BoxSKU
		FROM dbo.DimProductMaster pm
			LEFT JOIN dbo.DimBillOfMaterial bom ON bom.CHILD_SKU = pm.ProductKey AND bom.CHILD_SKU <> bom.PARENT_SKU AND bom.PARENT_SKU IS NOT NULL
		WHERE pm.[Part Type] = 'FINISHED GOODS'
			AND pm.[Item Type] <> 'STEP2 FG KIT'
			AND bom.CHILD_SKU IS NULL --is not part of a kit
			AND LEN(pm.ProductKey) < 25
			AND pm.ProductKey NOT LIKE 'Placeholder%'
			AND pm.ProductKey NOT LIKE 'Roll%'
		UNION
		SELECT pm1.ProductKey, pm1.[Part Type], pm1.[MakeBuy], pm2.ProductKey + '-BOX' + CAST(ROW_NUMBER() OVER (PARTITION BY pm1.ProductKey ORDER BY ITEM_NUM) AS VARCHAR(2)) AS BoxSKU
		FROM dbo.DimProductMaster pm1 
			LEFT JOIN dbo.DimBillOfMaterial bom ON bom.PARENT_SKU = pm1.ProductKey
			LEFT JOIN dbo.DimProductMaster pm2 ON bom.CHILD_SKU = pm2.ProductKey AND pm2.[Part Type] = 'FINISHED GOODS'
		WHERE pm1.[Item Type] = 'STEP2 FG KIT'
			AND pm2.[Part Type] = 'FINISHED GOODS'
			AND '|' + bom.PARENT_SKU = bom.PARENT_PATH
			AND LEN(pm1.ProductKey) < 25
			AND pm1.ProductKey NOT LIKE 'Placeholder%'
			AND pm1.ProductKey NOT LIKE 'Roll%'
		GROUP BY pm1.ProductKey, pm1.[Part Type], pm1.[MakeBuy], pm2.ProductKey,  bom.ITEM_NUM
	)
	, BoxSKUs AS (
		SELECT ProductKey, [Part Type], [MakeBuy], STRING_AGG(BoxSKU,',') AS BoxSKU FROM SKUs GROUP BY ProductKey, [Part Type], [MakeBuy]
	)
	, Data AS (
		SELECT
			  s.[Part Type]
			, msib.segment1 AS [SKU]
			, msib.description AS [Oracle Name]
			, s.[BoxSKU]
			, msib.attribute9 AS [SIOP Family]
			, msib.attribute1 AS [Category]
			, msib.attribute2 AS [Sub-Category]
			, mcr.Cross_reference AS UPC
			, CASE WHEN mcr.CROSS_REFERENCE IS NOT NULL THEN RIGHT('00000000000'+mcr.CROSS_REFERENCE,14) END AS  [GTIN]
			, msib.attribute5 AS [H.S. Code]
			, s.[MakeBuy] AS [Make/Buy]
			, msib.inventory_item_status_code AS [Product Lifecycle Stage]

			,NULL [Standard Cost]
			,AmazonPrice AS [Amazon DS Invoice Price]	  --S2C 2006 AMAZON.COM TOYS USD + S2C DSF AMAZON.COM
			,WayfairPrice AS [Wayfair Invoice Price]	  --S2C 2013 WAYFAIR + S2C DSF WAYFAIR	
			,WalmartPrice AS [Walmart Invoice Price]		--S2C DSF WAL-MART.COM (Ship to Home)
			,HomeDepotPrice AS [HD.com Invoice Price]	  --S2C 2008 HOME DEPOT.COM USD + S2C DSF HOME DEPOT.COM
			,KohlsPrice AS [Kohls.com Invoice Price]   --S2C 2018 KOHLS.COM USD + S2C DSF KOHLS.COM
			,TargetPrice AS [Target.com Invoice Price]  --S2C 2010 TARGET.COM USD + 'S2C DSF TARGET.COM
			,SmythsPrice AS [Smyths Invoice Price]	  --S2C 2014 SMYTHS PRICE CODE USD
			,AldiPrice AS [Aldi B&M Invoice Price]
			,LowesPrice [Lowes B&M Invoice Price]	  --S2C 2011 LOWES RDC USD
			

			,AmazonSKU		AS [Amazon SKU]
			,HomeDepotSKU	AS [Home Depot OMSID]	
			,WayfairSKU		AS [Wayfair SKU]	
			,WalmartSKU		AS [Walmart SKU]
			,KohlsSKU		AS [Kohls.com SKU]	
			,TargetSKU		AS [Target.com SKU]	
			,AldiSKU		AS [Aldi SKU]	
			,LowesSKU		AS [Lowe's B&M SKU]	
			,SmythsSKU		AS [Smyths ID]

			, msib.attribute7 AS [Country of Origin]
			, NULL [Multipack Quantity]
			, [CONVERSION_RATE] AS [Count]		
			, msib.item_type AS [Item Type]

			, DIMENSION_UOM_CODE
			, msib.UNIT_LENGTH AS [Master Carton: Packaged Length (in)]
			, msib.UNIT_WIDTH AS [Master Carton: Packaged Width (in)]
			, msib.UNIT_HEIGHT AS [Master Carton: Packaged Height (in)]

			, WEIGHT_UOM_CODE
			, msib.UNIT_WEIGHT * [CONVERSION_RATE] AS [Master Carton: Packaged Weight (lbs)]

			, VOLUME_UOM_CODE
			, msib.unit_volume AS [Master Carton: Cube (sq ft)]		
		
			-- other stuff
			, REPLACE(REPLACE([Long_Description], CHAR(13), ' '), CHAR(10), ' ') AS [Long Description]
			, msib.attribute3 AS [Brand]
			, msib.attribute4 AS [Part Class]
			,CASE WHEN msib.UNIT_LENGTH >= msib.UNIT_WIDTH AND msib.UNIT_LENGTH >= msib.UNIT_HEIGHT THEN msib.UNIT_LENGTH
				WHEN msib.UNIT_WIDTH >= msib.UNIT_LENGTH AND msib.UNIT_WIDTH >= msib.UNIT_HEIGHT THEN msib.UNIT_WIDTH
				WHEN msib.UNIT_HEIGHT >= msib.UNIT_LENGTH AND msib.UNIT_HEIGHT >= msib.UNIT_WIDTH THEN msib.UNIT_HEIGHT
			END AS LongestSide
		FROM Oracle.inv_mtl_system_items_b msib
			LEFT JOIN Oracle.inv_mtl_system_items_tl msit ON msib.ORGANIZATION_ID = msit.ORGANIZATION_ID AND msib.INVENTORY_ITEM_ID = msit.INVENTORY_ITEM_ID AND msit.CurrentRecord = 1
			LEFT JOIN PIM.CustomerPrice pp ON msib.Segment1 = pp.SKU
			LEFT JOIN Oracle.APPS_MTL_CROSS_REFERENCES mcr on msib.INVENTORY_ITEM_ID = mcr.INVENTORY_ITEM_ID and mcr.cross_reference_type = 'UPC' AND mcr.CurrentRecord = 1
			INNER JOIN BoxSKUs s ON msib.SEGMENT1 = s.ProductKey
			LEFT JOIN PIM.CustomerPartNumber pn ON s.ProductKey = pn.SKU
			LEFT JOIN Oracle.INV_MTL_UOM_CLASS_CONVERSIONS uom ON uom.INVENTORY_ITEM_ID = msib.INVENTORY_ITEM_ID
		WHERE msib.organization_id = 85 AND msib.CurrentRecord = 1 
	)
	SELECT  [Part Type]
      ,[SKU]
      ,[Oracle Name]
	  ,[BoxSKU] AS [Box SKU]
      ,[SIOP Family]
      ,[Category]
      ,[Sub-Category]
      ,[UPC]
      ,[GTIN]
      ,[H.S. Code]
      ,[Make/Buy]
      ,[Product Lifecycle Stage]
      ,[Standard Cost]
      ,[Amazon DS Invoice Price]
	  ,[Walmart Invoice Price]
      ,[Wayfair Invoice Price]
      ,[HD.com Invoice Price]
      ,[Kohls.com Invoice Price]
      ,[Target.com Invoice Price]
      ,[Smyths Invoice Price]
      ,[Lowes B&M Invoice Price]
	  ,[Aldi B&M Invoice Price]
	  ,[Amazon SKU]
      ,[Walmart SKU]
      ,[Wayfair SKU]
      ,[Home Depot OMSID]
	  ,[Kohls.com SKU]
      ,[Target.com SKU]
      ,[Smyths ID]
      ,[Lowe's B&M SKU]
	  ,[Aldi SKU]      
      ,[Country of Origin]
      ,[Multipack Quantity]
      ,[Count]
      ,[Item Type]
      ,[DIMENSION_UOM_CODE]
      ,[Master Carton: Packaged Length (in)]
      ,[Master Carton: Packaged Width (in)]
      ,[Master Carton: Packaged Height (in)]
      ,[WEIGHT_UOM_CODE]
      ,[Master Carton: Packaged Weight (lbs)]
      ,[VOLUME_UOM_CODE]
      ,[Master Carton: Cube (sq ft)]
		--,CASE WHEN LongestSide = [Master Carton: Packaged Length (in)] THEN [Master Carton: Packaged Length (in)] + [Master Carton: Packaged Width (in)]*2+[Master Carton: Packaged Height (in)]*2
		--	WHEN LongestSide = [Master Carton: Packaged Width (in)]  THEN [Master Carton: Packaged Width (in)]  + [Master Carton: Packaged Length (in)]*2+[Master Carton: Packaged Height (in)]*2
		--	WHEN LongestSide = [Master Carton: Packaged Height (in)] THEN [Master Carton: Packaged Height (in)] + [Master Carton: Packaged Width (in)]*2+[Master Carton: Packaged Length (in)]*2
	 --  END AS Girth


	 /*
		Packages can be up to 150 pounds.
		Packages can be up to 165 inches in length and girth combined.
		Packages can be up to 108 inches in length.
		Packages with a large size-to-weight ratio require special pricing and dimensional weight calculations.
	*/

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

	FROM Data 




GO
