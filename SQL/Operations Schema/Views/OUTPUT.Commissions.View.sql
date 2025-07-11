USE [Operations]
GO
/****** Object:  View [OUTPUT].[Commissions]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [OUTPUT].[Commissions] AS
WITH CurrentPeriod AS (
	SELECT DISTINCT GL_PERIOD FROM Oracle.Invoice i 
	WHERE GL_DATE = (
		SELECT DateKey FROM dbo.DimCalendarFiscal
		WHERE DATEADD(WEEK,-3,CAST(GETDATE() AS DATE)) = DateKey
	)
	)
	   SELECT 
       i.[ACCT_NUM]
      ,i.[ACCT_NAME]
      ,i.[TRX_NUMBER]
	  ,i.[SKU]
	  ,i.[INV_DESCRIPTION]
      ,i.[GL_PERIOD]
      ,i.[PERIOD_YEAR]
      ,i.[GL_DATE]
	  ,i.QTY_INVOICED
      ,i.[ENTERED_AMOUNT]
      ,i.[CURRENCY]
      ,i.[ACCTD_USD]
	  ,c.[Sales Representative]
	  ,e.RESOURCE_NAME
	  ,ISNULL(sg1.Commission,sg2.Commission) AS Commission_Rate
	  ,CASE WHEN  c.[Sales Representative] = 'Mike Lerner' AND (i.SKU = 'Amortization Fee' OR i.SKU = 'ZAMR') THEN 0
			WHEN i.GL_REVENUE_DISTRIBUTION = '10.00.000.2490.00.000.000' THEN 0
			ELSE i.ACCTD_USD*ISNULL(sg1.Commission,sg2.Commission) END AS Commission_Dollars
	  FROM Oracle.Invoice i
	  LEFT JOIN dbo.DimCustomerMaster c ON i.ACCT_NUM = c.CustomerKey 
	  LEFT JOIN Oracle.RA_CUST_TRX_LINE_SALESREPS_ALL r ON i.CUSTOMER_TRX_LINE_ID = r.CUSTOMER_TRX_LINE_ID
	  LEFT JOIN Oracle.JTF_RS_SALESREPS s ON r.SALESREP_ID = s.SALESREP_ID
	  LEFT JOIN Oracle.JTF_RS_RESOURCE_EXTNS_VL e ON s.RESOURCE_ID = e.RESOURCE_ID
	  LEFT JOIN xref.SalesGridByCustomer sg1 ON i.ACCT_NUM = CAST(sg1.[Account Number] AS VARCHAR(30)) AND i.PERIOD_YEAR = sg1.Year AND i.PERIOD_NUM = sg1.Month --match on a year + month for the customer grid  --AND i.DEM_CLASS = sg1.[Demand Class Code] 
	  LEFT JOIN xref.SalesGridByCustomer sg2 ON i.ACCT_NUM = CAST(sg2.[Account Number] AS VARCHAR(30)) AND i.PERIOD_YEAR = sg2.Year AND sg1.[Account Number] IS NULL AND sg2.Month IS NULL  --else use the NULL month for the customer grid  --AND i.DEM_CLASS = sg1.[Demand Class Code] 
	  WHERE i.CurrentRecord = 1 
	  AND i.[REVENUE_TYPE] NOT LIKE '%%ZTAX%%'
	  AND i.[REVENUE_TYPE] <> 'SHIPHANDLING'
	  AND i.[REVENUE_TYPE] <> 'TPI'
	  AND i.GL_PERIOD = (SELECT GL_PERIOD FROM CurrentPeriod)

GO
