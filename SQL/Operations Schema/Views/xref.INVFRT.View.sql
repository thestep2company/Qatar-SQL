USE [Operations]
GO
/****** Object:  View [xref].[INVFRT]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [xref].[INVFRT] AS 
WITH INVFRT AS (
	SELECT cm.DEMAND_CLASS_CODE, CustomerKey, CustomerName
		, SUM(ISNULL(CASE WHEN RevenueID = 5 THEN Sales END,0)) AS InvoicedFreight
		, SUM(ISNULL(CASE WHEN RevenueID <> 5 THEN Sales END,0)) AS Sales
		, CASE  WHEN SUM(ISNULL(CASE WHEN RevenueID <> 5 THEN Sales END,0)) <> 0 
				THEN SUM(ISNULL(CASE WHEN RevenueID = 5 THEN Sales ELSE 0 END,0))/SUM(ISNULL(CASE WHEN RevenueID <> 5 THEN Sales END,0)) 
		  END AS InvoiceFreightPercentage 
	FROM dbo.FactPBISales pbi
		LEFT JOIN dbo.DimCalendarFiscal cf ON pbi.DateID = cf.DateID
		LEFT JOIN dbo.DimCustomerMaster cm ON pbi.CustomerID = cm.CustomerID
	WHERE cf.Year = 2022
	GROUP BY cm.DEMAND_CLASS_CODE, CustomerKey, CustomerName
)
SELECT sgc.* 
	,INVFRT.[DEMAND_CLASS_CODE]
	,INVFRT.CustomerKey
	,INVFRT.[CustomerName]
	,invfrt.InvoicedFreight AS InvoicedFreightLY
	,invfrt.Sales AS SalesLY
	,invfrt.InvoiceFreightPercentage AS InvoicedFreightPercentageLY
	,ISNULL(invfrt.InvoiceFreightPercentage,0) - sgc.[Invoiced Freight] AS DifferenceActualToGrid
FROM xref.[SalesGridByCustomer] sgc
	FULL OUTER JOIN INVFRT ON sgc.[Account Number] = INVFRT.[CustomerKey]
WHERE ISNULL(sgc.[Invoiced Freight],0) <> 0 OR ISNULL(invfrt.[InvoiceFreightPercentage],0) <> 0
--ORDER BY SalesLY DESC
GO
