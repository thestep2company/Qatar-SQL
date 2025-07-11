USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Upsert_CycleReason]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [xref].[Upsert_CycleReason] 
AS BEGIN

	INSERT INTO xref.CycleReason
	SELECT s.ReasonKey, s.ReasonName, s.ReasonCategory 
	FROM xref.dbo.CycleReason s
		LEFT JOIN xref.CycleReason t ON s.ReasonKey = t.ReasonKey 
	WHERE t.ReasonKey IS NULL

	UPDATE t 
	SET t.ReasonName = s.ReasonName
		,t.ReasonCategory = s.ReasonCategory 
	FROM xref.dbo.CycleReason s
		LEFT JOIN xref.CycleReason t ON s.ReasonKey = t.ReasonKey 
	WHERE t.ReasonName <> s.ReasonName 
		OR t.ReasonCategory <> s.ReasonCategory

END

GO
