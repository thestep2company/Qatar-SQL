USE [Operations]
GO
/****** Object:  View [Dim].[Plant]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[Plant] AS
SELECT DISTINCT 
	DENSE_RANK() OVER (ORDER BY Org_Code) AS PlantID
	,Org_Code AS PlantKey
	,Org_Name AS PlantName
	,Org_Code + ': ' + Org_Name AS PlantDesc
	,RIGHT('00000' + Org_Code,5) AS PlantSort
FROM [Manufacturing].[PRODUCTION]
WHERE CurrentRecord = 1
GO
