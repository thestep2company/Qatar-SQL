USE [Operations]
GO
/****** Object:  View [Dim].[ShiftFactor]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[ShiftFactor] AS 
	SELECT '111' AS LocationKey, 1.0 AS ShiftFactor
	UNION
	SELECT '122' AS LocationKey, 2.0/3.0 AS ShiftFactor
	UNION
	SELECT '133' AS LocationKey, 2.0/3.0 AS ShiftFactor
GO
