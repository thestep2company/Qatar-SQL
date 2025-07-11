USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Geography]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Geography] 
AS BEGIN

		CREATE TABLE #geography (
			[PostalCode] [nvarchar](30) NOT NULL,
			[State] [nvarchar](240) NULL,
			[Country] [nvarchar](30) NULL,
			[Fingerprint] [varchar](32) NOT NULL
		)

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

		;WITH CTE AS (
			SELECT [PostalCode]
			  ,[State]
			  ,[Country]
			  ,ROW_NUMBER() OVER (PARTITION BY PostalCode, Country ORDER BY RecordCount DESC) AS Rank
			  ,'XXX' AS Fingerprint
			FROM  ETL.[GeographyInvoice]
		)
		INSERT INTO #geography (
			   [PostalCode]
			  ,[State]
			  ,[Country]
			  ,[FINGERPRINT]
		)
		SELECT [PostalCode]
			  ,[State]
			  ,[Country]
			  ,[FINGERPRINT] 
		FROM CTE 
		WHERE Rank  = 1

		;WITH CTE AS (
			SELECT [PostalCode]
			  ,[State]
			  ,[Country]
			  ,ROW_NUMBER() OVER (PARTITION BY PostalCode, Country ORDER BY RecordCount DESC) AS Rank
			  ,'XXX' AS Fingerprint
			FROM  ETL.[GeographyOrders]
		)
		INSERT INTO #geography (
			   [PostalCode]
			  ,[State]
			  ,[Country]
			  ,[FINGERPRINT]
		)
		SELECT DISTINCT
			  cte.[PostalCode]
			  ,cte.[State]
			  ,cte.[Country]
			  ,cte.[FINGERPRINT] 
		FROM CTE 
			LEFT JOIN #geography g ON CTE.PostalCode = g.PostalCode AND CTE.Country = g.Country
		WHERE Rank  = 1 AND g.PostalCode IS NULL 
			

		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Geography','Oracle') SELECT @columnList
		*/

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

		UPDATE #geography
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				CAST(ISNULL(PostalCode,'') AS VARCHAR(30)) +  CAST(ISNULL(State,'') AS VARCHAR(240)) +  CAST(ISNULL(Country,'') AS VARCHAR(30)) 
			),1)),3,32);

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
		INSERT INTO Oracle.[Geography] (
			   [PostalCode]
			  ,[State]
			  ,[Country]
			  ,[FINGERPRINT]
		)
			SELECT
				    a.[PostalCode]
					,a.[State]
					,a.[Country]
					,a.[FINGERPRINT]
			FROM (
				MERGE Oracle.[Geography] b
				USING (SELECT * FROM #geography) a
				ON a.PostalCode = b.PostalCode AND a.Country = b.Country AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [PostalCode]
						,[State]
						,[Country]
						,[FINGERPRINT]
				)
				VALUES (
					   a.[PostalCode]
					  ,a.[State]
					  ,a.[Country]
					  ,a.[FINGERPRINT]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[PostalCode]
					  ,a.[State]
					  ,a.[Country]
					  ,a.[FINGERPRINT]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		UPDATE [Dim].[Geography] SET PostalCode = replace(PostalCode, char(9), '') WHERE PostalCode LIKE '%'+char(9)+'%'

		;WITH CTE AS (
			SELECT [PostalCode]
			FROM [Dim].[Geography]
			GROUP BY PostalCode
			HAVING COUNT(*) > 1
		)
		, DuplicatePostalCodes AS (
			SELECT ROW_NUMBER() OVER (PARTITION BY g.PostalCode ORDER BY Country DESC, State, GeographyID) AS RowNum
				,g.PostalCode, State, Country, GeographyID
			FROM Dim.Geography g
				INNER JOIN CTE ON CTE.PostalCode = g.PostalCode
			GROUP BY g.PostalCode, State, Country, GeographyID
		)
		DELETE FROM g 
		FROM Dim.Geography g
			INNER JOIN DuplicatePostalCodes z 
		ON g.GeographyID = z.GeographyID
		WHERE z.RowNum > 1

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
	
		DROP TABLE #geography

END
GO
