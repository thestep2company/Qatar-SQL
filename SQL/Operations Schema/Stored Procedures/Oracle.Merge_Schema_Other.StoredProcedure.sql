USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Schema_Other]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_Schema_Other] AS BEGIN
	EXEC [Oracle].[Merge_APPS_MTL_CROSS_REFERENCES]
	EXEC [Oracle].[Merge_BOM_RESOURCES]
	EXEC [Oracle].[Merge_CRP_RESOURCE_HOURS]
	EXEC [Oracle].[Merge_CST_ITEM_COST_TYPE_V]
	EXEC [Oracle].[Merge_HR_OPERATING_UNITS]
	EXEC [Oracle].[Merge_ORG_ORGANIZATION_DEFINITIONS]
END
GO
