USE [Operations]
GO
/****** Object:  View [Dim].[BillOfMaterial]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[BillOfMaterial] AS 
--506919
WITH BOM AS (
  SELECT [CHILD_SKU]
	  ,[PARENT_SKU]
	  ,CHILD_PATH
	  ,PARENT_PATH
      ,[ITEM_TYPE]
      ,[ITEM_NUM]
      ,[LEVEL]
      ,[COMPONENT_QUANTITY]
  FROM Oracle.BillOfMaterial
  WHERE CurrentRecord = 1
  UNION 
  SELECT DISTINCT
       b1.[PARENT_SKU]
	  ,NULL
	  ,b1.PARENT_PATH
	  ,NULL
      ,NULL AS [ITEM_TYPE]
      ,10 AS [ITEM_NUM]
      ,0 [LEVEL]
      ,1 AS [COMPONENT_QUANTITY]
  FROM Oracle.BillOfMaterial b1
  WHERE b1.CurrentRecord = 1 AND b1.Level = 1 
)
SELECT pm1.ProductID
	, bom.CHILD_SKU
	, bom.PARENT_SKU
	, bom.CHILD_PATH
	, bom.PARENT_PATH
	, bom.ITEM_NUM
	, bom.COMPONENT_QUANTITY
	, pm2.ProductID AS ParentID
	, bom.Level
	, CAST(0 AS FLOAT) AS ROLLDOWN
	, CAST(0 AS FLOAT) AS DERIVED_QUANTITY
FROM BOM
	LEFT JOIN dbo.DimProductMaster pm1 ON BOM.CHILD_SKU = pm1.ProductKey
	LEFT JOIN dbo.DimProductMaster pm2 ON BOM.PARENT_SKU = pm2.ProductKey
--ORDER BY CHILD_PATH, ITEM_NUM
GO
