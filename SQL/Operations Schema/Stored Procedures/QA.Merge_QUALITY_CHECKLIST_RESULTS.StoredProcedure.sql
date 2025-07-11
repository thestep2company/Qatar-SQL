USE [Operations]
GO
/****** Object:  StoredProcedure [QA].[Merge_QUALITY_CHECKLIST_RESULTS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [QA].[Merge_QUALITY_CHECKLIST_RESULTS] AS BEGIN
	
	CREATE TABLE #ChecklistResults (
		[QCR_ID] [int] NOT NULL,
		[TEST_NUMBER] [int] NOT NULL,
		[PRODUCT_NUMBER] [varchar](20) NOT NULL,
		[CHECK_NUMBER] [int] NOT NULL,
		[TEST] [varchar](max) NOT NULL,
		[CHECK_VALUE] [varchar](20) NULL,
		[DATE_SAVED] [datetime] NULL,
		[RESULTS_COMMENTS] [varchar](max) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

	INSERT INTO #ChecklistResults
	SELECT *, 'XXXXXXXX'
	FROM OPENQUERY(FINDLAND,'
		SELECT [QCR_ID]
		  ,[TEST_NUMBER]
		  ,[PRODUCT_NUMBER]
		  ,[CHECK_NUMBER]
		  ,[TEST]
		  ,[CHECK_VALUE]
		  ,[DATE_SAVED]
		  ,[RESULTS_COMMENTS]
		FROM [Quality].[dbo].[QUALITY_CHECKLIST_RESULTS]
		WHERE [DATE_SAVED] >= DATEADD(DAY,-3,GETDATE())
	')

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('QUALITY_CHECKLIST_RESULTS','QA') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #ChecklistResults
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			 CAST(ISNULL([QCR_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([TEST_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([PRODUCT_NUMBER],'') AS VARCHAR(20)) +  CAST(ISNULL([CHECK_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([TEST],'') AS VARCHAR(MAX)) +  CAST(ISNULL([CHECK_VALUE],'') AS VARCHAR(20)) +  CAST(ISNULL([DATE_SAVED],'') AS VARCHAR(100)) +  CAST(ISNULL([RESULTS_COMMENTS],'') AS VARCHAR(MAX)) 
		),1)),3,32);


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO [QA].[QUALITY_CHECKLIST_RESULTS] (
			 [QCR_ID]
			,[TEST_NUMBER]
			,[PRODUCT_NUMBER]
			,[CHECK_NUMBER]
			,[TEST]
			,[CHECK_VALUE]
			,[DATE_SAVED]
			,[RESULTS_COMMENTS]
		    ,[Fingerprint]
		)
			SELECT 
				a.[QCR_ID]
				,[TEST_NUMBER]
				,[PRODUCT_NUMBER]
				,[CHECK_NUMBER]
				,[TEST]
				,[CHECK_VALUE]
				,[DATE_SAVED]
				,[RESULTS_COMMENTS]
				,[Fingerprint]
			FROM (
				MERGE QA.[QUALITY_CHECKLIST_RESULTS] b
				USING (SELECT * FROM #ChecklistResults) a
				ON a.[QCR_ID] = b.[QCR_ID] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					[QCR_ID]
					,[TEST_NUMBER]
					,[PRODUCT_NUMBER]
					,[CHECK_NUMBER]
					,[TEST]
					,[CHECK_VALUE]
					,[DATE_SAVED]
					,[RESULTS_COMMENTS]
					,[Fingerprint]
				)
				VALUES (
						a.[QCR_ID]
						,a.[TEST_NUMBER]
						,a.[PRODUCT_NUMBER]
						,a.[CHECK_NUMBER]
						,a.[TEST]
						,a.[CHECK_VALUE]
						,a.[DATE_SAVED]
						,a.[RESULTS_COMMENTS]
						,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						a.[QCR_ID]
						,a.[TEST_NUMBER]
						,a.[PRODUCT_NUMBER]
						,a.[CHECK_NUMBER]
						,a.[TEST]
						,a.[CHECK_VALUE]
						,a.[DATE_SAVED]
						,a.[RESULTS_COMMENTS]
						,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #ChecklistResults
END
GO
