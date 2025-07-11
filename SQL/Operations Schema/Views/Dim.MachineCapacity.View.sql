USE [Operations]
GO
/****** Object:  View [Dim].[MachineCapacity]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE VIEW [Dim].[MachineCapacity] AS 
  WITH Data AS (
	SELECT '111' AS LocationKey, '110' AS [MachineSize], 168 AS Capacity UNION
	SELECT '111', '190', 1512 UNION
	SELECT '111', '220', 336 UNION
	SELECT '111', '280', 672 UNION
	SELECT '122', '190', 1080 UNION
	SELECT '122', '220', 120 UNION
	SELECT '122', '280', 240
  )
  SELECT l.LocationID *1000 + mc.MachineSize AS MachineID, MachineSize, LocationID, mc.Capacity 
  FROM Data mc
	lEFT JOIN dbo.DimLocation l ON mc.LocationKey = l.LocationKey
GO
