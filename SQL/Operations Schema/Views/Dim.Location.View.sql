USE [Operations]
GO
/****** Object:  View [Dim].[Location]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



  CREATE VIEW [Dim].[Location] AS 
  SELECT DISTINCT 
	 o.ID AS LocationID
	,ISNULL(o.Organization_Code,'MISSING') AS LocationKey
	,ISNULL(o.ORGANIZATION_NAME,'Missing') AS LocationName
	,ISNULL(o.Organization_Code + ': ' + o.ORGANIZATION_NAME,'Missing') AS LocationDesc
	,ISNULL(o.Organization_Code,'999') AS Sort
	,CASE WHEN o.ORGANIZATION_CODE IN (111,122,133) THEN 'WIP'
		  WHEN o.ORGANIZATION_CODE IN (210,230,250,260,270) THEN 'Offsite'
		  WHEN o.ORGANIZATION_CODE = 555 THEN 'Outside Warehouse'
		  ELSE 'Fulfillment'
	END AS LocationType
	,CASE WHEN o.ORGANIZATION_CODE IN (210, 230,250,260,270) THEN 'International'
		  ELSE 'US'
	END AS LocationCountry
	,CASE WHEN o.ORGANIZATION_CODE IN (122,133) THEN .66666 ELSE 1 END AS ShiftScalar
	,CASE WHEN o.ORGANIZATION_CODE = '111' THEN 2 
		  WHEN o.ORGANIZATION_CODE = '122' THEN 3 
		  WHEN o.ORGANIZATION_CODE = '230' THEN 4
		  WHEN o.ORGANIZATION_CODE = '133' THEN 6 
		  WHEN o.ORGANIZATION_CODE = '260' THEN 24
		  WHEN o.ORGANIZATION_CODE = '250' THEN 25
		  WHEN o.ORGANIZATION_CODE = '999' THEN 0
	 END AS GLLocationID
	,ISNULL(Storage,0) AS WarehouseCapacity
	,CASE WHEN o.ORGANIZATION_CODE = '111' OR o.ORGANIZATION_CODE = '110' THEN 'Streetsboro'
		  WHEN o.ORGANIZATION_CODE = '122' OR o.ORGANIZATION_CODE = '120' THEN 'Perrysville' 
		  WHEN o.ORGANIZATION_CODE = '140' THEN 'Warren'
		  WHEN o.ORGANIZATION_CODE = '133' OR o.ORGANiZATION_CODE = '130' THEN 'Decatur' 
		  WHEN o.ORGANIZATION_CODE = '134' OR o.ORGANIZATION_CODE = '135' THEN 'Jonesboro'
		  WHEN o.ORGANIZATION_CODE = '160' THEN 'Ashland'
		  WHEN o.ORGANIZATION_CODE = '170' THEN 'Wickliffe'
		  WHEN o.ORGANIZATION_CODE = '555' THEN 'Outside Warehouse'
		  WHEN o.ORGANIZATION_CODE IN ('210','230','250','260','270') THEN 'International'
	 END AS PhysicalLocation
	 ,CASE WHEN o.Organization_Code IN ('111','122','133','135','555') THEN 4 ELSE 22 END AS PlanID
	 ,CASE WHEN o.ORGANIZATION_CODE IN ('110','140','260','555') THEN 3 WHEN o.ORGANIZATION_CODE = '120' THEN 2 ELSE o.ID END AS COGSLocationID
  FROM Oracle.ORG_ORGANIZATION_DEFINITIONS o 
	LEFT JOIN xref.WarehouseSpace ws ON o.ORGANIZATION_CODE = ws.Plant
  WHERE o.CurrentRecord = 1
  UNION
  SELECT 0 AS LocationID
	,'Adj' AS LocationKey
	,'Adjustment' AS LocationName
	,'Adjustment' AS LocationDesc
	,'999' AS Sort
	,'Adjustment' AS LocationType
	,'Adjustment' AS LocationCountry
	,0 AS ShiftScalar
	,NULL AS GLLocationID
	,0 AS WarehouseCapcity
	,NULL AS PhysicalLocation
	,NULL AS PlanID
	,NULL AS COGSLocationID
GO
