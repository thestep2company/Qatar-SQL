USE [Operations]
GO
/****** Object:  View [Dim].[BOM]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[BOM] AS 
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
      ,NULL AS [ITEM_NUM]
      ,0 [LEVEL]
      ,1 AS [COMPONENT_QUANTITY]
  FROM Oracle.BillOfMaterial b1
	LEFT JOIN Oracle.BillOfMaterial b2 ON b1.[PARENT_SKU] = b2.[CHILD_SKU] AND b2.CurrentRecord = 1
  WHERE b1.CurrentRecord = 1 AND b2.CHILD_SKU IS NULL
)
SELECT pm.ProductID, bom.CHILD_SKU, bom.PARENT_SKU, bom.CHILD_PATH, bom.PARENT_PATH, bom.ITEM_NUM, bom.COMPONENT_QUANTITY 
FROM BOM
	LEFT JOIN dbo.DimProductMaster pm ON BOM.CHILD_SKU = pm.ProductKey

GO
