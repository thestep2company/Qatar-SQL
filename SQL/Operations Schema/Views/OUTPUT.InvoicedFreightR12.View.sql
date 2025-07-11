USE [Operations]
GO
/****** Object:  View [OUTPUT].[InvoicedFreightR12]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[InvoicedFreightR12] AS
WITH InvoicedFreight AS (
	SELECT [Month Sort], MonthID, CustomerKey, Category, DemandClassKey, SUM(Sales) AS InvoicedFreight
	FROM dbo.FactPBISales s WITH (NOLOCK)
		LEFT JOIN dbo.DimCalendarFiscal cf ON s.DateID = cf.DateID
		LEFT JOIN dbo.DimCustomerMaster cm ON s.CustomerID = cm.CustomerID
		LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassID = s.DemandClassID
		LEFT JOIN dbo.DimProductMaster pm ON pm.ProductID = s.ProductID
	WHERE RevenueID = 5
	GROUP BY [Month Sort], MonthID, CustomerKey, Category, DemandClassKey
)
, Sales AS (
	SELECT [Month Sort], MonthID, CustomerKey, Category, DemandClassKey, SUM(Sales) AS Sales
	FROM dbo.FactPBISales s WITH (NOLOCK)
		LEFT JOIN dbo.DimCalendarFiscal cf ON s.DateID = cf.DateID
		LEFT JOIN dbo.DimCustomerMaster cm ON s.CustomerID = cm.CustomerID
		LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassID = s.DemandClassID
		LEFT JOIN dbo.DimProductMaster pm ON pm.ProductID = s.ProductID
	WHERE RevenueID <> 5
	GROUP BY [Month Sort], MonthID, CustomerKey, Category, DemandClassKey
)
, Combine AS (
	SELECT s.[Month Sort], s.[MonthID], s.CustomerKey, s.Category, s.DemandClassKey, SUM(InvoicedFreight) InvoicedFreight, SUM(Sales) AS Sales
	FROM Sales s
		LEFT JOIN InvoicedFreight i ON s.CustomerKey = i.CustomerKey AND s.DemandClassKey = i.DemandClassKey AND s.[Month Sort] = i.[Month Sort] AND s.[Category] = i.Category
	GROUP BY s.[Month Sort], s.[MonthID], s.CustomerKey, s.Category, s.DemandClassKey
)
--, SalesGridCompare AS (
	SELECT cf.[Month Sort], DemandClassKey, CustomerKey, Category, SUM([InvoicedFreight]) AS InvoicedFreight, SUM([Sales]) AS Sales, CASE WHEN SUM([Sales]) <> 0 THEN SUM([InvoicedFreight])/SUM([Sales]) ELSE 0 END AS [Calculated Invoiced Freight], [Invoiced Freight] AS [Grid Invoiced Freight]
	FROM (SELECT DISTINCT [Month Sort], [MonthID] FROM dbo.DimCalendarFiscal) cf
		LEFT JOIN Combine c ON c.[MonthID] BETWEEN cf.[MonthID] - 12 AND cf.[MonthID] - 1
		LEFT JOIN xref.dbo.[Customer Grid by Account] sg ON sg.[Demand Class Code] = DemandClassKey AND sg.[Account NUmber] = CustomerKey
	WHERE cf.[Month Sort] = (SELECT [Month Sort] FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(GETDATE() AS DATE))
	GROUP BY cf.[Month Sort], CustomerKey, Category, DemandClassKey, [Invoiced Freight]
	--ORDER BY [DemandClassKey], [CustomerKey]
--)
--SELECT * FROM SalesGridCompare sgc
--	LEFT JOIN xref.dbo.[Customer Grid by Account] sg ON sg.[Demand Class Code] = sgc.DemandClassKey AND sg.[Account NUmber] = sgc.CustomerKey
GO
