USE [Operations]
GO
/****** Object:  View [Fact].[OverheadLive]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Fact].[OverheadLive] AS
SELECT l.LocationID	
	, l.GLLocationID
	, b.Account AS AccountID
	,'10.0' + CAST(l.GLLocationID AS VARCHAR(3)) + '.000.' + b.Account + '.00.000.000' AS AccountCombo
	--, b.Budget 
	--, CAST(LEFT(cf.[Week Sort],4) AS INT) AS Year
	--, CAST(RIGHT(cf.[Month Sort],2) AS INT) AS Month
	--, CAST(RIGHT(cf.[Week Sort],2) AS INT) AS Week
	, cf.DateID
	--, pf.[Percent]
	, 0 AS Actual
	, b.Budget/CASE WHEN CAST(RIGHT(cf.[Month Sort],2) AS INT) IN (3,6,9,12) THEN 5 ELSE 4 END *pf.[Percent] AS Budget
	--, COUNT(DISTINCT CAST(RIGHT(cf.[Week Sort],2) AS INT)) OVER (PARTITION BY CAST(RIGHT(cf.[Month Sort],2) AS INT))
FROM Manufacturing.OverheadBudget b
	LEFT JOIN dbo.DimCalendarFiscal cf ON YEAR(b.Month)*100+MONTH(b.Month) = cf.[Month Sort]
	LEFT JOIN xref.ProductionForecast pf ON pf.Org = b.Plant AND cf.DateKey = pf.Date
	LEFT JOIN dbo.DimLocation l ON b.Plant = l.LocationKey
WHERE DateKey  >=
			(
		SELECT MIN(DateKey) AS DateKey
			FROM Dim.M2MTimeSeries m2m
			LEFT JOIN Dim.TimeSeries ts ON m2m.TimeSeriesID = ts.TimeSeriesID
			LEFT JOIN dbo.DimCalendarFiscal cf ON m2m.DateID = cf.DateID
		WHERE ts.TimeSeriesKey = 'T4W'
		)
UNION 
SELECT DISTINCT l.LocationID, l.GLLocationID, b.Account AS AccountID, '10.0' + CAST(l.GLLocationID AS VARCHAR(3)) + '.000.' + b.Account + '.00.000.000' AS AccountCombo, cf.DateID, tb.Actual, 0 AS Budget
FROM Manufacturing.OverheadBudget b 
	LEFT JOIN dbo.DimLocation l ON b.Plant = l.LocationKey
	LEFT JOIN fact.TrialBalance tb ON b.Account = tb.Account AND l.GLLocationID = tb.Location
	LEFT JOIN dbo.DimCalendarFiscal cf ON tb.TransDate = cf.DateKey 
WHERE DateKey  >=
			(
		SELECT MIN(DateKey) AS DateKey
			FROM Dim.M2MTimeSeries m2m
			LEFT JOIN Dim.TimeSeries ts ON m2m.TimeSeriesID = ts.TimeSeriesID
			LEFT JOIN dbo.DimCalendarFiscal cf ON m2m.DateID = cf.DateID
		WHERE ts.TimeSeriesKey = 'T4W'
		)
	AND JournalEntry = 0
GO
