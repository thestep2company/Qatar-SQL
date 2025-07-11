USE [Operations]
GO
/****** Object:  View [Fact].[PriceList]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Fact].[PriceList] AS 
	WITH Data AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY ACCOUNT_NUMBER, ITEM ORDER BY START_DATE) AS RowNumber
			, ACCOUNT_NUMBER
			, ITEM
			, PRICE_LIST
			, [VALUE]
			, [CURRENCY]
			, START_DATE
			, END_DATE 
		FROM Oracle.CustomerPriceList 
		WHERE [Value] <> 0
	)
	, CPL AS ( --do not have two active price_lists for customer/sku
		SELECT a.ACCOUNT_NUMBER, a.ITEM, a.PRICE_LIST, a.VALUE, a.CURRENCY, a.START_DATE, ISNULL(a.END_DATE,b.START_DATE) AS END_DATE 
		FROM Data a 
			LEFT JOIN Data b ON a.ACCOUNT_NUMBER = b.ACCOUNT_NUMBER AND a.ITEM = b.ITEM	AND a.RowNumber + 1 = b.RowNumber
	)
	SELECT cm.CustomerID
		, pm.ProductID
		, cpl.PRICE_LIST AS PriceList
		, cpl.[VALUE] * ISNULL(cc.CONVERSION_RATE,1) 
		  + CASE WHEN cpm.ARITHMETIC = 'AMT' THEN ISNULL([MODIFIER_AMOUNT],0) * ISNULL(cc.CONVERSION_RATE,1) ELSE 0 END AS Price
		, cpl.[CURRENCY]
		, cpl.START_DATE AS StartDate
		, ISNULL(cpl.END_DATE,'9999-12-31') AS EndDate
	FROM CPL
		LEFT JOIN dbo.DimCustomerMaster cm ON cpl.ACCOUNT_NUMBER = cm.CustomerKey
		LEFT JOIN dbo.DimProductMaster pm ON cpl.ITEM = pm.ProductKey
		LEFT JOIN (SELECT TOP 1 * FROM Oracle.GL_DAILY_RATES cc ORDER BY CONVERSION_DATE DESC) cc ON cpl.Currency = cc.FROM_CURRENCY --pull the last known value, accounting does not always have the conversion in on time
		LEFT JOIN Oracle.CustomerPricingModifiers cpm ON cpm.[ACCOUNT_NUMBER] = cm.CustomerKey AND cpm.Part = pm.ProductKey AND YEAR(cpm.STARTDATE) >= 2025 AND LEFT(MODIFIER_NAME,7) = 'S2C TPI'
	WHERE (GETDATE() BETWEEN cpl.START_DATE AND cpl.END_DATE OR (cpl.END_DATE IS NULL AND cpl.START_DATE IS NOT NULL) OR cpl.START_DATE > GETDATE())

GO
