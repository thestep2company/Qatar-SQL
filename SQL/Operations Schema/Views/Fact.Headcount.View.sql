USE [Operations]
GO
/****** Object:  View [Fact].[Headcount]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[Headcount] AS
WITH CTE AS (
	SELECT --[Employee Full Name]
		  [EmployeeID]
		, CASE WHEN DATEDIFF(DAY,[Hire Date],GETDATE()) > 30 THEN 1 ELSE 0 END AS HeadcountTypeID
		, [LocationID]
		, e.DepartmentID
		, e.ShiftID
		, [DateID]
		--, [DateKey]
		, CASE WHEN [Hire Date] = cf.DateKey THEN [EmployeeID] END AS Hire
		, NULL AS Term
		, DATEDIFF(DAY,[Hire Date],DateKey) AS Tenure
	FROM Dim.Employee e
			LEFT JOIN Dim.CalendarFiscal cf ON cf.DateKey >= [Hire Date] AND cf.DateKey <= [Date Terminated]
			LEFT JOIN Dim.Location l ON e.LocationKey = l.LocationKey
	WHERE cf.DateKey >= '2019-01-01' AND cf.DateKey < GETDATE() --AND e.[Employee Full Name] LIKE '%Benn%Ash%'
		AND [Employee ID] <> '1234'
		AND ((ISNUMERIC([Employee ID]) = 1 AND cf.DateKey <= '2023-12-31') --Kronos IDs
		 OR (ISNUMERIC([Employee ID]) = 0 AND cf.DateKey > '2023-12-31')) --ADP IDs
	GROUP BY [EmployeeID]
		, [LocationID]
		, e.DepartmentID
		, e.ShiftID
		, [DateID]
		, cf.DateKey
		, [Hire Date]
		--, [Employee Full Name]		 
	UNION
	SELECT -- [Employee Full Name]
		  [EmployeeID]
		, CASE WHEN DATEDIFF(DAY,[Hire Date],[Date Terminated]) > 30 THEN 1 ELSE 0 END AS HeadcountTypeID
		, [LocationID]
		, e.DepartmentID
		, e.ShiftID
		, [DateID]
		--, [DateKey]
		, NULL AS Hire
		, [EmployeeID] AS Term
		, DATEDIFF(DAY,[Hire Date],[Date Terminated]) AS Tenure
	FROM Dim.Employee e
			LEFT JOIN Dim.CalendarFiscal cf ON cf.DateKey = [Date Terminated]
			LEFT JOIN Dim.Location l ON e.LocationKey = l.LocationKey
	WHERE cf.DateKey >= '2019-01-01' AND cf.DateKey < GETDATE()  --AND e.[Employee Full Name] LIKE '%Benn%Ash%'
		AND [Employee ID] <> '1234'
		AND ((ISNUMERIC([Employee ID]) = 1 AND cf.DateKey <= '2023-12-31') --Kronos IDs
		 OR (ISNUMERIC([Employee ID]) = 0 AND cf.DateKey > '2023-12-31')) --ADP IDs
		AND [Employee Full Name] = 'Abrams, Zain'
	GROUP BY -- [Employee Full Name]
		  [EmployeeID]
		, [LocationID]
		, e.DepartmentID
		, e.ShiftID
		, [DateID]
		, [DateKey]
		, [Hire Date]
		, [Date Terminated]
	
)
SELECT * FROM CTE

GO
