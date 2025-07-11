USE [Operations]
GO
/****** Object:  View [Error].[COGSLookup]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Error].[COGSLookup] AS 
WITH CTE AS (   
	SELECT 'Table' AS Source, cf.[Month Sort], SUM(Sales) AS Sales, SUM(COGS) AS COGS, SUM(QTY) AS Units   
	FROM dbo.FactPBISales pbi    
		LEFT JOIN dbo.DimCalendarFiscal cf ON pbi.DateID = cf.DateID   
	WHERE Year = 2023   GROUP BY cf.[Month Sort]   
	UNION   
	SELECT 'View' AS Source, cf.[Month Sort], SUM(Sales) AS Sales, SUM(COGS) AS COGS, SUM(QTY) AS Units   
	FROM Fact.PBISales pbi    
		LEFT JOIN dbo.DimCalendarFiscal cf ON pbi.DateID = cf.DateID   
	WHERE Year = 2023   GROUP BY cf.[Month Sort]   
	UNION   
	SELECT 'Oracle' AS Source, cf.[Month Sort], SUM(ACCTD_USD) AS Sales, SUM(COGS) AS COGS, SUM(QTY_INVOICED) AS Units   
	FROM Oracle.Invoice pbi    
		LEFT JOIN dbo.DimCalendarFiscal cf ON pbi.GL_Date = cf.DateKey   
	WHERE Year = 2023 AND CurrentRecord = 1 AND REPORTING_REVENUE_TYPE <> 'ZTAX'   
	GROUP BY cf.[Month Sort]  
)  
, Data AS (   
	SELECT *, SUM(COGS) OVER(PARTITION BY [Month Sort])/COUNT(*) OVER(PARTITION BY [Month Sort]) AS CheckSUM   
	FROM CTE   
)   --all sources must match  
SELECT * FROM Data  WHERE CheckSUM <> COGS  
--ORDER BY [Month Sort]
GO
