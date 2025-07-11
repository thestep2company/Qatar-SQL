USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_CustomerDates]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_CustomerDates] 
AS BEGIN

	CREATE TABLE #CustomerDates (
		CustomerKey VARCHAR(50), 
		FirstSaleDate DATE, 
		LastSaleDate DATE,
		CreationDate DATE
	)

	INSERT INTO #CustomerDates (CustomerKey, FirstSaleDate, LastSaleDate)
	SELECT CUSTOMER_NUM
		, MIN(CAST(ORDER_DATE AS DATE)) AS FirstSaleDate
		, MAX(CAST(ORDER_DATE AS DATE)) AS LastSaleDate
	FROM [Oracle].Orders o
		LEFT JOIN Oracle.CustomerMaster c ON o.CUSTOMER_NUM = c.ACCOUNT_NUMBER AND c.CurrentRecord = 1
	WHERE o.CurrentRecord = 1 AND FLOW_STATUS_CODE <> 'CANCELLED' AND QTY > 0
	GROUP BY CUSTOMER_NUM
	
	MERGE Oracle.CustomerDates b
	USING (SELECT * FROM #customerDates ) a
	ON a.CustomerKey = b.CustomerKey
	WHEN NOT MATCHED --BY TARGET 
	THEN INSERT (
		CustomerKey
		, FirstSaleDate
		, LastSaleDate
		, CreationDate
	)
	VALUES (
		a.CustomerKey
		, a.FirstSaleDate
		, a.LastSaleDate
		, a.CreationDate
	)
	--Existing records that have changed are expired
	WHEN MATCHED AND 
		(
			ISNULL(a.FirstSaleDate,'1900-01-01')  <> ISNULL(b.FirstSaleDate,'1900-01-01')
		OR ISNULL(a.LastSaleDate,'1900-01-01')	<> 	ISNULL(b.LastSaleDate,'1900-01-01')
		OR ISNULL(a.CreationDate,'1900-01-01')	<> 	ISNULL(b.CreationDate,'1900-01-01')
	)
	THEN 
	UPDATE SET 
		b.FirstSaleDate = a.FirstSaleDate
		,b.LastSaleDate	= a.LastSaleDate
		,b.CreationDate = a.CreationDate;
		
	DROP TABLE #CustomerDates

END

	



GO
