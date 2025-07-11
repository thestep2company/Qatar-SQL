USE [Operations]
GO
/****** Object:  View [Fact].[MachineCapacity]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




  CREATE VIEW [Fact].[MachineCapacity] AS 
  WITH Dates AS (
	SELECT DateID - 28 AS DateIDStart, DateID - 1 AS DateIDEnd FROM dbo.DimCalendarFiscal WHERE [Day of Week Sort] = 1 AND DateKey >= DATEADD(YEAR,-1,GETDATE()) AND DateKey  < GETDATE()
  )
  , Data AS (
	  SELECT cf.DateID + 1 AS DateID, mc.LocationID * 1000 + mc.MachineSize AS MachineID, mc.LocationID, mc.Capacity, SUM(ISNULL(p.[Total Machine Hours],0))/4 AS RunRate
	  FROM Dim.MachineCapacity mc
		CROSS JOIN Dates d
		LEFT JOIN dbo.DimCalendarFiscal cf ON d.DateIDEnd = cf.DateID 
		LEFT JOIN dbo.DimMachine m ON mc.MachineSize = m.MachineModel
		LEFT JOIN dbo.DimLocation l ON mc.LocationID = l.LocationID
		LEFT JOIN dbo.FactProduction p ON p.PlantID = l.LocationID AND p.MachineID = m.MachineID AND p.DateID BETWEEN d.DateIDStart AND d.DateIDEnd AND p.ShiftOffsetID = 1 
		LEFT JOIN dbo.DimProductMaster pm ON p.ProductID = pm.ProductID
	  WHERE l.LocationCountry = 'US' AND pm.[Step2 Custom] <> 'Step2 Custom'
	  GROUP BY cf.DateID, mc.LocationID, mc.MachineSize, mc.Capacity
  )
  , LastDate AS (
	 SELECT DENSE_RANK() OVER(ORDER BY DateID DESC) AS DateRank, * FROM Data
  )
  ,  N13 AS (
	  SELECT cf.DateID FROM dbo.DimTimeSeries ts
		LEFT JOIN dbo.M2MTimeSeries m2m ON ts.TimeSeriesID = m2m.TimeSeriesID
		LEFT JOIN dbo.DimCalendarFiscal cf ON m2m.DateID = cf.DateID 
	  WHERE cf.[Day of Week Sort] = 1 AND ts.TimeSeriesKey  = 'N13W'
  )
  SELECT * FROM Data 
  UNION
  SELECT n13.DateID, MachineID, LocationID, Capacity, RunRate 
  FROM LastDate 
	CROSS JOIN N13
  WHERE DateRank = 1
GO
