USE [Operations]
GO
/****** Object:  View [Error].[COGSMonitor]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Error].[COGSMonitor] AS

SELECT 
	  i.GL_PERIOD
	  ,SUM([ITEM_FROZEN_COST]*[QTY_INVOICED]) AS LookupCOGS
	  ,SUM([GLUnitCOGS]*[QTY_INVOICED]) AS GLCogs --v2 = SUM([ITEM_FROZEN_COST]*[QTY_INVOICED]),  v1 = SUM(ISNULL([COGS_AMOUNT],0))
	  ,SUM([ITEM_FROZEN_COST]*[QTY_INVOICED])-SUM([GLUnitCOGS]*[QTY_INVOICED]) AS DollarVaraince
	  ,SUM([ITEM_FROZEN_COST]*[QTY_INVOICED])/SUM([GLUnitCOGS]*[QTY_INVOICED])-1 AS PercentVaraince
FROM Oracle.Invoice i
	LEFT JOIN dbo.DimCustomerMaster c ON i.ACCT_NUM = c.CustomerKey 
	LEFT JOIN Dim.RevenueType r ON i.REVENUE_TYPE = r.RevenueKey
	LEFT JOIN dbo.DimProductMaster p ON i.SKU = p.ProductKey
	LEFT JOIN dbo.DimLocation l ON i.WH_CODE = l.LocationKey
	LEFT JOIN dbo.DimCalendarFiscal cf ON i.GL_DATE = cf.DateKey
	LEFT JOIN Dim.[Geography] g ON UPPER(ISNULL(CASE WHEN i.[SHIP_TO_POSTAL_CODE] LIKE '%-%' OR LEN(i.[SHIP_TO_POSTAL_CODE]) >= 9 THEN LEFT(i.[SHIP_TO_POSTAL_CODE],5) ELSE i.[SHIP_TO_POSTAL_CODE] END,'MISSING')) = g.PostalCode
		AND UPPER(ISNULL(i.[SHIP_TO_COUNTRY],'MISSING')) = g.COuntry
	LEFT JOIN dbo.DimDemandClass dc ON i.DEM_CLASS = dc.DemandClassKey
	LEFT JOIN xref.CM cm ON i.ID = cm.ID
	LEFT JOIN dbo.FactMAPP map ON p.ProductKey = map.SKU AND dc.DemandClassKey = map.DemandClass AND cf.DateKey BETWEEN map.StartDate AND ISNULL(map.EndDate,'9999-12-31')
	LEFT JOIN xref.COGSLookup cogs ON cogs.TRX_NUMBER = i.TRX_NUMBER AND cogs.SKU = i.SKU
WHERE i.CurrentRecord = 1 AND cf.DateID >= (43100 + 366) AND INV_DESCRIPTION NOT LIKE '% PPD %'
	AND cf.DateKey >= '2021-01-01'
GROUP BY i.GL_PERIOD,  cf.[Month Sort]
--HAVING ABS(SUM([ITEM_FROZEN_COST]*[QTY_INVOICED])/SUM([GLUnitCOGS]*[QTY_INVOICED])-1) > .01
--ORDER BY cf.[Month Sort]
GO
