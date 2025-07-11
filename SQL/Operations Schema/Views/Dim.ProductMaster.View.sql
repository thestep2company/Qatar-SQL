USE [Operations]
GO
/****** Object:  View [Dim].[ProductMaster]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Dim].[ProductMaster] AS

	WITH ASL AS (
	  SELECT REPLACE(ProductKey,'OSP','') AS ProductKey, MIN(asl.VENDOR_NAME) AS VENDOR_NAME, CASE WHEN MIN(asl.VENDOR_NUMBER) <> MAX(asl.VENDOR_NUMBER) THEN MAX(asl.VENDOR_NAME) END AS VENDOR_NAME_ALTERNATE, MIN(b.PLANNER_CODE) AS PLANNER_CODE, MIN(b.BUYER_NAME) AS BUYER_NAME
	  FROM  dbo.DimProductMaster pm 
			LEFT JOIN Oracle.ApprovedSupplierList asl  ON pm.ProductKey = asl.ITEM_NUMBER AND asl.CurrentRecord = 1 AND ISNULL(DISABLE_FLAG,'N') = 'N' --AND INACTIVE_DATE IS NULL
			LEFT JOIN Oracle.Buyer b ON pm.ProductKey = b.ITEM_NAME AND b.CurrentRecord = 1
	  GROUP BY REPLACE(ProductKey,'OSP','')
    )
	, B2B AS (
		SELECT DISTINCT CHILD_SKU AS SKU
		FROM Oracle.BOM bom
			LEFT JOIN Oracle.inv_mtl_system_items_b msib ON msib.organization_id = 85 AND msib.CurrentRecord = 1 AND msib.Enabled_Flag = 'Y' AND bom.PARENT_SKU = msib.Segment1 
		WHERE (PARENT_SKU >= '40000' AND LEN(bom.PARENT_SKU) = 6 AND bom.PARENT_SKU LIKE '6%' OR bom.PARENT_SKU LIKE '%YL' OR msib.Attribute1 = 'B2B') AND bom.CurrentRecord = 1
		UNION
		SELECT DISTINCT Segment1
		FROM Oracle.inv_mtl_system_items_b msib
		WHERE msib.organization_id = 85 AND msib.CurrentRecord = 1 AND msib.Enabled_Flag = 'Y' 
			AND (msib.Segment1 >= '40000' AND LEN(msib.Segment1) = 6 AND (LEFT(msib.Segment1,1) = '6' OR RIGHT(msib.Segment1,2) = 'YL') OR msib.Attribute1 = 'B2B')
	)
	SELECT
		msib.ID AS ProductID
		,msib.segment1 AS ProductKey
		,msib.description AS ProductName
		,msib.segment1 + ': ' + msib.description AS ProductDesc
		,RIGHT('0000000000'+[segment1],10) AS ProductSort
		,CASE WHEN ISNULL(msib.attribute4,'') IN ('Manufactured Finished Goods', 'Purchased Finished Goods') OR (ISNULL(msib.attribute4,'') = '' AND LEN(msib.Segment1) = 6 AND msib.Segment1 >= '400000' AND msib.Segment1 <= '9999ZZ') THEN LEFT(msib.Segment1,4) + ': ' + MIN(msib.description) OVER (PARTITION BY LEFT(msib.Segment1,4) ORDER BY LEN(msib.description)) ELSE '' END AS [4 Digit]
		,ISNULL(primary_uom_code,'OTHER') AS UOM
		,ISNULL(msib.item_type,'OTHER') AS [Item Type]
		,ISNULL(msib.attribute9,'OTHER') AS [SIOP Family]
		,ISNULL(msib.attribute1,'OTHER') AS [Category]
		,ISNULL(msib.attribute2,'OTHER') AS [SubCategory]
		,ISNULL(ct.[CategoryType],'OTHER') AS [CategoryType]  --remove
		,ISNULL(msib.attribute3,'OTHER') AS [Brand]
		,ISNULL(msib.inventory_item_status_code,'OTHER') AS [Inventory Status Code]
		,ISNULL(msib.attribute7,'OTHER') AS [Country of Origin]
		,ISNULL(msib.attribute4,'OTHER') AS [Part Class]
		,CASE WHEN ITEM_TYPE = 'STEP2 FG SUB CONTRACTED' OR  planning_make_buy_code = 2 THEN 'BUY'
			  WHEN planning_make_buy_code = 1 THEN 'MAKE'	
			  WHEN mb.MakeBuy IS NOT NULL THEN mb.MakeBuy --remove
			  ELSE 'NONE'
		END AS MakeBuy
		,CASE WHEN b2b.SKU IS NOT NULL THEN 'CONTRACT MANUFACTURING' ELSE 'TOYS' END AS [Contract Manufacturing]  --remove 
		,ISNULL(pc.Channel,'OTHER') AS Channel
		,CASE WHEN ISNULL(msib.attribute4,'') IN ('Assembles','COMPONENTS / OTHER', 'Corogate / Labels', 'Decals & Instr / Other', 'Metal Components', 'Molded Parts', 'Roto Molded Parts') OR msib.segment1 LIKE 'Z%' THEN 'COMPONENTS'
			   WHEN ISNULL(msib.attribute4,'') IN ('Manufactured Finished Goods', 'Purchased Finished Goods') OR (msib.attribute4 IS NULL AND LEN(msib.Segment1) = 6 AND msib.Segment1 >= '400000' AND msib.Segment1 <= '9999ZZ') THEN 'FINISHED GOODS'
			   WHEN ISNULL(msib.attribute4,'') IN ('Chip Regrind', 'Ground Resin', 'Pigmented Resins', 'Pigments', 'Pulv Regrind / Other', 'Resin Pellets') THEN 'RESIN/PELLETS'
			   ELSE 'OTHER'
		END AS [Part Type]
		,CASE WHEN im.SKU IS NOT NULL THEN 'IMAP Tracking' ELSE 'Other' END AS IMAP --remove
		,CASE WHEN npd.[4 Digit] IS NOT NULL THEN 'NPD' ELSE 'Other' END AS NPD --remove
		,ISNULL(msib.unit_volume,0) AS [Product Volume]
		,LIST_LESS_7 AS [List Price] --remove
		,[Royalty License Name]  --remove
		,[Type] AS [Shipping Method] --do we still need for anything?
		,CASE WHEN msib.description LIKE '% QT %' THEN
			CASE WHEN msib.attribute4 = 'MANUFACTURED FINISHED GOODS'
				THEN REVERSE(LTRIM(REVERSE(SUBSTRING(msib.description,1,CHARINDEX(' QT ',msib.description))))) + ' QT' 
				ELSE LTRIM(REVERSE(SUBSTRING(
					LTRIM(REVERSE(SUBSTRING(msib.description,1,CHARINDEX(' QT ',msib.attribute4))))
					,1
					,CHARINDEX(' ',LTRIM(REVERSE(SUBSTRING(msib.description,1,CHARINDEX(' QT ',msib.description)))))
				))) + ' QT'
			END 
			WHEN msib.attribute3 = 'ORCA' THEN REPLACE(LTRIM(RTRIM(SUBSTRING(msib.description,6,3))) + ' QT',',','')
		END AS [Cooler Size]
		--,[Quarter] AS Season
		,FirstProductionDate
		,LastProductionDate
		,FirstSaleDate
		,LastSaleDate
		,CreationDate
		,ProductGroup
		,ProductLine
		,Department
		,Dimensions
		,FootPrint
		,[Cube]
		,[ChildAdult]
		,px.Size
		,CASE WHEN b2b.SKU IS NOT NULL THEN 'STEP2 Custom' ELSE 'TOYS' END AS [Step2 Custom]
		,msib.Segment1 AS DerivedProductKey
		,NULL AS PlaceholderName
		,NULL AS PlaceholderDesc
		,'SKU' AS PlaceholderType
		,'SKU' AS [Forecast Segment]
		,ISNULL(mcr.Cross_reference,'')     AS UPC
		,CASE WHEN ISNULL(msib.attribute4,'') IN ('Manufactured Finished Goods', 'Purchased Finished Goods') OR (ISNULL(msib.attribute4,'') = '' AND LEN(msib.Segment1) = 6 AND msib.Segment1 >= '400000' AND msib.Segment1 <= '9999ZZ') THEN LEFT(msib.Segment1,4) ELSE '' END AS [4 Digit SKU]
		,CASE WHEN ds.Part IS NULL THEN 'Active' ELSE 'Discontinued' END AS ProductStatus --remove
		,asl.VENDOR_NAME
		,asl.VENDOR_NAME_ALTERNATE
		,asl.PLANNER_CODE
		,asl.BUYER_NAME
		,[Product Name Consolidated] --added 4.1.24
		,ISNULL(msib.ATTRIBUTE21,'OTHER') AS [Supercategory_NEW]		  --added 1.13.25
		,ISNULL(msib.ATTRIBUTE22,'OTHER') AS [Category_NEW]				  --added 1.13.25
		,ISNULL(msib.ATTRIBUTE23,'OTHER') AS [Sub-Category_NEW]			  --added 1.13.25
		,ISNULL(msib.ATTRIBUTE24,'OTHER') AS [ProductType_NEW]			  --added 1.13.25
		,ISNULL(msib.ATTRIBUTE25,'OTHER') AS [Brand_NEW]				  --added 1.13.25
		,ISNULL(msib.ATTRIBUTE26,'OTHER') AS [License]					  --added 5.5.25
		,ISNULL(msib.ATTRIBUTE27,'OTHER') AS [Product Family]			  --added 5.5.25
		,msib.ATTRIBUTE28 AS [US Exclusive]								  --added 5.5.25		
		,msib.ATTRIBUTE29 AS [ABCD Code]								  --added 5.5.25
		,msib.ATTRIBUTE30 AS [Safety Stock Variability]					  --added 5.5.25
		,mcr.ATTRIBUTE10 AS [Weight_Assembled]							  --added 5.5.25
		,mcr.ATTRIBUTE11 AS [Volume_Assembled]							  --added 5.5.25
		,mcr.ATTRIBUTE12 AS [Length_Assembled]							  --added 5.5.25
		,mcr.ATTRIBUTE13 AS [Width_Assembled]							  --added 5.5.25
		,mcr.ATTRIBUTE14 AS [Height_Assembled]							  --added 5.5.25
	FROM Oracle.inv_mtl_system_items_b msib
		LEFT JOIN xref.ProductChannel pc ON RIGHT(msib.segment1,2) = pc.Suffix AND msib.segment1 >= '400000'  --AND LEN(msib.segment1) = 6
		LEFT JOIN xref.CategoryType ct ON ISNULL(msib.attribute1,'')  = ct.Category --remove
		LEFT JOIN xref.MakeBuy mb ON msib.Segment1 = mb.Item --remove
		LEFT JOIN xref.IMAP im ON msib.SEGMENT1 = im.SKU --remove
		LEFT JOIN Fact.ProductPricing pp ON msib.Segment1 = pp.ProductKey
		LEFT JOIN xref.NewProductDevelopment npd ON LEFT(msib.Segment1,4) = npd.[4 Digit] --remove
		LEFT JOIN xref.Royalty r ON r.[4 Digit] = LEFT(msib.Segment1,4) AND r.Year = YEAR(GETDATE()) --remove
		LEFT JOIN (SELECT LEFT([SKU],4) AS [4 Digit], MIN([Type]) AS [Type] FROM dbo.Freight WHERE CurrentRecord = 1 GROUP BY LEFT([SKU],4)) f ON f.[4 Digit] = LEFT(msib.Segment1,4)
		LEFT JOIN B2B ON B2B.SKU = msib.segment1
		LEFT JOIN xref.ProductExtension px ON px.ProductKey = msib.Segment1
		LEFT JOIN Oracle.APPS_MTL_CROSS_REFERENCES mcr on msib.INVENTORY_ITEM_ID = mcr.INVENTORY_ITEM_ID and mcr.cross_reference_type = 'UPC' AND mcr.CurrentRecord = 1
		LEFT JOIN xref.DiscontinuedSKU ds ON ds.Part = msib.SEGMENT1 --remove
		LEFT JOIN ASL ON asl.ProductKey = msib.SEGMENT1
	WHERE msib.organization_id = 85 AND msib.CurrentRecord = 1 AND msib.Enabled_Flag = 'Y'
	--UNION
	--SELECT DISTINCT -1*DENSE_RANK() OVER (ORDER BY DerivedPart) AS ProductID
 -- 		, DerivedPart AS ProductKey
 -- 		, MAX(Part_Desc) OVER (PARTITION BY DerivedPart) AS ProductName
 -- 		, DerivedPart + ': ' + MAX(Part_Desc) OVER (PARTITION BY DerivedPart) AS ProductDesc
 -- 		, RIGHT('000000000000' + LEFT(DerivedPart,10), 10) AS ProductSort
 -- 		,'' AS [4 Digit]
 -- 		,'' AS UOM
 -- 		,'OTHER' AS [Item Type]
 -- 		,'OTHER' AS [SIOP Family] 
 -- 		,'OTHER' AS [Category] 
 -- 		,'OTHER' AS [SubCategory] 
 -- 		,'RECLASS' AS [CategoryType] 
 -- 		,'OTHER' AS [Brand]
 -- 		,'OTHER' AS [Inventory Status Code]
 -- 		,'OTHER' AS [Country of Origin]
 -- 		,'OTHER' AS [Part Class]
 -- 		,'OTHER' AS [MakeBuy]
 -- 		,'OTHER' AS [Contract Manufacturing]
 -- 		,'OTHER' AS [Channel]
 -- 		,'OTHER' AS [Part Type]
 -- 		,'OTHER' AS [IMAP]
 -- 		,'OTHER' AS [NPD]
 -- 		,0 AS [Product Volume]
 -- 		,NULL AS [List Price]
 -- 		,NULL AS [Royalty License Name]
 -- 		,NULL AS [Shipping Method]
 -- 		,NULL AS [Cooler Size]
	--	,NULL AS FirstProductionDate
	--	,NULL AS LastProductionDate
	--	,NULL AS FirstSaleDate
	--	,NULL AS LastSaleDate
	--	,NULL AS CreationDate
	--	,NULL AS ProductGroup
	--	,NULL AS ProductLine
	--	,NULL AS Department
	--	,NULL AS Dimensions
	--	,NULL AS FootPrint
	--	,NULL AS [Cube]
	--	,NULL AS [ChildAdult]
	--	,NULL AS [Size]
	--	,NULL AS [Step2 Custom]
	--	,DerivedPart AS [DerivedProductKey]
	--	,NULL AS PlaceholderName
	--	,NULL AS PlaceholderDesc
	--	,'SKU' AS PlaceholderType
	--	,'SKU' AS [Forecast Segment]
	--	,NULL AS UPC
	--	,'' AS [4 Digit SKU]
	--	,NULL AS ProductStatus
	--	,NULL AS VENDOR_NAME
	--	,NULL AS VENDOR_NAME_ALTERNATE
	--	,NULL AS PLANNER_CODE
	--	,NULL AS BUYER_NAME
	--	,NULL AS [Product Name Consolidated] --Added 4.1.24
	--	,'OTHER' AS [Supercategory_NEW] --Added 1.13.25
	--	,'OTHER' AS [Category_NEW]		 --Added 1.13.25
	--	,'OTHER' AS [Sub-Category_NEW]	 --Added 1.13.25
	--	,'OTHER' AS [ProductType_NEW]	 --Added 1.13.25
	--	,'OTHER' AS [Brand_NEW]		 --Added 1.13.25
 --   FROM [Dim].[ProductMasterReclassSKU]
    UNION
	SELECT
		0 AS ProductID
		,'?' AS ProductKey
		, 'OTHER' AS ProductName
		, 'OTHER' AS ProductDesc
		, '9999999999' AS ProductSort
		, '?' AS [4 Digit]
		, 'OTHER' AS UOM
		, 'OTHER' AS [Item Type]
		, 'OTHER' AS [SIOP Family]
		, 'OTHER' AS [Category]
		, 'OTHER' AS [SubCategory]
		, 'OTHER' AS [CategoryType]
		, 'OTHER' AS [Brand]
		, 'OTHER' AS [Inventory Status Code]
		, 'OTHER' AS [Country of Origin]
		, 'OTHER' AS [Part Class]
		, 'NONE' AS MakeBuy
		, 'OTHER' AS [Contract Manufacturing]
		, 'OTHER' AS Channel
		, 'OTHER' AS [Part Type]
		, 'OTHER' AS IMAP
		, 'OTHER' AS NPD
		, 0 AS [Product Volume]
		, 0 AS [List Price]
		, 'NONE' AS [Royalty License Name]
		, 'NONE' AS [Shipping Method]
		, 'NONE' AS [Cooler Size]
		,NULL AS FirstProductionDate
		,NULL AS LastProductionDate
		,NULL AS FirstSaleDate
		,NULL AS LastSaleDate
		,NULL AS CreationDate
		,NULL AS ProductGroup
		,NULL AS ProductLine
		,NULL AS Department
		,NULL AS Dimensions
		,NULL AS FootPrint
		,NULL AS [Cube]
		,NULL AS [ChildAdult]
		,NULL AS [Size]
		,NULL AS [Step2 Custom]
		,CAST('?' AS VARCHAR(100)) AS DerivedProductKey
		,CAST(NULL AS VARCHAR(300)) AS PlaceholderName
		,CAST(NULL AS VARCHAR(300)) AS PlaceholderDesc
		,CAST('SKU' AS VARCHAR(300)) AS PlaceholderType
		,CAST('SKU' AS VARCHAR(300)) AS [Forecast Segment]
		,NULL AS UPC
		, '?' AS [4 Digit]
		,NULL AS ProductStatus
		,NULL AS VENDOR_NAME
		,NULL AS VENDOR_NAME_ALTERNATE
		,NULL AS PLANNER_CODE
		,NULL AS BUYER_NAME	
		,NULL AS [Product Name Consolidated] --Added 4.1.24
		,'OTHER' AS [Supercategory_NEW]   --Added 1.13.25
		,'OTHER' AS [Category_NEW]		  --Added 1.13.25
		,'OTHER' AS [Sub-Category_NEW]	  --Added 1.13.25
		,'OTHER' AS [ProductType_NEW]	  --Added 1.13.25
		,'OTHER' AS [Brand_NEW]			  --Added 1.13.25
		,'OTHER' AS [License]					--added 5.5.25
		,'OTHER' AS [Product Family]		    --added 5.5.25
		,NULL AS [US Exclusive]					--added 5.5.25		
		,NULL AS [ABCD Code]					--added 5.5.25
		,NULL AS [Safety Stock Variability]		--added 5.5.25
		,NULL AS [Weight_Assembled]				--added 5.5.25
		,NULL AS [Volume_Assembled]				--added 5.5.25
		,NULL AS [Length_Assembled]				--added 5.5.25
		,NULL AS [Width_Assembled]				--added 5.5.25
		,NULL AS [Height_Assembled]				--added 5.5.25
	UNION
	SELECT --Added 7.26.24 for Finance Adjustment records -JT
		1 AS ProductID
		, 'Adjustment' AS ProductKey
		, 'Adjustment' AS ProductName
		, 'Adjustment' AS ProductDesc
		, '9999999999' AS ProductSort
		, 'Adjustment' AS [4 Digit]
		, 'OTHER' AS UOM
		, 'Adjustment' AS [Item Type]
		, 'Adjustment' AS [SIOP Family]
		, 'Adjustment' AS [Category]
		, 'Adjustment' AS [SubCategory]
		, 'OTHER' AS [CategoryType]
		, 'OTHER' AS [Brand]
		, 'OTHER' AS [Inventory Status Code]
		, 'OTHER' AS [Country of Origin]
		, 'Adjustment' AS [Part Class]
		, 'Make' AS MakeBuy
		, 'OTHER' AS [Contract Manufacturing]
		, 'OTHER' AS Channel
		, 'FINISHED GOODS' AS [Part Type]
		, 'OTHER' AS IMAP
		, 'OTHER' AS NPD
		, 0 AS [Product Volume]
		, 0 AS [List Price]
		, 'NONE' AS [Royalty License Name]
		, 'NONE' AS [Shipping Method]
		, 'NONE' AS [Cooler Size]
		,NULL AS FirstProductionDate
		,NULL AS LastProductionDate
		,NULL AS FirstSaleDate
		,NULL AS LastSaleDate
		,NULL AS CreationDate
		,'Adjustment' AS ProductGroup
		,'Adjustment' AS ProductLine
		,NULL AS Department
		,NULL AS Dimensions
		,NULL AS FootPrint
		,NULL AS [Cube]
		,NULL AS [ChildAdult]
		,NULL AS [Size]
		,NULL AS [Step2 Custom]
		,CAST('Adjustment' AS VARCHAR(100)) AS DerivedProductKey
		,CAST(NULL AS VARCHAR(300)) AS PlaceholderName
		,CAST(NULL AS VARCHAR(300)) AS PlaceholderDesc
		,CAST('SKU' AS VARCHAR(300)) AS PlaceholderType
		,CAST('SKU' AS VARCHAR(300)) AS [Forecast Segment]
		,NULL AS UPC
		, 'Adjustment' AS [4 Digit]
		,NULL AS ProductStatus
		,NULL AS VENDOR_NAME
		,NULL AS VENDOR_NAME_ALTERNATE
		,NULL AS PLANNER_CODE
		,NULL AS BUYER_NAME	
		,'Adjustment' AS [Product Name Consolidated]
		,'OTHER' AS [Supercategory_NEW]  --Added 1.13.25
		,'Adjustment' AS [Category_NEW]		  --Added 1.13.25
		,'Adjustment' AS [Sub-Category_NEW]	  --Added 1.13.25
		,'Adjustment' AS [ProductType_NEW]	  --Added 1.13.25
		,'Adjustment' AS [Brand_NEW]		  --Added 1.13.25
		,'OTHER' AS [License]					--added 5.5.25
		,'OTHER' AS [Product Family]		    --added 5.5.25
		,NULL AS [US Exclusive]					--added 5.5.25		
		,NULL AS [ABCD Code]					--added 5.5.25
		,NULL AS [Safety Stock Variability]		--added 5.5.25
		,NULL AS [Weight_Assembled]	  --added 5.5.25
		,NULL AS [Volume_Assembled]	  --added 5.5.25
		,NULL AS [Length_Assembled]	  --added 5.5.25
		,NULL AS [Width_Assembled]	  --added 5.5.25
		,NULL AS [Height_Assembled]	  --added 5.5.25

GO
