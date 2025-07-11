USE [Operations]
GO
/****** Object:  View [Error].[LaborImport]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Error].[LaborImport] AS 
	--make into checksum
WITH CTE AS (
	SELECT SUM([Actual Hours]) AS [Actual Hours]
			,SUM([Actual Wages]) AS [Actual Wages]
			,COUNT(*) AS [Record Count]
	FROM Kronos.EmployeeHours 
	WHERE CurrentRecord = 1 AND [Work Date] = CAST(GETDATE() AS DATE)
	UNION
	SELECT 
			-SUM(CAST([Actual Total Hours (Include Corrections)] AS FLOAT)) AS [Actual Hours]
			,-SUM(CAST([Actual Total Wages (Include Corrections)] AS MONEY)) AS [Actual Wages]
			,-COUNT(*) AS [Record Count]
	FROM [Kronos].[Employee Hours by Worked Acct Daily] WHERE CAST([Actual Total Apply Date] AS DATE) = CAST(GETDATE() AS DATE)
)
SELECT SUM([Actual Hours]) AS [Actual Hours]
	,  SUM([Actual Wages]) AS [Actual Wages]
	,  SUM([Record Count]) AS [Record Count]
FROM CTE 
HAVING ABS(SUM([Actual Hours])) > .01
	OR ABS(SUM([Actual Wages])) > .01
	OR ABS(SUM([Record Count])) > .01
GO
