USE [Operations]
GO
/****** Object:  View [Fact].[MachineIndexLive]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[MachineIndexLive] AS 
SELECT   cf.DateID
		,h.HourID
		,l.LocationID AS PlantID
		,ISNULL(pma.ProductID,0) AS ProductAID
		,ISNULL(pmb.ProductID,0) AS ProductBID
		,s2.ShiftID
		,m.MachineID
		,ISNULL(o.OperatorID,0) AS OperatorID
		,cr.ReasonID
		,0 AS ShiftOffsetID
		,CookCount AS CycleCount
		,MissedCycleCount AS MissedCycle
		,DeadArmCount AS EmptyCycle
		,CASE WHEN CycleTimeSetPoint NOT LIKE '%:%'
			 THEN DATEDIFF(SECOND, 0, CAST(RIGHT('00'+CONVERT(VARCHAR(12), [CycleTimeSetPoint] /60/60 % 24),2) + ':'
			+ RIGHT('00'+CONVERT(VARCHAR(2),  [CycleTimeSetPoint] /60 % 60),2)    + ':' 
			+ RIGHT('00'+CONVERT(VARCHAR(2),  [CycleTimeSetPoint] % 60),2) AS TIME))
				WHEN CycleTimeSetPoint NOT LIKE '%:%:%' THEN DATEDIFF(SECOND, 0, CAST('00:' + CycleTimeSetPoint AS TIME))
				ELSE DATEDIFF(SECOND, 0, CAST(CycleTimeSetPoint AS TIME)) 
		 END/3600.0 AS CycleTime --set the machine to hours
		,CASE WHEN ISNULL(MissTimeTotal,'0') <> '0' THEN DATEDIFF(SECOND, 0, CAST(MissTimeTotal AS TIME))/3600.0 END AS IndexTime
		,ABS(
			CASE WHEN ISNULL(ActualWorkTime,'0') <> '0' AND MissedCycleCount = 1 
				THEN DATEDIFF(SECOND, 0, CAST(ActualWorkTime AS TIME))
				-CASE WHEN CycleTimeSetPoint NOT LIKE '%:%'
					 THEN DATEDIFF(SECOND, 0, CAST(RIGHT('00'+CONVERT(VARCHAR(12), [CycleTimeSetPoint] /60/60 % 24),2) + ':'
					+ RIGHT('00'+CONVERT(VARCHAR(2),  [CycleTimeSetPoint] /60 % 60),2)    + ':' 
					+ RIGHT('00'+CONVERT(VARCHAR(2),  [CycleTimeSetPoint] % 60),2) AS TIME))
						WHEN CycleTimeSetPoint NOT LIKE '%:%:%' THEN DATEDIFF(SECOND, 0, CAST('00:' + CycleTimeSetPoint AS TIME))
						ELSE DATEDIFF(SECOND, 0, CAST(CycleTimeSetPoint AS TIME)) 
					 END		
				END
			)/3600.0 AS MissedTime
		,ABS(
			CASE WHEN ISNULL(ActualWorkTime,'0') <> '0' AND MissedCycleCount = 0 
				THEN DATEDIFF(SECOND, 0, CAST(ActualWorkTime AS TIME))
				-CASE WHEN CycleTimeSetPoint NOT LIKE '%:%'
					 THEN DATEDIFF(SECOND, 0, CAST(RIGHT('00'+CONVERT(VARCHAR(12), [CycleTimeSetPoint] /60/60 % 24),2) + ':'
					+ RIGHT('00'+CONVERT(VARCHAR(2),  [CycleTimeSetPoint] /60 % 60),2)    + ':' 
					+ RIGHT('00'+CONVERT(VARCHAR(2),  [CycleTimeSetPoint] % 60),2) AS TIME))
						WHEN CycleTimeSetPoint NOT LIKE '%:%:%' THEN DATEDIFF(SECOND, 0, CAST('00:' + CycleTimeSetPoint AS TIME))
						ELSE DATEDIFF(SECOND, 0, CAST(CycleTimeSetPoint AS TIME)) 
					 END		
				END
			)/3600.0 AS MadeTime
		,CASE WHEN ISNULL(ActualTimeInOven,'0') <> '0'  THEN DATEDIFF(SECOND, 0, CAST(ActualTimeInOven AS TIME))/3600.0 END AS OvenTime
		,CASE WHEN ISNULL(ActualTimeInOven,'0') <> '0' AND ISNULL(MissTimeTotal,'0') <> '0' THEN (DATEDIFF(SECOND, 0, CAST(ActualTimeInOven AS TIME))+DATEDIFF(SECOND, 0, CAST(MissTimeTotal AS TIME)))/3600.0 END AS TotalTime
		,sc.CurrentShiftID
FROM  
		[MachineData].[MachineIndex] mi 
		LEFT JOIN dbo.DimMachine m on 'L' + RIGHT('00'+CAST(mi.MachineNumber AS VARCHAR(2)),2) + '_' + CAST(mi.MachineSize AS VARCHAR(4)) = m.MachineKey AND CAST(mi.MachineLocation AS VARCHAR(4)) = m.LocationKey
		LEFT JOIN dbo.DimLocation l ON l.LocationKey = CAST(mi.MachineLocation AS VARCHAR(3))
		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
		LEFT JOIN Dim.Hour h ON DATEPART(HOUR,LogDateTime) = h.HourID
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(mi.LogDateTime AS DATE)  = cf.DateKey
		LEFT JOIN dbo.DimProductMaster pma ON CAST(mi.SQNumber_A AS VARCHAR(50)) = pma.ProductKey
		LEFT JOIN dbo.DimProductMaster pmb ON CAST(mi.SQNumber_B AS VARCHAR(50)) = pmb.ProductKey
		LEFT JOIN dbo.DimMachineOperator o ON CAST(mi.Operator AS VARCHAR(50)) = o.[OperatorKey]
		LEFT JOIN Dim.CycleReason cr ON mi.ReasonCodeMissed = cr.ReasonKey
		INNER JOIN Dim.ShiftControl sc ON sc.CurrentShiftID = mi.Shift_ID
WHERE	mi.CurrentRecord = 1
UNION
SELECT   cf.DateID
		,h.HourID
		,l.LocationID AS PlantID
		,ISNULL(pma.ProductID,0) AS ProductAID
		,ISNULL(pmb.ProductID,0) AS ProductBID
		,s2.ShiftID
		,m.MachineID
		,ISNULL(o.OperatorID,0) AS OperatorID
		,cr.ReasonID
		,1 AS ShiftOffsetID
		,CookCount AS CycleCount
		,MissedCycleCount AS MissedCycle
		,DeadArmCount AS EmptyCycle
		,CASE WHEN CycleTimeSetPoint NOT LIKE '%:%'
			 THEN DATEDIFF(SECOND, 0, CAST(RIGHT('00'+CONVERT(VARCHAR(12), [CycleTimeSetPoint] /60/60 % 24),2) + ':'
			+ RIGHT('00'+CONVERT(VARCHAR(2),  [CycleTimeSetPoint] /60 % 60),2)    + ':' 
			+ RIGHT('00'+CONVERT(VARCHAR(2),  [CycleTimeSetPoint] % 60),2) AS TIME))
				WHEN CycleTimeSetPoint NOT LIKE '%:%:%' THEN DATEDIFF(SECOND, 0, CAST('00:' + CycleTimeSetPoint AS TIME))
				ELSE DATEDIFF(SECOND, 0, CAST(CycleTimeSetPoint AS TIME)) 
		 END/3600.0 AS CycleTime --set the machine to hours
		,CASE WHEN ISNULL(MissTimeTotal,'0') <> '0' THEN DATEDIFF(SECOND, 0, CAST(MissTimeTotal AS TIME))/3600.0 END AS IndexTime
		,ABS(
			CASE WHEN ISNULL(ActualWorkTime,'0') <> '0' AND MissedCycleCount = 1 
				THEN DATEDIFF(SECOND, 0, CAST(ActualWorkTime AS TIME))
				-CASE WHEN CycleTimeSetPoint NOT LIKE '%:%'
					 THEN DATEDIFF(SECOND, 0, CAST(RIGHT('00'+CONVERT(VARCHAR(12), [CycleTimeSetPoint] /60/60 % 24),2) + ':'
					+ RIGHT('00'+CONVERT(VARCHAR(2),  [CycleTimeSetPoint] /60 % 60),2)    + ':' 
					+ RIGHT('00'+CONVERT(VARCHAR(2),  [CycleTimeSetPoint] % 60),2) AS TIME))
						WHEN CycleTimeSetPoint NOT LIKE '%:%:%' THEN DATEDIFF(SECOND, 0, CAST('00:' + CycleTimeSetPoint AS TIME))
						ELSE DATEDIFF(SECOND, 0, CAST(CycleTimeSetPoint AS TIME)) 
					 END		
				END
			)/3600.0 AS MissedTime
		,ABS(
			CASE WHEN ISNULL(ActualWorkTime,'0') <> '0' AND MissedCycleCount = 0 
				THEN DATEDIFF(SECOND, 0, CAST(ActualWorkTime AS TIME))
				-CASE WHEN CycleTimeSetPoint NOT LIKE '%:%'
					 THEN DATEDIFF(SECOND, 0, CAST(RIGHT('00'+CONVERT(VARCHAR(12), [CycleTimeSetPoint] /60/60 % 24),2) + ':'
					+ RIGHT('00'+CONVERT(VARCHAR(2),  [CycleTimeSetPoint] /60 % 60),2)    + ':' 
					+ RIGHT('00'+CONVERT(VARCHAR(2),  [CycleTimeSetPoint] % 60),2) AS TIME))
						WHEN CycleTimeSetPoint NOT LIKE '%:%:%' THEN DATEDIFF(SECOND, 0, CAST('00:' + CycleTimeSetPoint AS TIME))
						ELSE DATEDIFF(SECOND, 0, CAST(CycleTimeSetPoint AS TIME)) 
					 END		
				END
			)/3600.0 AS MadeTime
		,CASE WHEN ISNULL(ActualTimeInOven,'0') <> '0'  THEN DATEDIFF(SECOND, 0, CAST(ActualTimeInOven AS TIME))/3600.0 END AS OvenTime
		,CASE WHEN ISNULL(ActualTimeInOven,'0') <> '0' AND ISNULL(MissTimeTotal,'0') <> '0' THEN (DATEDIFF(SECOND, 0, CAST(ActualTimeInOven AS TIME))+DATEDIFF(SECOND, 0, CAST(MissTimeTotal AS TIME)))/3600.0 END AS TotalTime
		,sc.CurrentShiftID
FROM  
		[MachineData].[MachineIndex] mi 
		LEFT JOIN dbo.DimMachine m on 'L' + RIGHT('00'+CAST(mi.MachineNumber AS VARCHAR(2)),2) + '_' + CAST(mi.MachineSize AS VARCHAR(4)) = m.MachineKey AND CAST(mi.MachineLocation AS VARCHAR(4)) = m.LocationKey
		LEFT JOIN dbo.DimLocation l ON l.LocationKey = CAST(mi.MachineLocation AS VARCHAR(3))
		LEFT JOIN dbo.DimShift s2 ON mi.Shift = s2.ShiftKey
		LEFT JOIN Dim.Hour h ON DATEPART(HOUR,LogDateTime) = h.HourID
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(DATEADD(HOUR,-6,mi.LogDateTime) AS DATE)  = cf.DateKey --streetsboro offset
		LEFT JOIN dbo.DimProductMaster pma ON CAST(mi.SQNumber_A AS VARCHAR(50)) = pma.ProductKey
		LEFT JOIN dbo.DimProductMaster pmb ON CAST(mi.SQNumber_B AS VARCHAR(50)) = pmb.ProductKey
		LEFT JOIN dbo.DimMachineOperator o ON CAST(mi.Operator AS VARCHAR(50)) = o.[OperatorKey]
		LEFT JOIN Dim.CycleReason cr ON mi.ReasonCodeMissed = cr.ReasonKey
		INNER JOIN Dim.ShiftControl sc ON sc.CurrentShiftID = mi.Shift_ID
WHERE	mi.CurrentRecord = 1

GO
