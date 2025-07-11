USE [Operations]
GO
/****** Object:  View [OUTPUT].[OSPPlan]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[OSPPlan] AS 
SELECT pm.ProductKey, pm.ProductName, pm.[Item Type], sc.[ORDER_TYPE_TEXT]
	, SUM(CASE WHEN l.LocationKey = '111' THEN sc.Quantity ELSE 0 END) AS QtySB
	, SUM(CASE WHEN l.LocationKey = '122' THEN sc.Quantity ELSE 0 END) AS QtyPV
	, SUM(CASE WHEN l.LocationKey = '140' THEN sc.Quantity ELSE 0 END) AS QtyWN
	, SUM(CASE WHEN l.LocationKey = '555' THEN sc.Quantity ELSE 0 END) AS QtyOffsite
	, SUM(CASE WHEN l.LocationKey NOT IN ('111','122','140','555') THEN sc.Quantity ELSE 0 END) AS QtyOther
FROM dbo.DimProductMaster pm
	INNER JOIN dbo.FactSupplyChainPlan sc ON pm.ProductID = sc.ProductID
	LEFT JOIn dbo.DimLocation l ON sc.PlantID = l.LocationID
WHERE pm.[Item Type] = 'STEP2 SUB ASSY SUB-CONTRACTED'
	AND pm.ProductID > 0
GROUP BY pm.ProductKey, pm.ProductName, pm.[Item Type], sc.[ORDER_TYPE_TEXT]
--ORDER BY pm.ProductKey, ORDER_TYPE_TEXT
GO
