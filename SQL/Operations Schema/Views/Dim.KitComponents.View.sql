USE [Operations]
GO
/****** Object:  View [Dim].[KitComponents]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Dim].[KitComponents] AS
SELECT DISTINCT [ASSEMBLY_ITEM]
      ,[ASSEMBLY_DESCRIPTION]
      ,[PATH]
      ,[NEW_PATH]
      ,[COMPONENT_ITEM]
      ,[COMPONENT_QUANTITY]
	  ,COUNT(*) OVER (PARTITION BY [ASSEMBLY_ITEM]) AS ComponentSKUCount
  FROM [Oracle].[BillOfMaterialTesting] bom
	LEFT JOIN dbo.DimProductMaster pm1 ON bom.ASSEMBLY_ITEM = pm1.ProductKey
	LEFT JOIN dbo.DimProductMaster pm2 ON bom.COMPONENT_ITEM = pm2.ProductKey 
  WHERE --PATH LIKE '%/4902KR%' AND 
	LTRIM(RTRIM(ORDER_LEVEL)) = 1 AND CurrentRecord = 1
	AND pm1.[Part Type] = 'FINISHED GOODS' AND pm2.[Part Type] = 'FINISHED GOODS'
  --ORDER BY ASSEMBLY_ITEM, COMPONENT_ITEM
GO
