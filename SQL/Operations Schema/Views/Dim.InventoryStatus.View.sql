USE [Operations]
GO
/****** Object:  View [Dim].[InventoryStatus]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[InventoryStatus] AS
SELECT 1 AS InventoryStatusID, 'Reservable' AS InventoryStatus UNION
SELECT 2 AS InventoryStatusID, 'Non-Reservable' AS InventoryStatus
GO
