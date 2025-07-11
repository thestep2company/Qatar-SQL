USE [Operations]
GO
/****** Object:  View [OUTPUT].[StandardCostChanges]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[StandardCostChanges] AS 
SELECT pm.ProductKey
	, pm.ProductName
	, pm.[Part Type] AS PartType
	, 'Frozen' AS NewCostType
	, 'Frozen' AS OriginalCostType
	, a.ItemCost AS NewCost
	, b.ItemCost AS OriginalCost
	, a.ItemCost - b.ItemCost AS CostVariance
	, a.StartDate
FROM 
	(SELECT * FROM dbo.FactStandard WHERE dateadd(week, datediff(week, 0, getdate()), 0) BETWEEN StartDate AND EndDate) a
	LEFT JOIN (SELECT * FROM dbo.FactStandard WHERE DATEADD(WEEK,-1,dateadd(week, datediff(week, 0, getdate()), 0)) BETWEEN StartDate AND EndDate) b
	ON a.ProductID = b.ProductID AND a.LocationID = b.LocationID
	LEFT JOIN dbo.DimProductMaster pm ON a.ProductID = pm.ProductID 
WHERE ABS(a.ItemCost -  b.ItemCost) >= .01
UNION
SELECT pm.ProductKey
	, pm.ProductName
	, pm.[Part Type] AS PartType
	, 'Frozen' AS NewCostType
	, 'Pending' AS OriginalCostType
	, a.ItemCost AS NewCost
	, b.ItemCost AS OriginalCost
	, a.ItemCost - b.ItemCost AS CostVariance
	, a.StartDate
FROM 
	(SELECT * FROM dbo.FactStandard WHERE dateadd(week, datediff(week, 0, getdate()), 0) BETWEEN StartDate AND EndDate) a
	LEFT JOIN (SELECT * FROM dbo.FactStandardPending WHERE DATEADD(WEEK,-1,dateadd(week, datediff(week, 0, getdate()), 0)) BETWEEN StartDate AND EndDate) b
	ON a.ProductID = b.ProductID AND a.LocationID = b.LocationID
	LEFT JOIN dbo.DimProductMaster pm ON a.ProductID = pm.ProductID 
WHERE ABS(a.ItemCost -  b.ItemCost) >= .01
UNION
SELECT pm.ProductKey
	, pm.ProductName
	, pm.[Part Type] AS PartType
	, 'Pending' AS NewCostType
	, 'Pending' AS OriginalCostType
	, a.ItemCost AS NewCost
	, b.ItemCost AS OriginalCost
	, a.ItemCost - b.ItemCost AS CostVariance
	, a.StartDate
FROM 
	(SELECT * FROM dbo.FactStandardPending WHERE dateadd(week, datediff(week, 0, getdate()), 0) BETWEEN StartDate AND EndDate) a
	LEFT JOIN (SELECT * FROM dbo.FactStandardPending WHERE DATEADD(WEEK,-1,dateadd(week, datediff(week, 0, getdate()), 0)) BETWEEN StartDate AND EndDate) b
	ON a.ProductID = b.ProductID AND a.LocationID = b.LocationID 
	LEFT JOIN dbo.DimProductMaster pm ON a.ProductID = pm.ProductID 
WHERE ABS(a.ItemCost -  b.ItemCost) >= .01
GO
