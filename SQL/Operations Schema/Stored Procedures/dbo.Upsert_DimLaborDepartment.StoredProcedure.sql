USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimLaborDepartment]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_DimLaborDepartment] 
AS BEGIN

	INSERT INTO dbo.DimLaborDepartment (DepartmentKey, LaborType)
	SELECT s.DepartmentKey, s.LaborType
	FROM Dim.LaborDepartment s
		LEFT JOIN dbo.DimLaborDepartment t
	ON s.DepartmentKey = t.DepartmentKey
	WHERE t.DepartmentKey IS NULL

	UPDATE t 
	SET t.LaborType = s.LaborType
	FROM Dim.LaborDepartment s
		LEFT JOIN dbo.DimLaborDepartment t
	ON s.DepartmentKey = t.DepartmentKey
	WHERE ISNULL(s.LaborType,'') <> ISNULL(t.LaborType,'')
END
GO
