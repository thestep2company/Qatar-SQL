USE [Operations]
GO
/****** Object:  View [Fact].[GLReconcile]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE VIEW [Fact].[GLReconcile] AS
	SELECT 	CAST(0 AS FLOAT) AS Order_Num
		,CAST(0 AS FLOAT) AS Order_Line
		,CAST(0 AS INT) AS SaleTypeID
		,-3 AS RevenueID
		,0 AS AccountID
		,CAST(0 AS INT) AS CustomerID
		,CAST(0 AS INT) AS GeographyID
		,0 AS ProductID
		,0 AS LocationID
		,0 AS DemandClassID
		,a.DateID AS DateID
		,CAST(0 AS INT) AS HourID
		,ISNULL(a.Sales,0) - ISNULL(b.Sales,0) AS ACCTD_USD
		--,ISNULL(a.Sales,0)-ISNULL(a.JournalEntry,0)-ISNULL(b.Sales,0) AS ACCTD_USD
		,CAST(0 AS MONEY) AS [ENTERED_AMOUNT]
		,CAST(0 AS MONEY) AS [ITEM_FROZEN_COST]
		,CAST(0 AS MONEY) AS [COGS_AMOUNT]
		,CAST(0 AS MONEY) AS [QTY]
		, 0 [COOP]
		, 0 AS [DIF RETURNS]
		, 0 AS [Invoiced Freight]
		, 0 AS [Frieght Allowance]
		, 0 AS [Cash Discounts]
		, 0 AS [Markdown]
		, 0 [Other]
		, 0 AS [FREIGHT OUT]
		, 0 AS [ROYALTY]
		, 0 AS [SURCHARGE]
		, 0 AS [COMMISSION] 
		, 0 AS MAPP
	FROM ( --GL
		SELECT 
			[Month Sort] AS GL_DATE
			,MAX(DateID) AS DateID
			,SUM(CASE WHEN  JE_HDR_CREATED_BY = 'Fernando, Roy' THEN ISNULL(tb.ACCT_DEBIT,0)-ISNULL(tb.ACCT_CREDIT,0) END)*-1 AS System
			,SUM(CASE WHEN  JE_HDR_CREATED_BY <> 'Fernando, Roy' AND ISNULL(Mute,0) = 0 THEN ISNULL(tb.ACCT_DEBIT,0)-ISNULL(tb.ACCT_CREDIT,0) END)*-1 AS Reclass
			,SUM(CASE WHEN  JE_HDR_CREATED_BY <> 'Fernando, Roy' THEN ISNULL(tb.ACCT_DEBIT,0)-ISNULL(tb.ACCT_CREDIT,0) END)*-1 AS JournalEntry
			,SUM(ISNULL(tb.ACCT_DEBIT,0)-ISNULL(tb.ACCT_CREDIT,0))*-1 AS Sales
		FROM Oracle.TrialBalance tb
			LEFT JOIN dbo.DimCalendarFiscal c1 ON CASE WHEN CAST(JE_HDR_EFF_DATE AS DATE) < CAST(tb.JE_HDR_POSTED_DATE AS DATE)  THEN CAST(JE_HDR_EFF_DATE AS DATE) ELSE CAST(tb.JE_HDR_POSTED_DATE AS DATE) END = c1.DateKey
			LEFT JOIN Dim.ProductMasterReclassSKU pmf ON pmf.JEDescription = tb.LINE_DESCRIPTION
		WHERE ACCOUNT IN ('3000','3200') AND RIGHT(PERIOD,2) >= 19 AND tb.CurrentRecord = 1 AND LEFT(CODE_COMBINATION,2) = '10' AND Source <> 'Marketing'
		GROUP BY [Month Sort]--,tb.LINE_DESCRIPTION
			
	) a
	FULL OUTER JOIN
	(	--AAA/TPI
		SELECT [GL_DATE], DateID, SUM(Sales) AS Sales
		FROM 
		(
			SELECT [Month Sort] AS GL_DATE, MAX(DateID) AS DateID, SUM(ACCTD_USD) AS Sales --*CASE WHEN REVENUE_TYPE = 'SHIPHANDLING' THEN -1 ELSE 1 END
			FROM Oracle.Invoice i
				LEFT JOIN dbo.DimCalendarFiscal c1 ON i.GL_DATE = c1.DateKey
			WHERE RIGHT(GL_PERIOD,2)>= 19 AND CurrentRecord = 1 
				AND (GL_REVENUE_DISTRIBUTION LIKE '%3000%' OR GL_REVENUE_DISTRIBUTION LIKE '%3200%')
				AND (REVENUE_TYPE IN ('AAA-SALES','TPI')
					--OR (INV_DESCRIPTION LIKE '%FRT%MBS%') 
					--OR (REVENUE_TYPE IN ('SHIPHANDLING') AND  INV_DESCRIPTION NOT LIKE '%DSF%' AND i.SKU <> 'ZFRT')
				)
			GROUP BY [Month Sort] --GL_DATE
			UNION ALL
			SELECT [Month Sort] AS GL_DATE, MAX(i.DateID) AS DateID, SUM(ACCTD_USD) AS Sales
			FROM Fact.SalesReclass i
				LEFT JOIN dbo.DimCalendarFiscal c1 ON i.DateID = c1.DateID
			WHERE RevenueID = -1
			GROUP BY [Month Sort]
		) aa
		GROUP BY [GL_DATE], DateID
	) b ON a.GL_DATE = b.GL_DATE 
		INNER JOIN dbo.DimCalendarFiscal fc ON a.DateID = fc.DateID
	WHERE fc.UseActual = 1 OR a.[GL_Date] = '202210'
	--ORDER BY a.GL_DATE
	UNION
	SELECT 	CAST(0 AS FLOAT) AS Order_Num
		,CAST(0 AS FLOAT) AS Order_Line
		,CAST(0 AS INT) AS SaleTypeID
		,-10 AS RevenueID
		,0 AS AccountID
		,CAST(0 AS INT) AS CustomerID
		,CAST(0 AS INT) AS GeographyID
		,0 AS ProductID
		,0 AS LocationID
		,0 AS DemandClassID
		,b.DateID AS DateID
		,CAST(0 AS INT) AS HourID
		,CAST(ISNULL(a.Sales,0)-ISNULL(a.Reclass,0)-ISNULL(b.Sales,0) AS MONEY) AS ACCTD_USD
		,CAST(0 AS MONEY) AS [ENTERED_AMOUNT]
		,CAST(0 AS MONEY) AS [ITEM_FROZEN_COST]
		,CAST(0 AS MONEY) AS [COGS_AMOUNT]
		,CAST(0 AS MONEY) AS [QTY]
		, 0 [COOP]
		, 0 AS [DIF RETURNS]
		, 0 AS [Invoiced Freight]
		, 0 AS [Frieght Allowance]
		, 0 AS [Cash Discounts]
		, 0 AS [Markdown]
		, 0 [Other]
		, 0 AS [FREIGHT OUT]
		, 0 AS [ROYALTY]
		, 0 AS [SURCHARGE]
		, 0 AS [COMMISSION] 
		, 0 AS MAPP
	FROM ( --GL
		SELECT 
			[Month Sort] AS GL_DATE
			,SUM(CASE WHEN  JE_HDR_CREATED_BY = 'Fernando, Roy' THEN ISNULL(tb.ACCT_DEBIT,0)-ISNULL(tb.ACCT_CREDIT,0) END)*-1 AS System
			,SUM(CASE WHEN  JE_HDR_CREATED_BY <> 'Fernando, Roy' AND Mute = 0 THEN ISNULL(tb.ACCT_DEBIT,0)-ISNULL(tb.ACCT_CREDIT,0) END)*-1 AS Reclass
			,SUM(CASE WHEN  JE_HDR_CREATED_BY <> 'Fernando, Roy' THEN ISNULL(tb.ACCT_DEBIT,0)-ISNULL(tb.ACCT_CREDIT,0) END)*-1 AS JournalEntry
			,SUM(ISNULL(tb.ACCT_DEBIT,0)-ISNULL(tb.ACCT_CREDIT,0))*-1 AS Sales
		FROM Oracle.TrialBalance tb
			LEFT JOIN dbo.DimCalendarFiscal c1 ON CASE WHEN CAST(JE_HDR_EFF_DATE AS DATE) < CAST(tb.JE_HDR_POSTED_DATE AS DATE)  THEN CAST(JE_HDR_EFF_DATE AS DATE) ELSE CAST(tb.JE_HDR_POSTED_DATE AS DATE) END = c1.DateKey
			LEFT JOIN Dim.ProductMasterReclassSKU pmf ON pmf.JEDescription = tb.LINE_DESCRIPTION
		WHERE ACCOUNT IN ('3300') AND RIGHT(PERIOD,2) >= 19 AND tb.CurrentRecord = 1 AND LEFT(CODE_COMBINATION,2) = '10'
		GROUP BY [Month Sort]
			
	) a
	FULL OUTER JOIN
	(	--AAA/TPI
		SELECT [Month Sort] AS GL_DATE, MAX(DateID) AS DateID, SUM(ACCTD_USD) AS Sales --*CASE WHEN REVENUE_TYPE = 'SHIPHANDLING' THEN -1 ELSE 1 END
		FROM Oracle.Invoice i
			LEFT JOIN dbo.DimCalendarFiscal c1 ON i.GL_DATE = c1.DateKey
		WHERE RIGHT(GL_PERIOD,2)>= 19 AND CurrentRecord = 1 
			AND (REVENUE_TYPE IN ('SHIPHANDLING') AND (INV_DESCRIPTION NOT LIKE '%FRT%MBS%'))-- the Freight to Sales reclass moves out
		GROUP BY [Month Sort] --GL_DATE
	) b ON a.GL_DATE = b.GL_DATE 
		INNER JOIN dbo.DimCalendarFiscal fc ON b.DateID = fc.DateID
	WHERE fc.UseActual = 1 OR a.[GL_Date] = '202210'

	--UNION --will need to talk about how to reconcile COGS to a month.  I don't believe it is possible at the sales/invoice level.
	--SELECT 	CAST(0 AS FLOAT) AS Order_Num
	--	,CAST(0 AS FLOAT) AS Order_Line
	--	,CAST(0 AS INT) AS SaleTypeID
	--	,-3 AS RevenueID
	--	,0 AS AccountID
	--	,CAST(0 AS INT) AS CustomerID
	--	,CAST(0 AS INT) AS GeographyID
	--	,0 AS ProductID
	--	,0 AS LocationID
	--	,0 AS DemandClassID
	--	,DateID AS DateID
	--	,CAST(0 AS INT) AS HourID
	--	,CAST(0 AS MONEY) AS [ACCTD_USD] 
	--	,CAST(0 AS MONEY) AS [ENTERED_AMOUNT]
	--	,CAST(0 AS MONEY) AS [ITEM_FROZEN_COST]
	--	,CAST(ISNULL(b.COGS,0)-ISNULL(a.Reclass,0)+ISNULL(a.COGS,0) AS MONEY) *-1 AS [COGS_AMOUNT]
	--	,CAST(0 AS MONEY) AS [QTY]
	--	, 0 [COOP]
	--	, 0 AS [DIF RETURNS]
	--	, 0 AS [Invoiced Freight]
	--	, 0 AS [Frieght Allowance]
	--	, 0 AS [Cash Discounts]
	--	, 0 AS [Markdown]
	--	, 0 [Other]
	--	, 0 AS [FREIGHT OUT]
	--	, 0 AS [ROYALTY]
	--	, 0 AS [SURCHARGE]
	--	, 0 AS [COMMISSION] 
	--	, 0 AS MAPP
	--FROM ( --GL
	--	SELECT 
	--		[Month Sort] AS GL_DATE
	--		,SUM(CASE WHEN  JE_HDR_CREATED_BY = 'Fernando, Roy' THEN ISNULL(tb.ACCT_DEBIT,0)-ISNULL(tb.ACCT_CREDIT,0) END)*-1 AS System
	--		,SUM(CASE WHEN  JE_HDR_CREATED_BY <> 'Fernando, Roy' AND Mute = 0 THEN ISNULL(tb.ACCT_DEBIT,0)-ISNULL(tb.ACCT_CREDIT,0) END)*-1 AS Reclass
	--		,SUM(CASE WHEN  JE_HDR_CREATED_BY <> 'Fernando, Roy' THEN ISNULL(tb.ACCT_DEBIT,0)-ISNULL(tb.ACCT_CREDIT,0) END)*-1 AS JournalEntry
	--		,SUM(ISNULL(tb.ACCT_DEBIT,0)-ISNULL(tb.ACCT_CREDIT,0))*-1 AS Cogs
	--	FROM Oracle.TrialBalance tb
	--		LEFT JOIN dbo.DimCalendarFiscal c1 ON CASE WHEN CAST(JE_HDR_EFF_DATE AS DATE) < CAST(tb.JE_HDR_POSTED_DATE AS DATE)  THEN CAST(JE_HDR_EFF_DATE AS DATE) ELSE CAST(tb.JE_HDR_POSTED_DATE AS DATE) END = c1.DateKey
	--		LEFT JOIN Dim.ProductMasterReclassSKU pmf ON pmf.JEDescription = tb.LINE_DESCRIPTION
	--	WHERE ACCOUNT IN ('4030','4035','4040','4045','4100') AND LEFT(CODE_COMBINATION,2) = '10'
	--		AND RIGHT(PERIOD,2) >= 19 AND tb.CurrentRecord = 1 
	--		--AND c1.DateKey <= '2022-04-30' --(SELECT MAX(DateKey) FROM dbo.CalendarFiscal WHERE MonthID = (SELECT MonthID - 1 FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(GETDATE() AS DATE)))
	--	GROUP BY [Month Sort]
			
	--) a
	--LEFT JOIN
	--(	
	--	SELECT [Month Sort] AS GL_DATE, MAX(DateID) AS DateID, SUM([GLUnitCOGS]*[QTY_INVOICED]) AS Cogs
	--	FROM Oracle.Invoice i
	--		LEFT JOIN dbo.DimCalendarFiscal c1 ON i.GL_DATE = c1.DateKey
	--		LEFT JOIN xref.COGSLookup cogs ON cogs.TRX_NUMBER = i.TRX_NUMBER AND cogs.SKU = i.SKU
	--	WHERE RIGHT(GL_PERIOD,2)>= 19 AND CurrentRecord = 1 AND REVENUE_TYPE IN ('AAA-SALES','TPI')  
	--	GROUP BY [Month Sort] 
	--) b ON a.GL_DATE = b.GL_DATE 

GO
