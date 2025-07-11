USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimBillOfMaterial]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Reload_DimBillOfMaterial] 
AS BEGIN
	
	----old logic
	--TRUNCATE TABLE dbo.DimBillOfMaterial
	--INSERT INTO dbo.DimBillOfMaterial SELECT * FROM Dim.BillOfMaterial

	--if a quantity changes, how do you recalc the rolldown?
	UPDATE t 
	SET t.COMPONENT_QUANTITY = s.COMPONENT_QUANTITY
	FROM Dim.BillOfMaterial s
		INNER JOIN dbo.DimBillOfMaterial t ON s.CHILD_PATH = t.CHILD_PATH AND s.PARENT_PATH = t.PARENT_PATH
	WHERE t.PARENT_PATH IS NULL AND s.PARENT_PATH IS NOT NULL
		AND s.COMPONENT_QUANTITY <> t.COMPONENT_QUANTITY

	INSERT INTO dbo.DimBillOfMaterial
	SELECT s.* FROM Dim.BillOfMaterial s
		LEFT JOIN dbo.DimBillOfMaterial t ON s.CHILD_PATH = t.CHILD_PATH AND s.PARENT_PATH = t.PARENT_PATH
	WHERE t.PARENT_PATH IS NULL AND s.PARENT_PATH IS NOT NULL

	INSERT INTO dbo.DimBillOfMaterial
	SELECT s.* FROM Dim.BillOfMaterial s
		LEFT JOIN dbo.DimBillOfMaterial t ON s.CHILD_PATH = t.CHILD_PATH
	WHERE t.CHILD_PATH IS NULL AND s.PARENT_PATH IS NULL AND s.Level = 0

	DECLARE @i INT = 0 

	WHILE @i < 100 BEGIN

		WITH DW_BOM AS (
			SELECT TOP 100 
				  ID
				, PARENT_SKU
				, CHILD_SKU
				, ITEM_NUM
				, LEVEL
				, COMPONENT_QUANTITY
				, PARENT_PATH
				, CHILD_PATH
				, CAST(1 AS FLOAT) AS ROLLDOWN
			FROM dbo.DimBillofMaterial cbom
			WHERE Level = 0 AND DERIVED_QUANTITY = 0
			UNION ALL
			SELECT dbom.[ID]
				  ,dbom.[PARENT_SKU]
				  ,dbom.[CHILD_SKU]
				  ,dbom.[ITEM_NUM]
				  ,dbom.[LEVEL]
				  ,dbom.[COMPONENT_QUANTITY]
				  ,dbom.[PARENT_PATH]
				  ,dbom.[CHILD_PATH]
				  ,DW_BOM.COMPONENT_QUANTITY*DW_BOM.ROLLDOWN AS ROLLDOWN 
			FROM dbo.DimBillofMaterial dbom
				INNER JOIN DW_BOM ON dbom.PARENT_PATH = DW_BOM.CHILD_PATH

		)
		, DW_ROLLDOWN AS (
			SELECT DISTINCT *, ROLLDOWN*COMPONENT_QUANTITY AS DERIVED_QUANTITY 
			FROM DW_BOM
			--ORDER BY CHILD_PATH, ITEM_NUM
		)
		UPDATE dbom 
		SET dbom.DERIVED_QUANTITY = rd.DERIVED_QUANTITY
			,dbom.ROLLDOWN = rd.ROLLDOWN
		FROM DW_ROLLDOWN rd
			INNER JOIN dbo.DimBillOfMaterial dbom ON rd.ID = dbom.ID

		IF @@ROWCOUNT = 0 
			SET @i = 100
		ELSE 
			SET @i = @i + 1
	END

	UPDATE c SET DERIVED_QUANTITY = -1
	FROM dbo.DimBillOfMaterial c
		LEFT JOIN dbo.DimBillOfMaterial p ON c.PARENT_PATH = p.CHILD_PATH
	WHERE c.DERIVED_QUANTITY = 0
		AND p.CHILD_PATH IS NULL
		AND c.PARENT_SKU IS NOT NULL
END
GO
