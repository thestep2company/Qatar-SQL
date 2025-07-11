USE [Operations]
GO
/****** Object:  View [Dim].[Employee]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  CREATE VIEW [Dim].[Employee] AS 
  SELECT  [ID] AS EmployeeID
      ,[Employee ID]
      ,[Primary Location]
      ,[Primary Job]
      ,[Schedule Group Assignment Name]
      ,[Accrual Profile Name]
      ,[Employee Type]
      ,[Employee Full Name]
      ,CAST([Hire Date] AS DATE) AS [Hire Date]
      ,CASE WHEN [Date Terminated] = '' THEN '9999-12-31' ELSE CAST([Date Terminated] AS DATE) END AS [Date Terminated]
      ,[Termination Reason]
	  ,CASE WHEN [Primary Location] LIKE '%/SB-OH/%' OR [Primary Location] LIKE '%/SB/%' THEN '111'
			WHEN [Primary Location] LIKE '%/PV-OH/%' OR [Primary Location] LIKE '%/PV/%' THEN '122'
			WHEN [Primary Location] LIKE '%/DE-GA/%' THEN '133'
			WHEN [Primary Location] LIKE '%/WAR-OH/%' OR [Primary Location] LIKE '%/WAR/%' THEN '140'
	   END AS LocationKey
	   ,CASE WHEN [Primary Location] LIKE '%ROTO%' THEN 'ROTO'
			WHEN [Primary Location] LIKE '%ASSY%' THEN 'ASSY'
			WHEN [Primary Location] LIKE '%704%' THEN 'POWD'
			WHEN [Primary Location] LIKE '%DIST%' THEN 'DIST'
			WHEN [Primary Location] LIKE '%QUAL%' THEN 'QUAL'
			WHEN [Primary Location] LIKE '%TRUCK%' THEN 'TRUCK'
			WHEN [Primary Location] LIKE '%702%' THEN 'MAINT'
			ELSE 'OTHER'
			--WHEN [Primary Location (Path)] LIKE '%WAR-OH%' THEN '140'
	   END AS Job,
	   REVERSE(SUBSTRING(REVERSE([Primary Location]),1,CHARINDEX('/',REVERSE([Primary Location]))-1)) AS [Department],
	   d.DepartmentID,
	   CASE WHEN CAST([Date Terminated] AS DATE) < GETDATE() THEN 'Terminated' 
			WHEN DATEDIFF(DAY,CAST([Hire Date] AS DATE),GETDATE()) < 30 AND [Date Terminated] = '' THEN 'Training' 
			ELSE 'Employed'
	   END AS Status,
	   ISNULL(s.ShiftName,'OTHER') AS ShiftName,
	   [ShiftID],
	   DATEDIFF(DAY,[Hire Date], CASE WHEN [Date Terminated] < '9999-12-31' THEN [Date Terminated] ELSE GETDATE() END) AS Tenure
	FROM [Kronos].[Employee] e
		LEFT JOIN xref.Shift s ON s.ShiftLookup = [Schedule Group Assignment Name]
		LEFT JOIN Dim.LaborDepartment d ON REVERSE(SUBSTRING(REVERSE([Primary Location]),1,CHARINDEX('/',REVERSE([Primary Location]))-1)) = d.DepartmentKey
		LEFT JOIN dbo.DimShift ds ON ds.ShiftKey = CASE WHEN LEFT(s.[ShiftName],3) = '1st' THEN 'A'  WHEN LEFT(s.[ShiftName],3) = '2nd' THEN 'B'  WHEN LEFT(s.[ShiftName],3) = '3rd' THEN 'C' ELSE s.[ShiftName] END
	WHERE [Employee Type] IN ('Full-Time', 'Part-Time', 'Temporary') AND CurrentRecord = 1 --AND  e.[Employee Full Name] LIKE '%Benn%Ash%'
	--ORDER BY [Employee ID], RIGHT([Primary Location (Path)],4) ASC
GO
