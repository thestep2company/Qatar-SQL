USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Clean_S2DOrderNotes_Customer]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [xref].[Clean_S2DOrderNotes_Customer] AS BEGIN

	;
	WITH CustomerLookup AS (
		SELECT DISTINCT x.ID, cl.CustomerKey, ss.Value, [Order Notes], REPLACE([Cleansed Order Note],ss.Value+',','') AS [Cleansed Order Note]
		FROM xref.Step2DirectOrderNotes x
			CROSS APPLY string_split([Order Notes],',') ss
			INNER JOIN xref.Step2DirectOrderNotesCustomerLookup cl ON cl.Value = ss.value
		WHERE x.CustomerKey IS NULL
	)
	UPDATE x
	SET x.CustomerKey = cl.CustomerKey
		,x.[Cleansed Order Note] = cl.[Cleansed Order Note]
	FROM xref.Step2DirectOrderNotes x
		INNER JOIN CustomerLookup cl ON x.ID = cl.ID
	WHERE x.CustomerKey IS NULL	

END
GO
