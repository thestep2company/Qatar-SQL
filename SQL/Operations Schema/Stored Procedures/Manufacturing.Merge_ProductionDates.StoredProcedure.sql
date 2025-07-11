USE [Operations]
GO
/****** Object:  StoredProcedure [Manufacturing].[Merge_ProductionDates]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Manufacturing].[Merge_ProductionDates] 
AS BEGIN

	CREATE TABLE #ProductDates (
		Part_Number VARCHAR(50), 
		FirstProductionDate DATE, 
		AnniversaryDate DATE, 
		MaturityDate DATE, 
		LastProductionDate DATE,
		FirstPurchaseDate DATE,
		LastPurchaseDate DATE,
		CreationDate DATE
	)

	INSERT INTO #ProductDates (Part_Number, FirstProductionDate, AnniversaryDate, MaturityDate, LastProductionDate, FirstPurchaseDate, LastPurchaseDate, CreationDate)
	SELECT p.SEGMENT1 AS PART_NUMBER 			
		, MIN(CAST(pd.TRANS_DATE_TIME AS DATE)) AS FirstProductionDate
		, DATEADD(YEAR,1,MIN(CAST(pd.TRANS_DATE_TIME AS DATE))) AS AnniversaryDate
		, DATEADD(YEAR,2,MIN(CAST(pd.TRANS_DATE_TIME AS DATE))) AS MaturityDate
		, MAX(CAST(pd.TRANS_DATE_TIME AS DATE)) AS LastProductionDate 
		, MIN(CAST(bd.TRANS_DATE_TIME AS DATE)) AS FirstPurchaseDate 
		, MAX(CAST(bd.TRANS_DATE_TIME AS DATE)) AS LastPurchaseDate 
		, MIN(CAST(CREATION_DATE AS DATE)) AS CreationDate
	FROM [Oracle].[INV_MTL_SYSTEM_ITEMS_B] p
		LEFT JOIN dbo.FirstProductionDate pd ON p.SEGMENT1 = pd.PART_NUMBER 
		LEFT JOIN dbo.FirstPurchaseDate bd ON p.SEGMENT1 = bd.PART_NUMBER
	WHERE p.CurrentRecord = 1 AND (p.Attribute4 LIKE '%FINISHED%' OR pd.PART_NUMBER IS NOT NULL OR bd.PART_NUMBER IS NOT NULL)
	GROUP BY p.Segment1

		MERGE Oracle.ProductDates b
		USING (SELECT * FROM #productDates ) a
		ON a.Part_Number = b.Part_Number
		WHEN NOT MATCHED --BY TARGET 
		THEN INSERT (
			Part_Number
			, FirstProductionDate
			, AnniversaryDate
			, MaturityDate
			, LastProductionDate
			, FirstPurchaseDate
			, LastPurchaseDate
			, CreationDate
		)
		VALUES (
		   a.Part_Number
			,a.FirstProductionDate
			,a.AnniversaryDate
			,a.MaturityDate
			,a.LastProductionDate
			,a.FirstPurchaseDate
			,a.LastPurchaseDate
			,a.CreationDate
		)
		--Existing records that have changed are expired
		WHEN MATCHED AND 
			(
			   ISNULL(a.FirstProductionDate,'1900-01-01')	<> ISNULL(b.FirstProductionDate,'1900-01-01')
			OR ISNULL(a.AnniversaryDate,'1900-01-01')		<> ISNULL(b.AnniversaryDate,'1900-01-01')
			OR ISNULL(a.MaturityDate,'1900-01-01')			<> ISNULL(b.MaturityDate,'1900-01-01')
			OR ISNULL(a.LastProductionDate,'1900-01-01')	<> ISNULL(b.LastProductionDate,'1900-01-01')
			OR ISNULL(a.FirstPurchaseDate,'1900-01-01')		<> ISNULL(b.FirstPurchaseDate,'1900-01-01')
			OR ISNULL(a.LastPurchaseDate,'1900-01-01')		<> ISNULL(b.LastPurchaseDate,'1900-01-01')
			OR ISNULL(a.CreationDate,'1900-01-01')			<> ISNULL(b.CreationDate,'1900-01-01')
		)
		THEN UPDATE SET 
			 b.FirstProductionDate = a.FirstProductionDate
			,b.AnniversaryDate	=	a.AnniversaryDate
			,b.MaturityDate		=	a.MaturityDate
			,b.LastProductionDate	= 	a.LastProductionDate
			,b.FirstPurchaseDate	= a.FirstPurchaseDate
			,b.LastPurchaseDate	=	a.LastPurchaseDate
			,b.CreationDate	=	a.CreationDate;
		
		DROP TABLE #ProductDates

END
GO
