USE [Operations]
GO
/****** Object:  View [dbo].[FactPBICOGS]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FactPBICOGS] AS 
SELECT DateID, DateKey, ProductID, LocationID, SUM(COGS) AS COGS, SUM(Qty) AS Units
FROM dbo.FactPbiSales GROUP BY DateID, DateKey, ProductID, LocationID
GO
