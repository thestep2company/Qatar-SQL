USE [Operations]
GO
/****** Object:  View [Diff].[Invoice]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Diff].[Invoice] AS
WITH LastBatch AS (
	SELECT MAX(StartDate) AS LastBatch 
	FROM Oracle.Invoice 
)
SELECT 
	  -- i.[ID]
	   ISNULL([ORDER_NUM],0) AS ORDER_NUM
      ,ISNULL([SO_LINE_NUM],0) AS ORDER_LINE
      ,ISNULL(r.RevenueID,0) AS RevenueID
	  ,ISNULL(c.CustomerID,0) AS CustomerID
	  ,ISNULL(g.GeographyID,0) AS GeographyID
	  ,ISNULL(p.ProductID,0) AS ProductID
	  ,ISNULL(l.LocationID,0) AS LocationID
	  ,ISNULL(dc.DemandClassID,0) AS DemandClassID
	  ,ISNULL(cf.DateID,0) AS DateID
	  ,SUM([ACCTD_USD]) AS ACCTD_USD
	  ,SUM([ENTERED_AMOUNT]) AS ENTERED_AMOUNT
	  ,SUM([ITEM_FROZEN_COST]) AS ITEM_FROZEN_COST
	  ,SUM(ISNULL([COGS_AMOUNT],0)) AS COGS_AMOUNT
	  ,SUM([QTY_INVOICED]) AS QTY_INVOICED
FROM Oracle.Invoice i
	INNER JOIN LastBatch lb ON i.StartDate = lb.LastBatch	
	LEFT JOIN dbo.DimCustomerMaster c ON i.ACCT_NUM = c.CustomerKey 
	LEFT JOIN Dim.RevenueType r ON i.REVENUE_TYPE = r.RevenueKey
	LEFT JOIN dbo.DimProductMaster p ON i.SKU = p.ProductKey
	LEFT JOIN dbo.DimLocation l ON i.WH_CODE = l.LocationKey
	LEFT JOIN dbo.DimCalendarFiscal cf ON i.GL_DATE = cf.DateKey
	LEFT JOIN Dim.[Geography] g ON UPPER(ISNULL(CASE WHEN i.[SHIP_TO_POSTAL_CODE] LIKE '%-%' OR LEN(i.[SHIP_TO_POSTAL_CODE]) >= 9 THEN LEFT(i.[SHIP_TO_POSTAL_CODE],5) ELSE i.[SHIP_TO_POSTAL_CODE] END,'MISSING')) = g.PostalCode
		AND UPPER(ISNULL(i.[SHIP_TO_COUNTRY],'MISSING')) = g.COuntry
	LEFT JOIN dbo.DimDemandClass dc ON i.DEM_CLASS = dc.DemandClassKey
WHERE i.CurrentRecord = 1 AND cf.DateID >= 43100
GROUP BY 
	   ISNULL([ORDER_NUM],0)
      ,ISNULL([SO_LINE_NUM],0)
      ,ISNULL(r.RevenueID,0)
	  ,ISNULL(c.CustomerID,0)
	  ,ISNULL(g.GeographyID,0)
	  ,ISNULL(p.ProductID,0)
	  ,ISNULL(l.LocationID,0)
	  ,ISNULL(dc.DemandClassID,0)
	  ,ISNULL(cf.DateID,0)

GO
