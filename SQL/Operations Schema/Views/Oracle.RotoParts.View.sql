USE [Operations]
GO
/****** Object:  View [Oracle].[RotoParts]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Oracle].[RotoParts] AS
SELECT [PARENT_SKU]
      ,[CHILD_SKU]
      ,[ITEM_NUM]
	  --,[Item_Type]
      ,[LEVEL]
      ,[COMPONENT_QUANTITY]
      
  FROM [Oracle].[BOM]
  WHERE CurrentRecord = 1 
GO
