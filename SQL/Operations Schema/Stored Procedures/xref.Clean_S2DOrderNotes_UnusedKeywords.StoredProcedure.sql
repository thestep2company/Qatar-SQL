USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Clean_S2DOrderNotes_UnusedKeywords]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [xref].[Clean_S2DOrderNotes_UnusedKeywords] AS BEGIN

	UPDATE xref.Step2DirectOrderNotes SET [Cleansed Order Note] = [Order Notes] WHERE [Cleansed Order Note] IS NULL
	UPDATE xref.Step2DirectOrderNotes SET [Cleansed Order Note] = REPLACE([Order Notes],'INFO,','') WHERE [Cleansed Order Note] LIKE 'INFO,%'
	UPDATE xref.Step2DirectOrderNotes SET [Cleansed Order Note] = REPLACE([Cleansed Order Note],'NA |','') WHERE [Cleansed Order Note] LIKE '%NA |'
	UPDATE xref.Step2DirectOrderNotes SET [Cleansed Order Note] = REPLACE([Cleansed Order Note],'RECEIPT |','') WHERE [Cleansed Order Note] LIKE '%RECEIPT |'

END
GO
