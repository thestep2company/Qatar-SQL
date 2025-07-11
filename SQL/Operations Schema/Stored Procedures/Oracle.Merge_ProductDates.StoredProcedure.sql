USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_ProductDates]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [Oracle].[Merge_ProductDates] 
AS BEGIN

	CREATE TABLE #ProductDates (
		Part VARCHAR(50), 
		FirstSaleDate DATE, 
		LastSaleDate DATE
	)


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

	INSERT INTO #ProductDates (Part, FirstSaleDate, LastSaleDate)
	SELECT PART
		, MIN(CAST(ORDER_DATE AS DATE)) AS FirstSaleDate
		, MAX(CAST(ORDER_DATE AS DATE)) AS LastSaleDate
	FROM [Oracle].Orders 
	WHERE CurrentRecord = 1 AND FLOW_STATUS_CODE <> 'CANCELLED' AND QTY > 0
	GROUP BY PART

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
	MERGE Oracle.ProductDates b
	USING (SELECT * FROM #productDates ) a
	ON a.Part = b.Part_Number
	WHEN NOT MATCHED --BY TARGET 
	THEN INSERT (
		Part_Number
		, FirstSaleDate
		, LastSaleDate
	)
	VALUES (
		a.Part
		, a.FirstSaleDate
		, a.LastSaleDate
	)
	--Existing records that have changed are expired
	WHEN MATCHED AND 
		(
			ISNULL(a.FirstSaleDate,'1900-01-01')  <> ISNULL(b.FirstSaleDate,'1900-01-01')
		OR ISNULL(a.LastSaleDate,'1900-01-01')	<> 	ISNULL(b.LastSaleDate,'1900-01-01')
	)
	THEN 
	UPDATE SET 
		b.FirstSaleDate = a.FirstSaleDate
		,b.LastSaleDate	= 	a.LastSaleDate;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
		
	DROP TABLE #ProductDates

END

	



GO
