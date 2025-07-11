USE [Operations]
GO
/****** Object:  View [Dim].[ProductMasterReclassSKU]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Dim].[ProductMasterReclassSKU] AS
WITH JE AS (
	SELECT LINE_DESCRIPTION FROM Oracle.TrialBalance tb 
	WHERE JE_HDR_CREATED_BY <> 'Fernando, Roy' AND ACCOUNT IN ('3000','3200') AND RIGHT(PERIOD,2) >= 21 
	GROUP BY LINE_DESCRIPTION
)

SELECT DISTINCT 
	LINE_DESCRIPTION AS JEDescription
	,ISNULL(SKU,'OTHER') AS Part
	,ISNULL(DemandClassKey,'OTHER') AS [Demand Class]
	,ISNULL(LINE_DESCRIPTION,'OTHER') AS Part_Desc
	,ISNULL(DemandClassKey,'OTHER') + '-' +ISNULL(SKU,'OTHER') AS DerivedPart
	,ISNULL(Mute,0) AS Mute
FROM JE
	LEFT JOIN xref.SalesReclass rc  ON je.LINE_DESCRIPTION = rc.JEDescription
UNION
SELECT DISTINCT '' AS JEDescription
	,Part
	,[Demand Class]
	,[Part_Desc]
	,[DerivedPart]
	,0 AS Mute
FROM [Dim].[ProductMasterForecastSKU]


GO
