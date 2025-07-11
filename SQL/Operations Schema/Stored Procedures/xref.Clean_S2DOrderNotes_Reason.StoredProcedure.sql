USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Clean_S2DOrderNotes_Reason]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [xref].[Clean_S2DOrderNotes_Reason] AS BEGIN

		UPDATE x 
		SET x.ReasonKey = ReasonCategory
			,x.[Cleansed Order Note] = REPLACE([Cleansed Order Note],ss.Value+',','')
		FROM xref.Step2DirectOrderNotes x
			CROSS APPLY string_split([Order Notes],',') ss
			INNER JOIN xref.Step2DirectReasonLookup r ON ss.Value = r.ReasonKey 
		WHERE x.ReasonKey IS NULL

END
GO
