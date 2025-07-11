USE [Operations]
GO
/****** Object:  View [OUTPUT].[ProductLifecycle]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [OUTPUT].[ProductLifecycle] AS 
SELECT cf.[Month Sort]
	, cf.[Quarter Sort]
	, cf.Year
	, pm.ProductDesc
	, FirstProductionDate
	, AnniversaryDate
	, MaturityDate
	, LastProductionDate
	,CASE WHEN cf.DateKey >= FirstProductionDate AND cf.DateKey < AnniversaryDate THEN 'Intro'
		 WHEN cf.DateKey >= AnniversaryDate AND cf.DateKey < MaturityDate THEN 'Growth'
		 WHEN cf.DateKey >= MaturityDate AND cf.DateKey < LastProductionDate THEN 'Maturity'
		 WHEN pp.ITEM_SEGMENTS IS NOT NULL THEN 'Extension'
		 WHEN cf.DateKey >= LastProductionDate THEN 'Decline'
		 ELSE '?'
	END AS Lifecycle
	,SUM(Sales) AS Sales
	,SUM(QTY) AS Units
FROM Manufacturing.ProductionDates pd
	LEFT JOIN dbo.DimProductMaster pm ON pd.Part_Number = pm.ProductKey
	INNER JOIN dbo.FactPBISales s ON pm.ProductID = s.ProductID
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = s.DateID
	LEFT JOIN (SELECT DISTINCT ITEM_SEGMENTS FROM xref.PlannedProduction WHERE START_OF_WEEK > GETDATE()) pp ON pm.ProductKey = pp.ITEM_SEGMENTS
WHERE cf.Year >= 2019 AND MakeBuy = 'Make'
GROUP BY cf.[Month Sort]
	, cf.[Quarter Sort]
	, cf.Year
	, pm.ProductDesc
	, FirstProductionDate
	, AnniversaryDate
	, MaturityDate
	, LastProductionDate
	,CASE WHEN cf.DateKey >= FirstProductionDate AND cf.DateKey < AnniversaryDate THEN 'Intro'
		 WHEN cf.DateKey >= AnniversaryDate AND cf.DateKey < MaturityDate THEN 'Growth'
		 WHEN cf.DateKey >= MaturityDate AND cf.DateKey < LastProductionDate THEN 'Maturity'
		 WHEN pp.ITEM_SEGMENTS IS NOT NULL THEN 'Extension'
		 WHEN cf.DateKey >= LastProductionDate THEN 'Decline'
		 ELSE '?'
	END
--ORDER BY cf.[Month Sort]
	
GO
