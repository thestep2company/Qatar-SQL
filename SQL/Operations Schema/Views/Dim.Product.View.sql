USE [Operations]
GO
/****** Object:  View [Dim].[Product]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Dim].[Product] AS
WITH ProdData AS (
	SELECT DISTINCT
		 [Part_Number] AS ProductKey
		,MAX([Part_Description]) AS ProductName
		,[Part_Number] + ': ' + MAX([Part_Description]) AS ProductDesc
		,RIGHT('0000000000'+[Part_Number],10) AS ProductSort
	FROM [Manufacturing].[Production]
	WHERE CurrentRecord = 1
	GROUP BY [Part_Number]
)
, ScrapData AS (
	SELECT DISTINCT
		 [COMP_ITEM] AS ProductKey
		,MAX([ROTO_DESCRIPTION]) AS ProductName
		,[COMP_ITEM] + ': ' + MAX([ROTO_DESCRIPTION]) AS ProductDesc
		,RIGHT('0000000000'+[COMP_ITEM],10) AS ProductSort
	FROM [Manufacturing].[Scrap] s
		LEFT JOIN [Manufacturing].[Production] p ON s.[COMP_ITEM] = p.[Part_Number]
	WHERE p.[Part_Number] IS NULL AND s.CurrentRecord = 1
	GROUP BY [COMP_ITEM]
)
,[Data] AS 
(
	SELECT 
		 ProductKey
		,ProductName
		,ProductDesc
		,ProductSort
	FROM ProdData
	UNION
	SELECT 
		 ProductKey
		,ProductName
		,ProductDesc
		,ProductSort
	FROM ScrapData
)
SELECT 
	DENSE_RANK() OVER (ORDER BY [ProductKey], [ProductName]) AS ProductID
	,ProductKey
	,ProductName
	,ProductDesc
	,ProductSort	
FROM Data
GO
