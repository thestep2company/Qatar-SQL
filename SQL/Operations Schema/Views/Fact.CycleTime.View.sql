USE [Operations]
GO
/****** Object:  View [Fact].[CycleTime]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[CycleTime] AS

SELECT  -mi.INDEX_ID AS RecNum --negative to distinguish from new program
		,cf.DateID
		,h.HourID
		,l.LocationID AS PlantID
		,0 AS ComponentID
		,0 AS ProductID
		,s2.ShiftID
		,m.MachineID
		,o.OperatorID
		,cr.ReasonID
		,0 AS ShiftOffsetID
		,mi.SHIFT_ID AS CurrentShiftID
		,SUM(MISSED_CYCLE) AS MISSED_CYCLE
		,SUM(DEAD_ARM) AS EMPTY_CYCLE
		,SUM(CYCLE_COUNT) AS CYCLE_COUNT
		,(SUM(CASE WHEN MISSED_TIME > 1800 THEN 0 ELSE MISSED_TIME END)*1.0)/3600.0 AS MISSED_TIME
		,(SUM(CYCLE_TIME)*1.0)/3600.0 AS CYCLE_TIME
		,COUNT(*)*(15.0/3600.0) AS INDEX_TIME
		,0 AS CAPACITY
FROM  
		[Manufacturing].[MACHINE_INDEX] mi 
		LEFT JOIN dbo.DimMachine m on 'L' + RIGHT('00'+mi.MACHINE_NUM,2) + '_' + mi.MACHINE_SIZE = m.MachineKey AND mi.PLANT = m.LocationKey
		LEFT JOIN dbo.DimLocation l ON l.LocationKey = mi.PLANT
		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
		LEFT JOIN Dim.Hour h ON DATEPART(HOUR,DATE_TIME) = h.HourID
		LEFT JOIN dbo.DimCalendarFiscal cf ON mi.TransDate  = cf.DateKey
		LEFT JOIN dbo.DimMachineOperator o ON mi.OPERATOR = o.OperatorKey
		LEFT JOIN Dim.CycleReason cr ON mi.REASON_CODE = cr.ReasonKey
WHERE	DateKey >= '2019-01-01' AND DateKey < GETDATE() AND PLANT IN ('111') AND mi.CurrentRecord = 1
GROUP BY 
	 mi.INDEX_ID
	,cf.DateID
	,h.HourID
	,l.LocationID
	,s2.ShiftID
	,m.MachineID
	,o.OperatorID
	,cr.ReasonID
	,mi.SHIFT_ID
	,Plant
UNION ALL
SELECT  -mi.INDEX_ID AS RecNum  --negative to distinguish from new program
		,cf.DateID
		,h.HourID
		,l.LocationID AS PlantID
		,0 AS ComponentID
		,0 AS ProductID
		,s2.ShiftID
		,m.MachineID
		,o.OperatorID
		,cr.ReasonID
		,1 AS ShiftOffsetID
		,mi.SHIFT_ID AS CurrentShiftID
		,SUM(MISSED_CYCLE) AS MISSED_CYCLE
		,SUM(DEAD_ARM) AS EMPTY_CYCLE
		,SUM(CYCLE_COUNT) AS CYCLE_COUNT
		,(SUM(CASE WHEN MISSED_TIME > 1800 THEN 0 ELSE MISSED_TIME END)*1.0)/3600.0 AS MISSED_TIME
		,(SUM(CYCLE_TIME)*1.0)/3600.0 AS CYCLE_TIME
		,COUNT(*)*(15.0/3600.0) AS INDEX_TIME
		,0 AS CAPACITY
FROM  
		[Manufacturing].[MACHINE_INDEX] mi 
		LEFT JOIN dbo.DimMachine m on 'L' + RIGHT('00'+mi.MACHINE_NUM,2) + '_' + mi.MACHINE_SIZE = m.MachineKey AND mi.PLANT = m.LocationKey
		LEFT JOIN dbo.DimLocation l ON l.LocationKey = mi.PLANT
		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
		LEFT JOIN Dim.Hour h ON DATEPART(HOUR,DATE_TIME) = h.HourID
		LEFT JOIN dbo.DimCalendarFiscal cf ON mi.TransDateOffset  = cf.DateKey
		LEFT JOIN dbo.DimMachineOperator o ON mi.OPERATOR = o.OperatorKey
		LEFT JOIN Dim.CycleReason cr ON mi.REASON_CODE = cr.ReasonKey
WHERE	DateKey >= '2019-01-01'  AND DateKey < GETDATE() AND PLANT IN ('111') AND mi.CurrentRecord = 1
GROUP BY 
	 mi.INDEX_ID
	,cf.DateID
	,h.HourID
	,l.LocationID
	,s2.ShiftID
	,m.MachineID
	,o.OperatorID
	,cr.ReasonID
	,mi.SHIFT_ID
	,Plant
UNION ALL
SELECT  -mi.INDEX_ID AS RecNum  --negative to distinguish from new program
		,cf.DateID
		,h.HourID
		,l.LocationID AS PlantID
		,0 AS ComponentID
		,0 AS ProductID
		,s2.ShiftID
		,m.MachineID
		,o.OperatorID
		,cr.ReasonID
		,0 AS ShiftOffsetID
		,mi.SHIFT_ID AS CurrentShiftID
		,MISSED_CYCLE AS MISSED_CYCLE
		,DEAD_ARM AS EMPTY_CYCLE
		,CYCLE_COUNT AS CYCLE_COUNT
		,CASE WHEN MISSED_TIME = 0 THEN NULL WHEN MISSED_TIME > 1800 THEN 0 ELSE MISSED_TIME END/3600.0 AS MISSED_TIME
		,CASE WHEN CYCLE_TIME = 0 THEN NULL ELSE CYCLE_TIME/3600.0 END AS CYCLE_TIME
		,CASE WHEN CYCLE_TIME = 0 THEN NULL ELSE 15.0/3600 END AS INDEX_TIME
		,0 AS CAPACITY
FROM  
		[Manufacturing].[MACHINE_INDEX] mi 
		LEFT JOIN dbo.DimMachine m on 'L' + RIGHT('00'+mi.MACHINE_NUM,2) + '_' + mi.MACHINE_SIZE = m.MachineKey AND mi.PLANT = m.LocationKey
		LEFT JOIN dbo.DimLocation l ON l.LocationKey = mi.PLANT
		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
		LEFT JOIN Dim.Hour h ON DATEPART(HOUR,DATE_TIME) = h.HourID
		LEFT JOIN dbo.DimCalendarFiscal cf ON mi.TransDate  = cf.DateKey
		LEFT JOIN dbo.DimMachineOperator o ON mi.OPERATOR = o.OperatorKey
		LEFT JOIN Dim.CycleReason cr ON mi.REASON_CODE = cr.ReasonKey
WHERE	DateKey >= '2019-01-01' AND DateKey < GETDATE() AND PLANT IN ('122') AND mi.CurrentRecord = 1
UNION ALL
SELECT  -mi.INDEX_ID AS RecNum  --negative to distinguish from new program
		,cf.DateID
		,h.HourID
		,l.LocationID AS PlantID
		,0 AS ComponentID
		,0 AS ProductID
		,s2.ShiftID
		,m.MachineID
		,o.OperatorID
		,cr.ReasonID
		,1 AS ShiftOffsetID
		,mi.SHIFT_ID AS CurrentShiftID
		,MISSED_CYCLE AS MISSED_CYCLE
		,DEAD_ARM AS EMPTY_CYCLE
		,CYCLE_COUNT AS CYCLE_COUNT
		,CASE WHEN MISSED_TIME = 0 THEN NULL WHEN MISSED_TIME > 1800 THEN 0 ELSE MISSED_TIME END/3600.0 AS MISSED_TIME
		,CASE WHEN CYCLE_TIME = 0 THEN NULL ELSE CYCLE_TIME/3600.0 END AS CYCLE_TIME
		,CASE WHEN CYCLE_TIME = 0 THEN NULL ELSE 15.0/3600 END AS INDEX_TIME
		,0 AS CAPACITY
FROM  
		[Manufacturing].[MACHINE_INDEX] mi 
		LEFT JOIN dbo.DimMachine m on 'L' + RIGHT('00'+mi.MACHINE_NUM,2) + '_' + mi.MACHINE_SIZE = m.MachineKey AND mi.PLANT = m.LocationKey
		LEFT JOIN dbo.DimLocation l ON l.LocationKey = mi.PLANT
		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
		LEFT JOIN Dim.Hour h ON DATEPART(HOUR,DATE_TIME) = h.HourID
		LEFT JOIN dbo.DimCalendarFiscal cf ON mi.TransDateOffset  = cf.DateKey
		LEFT JOIN dbo.DimMachineOperator o ON mi.OPERATOR = o.OperatorKey
		LEFT JOIN Dim.CycleReason cr ON mi.REASON_CODE = cr.ReasonKey
WHERE	DateKey >= '2019-01-01'  AND DateKey < GETDATE() AND PLANT IN ('122') AND mi.CurrentRecord = 1
UNION
SELECT [RecNum]
	,[DateID]
	,[HourID]
	,[PlantID]
	,[ProductAID]
	,[ProductBID]
	,[ShiftID]
	,[MachineID]
	,[OperatorID]
	,[ReasonID]
	,[ShiftOffsetID]
	,[CurrentShiftID]
	,[MISSEDCYCLE]
	,[EMPTYCYCLE]
	,[CYCLECOUNT]
	,[MISSEDTIME]
	,[CYCLETIME]
	,[INDEXTIME]
	,0 AS CAPACITY
FROM dbo.FactMachineIndex
WHERE RecNum > 0

GO
