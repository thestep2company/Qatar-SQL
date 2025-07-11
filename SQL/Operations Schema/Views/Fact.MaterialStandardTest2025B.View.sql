USE [Operations]
GO
/****** Object:  View [Fact].[MaterialStandardTest2025B]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[MaterialStandardTest2025B] AS 
SELECT im.ProductID
		,l.LocationID
		,ISNULL(cst.Item_Cost,0) AS ItemCost
		,ISNULL(cst.Material_Cost,0) AS MaterialCost
		,ISNULL(cst.Material_Overhead_Cost,0) AS MaterialOverheadCost
		,ISNULL(cst.Resource_Cost,0) AS ResourceCost
		,ISNULL(cst.Outside_Processing_Cost,0) AS OutsideProcessingCost
		,ISNULL(cst.Overhead_Cost,0) AS OverheadCost
		,cst.StartDate
		,ISNULL(cst.EndDate,'9999-12-31') AS EndDate
FROM Oracle.CST_ITEM_COST_TYPE_V cst
	LEFT JOIN dbo.DimProductMaster im ON cst.ITEM_NUMBER = im.ProductKey
	LEFT JOIN Oracle.Org_Organization_Definitions org ON org.CurrentRecord = 1 AND cst.Organization_ID = org.Organization_ID
	LEFT JOIN dbo.DimLocation l ON org.Organization_code = l.LocationKey
WHERE COST_TYPE = 'Test2025B' AND cst.ORGANIZATION_ID IN ('86', '87') --AND Item_Cost <> 0
GO
