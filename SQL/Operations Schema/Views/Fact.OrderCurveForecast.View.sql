USE [Operations]
GO
/****** Object:  View [Fact].[OrderCurveForecast]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Fact].[OrderCurveForecast] AS
WITH Rolling14 AS (
	SELECT 
		  --CASE WHEN ORDER_DATE > DATEADD(DAY,-30,GETDATE()) OR FLOW_STATUS_CODE <> 'CLOSED' THEN i.[ORD_HEADER_ID] ELSE 0 END AS ORDER_NUM
		  --,CASE WHEN ORDER_DATE > DATEADD(DAY,-30,GETDATE()) OR FLOW_STATUS_CODE <> 'CLOSED' THEN i.[ORD_LINE_ID] ELSE 0 END AS ORDER_LINE
		   1 AS SaleTypeID --1 meaning open/written side
		  ,1 AS RevenueID --LIST || AAA Sales
		  ,ISNULL(c.CustomerID,0) AS CustomerID
		  ,ISNULL(g.GeographyID,0) AS GeographyID
		  ,ISNULL(p.ProductID,0) AS ProductID
		  ,ISNULL(l.LocationID,0) AS LocationID
		  ,ISNULL(dc.DemandClassID,0) AS DemandClassID
		  ,MAX(ISNULL(cf.DateID,0)) AS DateID
		  ,DATEPART(HOUR,ORDER_DATE) AS HourID
		  ,SUM([LIST_DOLLARS]) AS ACCTD_USD
		  ,SUM([QTY]) AS QTY
	FROM Oracle.Orders i
		LEFT JOIN dbo.DimCustomerMaster c ON i.Customer_NUM = c.CustomerKey 
		LEFT JOIN dbo.DimProductMaster p ON i.PART = p.ProductKey
		LEFT JOIN dbo.DimLocation l ON i.PLANT = l.LocationKey
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(i.ORDER_DATE AS DATE) = cf.DateKey
		LEFT JOIN Dim.[Geography] g ON UPPER(ISNULL(CASE WHEN i.[SHIP_TO_POSTAL_CODE] LIKE '%-%' OR LEN(i.[SHIP_TO_POSTAL_CODE]) >= 9 THEN LEFT(i.[SHIP_TO_POSTAL_CODE],5) ELSE i.[SHIP_TO_POSTAL_CODE] END,'MISSING')) = g.PostalCode
			AND UPPER(ISNULL(i.[SHIP_TO_COUNTRY],'MISSING')) = g.COuntry
		LEFT JOIN dbo.DimDemandClass dc ON i.DEMAND_CLASS = dc.DemandClassKey
		--LEFT JOIN Fact.LastCost lc ON i.PART = lc.SKU AND ISNULL(i.DEMAND_CLASS,'') = ISNULL(lc.DEMAND_CLASS,'')
	WHERE i.CurrentRecord = 1 AND cf.DateKey >= DATEADD(DAY,-14,CAST(GETDATE() AS DATE)) AND cf.DateKey < CAST(GETDATE() AS DATE)
	GROUP BY 
		  -- CASE WHEN ORDER_DATE > DATEADD(DAY,-30,GETDATE()) OR FLOW_STATUS_CODE <> 'CLOSED' THEN i.[ORD_HEADER_ID] ELSE 0 END
		  --,CASE WHEN ORDER_DATE > DATEADD(DAY,-30,GETDATE()) OR FLOW_STATUS_CODE <> 'CLOSED' THEN i.[ORD_LINE_ID] ELSE 0 END
		   ISNULL(c.CustomerID,0)
		  ,ISNULL(g.GeographyID,0)
		  ,ISNULL(p.ProductID,0)
		  ,ISNULL(l.LocationID,0)
		  ,ISNULL(dc.DemandClassID,0)
		  ,ISNULL(cf.DateID,0)
		  ,DATEPART(HOUR,ORDER_DATE)
)
,ByHour AS ( --tracks the last 14 days of sales by hour
	SELECT 
		   dc.DemandClassID --ISNULL(dc.DemandClassID,0) 
		   ,cf.DateID
		  ,DATEPART(HOUR,ORDER_DATE) AS HourID
		  ,SUM([LIST_DOLLARS])/14 AS ACCTD_USD
	FROM Oracle.Orders i
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(i.ORDER_DATE AS DATE) = cf.DateKey 
		LEFT JOIN dbo.DimDemandClass dc ON i.DEMAND_CLASS = dc.DemandClassKey
	WHERE i.CurrentRecord = 1 AND cf.DateKey >= DATEADD(DAY,-14,CAST(GETDATE() AS DATE)) AND cf.DateKey < CAST(GETDATE() AS DATE)
	GROUP BY dc.DemandClassID 
		  ,DATEPART(HOUR,ORDER_DATE)
		  ,cf.DateID
)
, Today AS (
	SELECT 
		   dc.DemandClassID --ISNULL(dc.DemandClassID,0) 
		  ,DATEPART(HOUR,ORDER_DATE) AS HourID
		  ,SUM([LIST_DOLLARS]) AS ACCTD_USD
	FROM Oracle.Orders i
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(i.ORDER_DATE AS DATE) = cf.DateKey 
		LEFT JOIN dbo.DimDemandClass dc ON i.DEMAND_CLASS = dc.DemandClassKey
	WHERE i.CurrentRecord = 1 AND cf.DateKey = CAST(GETDATE() AS DATE)
	GROUP BY dc.DemandClassID 
		  ,DATEPART(HOUR,ORDER_DATE)
)
, Percentage AS (
	SELECT t.DemandClassID, CASE WHEN SUM(ISNULL(bh.ACCTD_USD,t.ACCTD_USD)) <> 0 THEN SUM(t.ACCTD_USD)/SUM(ISNULL(bh.ACCTD_USD,t.ACCTD_USD)) ELSE 0 END AS SalesPercent
	FROM Today t
		LEFT JOIN ByHour bh ON t.DemandClassID = bh.DemandClassID AND t.HourID = bh.HourID
	GROUP BY t.DemandClassID
)
	SELECT 
		  r.SaleTypeID
		, r.RevenueID
		, r.CustomerID
		, r.GeographyID
		, r.ProductID
		, r.LocationID
		, r.DemandClassID
		, cf.DateID
		, r.HourID
		, (r.ACCTD_USD/14) * ISNULL(CASE WHEN SalesPercent > 1 THEN 1 WHEN dc.DemandClassKey IN ('WEBWH', 'A03898', 'W04904') THEN 0 ELSE SalesPercent END ,1) AS DerivedSales --do not estimate warehouse accounts
		, (r.Qty/14) * ISNULL(CASE WHEN SalesPercent > 1 THEN 1 WHEN dc.DemandClassKey IN ('WEBWH', 'A03898', 'W04904') THEN 0 ELSE SalesPercent END,1) AS DerivedQty
	FROM Rolling14 r
		LEFT JOIN Percentage p ON r.DemandClassID = p.DemandClassID
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(GETDATE() AS DATE) = cf.DateKey
		LEFT JOIN dbo.DimDemandClass dc ON r.DemandClassID = dc.DemandClassID
	WHERE r.HourID > DATEPART(HOUR,GETDATE()) 
	
GO
