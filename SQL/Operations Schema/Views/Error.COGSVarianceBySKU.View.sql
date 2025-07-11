USE [Operations]
GO
/****** Object:  View [Error].[COGSVarianceBySKU]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[COGSVarianceBySKU] AS 
Select COGS - (MaterialCost + MaterialOHCost + ResourceCost + OutsideProcessingCost + OverheadCost) AS COGSVariance
	, pm.ProductKey
	, s.* 
FROM dbo.FactPBISales s
	LEFT JOIN dbo.DimProductMaster pm ON s.ProductID = pm.ProductID
WHERE ABS(COGS - (MaterialCost + MaterialOHCost + ResourceCost + OutsideProcessingCost + OverheadCost)) > .25
	AND DateKey >= '2021-11-11'
	AND AR_TYPE NOT LIKE '%memo%'
	AND [Part Type] = 'FINISHED GOODS'
--ORDER BY ProductKey
GO
