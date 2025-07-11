USE [Operations]
GO
/****** Object:  View [dbo].[FactInventoryChecksum]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FactInventoryChecksum] AS
SELECT SUM([Inventory Cost]) AS Cost
FROM dbo.FactInventoryLPN fi
	LEFT JOIN dbo.DimProductMaster pm ON fi.ProductID = pm.ProductID
WHERE DateKey = DATEADD(DAY,-1,CAST(GETDATE() AS DATE))

GO
