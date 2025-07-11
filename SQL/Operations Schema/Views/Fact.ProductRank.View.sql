USE [Operations]
GO
/****** Object:  View [Fact].[ProductRank]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Fact].[ProductRank] AS 
WITH CTE AS (
	SELECT pm.ProductID
		,[Finance Reporting Channel]
		,pm.MakeBuy
		--, cf.[Month Sort]
		--, cf.DateKey
		,SUM(s.Cost) AS COGS
	FROM dbo.FactPlannedSalesFWOS s
		LEFT JOIN dbo.DimProductMaster pm ON s.ProductID = pm.ProductID 
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = s.ProductionDateID
		LEFT JOIN dbo.DimDemandClass dc On dc.DemandClassID = s.DemandClassID
		LEFT JOIN dbo.M2MTimeSeries m2m on m2m.DateID = cf.DateID
		LEFT JOIN dbo.DimTimeSeries ts ON ts.TimeSeriesID = m2m.TimeSeriesID
	WHERE s.ForecastID = 0  
		AND ts.TimeSeriesKey = 'N26W'
		AND dc.[Finance Reporting Channel] = 'E-COMMERCE'
		AND pm.[Part Type] = 'FINISHED GOODS'
	GROUP BY pm.ProductID
		, [Finance Reporting Channel]
		, MakeBuy
	--, cf.[Month Sort], cf.DateKey
	--ORDER BY pm.ProductKey--, cf.[Month Sort], cf.DateKey

)
, Rank AS (
	SELECT *
		, COGS/(SELECT SUM(COGS) FROM CTE) AS PercentOfSales 
		, ROW_NUMBER() OVER (ORDER BY COGS ASC) AS RankOfSales
	FROM CTE 
	--ORDER BY COGS ASC
)
, Roll AS (
	SELECT *
		, SUM(PercentOfSales) OVER(ORDER BY RankOfSales ASC) AS SalesPercentile
	FROM Rank
)
SELECT ProductID, COGS, RankOfSales, [Finance Reporting Channel]
	, CASE  WHEN SalesPercentile < .2 THEN 'A'
			WHEN SalesPercentile < .4 THEN 'B'
			WHEN SalesPercentile < .6 THEN 'C'
			WHEN SalesPercentile < .8 THEN 'D'
			--WHEN RankOfSales/MAX(RankOfSales*1.0) OVER (PARTITION BY [Finance Reporting Channel]) < .2 THEN 'A'  
			--WHEN RankOfSales/MAX(RankOfSales*1.0) OVER (PARTITION BY [Finance Reporting Channel]) < .4 THEN 'B'  
			--WHEN RankOfSales/MAX(RankOfSales*1.0) OVER (PARTITION BY [Finance Reporting Channel]) < .6 THEN 'C'  
			--WHEN RankOfSales/MAX(RankOfSales*1.0) OVER (PARTITION BY [Finance Reporting Channel]) < .8 THEN 'D'  
			ELSE 'F'
	END AS SalesGrade

FROM Roll
--ORDER BY COGS ASC
GO
