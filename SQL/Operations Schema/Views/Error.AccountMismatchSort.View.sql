USE [Operations]
GO
/****** Object:  View [Error].[AccountMismatchSort]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[AccountMismatchSort] AS 

	SELECT Level1, MIN(Level1Sort) AS FirstSort, MAX(Level1Sort) AS LastSort FROM Dim.Account GROUP BY Level1 HAVING MIN(Level1Sort) <> MAX(Level1Sort) UNION
	SELECT Level2, MIN(Level2Sort), MAX(Level2Sort) FROM xref.Account GROUP BY Level2 HAVING MIN(Level2Sort) <> MAX(Level2Sort) UNION
	SELECT Level3, MIN(Level3Sort), MAX(Level3Sort) FROM xref.Account GROUP BY Level3 HAVING MIN(Level3Sort) <> MAX(Level3Sort) UNION
	SELECT Level4, MIN(Level4Sort), MAX(Level4Sort) FROM xref.Account GROUP BY Level4 HAVING MIN(Level4Sort) <> MAX(Level4Sort)


GO
