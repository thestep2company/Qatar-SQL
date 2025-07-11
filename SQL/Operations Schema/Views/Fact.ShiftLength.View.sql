USE [Operations]
GO
/****** Object:  View [Fact].[ShiftLength]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--172,953 6:06
--172.953 1:08
CREATE VIEW [Fact].[ShiftLength] AS
WITH ShiftData AS (
		--shift up until midnight
		SELECT s1.Org, s1.Shift, CAST(s1.Start_Date_Time AS DATE) AS DateKey, s1.Start_Date_Time, CAST(cf.DateKey AS DATETIME) AS End_Date_Time, DATEDIFF(HOUR,s1.Start_Date_Time, cf.DateKey) AS ShiftTime
		FROM Manufacturing.Shift s1 
			INNER JOIN dbo.DimCalendarFiscal cf ON cf.DateKey BETWEEN s1.Start_Date_Time AND s1.End_Date_Time
		WHERE s1.CurrentRecord = 1 AND Org IN ('111','122') AND s1.Start_Date_Time BETWEEN '2019-01-01' AND '2023-01-01'
		UNION
		--shift after midnight
		SELECT s1.Org, s1.Shift, cf.DateKey, CAST(cf.DateKey AS DATETIME) AS Start_Date_Time, s1.End_Date_Time, DATEDIFF(HOUR,cf.DateKey, s1.End_Date_Time) AS ShiftTime
		FROM Manufacturing.Shift s1 
			INNER JOIN dbo.DimCalendarFiscal cf ON cf.DateKey BETWEEN s1.Start_Date_Time AND s1.End_Date_Time
		WHERE s1.CurrentRecord = 1 AND Org IN ('111','122') AND s1.Start_Date_Time BETWEEN '2019-01-01' AND '2023-01-01'
		UNION
		--shift does not cross midnight
		SELECT s1.Org, s1.Shift, CAST(s1.Start_Date_Time AS DATE) AS DateKey, s1.Start_Date_Time, s1.End_Date_Time, DATEDIFF(HOUR,s1.Start_Date_Time, s1.End_Date_Time) AS ShiftTime
		FROM Manufacturing.Shift s1 
			LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey BETWEEN s1.Start_Date_Time AND s1.End_Date_Time
		WHERE s1.CurrentRecord = 1 AND Org IN ('111','122') AND cf.DateKey IS NULL AND s1.Start_Date_Time BETWEEN '2019-01-01' AND '2023-01-01'
	)	
	, MachineData AS (
		SELECT mi.PLANT, mi.Shift, 'L' + mi.MACHINE_NUM + '_' + mi.MACHINE_SIZE AS Machine_Key, CAST(s1.Start_Date_Time AS DATE) AS DateKey, s1.Start_Date_Time, s1.End_Date_Time, (SUM(CYCLE_TIME)*1.0)/3600.0 + ((SUM(CYCLE_TIME)*1.0)/300*15)/3600.0 AS MachineTime
		FROM Manufacturing.Shift s1
			INNER JOIN dbo.DimCalendarFiscal cf ON cf.DateKey BETWEEN s1.Start_Date_Time AND s1.End_Date_Time
			INNER JOIN Manufacturing.MACHINE_INDEX mi ON mi.SHIFT = s1.Shift AND mi.Plant = s1.Org AND mi.DATE_TIME BETWEEN s1.Start_Date_Time AND s1.End_Date_Time AND mi.CurrentRecord = 1
		WHERE s1.CurrentRecord = 1  AND Org IN ('111','122') AND s1.Start_Date_Time BETWEEN '2019-01-01' AND '2023-01-01' AND cf.DateKey > DATE_TIME
		GROUP BY mi.PLANT, mi.Shift, cf.DateKey, 'L' + mi.MACHINE_NUM + '_' + mi.MACHINE_SIZE, s1.Start_Date_Time, s1.End_Date_Time
		UNION
		SELECT mi.PLANT, mi.Shift, 'L' + mi.MACHINE_NUM + '_' + mi.MACHINE_SIZE AS Machine_Key, cf.DateKey, s1.Start_Date_Time, s1.End_Date_Time, (SUM(CYCLE_TIME)*1.0)/3600.0 + ((SUM(CYCLE_TIME)*1.0)/300*15)/3600.0 AS MachineTime
		FROM Manufacturing.Shift s1
			INNER JOIN dbo.DimCalendarFiscal cf ON cf.DateKey BETWEEN s1.Start_Date_Time AND s1.End_Date_Time
			INNER JOIN Manufacturing.MACHINE_INDEX mi ON mi.SHIFT = s1.Shift AND mi.Plant = s1.Org AND mi.DATE_TIME BETWEEN s1.Start_Date_Time AND s1.End_Date_Time AND mi.CurrentRecord = 1
		WHERE s1.CurrentRecord = 1  AND Org IN ('111','122') AND s1.Start_Date_Time BETWEEN '2019-01-01' AND '2023-01-01' AND cf.DateKey <= DATE_TIME
		GROUP BY mi.PLANT, mi.Shift, cf.DateKey, 'L' + mi.MACHINE_NUM + '_' + mi.MACHINE_SIZE, s1.Start_Date_Time, s1.End_Date_Time
		UNION
		SELECT mi.PLANT, mi.Shift, 'L' + mi.MACHINE_NUM + '_' + mi.MACHINE_SIZE AS Machine_Key, CAST(s1.Start_Date_Time AS DATE) AS DateKey, s1.Start_Date_Time, s1.End_Date_Time, (SUM(CYCLE_TIME)*1.0)/3600.0 + ((SUM(CYCLE_TIME)*1.0)/300*15)/3600.0 AS MachineTime
		FROM Manufacturing.Shift s1
			LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey BETWEEN s1.Start_Date_Time AND s1.End_Date_Time
			INNER JOIN Manufacturing.MACHINE_INDEX mi ON mi.SHIFT = s1.Shift AND mi.Plant = s1.Org AND mi.DATE_TIME BETWEEN s1.Start_Date_Time AND s1.End_Date_Time AND mi.CurrentRecord = 1
		WHERE s1.CurrentRecord = 1  AND Org IN ('111','122') AND s1.Start_Date_Time BETWEEN '2019-01-01' AND '2023-01-01' AND cf.DateKey IS NULL
		GROUP BY mi.PLANT, mi.Shift, 'L' + mi.MACHINE_NUM + '_' + mi.MACHINE_SIZE, s1.Start_Date_Time, s1.End_Date_Time
	)
SELECT DISTINCT cf.DateID, md.DateKey, l.LocationID AS PlantID
	, s2.ShiftID, 0 AS ShiftOffsetID, m.MachineID, md.MachineTime
	, md.Start_Date_Time, md.End_Date_Time
	, CASE WHEN md.MachineTime >= .33333333 THEN sd.ShiftTime ELSE 0 END AS ShiftLength, 0 AS Breaks, cf.Holiday
FROM ShiftData sd
	INNER JOIN MachineData md ON sd.Shift = md.SHIFT AND sd.Org = md.Plant AND md.DateKey = sd.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf ON md.DateKey = cf.DateKey
	LEFT JOIN dbo.DimLocation l ON l.LocationKey = sd.Org
	LEFT JOIN dbo.DimShift s2 ON sd.Shift = s2.ShiftKey
	LEFT JOIN dbo.DimMachine m on md.Machine_Key = m.MachineKey 
UNION ALL
SELECT DISTINCT cf.DateID, md.DateKey, l.LocationID AS PlantID
	, s2.ShiftID, 1 AS ShiftOffsetID, m.MachineID, md.MachineTime
	, DATEADD(HOUR,-6,md.Start_Date_Time) AS Start_Date_Time, DATEADD(HOUR,-6,md.End_Date_Time) AS End_Date_Time
	, CASE WHEN md.MachineTime >= .33333333 THEN sd.ShiftTime ELSE 0 END AS ShiftLength, 0 AS Breaks, cf.Holiday
FROM ShiftData sd
	INNER JOIN MachineData md ON sd.Shift = md.SHIFT AND sd.Org = md.Plant AND md.DateKey = sd.DateKey
	LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(DATEADD(HOUR,-6,md.Start_Date_Time) AS DATE) = cf.DateKey
	LEFT JOIN dbo.DimLocation l ON l.LocationKey = sd.Org
	LEFT JOIN dbo.DimShift s2 ON sd.Shift = s2.ShiftKey
	LEFT JOIN dbo.DimMachine m on md.Machine_Key = m.MachineKey AND sd.Org = m.LocationKey
--ORDER BY  Start_Date_Time, DateKey, PlantID, MachineID


GO
