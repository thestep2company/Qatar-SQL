USE [Operations]
GO
/****** Object:  View [Fact].[PBISales]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Fact].[PBISales] AS
SELECT --invoice records
	   i.[ORDER_NUM]
	  ,i.[SO_LINE_NUM] AS ORDER_LINE
	  ,AR_TYPE
	  ,INV_DESCRIPTION
	  ,CUST_PO_NUM
	  ,ISNULL(r.RevenueID,0) AS RevenueID
	  ,SUBSTRING(GL_REVENUE_DISTRIBUTION,11,4) AS AccountID
	  ,ISNULL(c.CustomerID,0) AS CustomerID
	  ,ISNULL(g.GeographyID,0)  AS GeographyID
	  ,ISNULL(p.ProductID,0) AS ProductID
	  ,ISNULL(l.LocationID,0) AS LocationID
	  ,ISNULL(dc.DemandClassID,0) AS DemandClassID
	  ,ISNULL(cf.DateID,0) AS DateID
	  ,CAST(cf.DateKey AS DATETIME) AS DateKey
	  ,CAST(up.UnitPrice*100 AS INT) AS UnitPriceID
	  ,CAST([GLUnitCOGS]*100 AS INT) AS UnitCOGSID
	  ,SUM([ACCTD_USD]) AS Sales
	  ,SUM(CASE WHEN ISNULL([GLUnitCOGS],0) <> 0 THEN [GLUnitCOGS] WHEN AR_TYPE LIKE '%Memo%' THEN 0 ELSE ISNULL(LookupUnitCOGS,0) END*[QTY_INVOICED]) AS COGS
	  ,SUM(CASE WHEN ISNULL([GLUnitMaterial],0) <> 0 THEN [GLUnitMaterial] WHEN AR_TYPE LIKE '%Memo%' THEN 0 ELSE ISNULL(LookupUnitMaterial,0) END*[QTY_INVOICED]) AS MaterialCost
	  ,SUM(CASE WHEN ISNULL([GLUnitMaterialOH],0) <> 0 THEN [GLUnitMaterialOH] WHEN AR_TYPE LIKE '%Memo%' THEN 0 ELSE ISNULL(LookupUnitMaterialOH,0) END*[QTY_INVOICED]) AS MaterialOHCost
	  ,SUM(CASE WHEN ISNULL([GLUnitResourceCost],0) <> 0 THEN [GLUnitResourceCost] WHEN AR_TYPE LIKE '%Memo%' THEN 0 ELSE ISNULL(LookupUnitResourceCost,0) END*[QTY_INVOICED]) AS ResourceCost
	  ,SUM(CASE WHEN ISNULL([GLUnitOutsideProcessing],0) <> 0 THEN [GLUnitOutsideProcessing] WHEN AR_TYPE LIKE '%Memo%' THEN 0 ELSE ISNULL(LookupUnitOutsideProcessing,0) END*[QTY_INVOICED]) AS OutsideProcessingCost
	  ,SUM(CASE WHEN ISNULL([GLUnitOverhead],0) <> 0 THEN [GLUnitOverhead] WHEN AR_TYPE LIKE '%Memo%' THEN 0 ELSE ISNULL(LookupUnitOverhead,0) END*[QTY_INVOICED]) AS OverheadCost
	  ,SUM([QTY_INVOICED]) AS QTY
	  ,0 AS [COOP]
	  ,0 AS [DIF RETURNS]
	  ,0 AS [Invoiced Freight]
	  ,0 AS [Frieght Allowance]
	  ,0 AS [Cash Discounts]
	  ,0 AS [Markdown]
	  ,0 AS [Other]
	  ,0 AS [FREIGHT OUT]
	  ,0 AS [ROYALTY]
	  ,0 AS [SURCHARGE]
	  ,0 AS [COMMISSION]
	  ,t.ID AS TermsID
FROM Oracle.Invoice i
	LEFT JOIN dbo.DimCustomerMaster c ON i.ACCT_NUM = c.CustomerKey 
	LEFT JOIN dbo.DimProductMaster p ON i.SKU = p.ProductKey
	LEFT JOIN dbo.DimLocation l ON i.WH_CODE = l.LocationKey
	LEFT JOIN dbo.DimCalendarFiscal cf ON i.GL_DATE = cf.DateKey
	LEFT JOIN Dim.[Geography] g ON UPPER(ISNULL(CASE WHEN i.[SHIP_TO_POSTAL_CODE] LIKE '%-%' OR LEN(i.[SHIP_TO_POSTAL_CODE]) >= 9 THEN LEFT(i.[SHIP_TO_POSTAL_CODE],5) ELSE i.[SHIP_TO_POSTAL_CODE] END,'MISSING')) = g.PostalCode AND UPPER(ISNULL(i.[SHIP_TO_COUNTRY],'MISSING')) = g.COuntry
	LEFT JOIN dbo.DimDemandClass dc ON ISNULL(i.DEM_CLASS,c.DEMAND_CLASS_CODE) = dc.DemandClassKey
	LEFT JOIN xref.RevenueTypeOverride rt ON i.GL_REVENUE_DISTRIBUTION = rt.AccountCombo
	LEFT JOIN dbo.DimRevenueType r ON CASE WHEN rt.RevenueKey IS NULL THEN i.REVENUE_TYPE ELSE rt.RevenueKey END = r.RevenueKey
	--LEFT JOIN xref.StandardMargin cm ON i.ID = cm.ID
	LEFT JOIN xref.COGSLookup cogs ON cogs.TRX_NUMBER = i.TRX_NUMBER AND cogs.SKU = i.SKU
	LEFT JOIN dbo.FactMAPP map ON p.ProductKey = map.SKU AND dc.DemandClassKey = map.DemandClass AND cf.DateKey BETWEEN map.StartDate AND ISNULL(map.EndDate,'9999-12-31')
	LEFT JOIN dbo.FactUnitPrice up ON i.ORDER_NUM = up.ORDER_NUM AND i.SO_LINE_NUM = up.SO_LINE_NUM AND i.GL_DATE = up.LastGLDate
	LEFT JOIN Oracle.DavinciSales ds ON ds.CUSTOMER_TRX_LINE_ID = i.CUSTOMER_TRX_LINE_ID
	LEFT JOIN Oracle.Terms t ON ds.TERM_ID = t.TERM_ID
WHERE i.CurrentRecord = 1 
	AND Year >= 2014
	AND REPORTING_REVENUE_TYPE <> 'ZTAX'
	--(
	--	(   --Sales
	--		CASE  WHEN r.RevenueKey LIKE 'ZTAX%' THEN 'ZTAX' 
	--			WHEN INV_DESCRIPTION LIKE '%FRT%MBS%' THEN 'FRTMBS' 
	--			WHEN INV_DESCRIPTION LIKE 'S2C DSF%' THEN 'DSF'
	--			WHEN i.SKU = 'ZFRT' AND GL_REVENUE_DISTRIBUTION NOT LIKE '%3300%' THEN 'ZFRT' 
	--			WHEN GL_REVENUE_DISTRIBUTION LIKE '%3300%' THEN 'INVFRT' 
	--			WHEN ACCT_NAME = 'S2C: KOHLS.COM (PREPAID)' AND REVENUE_TYPE ='S2C_ADJ_OTHER' THEN 'PPDFRT'
	--			ELSE r.RevenueKey 
	--		END NOT IN ('ZTAX', 'DSF', 'ZFRT','INVFRT')
	--		AND (i.GL_REVENUE_DISTRIBUTION LIKE '%3000%' OR i.GL_REVENUE_DISTRIBUTION LIKE '%3200%' OR i.GL_REVENUE_DISTRIBUTION LIKE '%3250%')
	--	)
	--	OR 
	--	(   --Invoiced Freight
	--		CASE  WHEN r.RevenueKey LIKE 'ZTAX%' THEN 'ZTAX' 
	--			WHEN INV_DESCRIPTION LIKE '%FRT%MBS%' THEN 'FRTMBS' 
	--			WHEN INV_DESCRIPTION LIKE 'S2C DSF%' THEN 'DSF' 
	--			WHEN i.SKU = 'ZFRT' AND GL_REVENUE_DISTRIBUTION NOT LIKE '%3300%' THEN 'ZFRT' 
	--			WHEN GL_REVENUE_DISTRIBUTION LIKE '%3300%' THEN 'INVFRT' 
	--			WHEN ACCT_NAME = 'S2C: KOHLS.COM (PREPAID)' AND REVENUE_TYPE ='S2C_ADJ_OTHER' THEN 'PPDFRT'
	--			ELSE r.RevenueKey 
	--		END IN ('DSF', 'ZFRT', 'INVFRT')
	--		AND 
	--		i.GL_REVENUE_DISTRIBUTION LIKE '%3300%'
	--	)
	--)
GROUP BY 
       i.[ORDER_NUM]
	  ,i.[SO_LINE_NUM]
	  ,AR_TYPE
	  ,INV_DESCRIPTION
	  ,CUST_PO_NUM
	  ,ISNULL(r.RevenueID,0)
	  ,SUBSTRING(GL_REVENUE_DISTRIBUTION,11,4)
	  ,ISNULL(c.CustomerID,0)
	  ,ISNULL(g.GeographyID,0)
	  ,ISNULL(p.ProductID,0)
	  ,ISNULL(l.LocationID,0)
	  ,ISNULL(dc.DemandClassID,0)
	  ,ISNULL(cf.DateID,0)
	  ,cf.DateKey
	  ,CAST(up.UnitPrice*100 AS INT)
	  ,CAST([GLUnitCOGS]*100 AS INT)
	  ,t.ID

GO
