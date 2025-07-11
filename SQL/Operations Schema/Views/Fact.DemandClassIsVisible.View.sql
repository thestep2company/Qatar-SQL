USE [Operations]
GO
/****** Object:  View [Fact].[DemandClassIsVisible]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[DemandClassIsVisible] AS 
SELECT dc.DemandClassID, dc.DemandClassKey, dc.DemandClassName
	,CASE WHEN sales.DemandClassID IS NOT NULL THEN 1 ELSE 0 END AS HasSales
	,CASE WHEN Budget.DemandClassID IS NOT NULL THEN 1 ELSE 0 END AS HasBudget
	,CASE WHEN SCP.DemandClassID IS NOT NULL THEN 1 ELSE 0 END AS HasSCP
	,CASE WHEN Feed.DemandClassID IS NOT NULL THEN 1 ELSE 0 END AS HasFeed
	,CASE WHEN DemandClass.DemandClassID IS NOT NULL THEN 1 ELSE 0 END AS IsNew
FROM dbo.DimDemandClass dc
	LEFT JOIN (SELECT DISTINCT dc.DemandClassID, dc.DemandClassKey, dc.DemandClassName FROM dbo.DimDemandClass dc INNER JOIN dbo.FactPBISales pbi ON dc.DemandClassID = pbi.DemandClassID) sales ON sales.DemandClassID = dc.DemandClassID
	LEFT JOIN (SELECT DISTINCT dc.DemandClassID, dc.DemandClassKey, dc.DemandClassName FROM dbo.DimDemandClass dc INNER JOIN dbo.FactPBISalesBudget pbi ON dc.DemandClassID = pbi.DemandClassID) budget ON budget.DemandClassID = dc.DemandClassID
	LEFT JOIN (SELECT DISTINCT dc.DemandClassID, dc.DemandClassKey, dc.DemandClassName FROM dbo.DimDemandClass dc INNER JOIN dbo.FactSupplyChainPlan pbi ON dc.DemandClassID = pbi.DemandClassID) scp  ON scp.DemandClassID = dc.DemandClassID
	LEFT JOIN (SELECT DISTINCT dc.DemandClassID, dc.DemandClassKey, dc.DemandClassName FROM dbo.DimDemandClass dc INNER JOIN dbo.FactInventoryFeed pbi ON dc.DemandClassID = pbi.DemandClassID) feed  ON feed.DemandClassID = dc.DemandClassID
	LEFT JOIN (SELECT ID AS DemandClassID, SEGMENT1 AS DemandClassKey, DESCRIPTION AS DemandClassName   FROM Oracle.INV_MTL_SYSTEM_ITEMS_B WHERE ORGANIZATION_ID = 85 AND LAST_UPDATE_DATE > DATEADD(MONTH,-6,GETDATE()) AND CurrentRecord = 1) DemandClass ON DemandClass.DemandClassKey = dc.DemandClassKey
WHERE 
	sales.DemandClassID IS NOT NULL 
	OR budget.DemandClassID IS NOT NULL 
	OR scp.DemandClassID IS NOT NULL 
	OR DemandClass.DemandClassID IS NOT NULL
GO
