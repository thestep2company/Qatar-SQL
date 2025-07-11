USE [Operations]
GO
/****** Object:  View [Error].[ProductSort]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Error].[ProductSort] AS  
  SELECT ProductDesc, MIN(ProductSort) AS MinSort, MAX(ProductSort) AS MaxSort, COUNT(*) AS RecCount
  FROM [dbo].[DimProductMaster]
  --WHERE ProductKey LIKE '%1867635%'
  GROUP BY ProductDesc
  HAVING MIN(ProductSort) <> MAX(ProductSort)
GO
