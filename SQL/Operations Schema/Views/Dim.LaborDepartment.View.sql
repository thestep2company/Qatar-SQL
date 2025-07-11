USE [Operations]
GO
/****** Object:  View [Dim].[LaborDepartment]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Dim].[LaborDepartment] AS
SELECT DISTINCT
	DENSE_RANK() OVER (ORDER BY 
		SUBSTRING(
			SUBSTRING([Job Name],PATINDEX('%[0-9][0-9][0-9]%', [Job Name]),1000)
			,1
			,CHARINDEX('/',SUBSTRING([Job Name],PATINDEX('%[0-9][0-9][0-9]%', [Job Name]),1000))-1
		)	
	) AS DepartmentID
	,SUBSTRING(
		SUBSTRING([Job Name],PATINDEX('%[0-9][0-9][0-9]%', [Job Name]),1000)
		,1
		,CHARINDEX('/',SUBSTRING([Job Name],PATINDEX('%[0-9][0-9][0-9]%', [Job Name]),1000))-1
	) AS DepartmentKey
	,CASE WHEN 
		SUBSTRING([Job Name],PATINDEX('%[0-9][0-9][0-9]%', [Job Name]),3) IN ('704','705','706') THEN 'Direct Labor' ELSE 'Indirect Labor'
	END AS LaborType

FROM [Kronos].[EmployeeHours] WITH (NOLOCK)
WHERE LEN([Actual Hours])> 0
	AND [Paycode Type] = 'Regular'
	--AND ([PayCode Name] IN ('Regular', 'OT 1.0', 'OT 0.5', 'Lump Sum', 'Retroactive') OR [Paycode Name] LIKE 'Shift Diff%') --include all codes
	AND ([Job Name] LIKE '%/SB%' OR [Job Name] LIKE '%/PV%' OR [Job Name] LIKE '%/DE-GA%' OR [Job Name] LIKE '%/WAR%')
	AND SUBSTRING([Job Name],PATINDEX('%[0-9][0-9][0-9]%', [Job Name]),3) IN (701,702,703,704,705,706,901,903,905)
	AND CurrentRecord = 1
UNION
SELECT -1, '704-MATL', 'Direct Labor'
GO
