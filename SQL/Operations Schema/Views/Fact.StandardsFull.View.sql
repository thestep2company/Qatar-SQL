USE [Operations]
GO
/****** Object:  View [Fact].[StandardsFull]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Fact].[StandardsFull] AS 
	WITH MachineLookup AS (
		SELECT '111' AS PlantKey, '110' AS MachineKey, 16 AS MachineRate UNION 
		SELECT '111' AS PlantKey, '190' AS MachineKey, 49.62 AS MachineRate UNION 
		SELECT '111' AS PlantKey, '220' AS MachineKey, 62.72 AS MachineRate UNION 
		SELECT '111' AS PlantKey, '280' AS MachineKey, 80.14 AS MachineRate UNION 
		SELECT '122' AS PlantKey, '220' AS MachineKey, 62.72 AS MachineRate UNION 
		SELECT '122' AS PlantKey, '190' AS MachineKey, 49.62 AS MachineRate UNION 
		SELECT '133' AS PlantKey, '260' AS MachineKey, 74.32 AS MachineRate UNION
		--made up
		SELECT '133' AS PlantKey, '190' AS MachineKey, 49.62 AS MachineRate UNION
		SELECT '133' AS PlantKey, '220' AS MachineKey, 62.72 AS MachineRate UNION
		SELECT '133' AS PlantKey, '280' AS MachineKey, 80.14 AS MachineRate UNION
		SELECT '122' AS PlantKey, '280' AS MachineKey, 80.14 AS MachineRate
	)
	SELECT 
		'2' AS SourceID
		,im.ProductKey 
		,ood.Organization_Name 
		,ood.Organization_Code 
		,MAX(CASE WHEN r.Resource_Code LIKE 'Machine%' THEN SUBSTRING(r.Resource_Code,8,10) END) AS Machine
		,MAX(CASE WHEN r.Resource_Code LIKE 'Machine%' THEN itcdv.usage_rate_or_amount END) AS MachineHours
		,MAX(ml.MachineRate) AS MachineRate
		,MAX(ml.MachineRate)*MAX(CASE WHEN r.Resource_Code LIKE 'Machine%' THEN itcdv.usage_rate_or_amount END) AS MachineCost
		,MAX(CASE WHEN r.Resource_Code LIKE 'Roto_%' OR r.Resource_Code LIKE 'Assy_%' THEN itcdv.RESOURCE_RATE END) AS LaborRate
		,MAX(CASE WHEN r.Resource_Code LIKE 'Roto_Oper%' THEN itcdv.usage_rate_or_amount END) AS RotoOperHours
		,MAX(CASE WHEN r.Resource_Code LIKE 'Roto_Float%' THEN itcdv.usage_rate_or_amount END) AS RotoFloatHours
		,MAX(CASE WHEN r.Resource_Code LIKE 'Roto_Oper%' THEN itcdv.usage_rate_or_amount END) + MAX(CASE WHEN r.Resource_Code LIKE 'Roto_Float%' THEN itcdv.usage_rate_or_amount END) AS TotalRotoHours
		,MAX(CASE WHEN r.Resource_Code LIKE 'Roto_%' OR r.Resource_Code LIKE 'Assy_%' THEN itcdv.RESOURCE_RATE END)*MAX(CASE WHEN r.Resource_Code LIKE 'Roto_Oper%' THEN itcdv.usage_rate_or_amount END) 
		+ MAX(CASE WHEN r.Resource_Code LIKE 'Roto_%' OR r.Resource_Code LIKE 'Assy_%' THEN itcdv.RESOURCE_RATE END)*MAX(CASE WHEN r.Resource_Code LIKE 'Roto_Float%' THEN itcdv.usage_rate_or_amount END) AS TotalRotoCost
		,MAX(CASE WHEN r.Resource_Code LIKE 'Assy_Labor%' THEN itcdv.usage_rate_or_amount END) AS AssyLaborHours
		,MAX(CASE WHEN r.Resource_Code LIKE 'Assy_Lead%' THEN itcdv.usage_rate_or_amount END) AS AssyLeadHours
		,MAX(CASE WHEN r.Resource_Code LIKE 'Assy_Labor%' THEN itcdv.usage_rate_or_amount END) + MAX(CASE WHEN r.Resource_Code LIKE 'Assy_Lead%' THEN itcdv.usage_rate_or_amount END) AS TotalAssyHours
		,MAX(itcdv.RESOURCE_RATE)*MAX(CASE WHEN r.Resource_Code LIKE 'Assy_Labor%' THEN itcdv.usage_rate_or_amount END) + MAX(itcdv.RESOURCE_RATE)*MAX(CASE WHEN r.Resource_Code LIKE 'Assy_Lead%' THEN itcdv.usage_rate_or_amount END) AS TotalAssyCost
		, MAX(ml.MachineRate)*MAX(CASE WHEN r.Resource_Code LIKE 'Machine%' THEN itcdv.usage_rate_or_amount END)
		+ MAX(CASE WHEN r.Resource_Code LIKE 'Roto_%' OR r.Resource_Code LIKE 'Assy_%' THEN itcdv.RESOURCE_RATE END)*MAX(CASE WHEN r.Resource_Code LIKE 'Roto_Oper%' THEN itcdv.usage_rate_or_amount END) 
		+ MAX(CASE WHEN r.Resource_Code LIKE 'Roto_%' OR r.Resource_Code LIKE 'Assy_%' THEN itcdv.RESOURCE_RATE END)*MAX(CASE WHEN r.Resource_Code LIKE 'Roto_Float%' THEN itcdv.usage_rate_or_amount END)
		+ MAX(CASE WHEN r.Resource_Code LIKE 'Roto_%' OR r.Resource_Code LIKE 'Assy_%' THEN itcdv.RESOURCE_RATE END)*MAX(CASE WHEN r.Resource_Code LIKE 'Assy_Labor%' THEN itcdv.usage_rate_or_amount END) 
		+ MAX(CASE WHEN r.Resource_Code LIKE 'Roto_%' OR r.Resource_Code LIKE 'Assy_%' THEN itcdv.RESOURCE_RATE END)*MAX(CASE WHEN r.Resource_Code LIKE 'Assy_Lead%' THEN itcdv.usage_rate_or_amount END)
		AS TotalProcessingCost
		,MAX(CASE WHEN r.Resource_Code LIKE 'Machine%' THEN itcdv.usage_rate_or_amount END)
		+ MAX(CASE WHEN r.Resource_Code LIKE 'Roto_Oper%' THEN itcdv.usage_rate_or_amount END) + MAX(CASE WHEN r.Resource_Code LIKE 'Roto_Float%' THEN itcdv.usage_rate_or_amount END)
		+ MAX(CASE WHEN r.Resource_Code LIKE 'Assy_Labor%' THEN itcdv.usage_rate_or_amount END) + MAX(CASE WHEN r.Resource_Code LIKE 'Assy_Lead%' THEN itcdv.usage_rate_or_amount END) AS TotalStandardHours
	FROM   Oracle.BOM_CST_ITEM_COST_DETAILS				itcdv
		LEFT JOIN Oracle.INV_MTL_SYSTEM_ITEMS_B			s		ON itcdv.inventory_item_id = s.inventory_item_id AND itcdv.ORGANIZATION_ID = s.ORGANIZATION_ID AND s.CurrentRecord = 1
		LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS	OOD		ON itcdv.organization_id = ood.organization_id AND ood.CurrentRecord = 1
		LEFT JOIN Oracle.BOM_RESOURCES					r		ON itcdv.Resource_ID = r.Resource_ID AND r.Organization_ID = itcdv.Organization_ID AND r.CurrentRecord = 1
		LEFT JOIN MachineLookup ml ON ml.PlantKey = ood.ORGANIZATION_CODE AND CASE WHEN r.Resource_Code LIKE 'Machine%' THEN SUBSTRING(r.Resource_Code,8,10) END = ml.MachineKey
		LEFT JOIN dbo.DimProductMaster im ON LEFT(s.SEGMENT1,4) = LEFT(im.ProductKey,4)
		LEFT JOIN Oracle.Standards std ON std.Organization_Code = ood.Organization_Code AND std.ProductKey = im.ProductKey AND std.CurrentRecord = 1
	WHERE itcdv.CurrentRecord = 1
		and itcdv.cost_type_id = 1 -- = ''Frozen''
		and itcdv.level_type =  1  --- This
		and r.UNIT_OF_MEASURE = 'HR'
		--AND im.ProductKey >= '400000' --finished goods
		AND std.ProductKey IS NULL
	GROUP BY im.ProductKey
		,ood.Organization_Code 
		,ood.Organization_Name 
	UNION ALL
	SELECT '1' AS SourceID
		  ,[ProductKey]
		  ,[Organization_Name]
		  ,[Organization_Code]
		  ,[Machine]
		  ,[MachineHours]
		  ,[MachineRate]
		  ,[MachineCost]
		  ,[LaborRate]
		  ,[RotoOperHours]
		  ,[RotoFloatHours]
		  ,[TotalRotoHours]
		  ,[TotalRotoCost]
		  ,[AssyLaborHours]
		  ,[AssyLeadHours]
		  ,[TotalAssyHours]
		  ,[TotalAssyCost]
		  ,[TotalProcessingCost]
		  ,[TotalStandardHours]
	FROM Oracle.Standards std WHERE CurrentRecord = 1
	--ORDER BY ProductKey, ORGANIZATION_CODE
GO
