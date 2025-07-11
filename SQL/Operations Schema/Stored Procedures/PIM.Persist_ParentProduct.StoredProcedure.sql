USE [Operations]
GO
/****** Object:  StoredProcedure [PIM].[Persist_ParentProduct]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [PIM].[Persist_ParentProduct] AS BEGIN
	TRUNCATE TABLE dbo.PIMParentProduct 
	
	--/*
	--^ start of string
	--. any single charcter
	--* at least 0 times
	--? at least one time
	--\ escape
	--[...] charater list
	--\s space
	--| OR
	--\b empty string at edge of word
	--\d digits
	--$ end of string
	--*/

	--DROP TABLE IF EXISTS #ParentProduct 
	--DROP TABLE IF EXISTS #RegEx

	--SELECT DISTINCT 
	--	 'PARENT_'+[Oracle Name] AS [Parent Name]
	--	,[Oracle Name]
	--	,dbo.RegExMatch([Oracle Name], '^\(.*?\)\s*|\([^)]*\)|\b\d{4,}\b| ?[-–]? ?\d+(?: ?OF ?\d+)?\)?$') AS RegExMatch
	--	,dbo.RegexEvaluator('^\(.*?\)\s*|\([^)]*\)|\b\d{4,}\b| ?[-–]? ?\d+(?: ?OF ?\d+)?\)?$',[Oracle Name]) AS RegExString
	--	,dbo.CleanProductName([Oracle Name])
	--	,[Part Type]
	--	,[SIOP Family]
	--	,[Category]
	--	,[Sub-Category]
	--	,[Make/Buy]
	----INTO #ParentProduct
	--FROM PIM.ProductMaster
	--WHERE [Category] <> 'B2B'
	--	AND [Oracle Name] NOT LIKE '%COMBO %'

	--SELECT  d.[Oracle Name], LTRIM(RTRIM(ss.Value)) AS ReplaceString, ROW_NUMBER() OVER (PARTITION BY [Oracle Name] ORDER BY ss.[Value]) AS MatchRow
	--INTO #RegEx
	--FROM #ParentProduct d
	--	CROSS APPLY STRING_SPLIT([RegExString] , '~') ss
	--WHERE  ss.Value <> ''

	--DECLARE @i INT = 1, @rows INT = (SELECT MAX(MatchRow) FROM #RegEx)
	--WHILE @i <= @rows BEGIN

	--	UPDATE d
	--	SET d.[Parent Name] = REPLACE([Parent Name], [ReplaceString], '')
	--	FROM #ParentProduct d
	--		LEFT JOIN #RegEx pp ON d.[Oracle Name] = pp.[Oracle Name]
	--	WHERE pp.MatchRow = @i

	--	SET @i = @i + 1
	--END

	INSERT INTO dbo.PIMParentProduct 
	SELECT DISTINCT 
		 'Parent_'+TRIM(dbo.CleanProductName(dbo.CamelCase(pm.[ProductName]))) AS [Parent Name]
		--,pm.[ProductName] AS [Oracle Name]
		--,ISNULL(REPLACE(pp.RegExString,'~',''),'') AS [Strings Removed]
		,pm.[Part Type]
		,pm.[SIOP Family]
		,pm.[Category_NEW] AS [Category]
		,pm.[Sub-Category_NEW] AS [Sub-Category]
		,pm.[MakeBuy] AS [Make/Buy]
		,pm.[Category] AS [Category Old]
		,pm.[SubCategory] AS [Sub-Category Old]
		,pm.[Supercategory_NEW] AS [Supercategory]
		,pm.[ProductType_NEW] AS [ProductType]
		,pm.[Brand_NEW] AS [Brand]
	FROM dbo.DimProductMaster pm 
		--LEFT JOIN #ParentProduct pp ON pm.[ProductName] = pp.[Oracle Name]
	WHERE pm.[Category] <> 'B2B'
		AND pm.[inventory status code] = 'Active'
		AND pm.[Part Type] = 'FINISHED GOODS'
		--AND pm.[Item Type] <> 'STEP2 FG KIT'
		AND LEN(pm.ProductKey) < 25
		AND pm.ProductKey NOT LIKE 'Placeholder%'
		AND pm.ProductKey NOT LIKE 'Roll%'
		AND pm.ProductKey NOT LIKE 'DSKU%'
	ORDER BY [Parent Name]

END


GO
