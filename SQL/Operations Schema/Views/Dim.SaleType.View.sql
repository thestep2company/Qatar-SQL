USE [Operations]
GO
/****** Object:  View [Dim].[SaleType]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[SaleType] AS 
SELECT 1 AS SaleTypeID, 'Order' AS SaleTypeName, NULL AS SalesTypeDesc UNION
SELECT 0 AS SaleTypeID, 'Invoice' AS SaleTypeName, NULL AS SalesTypeDesc
GO
