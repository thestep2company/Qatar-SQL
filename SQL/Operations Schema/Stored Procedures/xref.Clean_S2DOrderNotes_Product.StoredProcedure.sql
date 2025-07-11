USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Clean_S2DOrderNotes_Product]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [xref].[Clean_S2DOrderNotes_Product] AS BEGIN

	;
	WITH SKULookup AS (
		SELECT x.ID, pm.ProductKey, ss.Value, [Order Notes], REPLACE([Cleansed Order Note],ss.Value+',','') AS [Cleansed Order Note]
		FROM xref.Step2DirectOrderNotes x
			CROSS APPLY string_split([Order Notes],',') ss
			INNER JOIN dbo.DimProductMaster pm ON LTRIM(RTRIM(ss.Value)) = pm.ProductKey
		WHERE x.ProductKey IS NULL
	)
	UPDATE x
	SET x.ProductKey = l.ProductKey
		,x.[Cleansed Order Note] = l.[Cleansed Order Note]
	FROM xref.Step2DirectOrderNotes x
		INNER JOIN SKULookup l ON x.ID = l.ID
	WHERE x.ProductKey IS NULL

	;
	WITH SKULookup AS (
		SELECT x.ID, pm.ProductKey, ss.Value, [Order Notes], REPLACE([Cleansed Order Note],ss.Value+',','') AS [Cleansed Order Note]
		FROM xref.Step2DirectOrderNotes x
			CROSS APPLY string_split([Order Notes],',') ss
			INNER JOIN dbo.DimProductMaster pm ON LTRIM(RTRIM(ss.Value))+'00' = pm.ProductKey
		WHERE x.ProductKey IS NULL
	)
	UPDATE x
	SET x.ProductKey = l.ProductKey
		,x.[Cleansed Order Note] = l.[Cleansed Order Note]
	FROM xref.Step2DirectOrderNotes x
		INNER JOIN SKULookup l ON x.ID = l.ID
	WHERE x.ProductKey IS NULL

	;
	WITH SKULookup AS (
		SELECT x.ID, pm.ProductKey, ss.Value, [Order Notes], REPLACE([Cleansed Order Note],ss.Value+',','') AS [Cleansed Order Note]
		FROM xref.Step2DirectOrderNotes x
			CROSS APPLY string_split([Order Notes],',') ss
			INNER JOIN dbo.DimProductMaster pm ON LTRIM(RTRIM(ss.Value))+'99' = pm.ProductKey
		WHERE x.ProductKey IS NULL
	)
	UPDATE x
	SET x.ProductKey = l.ProductKey
		,x.[Cleansed Order Note] = l.[Cleansed Order Note]
	FROM xref.Step2DirectOrderNotes x
		INNER JOIN SKULookup l ON x.ID = l.ID
	WHERE x.ProductKey IS NULL

	;
	WITH SKULookup AS (
		SELECT x.ID, pm.ProductKey, ss.Value, [Order Notes], REPLACE([Cleansed Order Note],ss.Value+',','') AS [Cleansed Order Note]
		FROM xref.Step2DirectOrderNotes x
			CROSS APPLY string_split([Order Notes],',') ss
			INNER JOIN dbo.DimProductMaster pm ON LTRIM(RTRIM(ss.Value))+'KL' = pm.ProductKey
		WHERE [Order Notes] LIKE '%Kohl%'
			AND x.ProductKey IS NULL
	)
	UPDATE x
	SET x.ProductKey = l.ProductKey
		,x.[Cleansed Order Note] = l.[Cleansed Order Note]
	FROM xref.Step2DirectOrderNotes x
		INNER JOIN SKULookup l ON x.ID = l.ID
	WHERE x.ProductKey IS NULL
	
	;
	WITH SKULookup AS (
		SELECT x.ID, pm.ProductKey, ss.Value, [Order Notes], REPLACE([Cleansed Order Note],ss.Value+',','') AS [Cleansed Order Note]
		FROM xref.Step2DirectOrderNotes x
			CROSS APPLY string_split([Order Notes],',') ss
			INNER JOIN dbo.DimProductMaster pm ON LTRIM(RTRIM(ss.Value))+'KR' = pm.ProductKey
		WHERE [Order Notes] LIKE '%Kohl%'
			AND x.ProductKey IS NULL
	)
	UPDATE x
	SET x.ProductKey = l.ProductKey
		,x.[Cleansed Order Note] = l.[Cleansed Order Note]
	FROM xref.Step2DirectOrderNotes x
		INNER JOIN SKULookup l ON x.ID = l.ID
	WHERE x.ProductKey IS NULL


END


/*
ALTER VIEW Fact.Step2DirectOrderNotes AS
SELECT ISNULL(pm.ProductID,0) AS ProductID, cf.DateID,  [Order Notes]
FROM xref.Step2DirectOrderNotes x
	LEFT JOIN dbo.DimCalendarFiscal cf On [File Date] = cf.[DateKey]
	LEFT JOIN dbo.DimProductMaster pm ON pm.[ProductKey] = x.[ProductKey]
*/


GO
