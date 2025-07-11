USE [Operations]
GO
/****** Object:  View [OUTPUT].[ProductMaster]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[ProductMaster] AS 
SELECT [ProductKey]
      ,[ProductName]
      ,[ProductDesc]
      ,[ProductSort]
      ,[4 Digit]
      ,[UOM]
      ,[Item Type]
      ,[SIOP Family]
      ,[Category]
      ,[SubCategory]
      ,[CategoryType]
      ,[Brand]
      ,[Inventory Status Code]
      ,[Country of Origin]
      ,[Part Class]
      ,[MakeBuy]
      ,[Contract Manufacturing]
      ,[Channel]
      ,[Part Type]
      ,[Product Volume]
  FROM [Operations].[Dim].[ProductMaster]
  WHERE ProductKey <> '?'
GO
