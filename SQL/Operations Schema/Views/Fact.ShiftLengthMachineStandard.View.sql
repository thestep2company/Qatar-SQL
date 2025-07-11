USE [Operations]
GO
/****** Object:  View [Fact].[ShiftLengthMachineStandard]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		CREATE VIEW [Fact].[ShiftLengthMachineStandard] AS 
		
		WITH Standards AS (
			SELECT ProductID, LocationID, Machine, SUM(MachineHours) AS MachineHours, SUM(TotalStandardHours) AS StandardHours, MAX(UnitsPerSpider) AS UP, MAX(RoundsPerShift) AS RoundsPerShift
			FROM dbo.FactStandards --use the persisted fact table for speed
			GROUP BY ProductID, LocationID, Machine
		)
		, StandardsOverrideLocation AS (
			SELECT pro.ProductID, LocationID, Machine, MAX(MachineHours) AS MachineHours, MAX(TotalStandardHours) AS StandardHours, MAX(UnitsPerSpider) AS UP, MAX(RoundsPerShift) AS RoundsPerShift
			FROM dbo.FactStandards pro --use the persisted fact table for speed
			WHERE LocationID = 3 
			GROUP BY pro.ProductID, LocationID, Machine
		)
		SELECT mi.ORG_CODE, mi.Shift, 'L' + SUBSTRING(REPLACE([Line_Code],'OO','O'),1,CHARINDEX('_',REPLACE([Line_Code],'OO','O'))-1)  AS Machine_Key, CAST(s.Start_Date_Time AS DATE) AS DateKey, s.Start_Date_Time, s.End_Date_Time
			, SUM(CASE WHEN s1.[MachineHours] = 0 OR s1.[MachineHours] IS NULL THEN s2.[MachineHours] ELSE s1.[MachineHours] END) AS MachineTime
		FROM Manufacturing.Shift s
			INNER JOIN dbo.CalendarFiscal cf ON cf.DateKey BETWEEN s.Start_Date_Time AND s.End_Date_Time
			INNER JOIN Manufacturing.Production mi ON mi.SHIFT = s.Shift AND mi.ORG_CODE = s.Org AND mi.TRANS_DATE_TIME BETWEEN s.Start_Date_Time AND s.End_Date_Time AND mi.CurrentRecord = 1
			LEFT JOIN dbo.DimLocation l ON mi.Org_Code = l.LocationKey
			LEFT JOIN dbo.DimProductMaster p ON mi.[Part_Number] = p.ProductKey
			LEFT JOIN Standards s1 ON l.LocationID = s1.LocationID AND p.ProductID = s1.ProductID
			LEFT JOIN StandardsOverrideLocation s2 ON p.ProductID = s2.ProductID
		WHERE s.CurrentRecord = 1  AND Org IN ('111','122') AND s.Start_Date_Time BETWEEN '2022-03-01' AND '2023-01-01' AND cf.DateKey > TRANS_DATE_TIME --overnight same day
		GROUP BY mi.ORG_CODE, mi.Shift, cf.DateKey, 'L' + SUBSTRING(REPLACE([Line_Code],'OO','O'),1,CHARINDEX('_',REPLACE([Line_Code],'OO','O'))-1) , s.Start_Date_Time, s.End_Date_Time
		UNION
		SELECT mi.ORG_CODE, mi.Shift, 'L' + SUBSTRING(REPLACE([Line_Code],'OO','O'),1,CHARINDEX('_',REPLACE([Line_Code],'OO','O'))-1) AS MachineKey, cf.DateKey, s.Start_Date_Time, s.End_Date_Time
			, SUM(CASE WHEN s1.[MachineHours] = 0 OR s1.[MachineHours] IS NULL THEN s2.[MachineHours] ELSE s1.[MachineHours] END) AS MachineTime
		FROM Manufacturing.Shift s
			INNER JOIN dbo.CalendarFiscal cf ON cf.DateKey BETWEEN s.Start_Date_Time AND s.End_Date_Time
			INNER JOIN Manufacturing.Production mi ON mi.SHIFT = s.Shift AND mi.ORG_CODE = s.Org AND mi.TRANS_DATE_TIME BETWEEN s.Start_Date_Time AND s.End_Date_Time AND mi.CurrentRecord = 1
			LEFT JOIN dbo.DimLocation l ON mi.Org_Code = l.LocationKey
			LEFT JOIN dbo.DimProductMaster p ON mi.[Part_Number] = p.ProductKey
			LEFT JOIN Standards s1 ON l.LocationID = s1.LocationID AND p.ProductID = s1.ProductID
			LEFT JOIN StandardsOverrideLocation s2 ON p.ProductID = s2.ProductID
		WHERE s.CurrentRecord = 1  AND Org IN ('111','122') AND s.Start_Date_Time BETWEEN '2022-03-01' AND '2023-01-01' AND cf.DateKey <= TRANS_DATE_TIME --overnight next day
		GROUP BY mi.ORG_CODE, mi.Shift, cf.DateKey, 'L' + SUBSTRING(REPLACE([Line_Code],'OO','O'),1,CHARINDEX('_',REPLACE([Line_Code],'OO','O'))-1) , s.Start_Date_Time, s.End_Date_Time
		UNION
		SELECT mi.ORG_CODE, mi.Shift, 'L' + SUBSTRING(REPLACE([Line_Code],'OO','O'),1,CHARINDEX('_',REPLACE([Line_Code],'OO','O'))-1) AS MachineKey, CAST(s.Start_Date_Time AS DATE) AS DateKey, s.Start_Date_Time, s.End_Date_Time
			, SUM(CASE WHEN s1.[MachineHours] = 0 OR s1.[MachineHours] IS NULL THEN s2.[MachineHours] ELSE s1.[MachineHours] END) AS MachineTime
		FROM Manufacturing.Shift s
			INNER JOIN dbo.CalendarFiscal cf ON cf.DateKey BETWEEN s.Start_Date_Time AND s.End_Date_Time
			INNER JOIN Manufacturing.Production mi ON mi.SHIFT = s.Shift AND mi.ORG_CODE = s.Org AND mi.TRANS_DATE_TIME BETWEEN s.Start_Date_Time AND s.End_Date_Time AND mi.CurrentRecord = 1
			LEFT JOIN dbo.DimLocation l ON mi.Org_Code = l.LocationKey
			LEFT JOIN dbo.DimProductMaster p ON mi.[Part_Number] = p.ProductKey
			LEFT JOIN Standards s1 ON l.LocationID = s1.LocationID AND p.ProductID = s1.ProductID
			LEFT JOIN StandardsOverrideLocation s2 ON p.ProductID = s2.ProductID
		WHERE s.CurrentRecord = 1  AND Org IN ('111','122') AND s.Start_Date_Time BETWEEN '2023-03-01' AND '2023-01-01' AND cf.DateKey IS NULL --day shifts
		GROUP BY mi.ORG_CODE, mi.Shift, cf.DateKey, 'L' + SUBSTRING(REPLACE([Line_Code],'OO','O'),1,CHARINDEX('_',REPLACE([Line_Code],'OO','O'))-1) , s.Start_Date_Time, s.End_Date_Time
GO
