USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimInventoryType]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Reload_DimInventoryType] AS BEGIN
	TRUNCATE TABLE dbo.DimInventoryType

	SET IDENTITY_INSERT dbo.DimInventoryType ON
	INSERT INTO dbo.DimInventoryType (InventoryTypeID, InventoryTypeName, InventoryTypeSort)
	SELECT InventoryTypeID, InventoryTypeName, InventoryTypeSort FROM Dim.InventoryType
END
GO
