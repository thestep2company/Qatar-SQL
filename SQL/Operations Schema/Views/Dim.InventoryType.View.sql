USE [Operations]
GO
/****** Object:  View [Dim].[InventoryType]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[InventoryType] AS 
SELECT ID AS InventoryTypeID, InventoryTypeName, InventoryTypeSort FROM Xref.InventoryType

GO
