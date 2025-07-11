USE [Operations]
GO
/****** Object:  View [Dim].[StandardFactor]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[StandardFactor] AS 
	SELECT '190' AS MachineSize, 31.0/36.0 AS StandardFactor, 36.0 AS RoundsPerShift
	UNION
	SELECT '220' AS MachineSize, 24.0/30.0 AS StandardFactor, 30.0 AS RoundsPerShift
	UNION
	SELECT '260' AS MachineSize, 24.0/30.0 AS StandardFactor, 30.0 AS RoundsPerShift
	UNION
	SELECT '280' AS MachineSize, 24.0/30.0 AS StandardFactor, 30.0 AS RoundsPerShift
GO
