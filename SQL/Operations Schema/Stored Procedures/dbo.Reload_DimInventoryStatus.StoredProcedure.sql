USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimInventoryStatus]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Reload_DimInventoryStatus] AS BEGIN
	TRUNCATE TABLE dbo.DimInventoryStatus
	SELECT * INTO dbo.DimInventoryStatus FROM Dim.InventoryStatus
END
GO
