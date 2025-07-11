USE [Operations]
GO
/****** Object:  View [Fact].[Freight]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[Freight] AS
WITH Data AS (
	SELECT [6 Dig] AS [SKU] ,[Year]*100+1 AS Period ,[1] AS Freight, [Type] FROM xref.FreightBySKU WHERE [1] IS NOT NULL UNION
	SELECT [6 Dig] AS [SKU] ,[Year]*100+2 AS Period ,[2] AS Freight, [Type] FROM xref.FreightBySKU WHERE [2] IS NOT NULL UNION
	SELECT [6 Dig] AS [SKU] ,[Year]*100+3 AS Period ,[3] AS Freight, [Type] FROM xref.FreightBySKU WHERE [3] IS NOT NULL UNION
	SELECT [6 Dig] AS [SKU] ,[Year]*100+4 AS Period ,[4] AS Freight, [Type] FROM xref.FreightBySKU WHERE [4] IS NOT NULL UNION
	SELECT [6 Dig] AS [SKU] ,[Year]*100+5 AS Period ,[5] AS Freight, [Type] FROM xref.FreightBySKU WHERE [5] IS NOT NULL UNION
	SELECT [6 Dig] AS [SKU] ,[Year]*100+6 AS Period ,[6] AS Freight, [Type] FROM xref.FreightBySKU WHERE [6] IS NOT NULL UNION
	SELECT [6 Dig] AS [SKU] ,[Year]*100+7 AS Period ,[7] AS Freight, [Type] FROM xref.FreightBySKU WHERE [7] IS NOT NULL UNION
	SELECT [6 Dig] AS [SKU] ,[Year]*100+8 AS Period ,[8] AS Freight, [Type] FROM xref.FreightBySKU WHERE [8] IS NOT NULL UNION
	SELECT [6 Dig] AS [SKU] ,[Year]*100+9 AS Period ,[9] AS Freight, [Type] FROM xref.FreightBySKU WHERE [9] IS NOT NULL UNION
	SELECT [6 Dig] AS [SKU] ,[Year]*100+10 AS Period ,[10] AS Freight, [Type] FROM xref.FreightBySKU WHERE [10] IS NOT NULL UNION 
	SELECT [6 Dig] AS [SKU] ,[Year]*100+11 AS Period ,[11] AS Freight, [Type] FROM xref.FreightBySKU WHERE [11] IS NOT NULL UNION
	SELECT [6 Dig] AS [SKU] ,[Year]*100+12 AS Period ,[12] AS Freight, [Type] FROM xref.FreightBySKU WHERE [12] IS NOT NULL 
)
, LastPeriod AS (
	SELECT MAX([Period]) AS Period FROM Data
)
--SELECT p.ProductID, p.[Category], cf.[Month Sort], Freight, Type 
--FROM Data d
--	LEFT JOIN dbo.DimProductMaster p ON LTRIM(RTRIM(d.[SKU])) = p.[ProductKey]
--	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.[Month Sort] > d.[Period]  AND cf.Year <= YEAR(GETDATE())
--	INNER JOIN LastPeriod lp ON lp.[Period] = d.[Period]
--WHERE Freight <> 0
--GROUP BY p.ProductID, p.[Category], cf.[Month Sort], d.[SKU], Freight, Type
--UNION
SELECT p.ProductID, p.[Category], [Month Sort], Freight, Type 
FROM Data d
	LEFT JOIN dbo.DimProductMaster p ON LTRIM(RTRIM(d.[SKU])) = p.[ProductKey]
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.[Month Sort] = d.[Period]
GROUP BY p.ProductID, p.[Category], [Month Sort], d.[SKU], Freight, Type
GO
