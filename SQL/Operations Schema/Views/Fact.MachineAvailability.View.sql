USE [Operations]
GO
/****** Object:  View [Fact].[MachineAvailability]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Fact].[MachineAvailability] AS

SELECT  cf.DateID
		,l.LocationID AS PlantID
		,s2.ShiftID
		,m.MachineID
		,0 AS ShiftOffsetID
		,mi.SHIFT_ID AS CurrentShiftID
		,(SUM(ISNULL(CASE WHEN MISSED_TIME > 1800 THEN 0 ELSE MISSED_TIME END,0))*1.0)/3600.0 
		+(SUM(ISNULL(CYCLE_TIME,0))*1.0)/3600.0 
		+COUNT(*)*(15.0/3600.0) AS RunTime
FROM  
		[Manufacturing].[MACHINE_INDEX] mi 
		LEFT JOIN dbo.DimMachine m on 'L' + RIGHT('00'+mi.MACHINE_NUM,2) + '_' + mi.MACHINE_SIZE = m.MachineKey AND mi.PLANT = m.LocationKey
		LEFT JOIN dbo.DimLocation l ON l.LocationKey = mi.PLANT
		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
		LEFT JOIN dbo.DimCalendarFiscal cf ON mi.TransDate  = cf.DateKey
WHERE	DateKey >= '2019-01-01' AND DateKey < GETDATE() AND PLANT IN ('111') AND mi.CurrentRecord = 1
GROUP BY cf.DateID
		,l.LocationID 
		,s2.ShiftID
		,m.MachineID
		,mi.SHIFT_ID
UNION ALL
SELECT  cf.DateID
		,l.LocationID AS PlantID
		,s2.ShiftID
		,m.MachineID
		,1 AS ShiftOffsetID
		,mi.SHIFT_ID AS CurrentShiftID
		,(SUM(ISNULL(CASE WHEN MISSED_TIME > 1800 THEN 0 ELSE MISSED_TIME END,0))*1.0)/3600.0 
		+(SUM(ISNULL(CYCLE_TIME,0))*1.0)/3600.0 
		+COUNT(*)*(15.0/3600.0)  AS RunTime
FROM  
		[Manufacturing].[MACHINE_INDEX] mi 
		LEFT JOIN dbo.DimMachine m on 'L' + RIGHT('00'+mi.MACHINE_NUM,2) + '_' + mi.MACHINE_SIZE = m.MachineKey AND mi.PLANT = m.LocationKey
		LEFT JOIN dbo.DimLocation l ON l.LocationKey = mi.PLANT
		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
		LEFT JOIN dbo.DimCalendarFiscal cf ON mi.TransDateOffset  = cf.DateKey
WHERE	DateKey >= '2019-01-01'  AND DateKey < GETDATE() AND PLANT IN ('111') AND mi.CurrentRecord = 1
GROUP BY cf.DateID
		,l.LocationID
		,s2.ShiftID
		,m.MachineID
		,mi.SHIFT_ID
UNION ALL
SELECT  cf.DateID
		,l.LocationID AS PlantID
		,s2.ShiftID
		,m.MachineID
		,0 AS ShiftOffsetID
		,mi.SHIFT_ID AS CurrentShiftID
		,ISNULL(CASE WHEN MISSED_TIME = 0 THEN NULL WHEN MISSED_TIME > 1800 THEN 0 ELSE MISSED_TIME END,0)/3600.0 
		+ISNULL(CASE WHEN CYCLE_TIME = 0 THEN NULL ELSE CYCLE_TIME/3600.0 END,0)
		+ISNULL(CASE WHEN CYCLE_TIME = 0 THEN NULL ELSE 15.0/3600 END,0) AS RunTime
FROM  
		[Manufacturing].[MACHINE_INDEX] mi 
		LEFT JOIN dbo.DimMachine m on 'L' + RIGHT('00'+mi.MACHINE_NUM,2) + '_' + mi.MACHINE_SIZE = m.MachineKey AND mi.PLANT = m.LocationKey
		LEFT JOIN dbo.DimLocation l ON l.LocationKey = mi.PLANT
		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
		LEFT JOIN dbo.DimCalendarFiscal cf ON mi.TransDate  = cf.DateKey
WHERE	DateKey >= '2019-01-01' AND DateKey < GETDATE() AND PLANT IN ('122') AND mi.CurrentRecord = 1
UNION ALL
SELECT  cf.DateID
		,l.LocationID AS PlantID
		,s2.ShiftID
		,m.MachineID
		,1 AS ShiftOffsetID
		,mi.SHIFT_ID AS CurrentShiftID
		,ISNULL(CASE WHEN MISSED_TIME = 0 THEN NULL WHEN MISSED_TIME > 1800 THEN 0 ELSE MISSED_TIME END,0)/3600.0
		+ISNULL(CASE WHEN CYCLE_TIME = 0 THEN NULL ELSE CYCLE_TIME/3600.0 END,0)
		+ISNULL(CASE WHEN CYCLE_TIME = 0 THEN NULL ELSE 15.0/3600 END,0) AS RunTime
FROM  
		[Manufacturing].[MACHINE_INDEX] mi 
		LEFT JOIN dbo.DimMachine m on 'L' + RIGHT('00'+mi.MACHINE_NUM,2) + '_' + mi.MACHINE_SIZE = m.MachineKey AND mi.PLANT = m.LocationKey
		LEFT JOIN dbo.DimLocation l ON l.LocationKey = mi.PLANT
		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
		LEFT JOIN dbo.DimCalendarFiscal cf ON mi.TransDateOffset  = cf.DateKey
WHERE	DateKey >= '2019-01-01'  AND DateKey < GETDATE() AND PLANT IN ('122') AND mi.CurrentRecord = 1


GO
