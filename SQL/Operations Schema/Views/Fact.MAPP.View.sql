USE [Operations]
GO
/****** Object:  View [Fact].[MAPP]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[MAPP] AS
  SELECT DISTINCT SKU, StartDate, EndDate, map.DemandClass, map.MAPP
  FROM dbo.MAPP map
  WHERE map.DemandClass IS NOT NULL 
  UNION 
  SELECT DISTINCT map.SKU, map.StartDate, CASE WHEN EndDate IS NULL THEN DATEADD(SECOND,-1,sku.StartDate) ELSE EndDate END AS EndDate, 
		t7.DemandClass, map.MAPP
  FROM dbo.MAPP map
	CROSS JOIN (SELECT DISTINCT [DemandClass] FROM dbo.MAPP WHERE DemandClass IS NOT NULL) t7
	LEFT JOIN (
		SELECT [DemandClass], [SKU], MIN(StartDate) AS StartDate FROM dbo.MAPP 
		WHERE DemandClass IS NOT NULL  
		GROUP BY [DemandClass], [SKU]
	) sku ON t7.DemandClass = sku.DemandClass AND map.SKU = sku.SKU
  WHERE map.DemandClass IS NULL 
  --ORDER BY SKU, DemandClass, StartDate
GO
