USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimLaborCategory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Upsert_DimLaborCategory] 
AS BEGIN

	INSERT INTO dbo.DimLaborCategory
	SELECT s.LaborCategoryName 
	FROM Dim.LaborCategory s
		LEFT JOIN dbo.DimLaborCategory t
	ON s.LaborCategoryName = t.LaborCategoryName 
	WHERE t.LaborCategoryName IS NULL

	--only add, may be issues with history if records are deleted
	--DELETE FROM t 
	--FROM dbo.DimLaborCategory t
	--	LEFT JOIN Dim.LaborCategory s
	--ON s.LaborCategoryName = t.LaborCategoryName
	--WHERE s.LaborCategoryName IS NULL

END
GO
