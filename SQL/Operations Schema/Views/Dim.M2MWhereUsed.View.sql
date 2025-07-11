USE [Operations]
GO
/****** Object:  View [Dim].[M2MWhereUsed]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Dim].[M2MWhereUsed] AS 
SELECT pm2.ProductID AS ProductID1, pm1.ProductID AS ProductID2, pm2.HasSCP, bom.DERIVED_QUANTITY AS Quantity, Level
	--, bom.PARENT_SKU, bom.PARENT_PATH, CASE WHEN Level = 1 THEN SUBSTRING(bom.PARENT_PATH,2,100) ELSE SUBSTRING(bom.PARENT_PATH,2,CHARINDEX('|',SUBSTRING(bom.PARENT_PATH,2,1000))-1) END AS Root
FROM dbo.[DimBillOfMaterial] bom 
	LEFT JOIN dbo.DimProductMaster pm1 ON bom.CHILD_SKU = pm1.ProductKey 
	INNER JOIN dbo.DimProductMaster pm2 ON CASE WHEN Level = 1 THEN SUBSTRING(bom.PARENT_PATH,2,100) ELSE SUBSTRING(bom.PARENT_PATH,2,CHARINDEX('|',SUBSTRING(bom.PARENT_PATH,2,1000))-1) END = pm2.ProductKey 
WHERE bom.DERIVED_QUANTITY > 0
UNION
SELECT pm2.ProductID, pm1.ProductID, pm1.HasSCP, bom.DERIVED_QUANTITY AS Quantity, Level
	--, bom.PARENT_SKU, bom.PARENT_PATH , CASE WHEN Level = 1 THEN SUBSTRING(bom.PARENT_PATH,2,100) ELSE SUBSTRING(bom.PARENT_PATH,2,CHARINDEX('|',SUBSTRING(bom.PARENT_PATH,2,1000))-1) END AS Root
FROM dbo.[DimBillOfMaterial] bom 
	LEFT JOIN dbo.DimProductMaster pm1 ON CASE WHEN Level = 1 THEN SUBSTRING(bom.PARENT_PATH,2,100) ELSE SUBSTRING(bom.PARENT_PATH,2,CHARINDEX('|',SUBSTRING(bom.PARENT_PATH,2,1000))-1) END = pm1.ProductKey 
	INNER JOIN dbo.DimProductMaster pm2 ON bom.CHILD_SKU = pm2.ProductKey 
WHERE bom.DERIVED_QUANTITY > 0
GO
