USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Clean_S2DOrderNotes_Claims]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [xref].[Clean_S2DOrderNotes_Claims] AS BEGIN

	UPDATE xref.Step2DirectOrderNotes
	SET [Cleansed Order Note] = SUBSTRING([Cleansed Order Note],1,PATINDEX('%'+SUBSTRING([Order Notes],PATINDEX('%COC[0-9]%',[Order Notes]),1000)+'%',[Cleansed Order Note])-1)
	--SELECT [Order Notes], [Cleansed Order Note]
	--	, SUBSTRING([Order Notes],PATINDEX('%COC[0-9]%',[Order Notes]),1000)
	--	, SUBSTRING([Cleansed Order Note],1,PATINDEX('%'+SUBSTRING([Order Notes],PATINDEX('%COC[0-9]%',[Order Notes]),1000)+'%',[Cleansed Order Note])-1)
	FROM xref.Step2DirectOrderNotes 
	WHERE [Cleansed Order Note] LIKE '%COC[0-9]%'
END 
GO
