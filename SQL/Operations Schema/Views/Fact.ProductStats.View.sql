USE [Operations]
GO
/****** Object:  View [Fact].[ProductStats]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[ProductStats] AS 
SELECT --TimeSeriesKey, SUM(s.Sales), SUM(s.COGS), SUM(s.Qty)
	 ProductID
	,SUM(CASE WHEN TimeSeriesKey = 'T90' THEN s.COGS END) AS T90Cogs
	,SUM(CASE WHEN TimeSeriesKey = 'PW' THEN s.Qty END) AS PWUnits
	,SUM(CASE WHEN TimeSeriesKey = 'T12M' THEN s.Qty END) AS T12MUnits
FROM dbo.FactPBISales s 
	LEFT JOIN dbo.DimCalendarFiscal cf ON s.DateID = cf.DateID 
	LEFT JOIN dbo.DimM2MTimeSeries m2m ON cf.DateID = m2m.DateID 
	LEFT JOIN dbo.DimTimeSeries ts ON ts.TimeSeriesID = m2m.TimeSeriesID
WHERE ts.TimeSeriesKey IN ('T12M', 'PW', 'T90')
GROUP BY ProductID
GO
