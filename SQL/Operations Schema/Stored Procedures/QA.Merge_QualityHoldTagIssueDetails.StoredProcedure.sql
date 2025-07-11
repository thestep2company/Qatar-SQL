USE [Operations]
GO
/****** Object:  StoredProcedure [QA].[Merge_QualityHoldTagIssueDetails]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [QA].[Merge_QualityHoldTagIssueDetails] AS BEGIN

	CREATE TABLE #QUALITY_HOLD_TAG_ISSUE_DETAILS
	(
		[INDEX_ID] [int] NOT NULL,
		[HOLD_TAG_NUMBER] [int] NOT NULL,
		[QUALITY_HOLD_TAG_ISSUE_NUMBER_ID] [int] NULL,
		[IS_CHECKED] [varchar](1) NULL,
		[ISSUE_NUMBER] [int] NULL,
		[Fingerprint] [varchar](32) NOT NULL
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

  	INSERT INTO #QUALITY_HOLD_TAG_ISSUE_DETAILS
	SELECT *, CAST('XXXXXXXX' AS VARCHAR(32)) AS Fingerprint
	FROM OPENQUERY(FINDLAND,'
	SELECT [INDEX_ID]
		  ,[HOLD_TAG_NUMBER]
		  ,[QUALITY_HOLD_TAG_ISSUE_NUMBER_ID]
		  ,[IS_CHECKED]
		  ,[ISSUE_NUMBER]
	  FROM [Quality].[dbo].[QUALITY_HOLD_TAG_ISSUE_DETAILS]
	')

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('QUALITY_HOLD_TAG_ISSUE_DETAILS','QA') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #QUALITY_HOLD_TAG_ISSUE_DETAILS
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			  CAST(ISNULL([INDEX_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([HOLD_TAG_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([QUALITY_HOLD_TAG_ISSUE_NUMBER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([IS_CHECKED],'') AS VARCHAR(1)) +  CAST(ISNULL([ISSUE_NUMBER],'0') AS VARCHAR(100)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO QA.[QUALITY_HOLD_TAG_ISSUE_DETAILS] (
			 [INDEX_ID]
			,[HOLD_TAG_NUMBER]
			,[QUALITY_HOLD_TAG_ISSUE_NUMBER_ID]
			,[IS_CHECKED]
			,[ISSUE_NUMBER]
		    ,[Fingerprint]
		)
			SELECT 
				 a.[INDEX_ID]
				,a.[HOLD_TAG_NUMBER]
				,a.[QUALITY_HOLD_TAG_ISSUE_NUMBER_ID]
				,a.[IS_CHECKED]
				,a.[ISSUE_NUMBER]
			    ,a.[Fingerprint]
			FROM (
				MERGE QA.[QUALITY_HOLD_TAG_ISSUE_DETAILS] b
				USING (SELECT * FROM #QUALITY_HOLD_TAG_ISSUE_DETAILS) a
				ON a.[INDEX_ID] = b.[INDEX_ID] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					 [INDEX_ID]
					,[HOLD_TAG_NUMBER]
					,[QUALITY_HOLD_TAG_ISSUE_NUMBER_ID]
					,[IS_CHECKED]
					,[ISSUE_NUMBER]
					,[Fingerprint]
				)
				VALUES (
					 a.[INDEX_ID]
					,a.[HOLD_TAG_NUMBER]
					,a.[QUALITY_HOLD_TAG_ISSUE_NUMBER_ID]
					,a.[IS_CHECKED]
					,a.[ISSUE_NUMBER]
				    ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					 a.[INDEX_ID]
					,a.[HOLD_TAG_NUMBER]
					,a.[QUALITY_HOLD_TAG_ISSUE_NUMBER_ID]
					,a.[IS_CHECKED]
					,a.[ISSUE_NUMBER]
				    ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #QUALITY_HOLD_TAG_ISSUE_DETAILS

END



GO
