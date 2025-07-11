USE [Operations]
GO
/****** Object:  StoredProcedure [QA].[Merge_QualityHoldTagIssues]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [QA].[Merge_QualityHoldTagIssues] AS BEGIN

	CREATE TABLE #QUALITY_HOLD_TAG_ISSUES (
		[INDEX_ID] [int] NOT NULL,
		[ISSUE_NUMBER] [int] NULL,
		[ISSUE_DESCRIPTION] [varchar](50) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) ON [PRIMARY]

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

	INSERT INTO #QUALITY_HOLD_TAG_ISSUES
  	SELECT *, CAST('XXXXXXXX' AS VARCHAR(32)) AS Fingerprint
	FROM OPENQUERY(FINDLAND,'
		SELECT [INDEX_ID]
		  ,[ISSUE_NUMBER]
		  ,[ISSUE_DESCRIPTION]
		FROM [Quality].[dbo].[QUALITY_HOLD_TAG_ISSUES]
	')

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('QUALITY_HOLD_TAG_ISSUES','QA') SELECT @columnList
	*/
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #QUALITY_HOLD_TAG_ISSUES
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			 CAST(ISNULL([INDEX_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ISSUE_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([ISSUE_DESCRIPTION],'') AS VARCHAR(50)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO QA.[QUALITY_HOLD_TAG_ISSUES] (
			 [INDEX_ID]
		    ,[ISSUE_NUMBER]
		    ,[ISSUE_DESCRIPTION]
		    ,[Fingerprint]
		)
			SELECT 
				 a.[INDEX_ID]
			    ,a.[ISSUE_NUMBER]
			    ,a.[ISSUE_DESCRIPTION]
			    ,a.[Fingerprint]
			FROM (
				MERGE QA.[QUALITY_HOLD_TAG_ISSUES] b
				USING (SELECT * FROM #QUALITY_HOLD_TAG_ISSUES) a
				ON a.[INDEX_ID] = b.[INDEX_ID] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
						 [INDEX_ID]
					    ,[ISSUE_NUMBER]
					    ,[ISSUE_DESCRIPTION]
					    ,[Fingerprint]				)
				VALUES (
						 a.[INDEX_ID]
					    ,a.[ISSUE_NUMBER]
					    ,a.[ISSUE_DESCRIPTION]
					    ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						 a.[INDEX_ID]
					    ,a.[ISSUE_NUMBER]
					    ,a.[ISSUE_DESCRIPTION]
					    ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #QUALITY_HOLD_TAG_ISSUES
END
GO
