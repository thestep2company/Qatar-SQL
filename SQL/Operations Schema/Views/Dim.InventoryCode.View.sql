USE [Operations]
GO
/****** Object:  View [Dim].[InventoryCode]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[InventoryCode] AS
SELECT DISTINCT DENSE_RANK() OVER (ORDER BY subinventory_code) AS InventoryCodeID
	, subinventory_code AS InventoryCodeKey 
FROM Oracle.Inv_mtl_onhand_quantities_detail WHERE CurrentRecord = 1
GO
