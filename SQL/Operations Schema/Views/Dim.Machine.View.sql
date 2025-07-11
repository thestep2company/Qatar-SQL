USE [Operations]
GO
/****** Object:  View [Dim].[Machine]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Dim].[Machine] AS 
WITH MachineLookup AS (
			SELECT '110' AS MachineKey, 40 AS RoundsPerShift, 50 AS CapacityRoundsPerShift UNION
			SELECT '190' AS MachineKey, 31 AS RoundsPerShift, 36 AS CapacityRoundsPerShift UNION 
			SELECT '220' AS MachineKey, 24 AS RoundsPerShift, 30 AS CapacityRoundsPerShift UNION 
			SELECT '280' AS MachineKey, 24 AS RoundsPerShift, 30 AS CapacityRoundsPerShift UNION
			SELECT '260' AS MachineKey, 24 AS RoundsPerShift, 30 AS CapacityRoundsPerShift
)
, Data AS (
	SELECT DISTINCT
		 LocationKey
		,REPLACE([Line_Code],'OO','O') AS MachineKey
		,REPLACE([Line_Code],'OO','O') AS MachineName
		,REPLACE([Line_Code],'OO','O') AS MachineDesc
		,SUBSTRING(REPLACE([Line_Code],'OO','O'),CHARINDEX('_',REPLACE([Line_Code],'OO','O'))+1,3) + '_' + SUBSTRING(REPLACE([Line_Code],'OO','O'),1,CHARINDEX('_',REPLACE([Line_Code],'OO','O'))-1) AS MachineSort
		,SUBSTRING(REPLACE([Line_Code],'OO','O'),CHARINDEX('_',REPLACE([Line_Code],'OO','O'))+1,3) AS MachineModel
		,SUBSTRING(REPLACE([Line_Code],'OO','O'),1,CHARINDEX('_',REPLACE([Line_Code],'OO','O'))-1) AS MachineNumber
		,ISNULL(Cell,0) AS MachineCell
		,Position AS CellPosition
		,ml.RoundsPerShift
		,ml.CapacityRoundsPerShift
	FROM [Manufacturing].[Production] p
		LEFT JOIN xref.MachineCell mc ON REPLACE([Line_Code],'OO','O') = MachineNumber AND ORG_CODE = mc.Plant
		LEFT JOIN MachineLookup ml ON SUBSTRING(REPLACE([Line_Code],'OO','O'),CHARINDEX('_',REPLACE([Line_Code],'OO','O'))+1,3) = ml.MachineKey
		LEFT JOIN Dim.Location l ON ORG_CODE = l.LocationKey
	WHERE CurrentRecord = 1
	UNION
	SELECT DISTINCT 
		 LocationKey
		,[LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END AS LINES
		,[LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END
		,[LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END
		,SUBSTRING([LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END,CHARINDEX('_',[LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END)+1,3) + '_' + SUBSTRING([LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END,1,CHARINDEX('_',[LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END)-1) AS MachineSort
		,SUBSTRING([LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END,CHARINDEX('_',[LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END)+1,3) AS MachineModel
		,SUBSTRING([LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END,1,CHARINDEX('_',[LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END)-1) AS MachineNumber
		,ISNULL(Cell,0) AS MachineCell
		,Position AS CellPosition
		,ml.RoundsPerShift
		,ml.CapacityRoundsPerShift
	FROM Manufacturing.Scrap scr
		LEFT JOIN xref.MachineCell mc ON [LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END = MachineNumber AND ORG_CODE = mc.Plant
		LEFT JOIN MachineLookup ml ON SUBSTRING([LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END,CHARINDEX('_',[LINES] + CASE WHEN RIGHT([LINES],1) = '_' THEN 'IG' ELSE '' END)+1,3) = ml.MachineKey
		LEFT JOIN Dim.Location l ON ORG_CODE = l.LocationKey
	WHERE CurrentRecord = 1
	UNION
	SELECT DISTINCT	
		 LocationKey
		,'L' + RIGHT('00'+mi.MACHINE_NUM,2) + '_' + mi.MACHINE_SIZE
		,'L' + RIGHT('00'+mi.MACHINE_NUM,2) + '_' + mi.MACHINE_SIZE
		,'L' + RIGHT('00'+mi.MACHINE_NUM,2) + '_' + mi.MACHINE_SIZE
		,mi.MACHINE_SIZE + '_L' + RIGHT('00'+mi.MACHINE_NUM,2)
		,mi.MACHINE_SIZE
		,'L' + RIGHT('00'+mi.MACHINE_NUM,2)
		,ISNULL(Cell,0) AS MachineCell
		,Position AS CellPosition
		,ml.RoundsPerShift
		,ml.CapacityRoundsPerShift
	FROM Manufacturing.Machine_Index mi
		LEFT JOIN xref.MachineCell mc ON 'L' + RIGHT('00'+mi.MACHINE_NUM,2) + '_' + mi.MACHINE_SIZE = MachineNumber AND mi.Plant= mc.Plant
		LEFT JOIN MachineLookup ml ON mi.MACHINE_SIZE = ml.MachineKey
		LEFT JOIN Dim.Location l ON mi.Plant = l.LocationKey
	WHERE CurrentRecord = 1
)
SELECT	
	DENSE_RANK() OVER (ORDER BY [MachineKey], LocationKey) AS MachineID
	,LocationKey
	,MachineKey
	,MachineName
	,MachineDesc
	,MachineSort
	,MachineModel
	,MachineNumber
	,ISNULL(MachineCell,0) AS MachineCell
	,ISNULL(CellPosition,0) AS CellPosition
	,RoundsPerShift
	,CapacityRoundsPerShift
FROM Data

GO
