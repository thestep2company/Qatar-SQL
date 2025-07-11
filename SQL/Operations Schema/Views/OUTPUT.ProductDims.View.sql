USE [Operations]
GO
/****** Object:  View [OUTPUT].[ProductDims]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[ProductDims] AS
WITH Dims AS (
	SELECT ID, ProductKey, Height, Width, Depth, Width*Depth AS Footprint, Height*Width*Depth AS Cube FROM xref.ProductDims
)
, Ranking AS (
	SELECT dims.*, pm.ProductName, pm.Category 
		,DENSE_RANK() OVER (PARTITION BY Category ORDER BY dims.Footprint ASC) AS FootprintRank
		,PERCENT_RANK() OVER (PARTITION BY Category ORDER BY dims.Footprint ASC) AS FootprintPercentile
	FROM Dims 
		LEFT JOIN dbo.DimProductMaster pm ON dims.ProductKey = pm.ProductKey
)
SELECT *
	,CASE WHEN FootprintPercentile >= 0 AND FootprintPercentile < .20 THEN 'XS'
		WHEN FootprintPercentile >= .20 AND FootprintPercentile < .40 THEN 'S'
		WHEN FootprintPercentile >= .40 AND FootprintPercentile < .60 THEN 'M'
		WHEN FootprintPercentile >= .60 AND FootprintPercentile < .80 THEN 'L'
		WHEN FootprintPercentile >= .80 AND FootprintPercentile <= 100 THEN 'XL'
	END AS Size
FROM Ranking
--ORDER BY Category, FootprintPercentile
GO
