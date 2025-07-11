USE [Operations]
GO
/****** Object:  View [Fact].[Labor]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







;
CREATE VIEW [Fact].[Labor] AS
WITH LaborData AS (
	SELECT 
	   ID
	   ,CASE WHEN [Job Name] LIKE '%/SB%' THEN '111'
			WHEN [Job Name] LIKE '%/PV%' THEN '122'
			WHEN [Job Name] LIKE '%/DE-GA%' THEN '133'
			WHEN [Job Name] LIKE '%/WAR%' THEN '140'
	   END AS PlantID
	  ,[Employee ID]
      ,[Work Date]
	  --,SUBSTRING([Job Name],PATINDEX('%[0-9][0-9][0-9]%', [Job Name]),8) 
	  ,SUBSTRING(
			SUBSTRING([Job Name],PATINDEX('%[0-9][0-9][0-9]%', [Job Name]),1000)
			,1
			,CHARINDEX('/',SUBSTRING([Job Name],PATINDEX('%[0-9][0-9][0-9]%', [Job Name]),1000))-1
		)	
	  AS Department
	  ,LTRIM(RTRIM(REPLACE([Labor Category Name],',',''))) AS LaborCategory
	  ,[Paycode Name]
      ,CASE WHEN [Paycode Name] IN ('Regular', 'OT 0.5') THEN [Actual Hours] ELSE 0 END AS [Actual Hours]
      ,CASE WHEN [Paycode Name] IN ('Call Off','No Show','Unpaid TimeOff','Sick Leave Unpaid') THEN 0 ELSE [Actual Wages] END [Actual Wages]
  FROM [Kronos].[EmployeeHours] WITH (NOLOCK)
  WHERE LEN([Actual Hours])> 0
	AND [Paycode Type] = 'Regular'
	AND ([Job Name] LIKE '%/SB%' OR [Job Name] LIKE '%/PV%' OR [Job Name] LIKE '%/DE-GA%' OR [Job Name] LIKE '%/WAR%')
	AND (SUBSTRING([Job Name],PATINDEX('%[0-9][0-9][0-9]%', [Job Name]),3) IN (701,702,703,704,705,706,901,903,905))
	AND CurrentRecord = 1
)
, Found AS (
	SELECT 
		ld.ID, 
		e.[EmployeeID],
		d.[DepartmentID],
		c.LaborCategoryID,
		pc.[PaycodeID],
		l.LocationID,
		s.ShiftID,
		cf.[DateID],
		[Actual Hours] AS Hours, 
		[Actual Wages] AS Wages--,
		--e.[Schedule Group Assignment Name],
		--sc.Shift, sc.Org, sd.Shift AS Shift2, sd.ShiftName
	FROM LaborData ld
		LEFT JOIN dbo.DimCalendarFiscal cf ON ld.[Work Date] = cf.[DateKey]
		LEFT JOIN dbo.DimLocation l ON ld.[PlantID] = l.[LocationKey]
		LEFT JOIN dbo.DimEmployee e ON ld.[Employee ID] = e.[Employee ID]
		LEFT JOIN dbo.DimLaborDepartment d ON ld.Department = d.DepartmentKey
		LEFT JOIN dbo.DimLaborCategory c ON ld.LaborCategory = c.LaborCategoryName
		LEFT JOIN xref.ShiftDecoderRing sd ON e.[Schedule Group Assignment Name] = sd.ShiftName
		INNER JOIN Manufacturing.Shift sc ON ld.[Work Date] = CAST(Start_Date_Time AS DATE) AND sc.Org = l.LocationKey 
			AND CASE WHEN sc.Shift = 'A' THEN 1
					 WHEN sc.Shift = 'D' THEN 2
					 WHEN sc.Shift = 'B' AND sc.Org = '111' THEN 1 
					 WHEN sc.Shift = 'B' AND sc.Org <> '111' THEN 2
					 WHEN sc.SHift = 'C' AND sc.Org = '111' THEN 2
					 WHEN sc.Shift = 'C' AND sc.Org <> '111' THEN 3
				END = sd.Shift
		LEFT JOIN dbo.DimShift s ON s.ShiftKey = sc.Shift
		LEFT JOIN dbo.DimPayCode pc ON ld.[Paycode Name] = pc.[Paycode Name]
)

SELECT 
	e.[EmployeeID],
	d.[DepartmentID],
	c.LaborCategoryID,
	pc.[PaycodeID],
	l.LocationID,
	s.ShiftID AS ShiftID,
	cf.[DateID],
	[Actual Hours] AS Hours, 
	[Actual Wages] AS Wages--,
	--e.[Schedule Group Assignment Name],
	--sc.Shift, sc.Org, sd.Shift AS Shift2, sd.ShiftName

FROM LaborData ld
	LEFT JOIN dbo.DimCalendarFiscal cf ON ld.[Work Date] = cf.[DateKey]
	LEFT JOIN dbo.DimLocation l ON ld.[PlantID] = l.[LocationKey]
	LEFT JOIN dbo.DimEmployee e ON ld.[Employee ID] = e.[Employee ID]
	LEFT JOIN dbo.DimLaborDepartment d ON ld.Department = d.DepartmentKey
	LEFT JOIN dbo.DimLaborCategory c ON ld.LaborCategory = c.LaborCategoryName
	LEFT JOIN xref.ShiftDecoderRing sd ON e.[Schedule Group Assignment Name] = sd.ShiftName
	LEFT JOIN Manufacturing.Shift sc ON ld.[Work Date] = CAST(Start_Date_Time AS DATE) AND sc.Org = l.LocationKey --AND sd.Shift = sc.Shift
				AND CASE WHEN sc.Shift = 'A' THEN 1
					 WHEN sc.Shift = 'D' THEN 2
					 WHEN sc.Shift = 'B' AND sc.Org = '111' THEN 1 
					 WHEN sc.Shift = 'B' AND sc.Org <> '111' THEN 2
					 WHEN sc.SHift = 'C' AND sc.Org = '111' THEN 2
					 WHEN sc.Shift = 'C' AND sc.Org <> '111' THEN 3
				END = sd.Shift
	LEFT JOIN dbo.DimShift s ON s.ShiftKey = sd.Shift
	LEFT JOIN dbo.DimPayCode pc ON ld.[Paycode Name] = pc.[Paycode Name]
	LEFT JOIN Found f ON f.ID = ld.ID
WHERE f.ID IS NULL
--ORDER BY l.LocationID
UNION
SELECT EmployeeID, DepartmentID, LaborCategoryID, PaycodeID, LocationID, ShiftID, DateID, Hours, Wages--, [Schedule Group Assignment Name], Shift, Org, Shift2, ShiftName 
FROM Found

GO
