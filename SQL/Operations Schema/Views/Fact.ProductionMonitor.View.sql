USE [Operations]
GO
/****** Object:  View [Fact].[ProductionMonitor]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[ProductionMonitor] AS
WITH Cycle AS (
	SELECT MAX(DATE_TIME) AS LastCycleRecord
		  ,PLANT AS [ORG_CODE]
		  ,'L'+RIGHT('00'+MACHINE_NUM,2)+'_'+MACHINE_SIZE AS Machine
		  ,[SHIFT]
	FROM Manufacturing.MACHINE_INDEX scr
		LEFT JOIN dbo.DimShift s ON scr.Shift = s.ShiftKey
	GROUP BY [PLANT]
		  ,[SHIFT]
		  ,'L'+RIGHT('00'+MACHINE_NUM,2)+'_'+MACHINE_SIZE
	HAVING SUM(CYCLE_TIME) <> 0
	--ORDER BY LastCycleRecord DESC
)
, Production AS (
	SELECT MAX([TRANS_DATE_TIME]) AS LastProductionRecord
		  ,[ORG_CODE]
		  ,LINE_CODE AS MACHINE
		  ,[SHIFT]
	FROM [Manufacturing].[Production]
	GROUP BY [ORG_CODE]
		  ,[LINE_CODE]
		  ,[SHIFT]
	HAVING SUM(PRODUCTION_QTY) <> 0
	--ORDER BY LastProductionRecord DESC
)
, Scrap AS (
	SELECT MAX(CAST([CREATION_DATE] AS DATETIME)) AS LastScrapRecord
		  ,[ORG_CODE]
		  ,LINES AS MACHINE
		  ,[SHIFTKey] AS [Shift]
	FROM [Oracle].[Scrap] scr
		LEFT JOIN dbo.DimShift s ON scr.Shift = s.ShiftKey
	GROUP BY [ORG_CODE]
		  ,LINES
		  ,[SHIFTKey]
	HAVING SUM(CAST(QTY AS FLOAT)) <> 0
	--ORDER BY LastScrapRecord DESC
)
, Data AS (
	SELECT 
		ISNULL(ISNULL(c.ORG_CODE,p.ORG_CODE),scr.ORG_CODE) AS ORG_CODE
		,ISNULL(ISNULL(c.MACHINE,p.MACHINE),scr.MACHINE) AS MACHINE
		,ISNULL(ISNULL(c.SHIFT,p.SHIFT),scr.SHIFT) AS SHIFT
		,MAX(LastCycleRecord) AS LastCycleRecord
		,MAX(LastProductionRecord) AS LastProductionRecord
		,MAX(LastScrapRecord) AS LastScrapRecord
	FROM Cycle c
		FULL OUTER JOIN Production p ON c.ORG_CODE = p.ORG_CODE AND c.SHIFT = p.SHIFT AND c.Machine = p.MACHINE
		FULL OUTER JOIN Scrap scr ON scr.ORG_CODE = c.ORG_CODE AND scr.SHIFT = c.SHIFT AND scr.Machine = c.Machine
	WHERE ISNULL(ISNULL(c.ORG_CODE,p.ORG_CODE),scr.ORG_CODE) IN ('111','122')
	GROUP BY ISNULL(ISNULL(c.ORG_CODE,p.ORG_CODE),scr.ORG_CODE)
		,ISNULL(ISNULL(c.MACHINE,p.MACHINE),scr.MACHINE)
		,ISNULL(ISNULL(c.SHIFT,p.SHIFT),scr.SHIFT)
	--ORDER BY ORG_CODE, MACHINE, SHIFT
)
SELECT LocationID, MachineID, ShiftID, LastCycleRecord, LastProductionRecord, LastScrapRecord 
FROM Data d
	LEFT JOIN dbo.DimLocation l ON d.ORG_CODE = l.LocationKey
	LEFT JOIN dbo.DimShift s ON d.SHIFT = s.ShiftKey
	LEFT JOIN dbo.DimMachine m ON m.MachineKey = d.MACHINE AND d.ORG_CODE = m.LocationKey
GO
