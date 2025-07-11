USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_DavinciSales]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_DavinciSales]
AS BEGIN

	DROP TABLE IF EXISTS #DavinciSales 

	CREATE TABLE #DavinciSales (Customer_TRX_LINE_ID INT, Term_ID INT)

	INSERT INTO #DavinciSales
	SELECT * 
	FROM OPENQUERY(PROD,'
	select rctla.Customer_TRX_LINE_ID, rcta.Term_ID
	FROM
		ra_customer_trx_all rcta,
		ra_customer_trx_lines_all rctla,
		ra_terms term
	WHERE
		rcta.customer_trx_id = rctla.customer_trx_id
		AND rcta.org_id=83
		AND rcta.term_id = term.term_id
		AND term.description LIKE ''%Davinci%''
		AND (rctla.creation_date>sysdate-7 OR rctla.last_update_date>sysdate-7)
	')

	--UPSERT 
	UPDATE t
	SET t.TERM_ID = s.TERM_ID
	FROM #DavinciSales s
		LEFT JOIN Oracle.DavinciSales t
	ON s.Customer_TRX_LINE_ID = t.CUSTOMER_TRX_LINE_ID
	WHERE s.Term_ID <> t.Term_ID

	INSERT INTO Oracle.DavinciSales (Customer_TRX_LINE_ID, Term_ID)
	SELECT s.* FROM #DavinciSales s
		LEFT JOIN Oracle.DavinciSales t
	ON s.Customer_TRX_LINE_ID = t.CUSTOMER_TRX_LINE_ID
	WHERE t.CUSTOMER_TRX_LINE_ID IS NULL
END

GO
