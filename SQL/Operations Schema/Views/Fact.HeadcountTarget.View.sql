USE [Operations]
GO
/****** Object:  View [Fact].[HeadcountTarget]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[HeadcountTarget] AS
SELECT l.LocationID AS PlantID 
	,s.ShiftID
	,d.DepartmentID 
	,hc.Headcount
FROM xref.HeadcountTarget hc
	LEFT JOIN dbo.DimLocation l ON hc.PlantID = l.LocationKey
	LEFT JOIN dbo.DimShift s ON hc.ShiftID = s.ShiftKey 
	LEFT JOIN Dim.LaborDepartment d ON hc.Department = d.DepartmentKey
GO
