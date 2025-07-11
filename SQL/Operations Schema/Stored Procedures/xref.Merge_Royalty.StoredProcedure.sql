USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Merge_Royalty]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [xref].[Merge_Royalty] AS BEGIN

	--new records
	INSERT INTO xref.Royalty
	SELECT r2.[Royalty License Name], r2.[Royalty License %], r2.[4 Digit], r2.[Year] 
	FROM xref.Royalty r1
		FULL OUTER JOIN xref.dbo.Royalty r2 ON r1.[4 Digit] = r2.[4 Digit] AND r1.[Year] = r2.[Year]
	WHERE r1.[4 Digit] IS NULL

	--existing records
	UPDATE r1 
	SET r1.[Royalty License %] = r2.[Royalty License %]
		,r1.[Royalty License Name] = r2.[Royalty License Name]
	FROM xref.Royalty r1
		FULL OUTER JOIN xref.dbo.Royalty r2 ON r1.[4 Digit] = r2.[4 Digit] AND r1.[Year] = r2.[Year]
	WHERE r1.[Royalty License Name] <> r2.[Royalty License Name]
		OR r2.[Royalty License %] <> r2.[Royalty License %]

END
GO
