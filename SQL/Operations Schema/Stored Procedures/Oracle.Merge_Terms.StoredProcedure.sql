USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Terms]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Terms] AS BEGIN
	CREATE TABLE #Terms (Term_ID INT, NAME VARCHAR(50), DESCRIPTION VARCHAR(250))

	INSERT INTO #Terms (Term_ID, Name, Description)
	SELECT * FROM OPENQUERY(PROD,'SELECT TERM_ID, NAME, DESCRIPTION FROM ra_terms term')

	UPDATE t
	SET t.Name = s.Name
		,t.Description = s.Description
	FROM #Terms s
		LEFT JOIN Oracle.Terms t ON s.Term_ID = t.Term_ID
	WHERE s.Name <> t.Name
		OR s.DESCRIPTION <> t.DESCRIPTION


	INSERT INTO Oracle.Terms (Term_ID, Name, Description)
	SELECT s.TERM_ID, s.Name, s.Description
	FROM #Terms s
		LEFT JOIN Oracle.Terms t ON s.Term_ID = t.Term_ID
	WHERE t.Term_ID IS NULL

END
GO
