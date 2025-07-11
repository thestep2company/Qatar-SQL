USE [Operations]
GO
/****** Object:  View [Fact].[CycleTimeLive]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Fact].[CycleTimeLive] 
--WITH SCHEMABINDING
AS 

--SELECT  -mi.INDEX_ID AS INDEX_ID --negative to distinguish from new program
--		,cf.DateID
--		,h.HourID
--		,l.LocationID AS PlantID
--		,0 AS ComponentID
--		,0 AS ProductID
--		,s2.ShiftID
--		,m.MachineID
--		,o.OperatorID
--		,cr.ReasonID
--		,0 AS ShiftOffsetID
--		,mi.SHIFT_ID AS CurrentShiftID
--		,SUM(MISSED_CYCLE) AS MISSED_CYCLE
--		,SUM(DEAD_ARM) AS EMPTY_CYCLE
--		,SUM(CYCLE_COUNT) AS CYCLE_COUNT
--		,(SUM(CASE WHEN MISSED_TIME > 1800 THEN 0 ELSE MISSED_TIME END)*1.0)/3600.0 AS MISSED_TIME
--		,(SUM(CYCLE_TIME)*1.0)/3600.0 AS CYCLE_TIME
--		,COUNT(*)*(15.0/3600.0) AS INDEX_TIME
--		,0 AS CAPACITY
--FROM  
--		[Manufacturing].[MACHINE_INDEX] mi 
--		LEFT JOIN dbo.DimMachine m on 'L' + mi.MACHINE_NUM + '_' + mi.MACHINE_SIZE = m.MachineKey AND mi.Plant = m.LocationKey
--		LEFT JOIN dbo.DimLocation l ON l.LocationKey = mi.PLANT
--		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
--		LEFT JOIN Dim.Hour h ON DATEPART(HOUR,DATE_TIME) = h.HourID
--		LEFT JOIN dbo.DimCalendarFiscal cf ON mi.TransDate  = cf.DateKey
--		LEFT JOIN Dim.MachineOperator o ON mi.OPERATOR = o.OperatorKey
--		LEFT JOIN Dim.CycleReason cr ON mi.REASON_CODE = cr.ReasonKey
--		INNER JOIN Dim.ShiftControl sc ON sc.CurrentShiftID = mi.Shift_ID
--WHERE	PLANT = '111' AND mi.CurrentRecord = 1
--GROUP BY 
--	 mi.INDEX_ID
--	,cf.DateID
--	,h.HourID
--	,l.LocationID
--	,s2.ShiftID
--	,m.MachineID
--	,o.OperatorID
--	,cr.ReasonID
--	,mi.SHIFT_ID
--UNION ALL
--SELECT  -mi.INDEX_ID AS INDEX_ID --negative to distinguish from new program
--		,cf.DateID
--		,h.HourID
--		,l.LocationID AS PlantID
--		,0 AS ComponentID
--		,0 AS ProductID
--		,s2.ShiftID
--		,m.MachineID
--		,o.OperatorID
--		,cr.ReasonID
--		,1 AS ShiftOffsetID
--		,mi.SHIFT_ID AS CurrentShiftID
--		,SUM(MISSED_CYCLE) AS MISSED_CYCLE
--		,SUM(DEAD_ARM) AS EMPTY_CYCLE
--		,SUM(CYCLE_COUNT) AS CYCLE_COUNT
--		,(SUM(CASE WHEN MISSED_TIME > 1800 THEN 0 ELSE MISSED_TIME END)*1.0)/3600.0 AS MISSED_TIME
--		,(SUM(CYCLE_TIME)*1.0)/3600.0 AS CYCLE_TIME
--		,COUNT(*)*(15.0/3600.0) AS INDEX_TIME
--		,0 AS CAPACITY
--FROM  
--		[Manufacturing].[MACHINE_INDEX] mi 
--		LEFT JOIN dbo.DimMachine m on 'L' + mi.MACHINE_NUM + '_' + mi.MACHINE_SIZE = m.MachineKey AND mi.Plant = m.LocationKey
--		LEFT JOIN dbo.DimLocation l ON l.LocationKey = mi.PLANT
--		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
--		LEFT JOIN Dim.Hour h ON DATEPART(HOUR,DATE_TIME) = h.HourID
--		LEFT JOIN dbo.DimCalendarFiscal cf ON mi.TransDateOffset  = cf.DateKey
--		LEFT JOIN Dim.MachineOperator o ON mi.OPERATOR = o.OperatorKey
--		LEFT JOIN Dim.CycleReason cr ON mi.REASON_CODE = cr.ReasonKey
--		INNER JOIN Dim.ShiftControl sc ON sc.CurrentShiftID = mi.Shift_ID
--WHERE	PLANT = '111' AND mi.CurrentRecord = 1
--GROUP BY 
--	 mi.INDEX_ID
--	,cf.DateID
--	,h.HourID
--	,l.LocationID
--	,s2.ShiftID
--	,m.MachineID
--	,o.OperatorID
--	,cr.ReasonID
--	,mi.SHIFT_ID
--UNION ALL
--SELECT  -mi.INDEX_ID AS INDEX_ID --negative to distinguish from new program
--		,cf.DateID
--		,h.HourID
--		,l.LocationID AS PlantID
--		,0 AS ComponentID
--		,0 AS ProductID
--		,s2.ShiftID
--		,m.MachineID
--		,o.OperatorID
--		,cr.ReasonID
--		,0 AS ShiftOffsetID
--		,mi.SHIFT_ID AS CurrentShiftID
--		,SUM(MISSED_CYCLE) AS MISSED_CYCLE
--		,SUM(DEAD_ARM) AS EMPTY_CYCLE
--		,SUM(CYCLE_COUNT) AS CYCLE_COUNT
--		,SUM(CASE WHEN MISSED_TIME = 0 THEN NULL WHEN MISSED_TIME > 1800 THEN 0 ELSE MISSED_TIME END)/3600.0 AS MISSED_TIME
--		,SUM(CASE WHEN Cycle_Time = 0 THEN NULL ELSE Cycle_Time*1.0/3600.0 END) AS CYCLE_TIME
--		,SUM(CASE WHEN Cycle_Time = 0 THEN NULL ELSE 15.0/3600.0 END) AS INDEX_TIME
--		,0 AS CAPACITY
--FROM  
--		[Manufacturing].[MACHINE_INDEX] mi 
--		LEFT JOIN dbo.DimMachine m on 'L' + mi.MACHINE_NUM + '_' + mi.MACHINE_SIZE = m.MachineKey AND mi.Plant = m.LocationKey
--		LEFT JOIN dbo.DimLocation l ON l.LocationKey = mi.PLANT
--		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
--		LEFT JOIN Dim.Hour h ON DATEPART(HOUR,DATE_TIME) = h.HourID
--		LEFT JOIN dbo.DimCalendarFiscal cf ON mi.TransDate  = cf.DateKey
--		LEFT JOIN Dim.MachineOperator o ON mi.OPERATOR = o.OperatorKey
--		LEFT JOIN Dim.CycleReason cr ON mi.REASON_CODE = cr.ReasonKey
--		INNER JOIN Dim.ShiftControl sc ON sc.CurrentShiftID = mi.Shift_ID
--WHERE	PLANT = '122' AND mi.CurrentRecord = 1
--GROUP BY 
--	 mi.INDEX_ID
--	,cf.DateID
--	,h.HourID
--	,l.LocationID
--	,s2.ShiftID
--	,m.MachineID
--	,o.OperatorID
--	,cr.ReasonID
--	,mi.SHIFT_ID
--UNION ALL
--SELECT  -mi.INDEX_ID AS INDEX_ID --negative to distinguish from new program
--		,cf.DateID
--		,h.HourID
--		,l.LocationID AS PlantID
--		,0 AS ComponentID
--		,0 AS ProductID
--		,s2.ShiftID
--		,m.MachineID
--		,o.OperatorID
--		,cr.ReasonID
--		,1 AS ShiftOffsetID
--		,mi.SHIFT_ID AS CurrentShiftID
--		,SUM(MISSED_CYCLE) AS MISSED_CYCLE
--		,SUM(DEAD_ARM) AS EMPTY_CYCLE
--		,SUM(CYCLE_COUNT) AS CYCLE_COUNT
--		,SUM(CASE WHEN MISSED_TIME = 0 THEN NULL WHEN MISSED_TIME > 1800 THEN 0 ELSE MISSED_TIME END)/3600.0 AS MISSED_TIME
--		,SUM(CASE WHEN Cycle_Time = 0 THEN NULL ELSE Cycle_Time*1.0/3600.0 END) AS CYCLE_TIME
--		,SUM(CASE WHEN Cycle_Time = 0 THEN NULL ELSE 15.0/3600.0 END) AS INDEX_TIME
--		,0 AS CAPACITY
--FROM  
--		[Manufacturing].[MACHINE_INDEX] mi 
--		LEFT JOIN dbo.DimMachine m on 'L' + mi.MACHINE_NUM + '_' + mi.MACHINE_SIZE = m.MachineKey AND mi.Plant = m.LocationKey
--		LEFT JOIN dbo.DimLocation l ON l.LocationKey = mi.PLANT
--		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
--		LEFT JOIN Dim.Hour h ON DATEPART(HOUR,DATE_TIME) = h.HourID
--		LEFT JOIN dbo.DimCalendarFiscal cf ON mi.TransDateOffset  = cf.DateKey
--		LEFT JOIN Dim.MachineOperator o ON mi.OPERATOR = o.OperatorKey
--		LEFT JOIN Dim.CycleReason cr ON mi.REASON_CODE = cr.ReasonKey
--		INNER JOIN Dim.ShiftControl sc ON sc.CurrentShiftID = mi.Shift_ID
--WHERE	PLANT = '122' AND mi.CurrentRecord = 1
--GROUP BY 
--	 mi.INDEX_ID
--	,cf.DateID
--	,h.HourID
--	,l.LocationID
--	,s2.ShiftID
--	,m.MachineID
--	,o.OperatorID
--	,cr.ReasonID
--	,mi.SHIFT_ID
--UNION
SELECT	ROW_NUMBER() OVER (ORDER BY [DateID]) AS INDEX_ID
	  ,DateID
	  ,[HourID]
      ,[PlantID]
      ,[ProductAID] AS ComponentID	
      ,[ProductBID] AS ProductID
      ,[ShiftID]
      ,[MachineID]
      ,0 AS [OperatorID]
      ,[ReasonID]
      ,[ShiftOffsetID]
	  ,[CurrentShiftID]
      ,[MissedCycle] AS MISSED_CYCLE
      ,[EmptyCycle] AS EMPTY_CYCLE
      ,[CycleCount] AS CYCLE_COUNT
	  ,[MissedTime] AS MISSED_TIME
      
      ,[CycleTime] AS CYCLE_TIME
      ,[IndexTime] AS INDEX_TIME
	  ,0 AS Capacity
FROM Fact.MachineIndexLive
--WHERE PlantID = 3

GO
