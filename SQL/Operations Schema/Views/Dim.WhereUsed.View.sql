USE [Operations]
GO
/****** Object:  View [Dim].[WhereUsed]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[WhereUsed] AS 
SELECT pm1.ProductID, pm1.ProductKey, pm1.ProductName, pm1.ProductDesc
FROM Dim.M2MWhereUsed wu
	LEFT JOIN dbo.DimProductMaster pm1 ON pm1.ProductID = wu.ProductID1
GROUP BY pm1.ProductID, pm1.ProductKey, pm1.ProductName, pm1.ProductDesc
GO
