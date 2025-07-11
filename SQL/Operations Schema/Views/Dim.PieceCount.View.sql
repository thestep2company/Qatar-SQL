USE [Operations]
GO
/****** Object:  View [Dim].[PieceCount]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[PieceCount] AS 
SELECT PARENT_SKU, SUM(Component_Quantity) AS Pieces FROM Oracle.RotoParts 
	WHERE Parent_sku >= '400000' GROUP BY Parent_SKU
GO
