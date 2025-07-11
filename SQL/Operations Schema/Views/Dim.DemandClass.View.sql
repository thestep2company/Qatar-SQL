USE [Operations]
GO
/****** Object:  View [Dim].[DemandClass]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Dim].[DemandClass] AS
WITH DemandClass AS (
	SELECT DISTINCT DEMAND_CLASS FROM Oracle.Orders WHERE DEMAND_CLASS IS NOT NULL AND DEMAND_CLASS <> 'Missing' AND CurrentRecord = 1
	UNION
	SELECT DISTINCT DEM_CLASS FROM Oracle.Invoice WHERE DEM_CLASS IS NOT NULL AND DEM_CLASS <> 'Missing' AND CurrentRecord = 1
	UNION 
	--SELECT DISTINCT [Demand Class] FROM xref.SalesForecast WHERE [Demand Class] IS NOT NULL
	--UNION
	SELECT DISTINCT [Demand Class Code] FROM xref.DemandClass
	UNION
	SELECT DISTINCT [Demand_Class] FROM Oracle.MSC_ORDERS_V WHERE [Demand_Class] IS NOT NULL
)
SELECT 0 AS DemandClassID
	, 'Missing' AS DemandClassKey
	, 'Missing' AS DemandClassName
	, 'Missing' AS DemandClassDesc
	, 'Missing' AS [Customer Rank]
	, 'Missing' AS [Customer Summary]
	, 'Missing' AS [Finance Reporting Channel]
	, 'Missing' AS [Customer Top Level] 	
	, 'Missing' AS [Ecommerce Type]
	, 'Missing' AS [Territory]
	, 'Missing' AS [Channel Code]
	, 'Missing' AS [Distribution Reporting Channel]
	, 'Missing' AS [Selling Method] 
	, 'Missing' AS [Drop Ship/Other]
	, 'Missing' AS [Parent Customer]
	, 'Missing' AS [International/Domestic/ CAD]
	, 'Missing' AS [Distribution Method]
	, 0 AS CreateCustomerRecord
UNION
SELECT ROW_NUMBER() OVER (ORDER BY dc.DEMAND_CLASS) AS DemandClassID
	, dc.DEMAND_CLASS AS DemandClassKey
	, ISNULL([DEMAND CLASS NAME], 'Missing') AS DemandClassName
	, dc.DEMAND_CLASS + ': ' + ISNULL([CUSTOMER - Demand Class], 'Missing') AS DemandClassDesc
	, ISNULL([Customer Rank], 'Missing') AS [Customer Rank]
	, ISNULL([Customer Summary], 'Missing') AS [Customer Summary]
	, ISNULL([Finance Reporting Channel], 'Missing') AS [Finance Reporting Channel]
	, ISNULL([Customer Top Level], 'Missing') AS [Customer Top Level]
	, ISNULL([Ecommerce Type], 'Missing') AS [Ecommerce Type]
	, ISNULL([Territory], 'Missing') AS [Territory]
	, ISNULL([Channel Code], 'Missing') AS [Channel Code]
	, ISNULL([Distribution Reporting Channel], 'Missing') AS [Distribution Reporting Channel]
	, ISNULL([Selling Method], 'Missing') AS [Selling Method]  
	, ISNULL([Drop Ship/Other], 'Missing') AS [Drop Ship/Other]
	, ISNULL([Parent Customer], 'Missing') AS [Parent Customer]
	, ISNULL([International/Domestic/ CAD], 'Missing') AS [International/Domestic/ CAD]
	, ISNULL([Distribution Method], 'Missing')	AS [Distrubution Method]
	, ISNULL([CreateCustomerRecord], 0) AS [CreateCustomerRecord]
FROM DemandClass dc
	LEFT JOIN xref.DemandClass x ON dc.DEMAND_CLASS = x.[Demand Class Code]
GO
