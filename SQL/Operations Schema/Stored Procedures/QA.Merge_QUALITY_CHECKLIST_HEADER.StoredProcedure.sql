USE [Operations]
GO
/****** Object:  StoredProcedure [QA].[Merge_QUALITY_CHECKLIST_HEADER]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [QA].[Merge_QUALITY_CHECKLIST_HEADER] AS BEGIN
	
	CREATE TABLE #ChecklistyHeader (
		[TEST_NUMBER] [int] NOT NULL,
		[PRODUCT_NUMBER] [varchar](20) NOT NULL,
		[DAILY_COMMENTS] [varchar](max) NULL,
		[CREATE_DATE] [datetime] NOT NULL,
		[LOCATION] [varchar](3) NULL,
		[INSPECTOR] [varchar](50) NULL,
		[SHIFT] [varchar](1) NULL,
		[PRODUCT_DESCRIPTION] [varchar](125) NULL,
		[MACHINE_NUM] [varchar](3) NOT NULL,
		[MACHINE_SIZE] [varchar](3) NOT NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) 

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

	INSERT INTO #ChecklistyHeader
	SELECT *, 'XXXXXXXX'
	FROM OPENQUERY(FINDLAND,'
		SELECT [TEST_NUMBER]
			,[PRODUCT_NUMBER]
			,[DAILY_COMMENTS]
			,[CREATE_DATE]
			,[LOCATION]
			,[INSPECTOR]
			,[SHIFT]
			,[PRODUCT_DESCRIPTION]
			,[MACHINE_NUM]
			,[MACHINE_SIZE]
		FROM [Quality].[dbo].[QUALITY_CHECKLIST_HEADER]
		WHERE [CREATE_DATE] >= DATEADD(DAY,-30,GETDATE())
	')

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('QUALITY_CHECKLIST_HEADER','QA') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #ChecklistyHeader
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			CAST(ISNULL([TEST_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([PRODUCT_NUMBER],'') AS VARCHAR(20)) +  CAST(ISNULL([DAILY_COMMENTS],'') AS VARCHAR(MAX)) +  CAST(ISNULL([CREATE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([LOCATION],'') AS VARCHAR(3)) +  CAST(ISNULL([INSPECTOR],'') AS VARCHAR(50)) +  CAST(ISNULL([SHIFT],'') AS VARCHAR(1)) +  CAST(ISNULL([PRODUCT_DESCRIPTION],'') AS VARCHAR(125)) +  CAST(ISNULL([MACHINE_NUM],'') AS VARCHAR(3)) +  CAST(ISNULL([MACHINE_SIZE],'') AS VARCHAR(3)) 
		),1)),3,32);


		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
		INSERT INTO QA.[QUALITY_CHECKLIST_HEADER] (
			[TEST_NUMBER]
			,[PRODUCT_NUMBER]
			,[DAILY_COMMENTS]
			,[CREATE_DATE]
			,[LOCATION]
			,[INSPECTOR]
			,[SHIFT]
			,[PRODUCT_DESCRIPTION]
			,[MACHINE_NUM]
			,[MACHINE_SIZE]
		    ,[Fingerprint]
		)
			SELECT 
				a.[TEST_NUMBER]
				,a.[PRODUCT_NUMBER]
				,a.[DAILY_COMMENTS]
				,a.[CREATE_DATE]
				,a.[LOCATION]
				,a.[INSPECTOR]
				,a.[SHIFT]
				,a.[PRODUCT_DESCRIPTION]
				,a.[MACHINE_NUM]
				,a.[MACHINE_SIZE]
				,a.[Fingerprint]
			FROM (
				MERGE QA.[QUALITY_CHECKLIST_HEADER] b
				USING (SELECT * FROM #ChecklistyHeader) a
				ON a.[TEST_NUMBER] = b.[TEST_NUMBER] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					[TEST_NUMBER]
					,[PRODUCT_NUMBER]
					,[DAILY_COMMENTS]
					,[CREATE_DATE]
					,[LOCATION]
					,[INSPECTOR]
					,[SHIFT]
					,[PRODUCT_DESCRIPTION]
					,[MACHINE_NUM]
					,[MACHINE_SIZE]
					,[Fingerprint]
				)
				VALUES (
						a.[TEST_NUMBER]
						,a.[PRODUCT_NUMBER]
						,a.[DAILY_COMMENTS]
						,a.[CREATE_DATE]
						,a.[LOCATION]
						,a.[INSPECTOR]
						,a.[SHIFT]
						,a.[PRODUCT_DESCRIPTION]
						,a.[MACHINE_NUM]
						,a.[MACHINE_SIZE]
						,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						a.[TEST_NUMBER]
						,a.[PRODUCT_NUMBER]
						,a.[DAILY_COMMENTS]
						,a.[CREATE_DATE]
						,a.[LOCATION]
						,a.[INSPECTOR]
						,a.[SHIFT]
						,a.[PRODUCT_DESCRIPTION]
						,a.[MACHINE_NUM]
						,a.[MACHINE_SIZE]
						,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #ChecklistyHeader
END
GO
