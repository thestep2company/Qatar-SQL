USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Clean_S2DOrderNotes_FinalComma]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [xref].[Clean_S2DOrderNotes_FinalComma] AS BEGIN

	UPDATE xref.Step2DirectOrderNotes 
	SET [Cleansed Order Note] = SUBSTRING([Cleansed Order Note],1,LEN([Cleansed Order Note])-1) 
	WHERE [Cleansed Order Note] LIKE '%,'

END	
GO
