USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_HR_Operating_Units]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_HR_Operating_Units]
AS BEGIN

	CREATE TABLE #OperatingUnits (
		[BUSINESS_GROUP_ID] [numeric](15, 0) NOT NULL,
		[ORGANIZATION_ID] [numeric](15, 0) NOT NULL,
		[NAME] [nvarchar](240) NOT NULL,
		[DATE_FROM] [datetime2](7) NOT NULL,
		[DATE_TO] [datetime2](7) NULL,
		[SHORT_CODE] [nvarchar](150) NULL,
		[SET_OF_BOOKS_ID] [nvarchar](150) NULL,
		[DEFAULT_LEGAL_CONTEXT_ID] [nvarchar](150) NULL,
		[USABLE_FLAG] [nvarchar](150) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #OperatingUnits 
	SELECT [BUSINESS_GROUP_ID]
		  ,[ORGANIZATION_ID]
		  ,[NAME]
		  ,[DATE_FROM]
		  ,[DATE_TO]
		  ,[SHORT_CODE]
		  ,[SET_OF_BOOKS_ID]
		  ,[DEFAULT_LEGAL_CONTEXT_ID]
		  ,[USABLE_FLAG]
		  ,'XXX' AS [Fingerprint]
	FROM OPENQUERY(PROD,'SELECT * FROM HR_OPERATING_UNITS')

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('HR_OPERATING_UNITS','Oracle') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #OperatingUnits
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
				 CAST(ISNULL(BUSINESS_GROUP_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(ORGANIZATION_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(NAME,'') AS VARCHAR(100)) +  CAST(ISNULL(DATE_FROM,'') AS VARCHAR(100)) +  CAST(ISNULL(DATE_TO,'') AS VARCHAR(100)) +  CAST(ISNULL(SHORT_CODE,'') AS VARCHAR(100)) +  CAST(ISNULL(SET_OF_BOOKS_ID,'') AS VARCHAR(100)) +  CAST(ISNULL(DEFAULT_LEGAL_CONTEXT_ID,'') AS VARCHAR(100)) +  CAST(ISNULL(USABLE_FLAG,'') AS VARCHAR(100)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.HR_Operating_Units (
			  [BUSINESS_GROUP_ID]
			  ,[ORGANIZATION_ID]
			  ,[NAME]
			  ,[DATE_FROM]
			  ,[DATE_TO]
			  ,[SHORT_CODE]
			  ,[SET_OF_BOOKS_ID]
			  ,[DEFAULT_LEGAL_CONTEXT_ID]
			  ,[USABLE_FLAG]
			  ,[Fingerprint]
		)
			SELECT 
			  a.[BUSINESS_GROUP_ID]
			  ,a.[ORGANIZATION_ID]
			  ,a.[NAME]
			  ,a.[DATE_FROM]
			  ,a.[DATE_TO]
			  ,a.[SHORT_CODE]
			  ,a.[SET_OF_BOOKS_ID]
			  ,a.[DEFAULT_LEGAL_CONTEXT_ID]
			  ,a.[USABLE_FLAG]
			  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.HR_Operating_Units b
				USING (SELECT * FROM #OperatingUnits) a
				ON a.Organization_ID = b.Organization_ID AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [BUSINESS_GROUP_ID]
					  ,[ORGANIZATION_ID]
					  ,[NAME]
					  ,[DATE_FROM]
					  ,[DATE_TO]
					  ,[SHORT_CODE]
					  ,[SET_OF_BOOKS_ID]
					  ,[DEFAULT_LEGAL_CONTEXT_ID]
					  ,[USABLE_FLAG]
					  ,[Fingerprint]
				)
				VALUES (
					   a.[BUSINESS_GROUP_ID]
					  ,a.[ORGANIZATION_ID]
					  ,a.[NAME]
					  ,a.[DATE_FROM]
					  ,a.[DATE_TO]
					  ,a.[SHORT_CODE]
					  ,a.[SET_OF_BOOKS_ID]
					  ,a.[DEFAULT_LEGAL_CONTEXT_ID]
					  ,a.[USABLE_FLAG]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[BUSINESS_GROUP_ID]
					  ,a.[ORGANIZATION_ID]
					  ,a.[NAME]
					  ,a.[DATE_FROM]
					  ,a.[DATE_TO]
					  ,a.[SHORT_CODE]
					  ,a.[SET_OF_BOOKS_ID]
					  ,a.[DEFAULT_LEGAL_CONTEXT_ID]
					  ,a.[USABLE_FLAG]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
	
	DROP TABLE #OperatingUnits
END
GO
