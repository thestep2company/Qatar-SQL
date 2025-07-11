USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_JTF_RS_SALESREPS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_JTF_RS_SALESREPS] 
AS BEGIN

	CREATE TABLE #SalesReps (
		--<column-list>
	[SALESREP_ID] [float] NOT NULL,
	[RESOURCE_ID] [float] NOT NULL,
	[LAST_UPDATE_DATE] [datetime2](7) NOT NULL,
	[LAST_UPDATED_BY] [float] NOT NULL,
	[CREATION_DATE] [datetime2](7) NOT NULL,
	[CREATED_BY] [float] NOT NULL,
	[LAST_UPDATE_LOGIN] [float] NULL,
	[SALES_CREDIT_TYPE_ID] [float] NOT NULL,
	[NAME] [nvarchar](240) NULL,
	[STATUS] [nvarchar](30) NULL,
	[START_DATE_ACTIVE] [datetime2](7) NOT NULL,
	[END_DATE_ACTIVE] [datetime2](7) NULL,
	[GL_ID_REV] [float] NULL,
	[GL_ID_FREIGHT] [float] NULL,
	[GL_ID_REC] [float] NULL,
	[SET_OF_BOOKS_ID] [float] NULL,
	[SALESREP_NUMBER] [nvarchar](30) NULL,
	[ORG_ID] [float] NULL,
	[EMAIL_ADDRESS] [nvarchar](240) NULL,
	[WH_UPDATE_DATE] [datetime2](7) NULL,
	[PERSON_ID] [float] NULL,
	[SALES_TAX_GEOCODE] [nvarchar](30) NULL,
	[SALES_TAX_INSIDE_CITY_LIMITS] [nvarchar](1) NULL,
	[OBJECT_VERSION_NUMBER] [float] NOT NULL,
	[ATTRIBUTE_CATEGORY] [nvarchar](30) NULL,
	[ATTRIBUTE1] [nvarchar](150) NULL,
	[ATTRIBUTE2] [nvarchar](150) NULL,
	[ATTRIBUTE3] [nvarchar](150) NULL,
	[ATTRIBUTE4] [nvarchar](150) NULL,
	[ATTRIBUTE5] [nvarchar](150) NULL,
	[ATTRIBUTE6] [nvarchar](150) NULL,
	[ATTRIBUTE7] [nvarchar](150) NULL,
	[ATTRIBUTE8] [nvarchar](150) NULL,
	[ATTRIBUTE9] [nvarchar](150) NULL,
	[ATTRIBUTE10] [nvarchar](150) NULL,
	[ATTRIBUTE11] [nvarchar](150) NULL,
	[ATTRIBUTE12] [nvarchar](150) NULL,
	[ATTRIBUTE13] [nvarchar](150) NULL,
	[ATTRIBUTE14] [nvarchar](150) NULL,
	[ATTRIBUTE15] [nvarchar](150) NULL,
	[SECURITY_GROUP_ID] [float] NULL,
	[FINGERPRINT] [varchar](32) NOT NULL
	) 

	--insert steps to log what is happening.  If the job fails, we can check the ETLLog and see where it failed.
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()
	
	INSERT INTO #SalesReps (
		  --<column-list>
		  [SALESREP_ID],
		  [RESOURCE_ID],
		  [LAST_UPDATE_DATE],
		  [LAST_UPDATED_BY],
		  [CREATION_DATE],
		  [CREATED_BY],
		  [LAST_UPDATE_LOGIN],
		  [SALES_CREDIT_TYPE_ID],
		  [NAME],
		  [STATUS],
		  [START_DATE_ACTIVE],
		  [END_DATE_ACTIVE],
		  [GL_ID_REV],
		  [GL_ID_FREIGHT],
		  [GL_ID_REC],
		  [SET_OF_BOOKS_ID],
		  [SALESREP_NUMBER],
		  [ORG_ID],
		  [EMAIL_ADDRESS],
		  [WH_UPDATE_DATE],
		  [PERSON_ID],
		  [SALES_TAX_GEOCODE],
		  [SALES_TAX_INSIDE_CITY_LIMITS],
		  [OBJECT_VERSION_NUMBER],
		  [ATTRIBUTE_CATEGORY],
		  [ATTRIBUTE1],
		  [ATTRIBUTE2],
		  [ATTRIBUTE3],
		  [ATTRIBUTE4],
		  [ATTRIBUTE5],
		  [ATTRIBUTE6],
		  [ATTRIBUTE7],
		  [ATTRIBUTE8],
		  [ATTRIBUTE9],
		  [ATTRIBUTE10],
		  [ATTRIBUTE11],
		  [ATTRIBUTE12],
		  [ATTRIBUTE13],
		  [ATTRIBUTE14],
		  [ATTRIBUTE15],
		  [SECURITY_GROUP_ID],
		  [Fingerprint]
	  )
	SELECT 
		 --<column-list>
		  [SALESREP_ID],
		  [RESOURCE_ID],
		  [LAST_UPDATE_DATE],
		  [LAST_UPDATED_BY],
		  [CREATION_DATE],
		  [CREATED_BY],
		  [LAST_UPDATE_LOGIN],
		  [SALES_CREDIT_TYPE_ID],
		  [NAME],
		  [STATUS],
		  [START_DATE_ACTIVE],
		  [END_DATE_ACTIVE],
		  [GL_ID_REV],
		  [GL_ID_FREIGHT],
		  [GL_ID_REC],
		  [SET_OF_BOOKS_ID],
		  [SALESREP_NUMBER],
		  [ORG_ID],
		  [EMAIL_ADDRESS],
		  [WH_UPDATE_DATE],
		  [PERSON_ID],
		  [SALES_TAX_GEOCODE],
		  [SALES_TAX_INSIDE_CITY_LIMITS],
		  [OBJECT_VERSION_NUMBER],
		  [ATTRIBUTE_CATEGORY],
		  [ATTRIBUTE1],
		  [ATTRIBUTE2],
		  [ATTRIBUTE3],
		  [ATTRIBUTE4],
		  [ATTRIBUTE5],
		  [ATTRIBUTE6],
		  [ATTRIBUTE7],
		  [ATTRIBUTE8],
		  [ATTRIBUTE9],
		  [ATTRIBUTE10],
		  [ATTRIBUTE11],
		  [ATTRIBUTE12],
		  [ATTRIBUTE13],
		  [ATTRIBUTE14],
		  [ATTRIBUTE15],
		  [SECURITY_GROUP_ID],
		  'XXX' AS [Fingerprint]
	FROM OPENQUERY(PROD, '
		SELECT * FROM JTF_RS_SALESREPS
		WHERE CREATION_DATE > sysdate - 7 OR LAST_UPDATE_DATE > sysdate - 7
	') 
	--	
		--8000 character limit for openqueries

	/*	--run this and replace @columnList below
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('JTF_RS_SALESREPS','Oracle') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #SalesReps
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
		CAST(ISNULL([SALESREP_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([RESOURCE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATED_BY],'0') AS VARCHAR(100)) +  CAST(ISNULL([CREATION_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([CREATED_BY],'0') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATE_LOGIN],'0') AS VARCHAR(100)) +  CAST(ISNULL([SALES_CREDIT_TYPE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([STATUS],'') AS VARCHAR(30)) +  CAST(ISNULL([START_DATE_ACTIVE],'') AS VARCHAR(100)) +  CAST(ISNULL([END_DATE_ACTIVE],'') AS VARCHAR(100)) +  CAST(ISNULL([GL_ID_REV],'0') AS VARCHAR(100)) +  CAST(ISNULL([GL_ID_FREIGHT],'0') AS VARCHAR(100)) +  CAST(ISNULL([GL_ID_REC],'0') AS VARCHAR(100)) +  CAST(ISNULL([SET_OF_BOOKS_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([SALESREP_NUMBER],'') AS VARCHAR(30)) +  CAST(ISNULL([ORG_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([EMAIL_ADDRESS],'') AS VARCHAR(240)) +  CAST(ISNULL([WH_UPDATE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([PERSON_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([SALES_TAX_GEOCODE],'') AS VARCHAR(30)) +  CAST(ISNULL([SALES_TAX_INSIDE_CITY_LIMITS],'') AS VARCHAR(1)) +  CAST(ISNULL([OBJECT_VERSION_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([ATTRIBUTE_CATEGORY],'') AS VARCHAR(30)) +  CAST(ISNULL([ATTRIBUTE1],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE2],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE3],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE4],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE5],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE6],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE7],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE8],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE9],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE10],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE11],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE12],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE13],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE14],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE15],'') AS VARCHAR(150)) +  CAST(ISNULL([SECURITY_GROUP_ID],'0') AS VARCHAR(100)) 
		),1)),3,32);


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO #SalesReps (
		  --<column-list>
		  [SALESREP_ID],
		  [RESOURCE_ID],
		  [LAST_UPDATE_DATE],
		  [LAST_UPDATED_BY],
		  [CREATION_DATE],
		  [CREATED_BY],
		  [LAST_UPDATE_LOGIN],
		  [SALES_CREDIT_TYPE_ID],
		  [NAME],
		  [STATUS],
		  [START_DATE_ACTIVE],
		  [END_DATE_ACTIVE],
		  [GL_ID_REV],
		  [GL_ID_FREIGHT],
		  [GL_ID_REC],
		  [SET_OF_BOOKS_ID],
		  [SALESREP_NUMBER],
		  [ORG_ID],
		  [EMAIL_ADDRESS],
		  [WH_UPDATE_DATE],
		  [PERSON_ID],
		  [SALES_TAX_GEOCODE],
		  [SALES_TAX_INSIDE_CITY_LIMITS],
		  [OBJECT_VERSION_NUMBER],
		  [ATTRIBUTE_CATEGORY],
		  [ATTRIBUTE1],
		  [ATTRIBUTE2],
		  [ATTRIBUTE3],
		  [ATTRIBUTE4],
		  [ATTRIBUTE5],
		  [ATTRIBUTE6],
		  [ATTRIBUTE7],
		  [ATTRIBUTE8],
		  [ATTRIBUTE9],
		  [ATTRIBUTE10],
		  [ATTRIBUTE11],
		  [ATTRIBUTE12],
		  [ATTRIBUTE13],
		  [ATTRIBUTE14],
		  [ATTRIBUTE15],
		  [SECURITY_GROUP_ID],
		  [Fingerprint]
	)
		SELECT 
			  --a.<column-list>
		  a.[SALESREP_ID],
		  a.[RESOURCE_ID],
		  a.[LAST_UPDATE_DATE],
		  a.[LAST_UPDATED_BY],
		  a.[CREATION_DATE],
		  a.[CREATED_BY],
		  a.[LAST_UPDATE_LOGIN],
		  a.[SALES_CREDIT_TYPE_ID],
		  a.[NAME],
		  a.[STATUS],
		  a.[START_DATE_ACTIVE],
		  a.[END_DATE_ACTIVE],
		  a.[GL_ID_REV],
		  a.[GL_ID_FREIGHT],
		  a.[GL_ID_REC],
		  a.[SET_OF_BOOKS_ID],
		  a.[SALESREP_NUMBER],
		  a.[ORG_ID],
		  a.[EMAIL_ADDRESS],
		  a.[WH_UPDATE_DATE],
		  a.[PERSON_ID],
		  a.[SALES_TAX_GEOCODE],
		  a.[SALES_TAX_INSIDE_CITY_LIMITS],
		  a.[OBJECT_VERSION_NUMBER],
		  a.[ATTRIBUTE_CATEGORY],
		  a.[ATTRIBUTE1],
		  a.[ATTRIBUTE2],
		  a.[ATTRIBUTE3],
		  a.[ATTRIBUTE4],
		  a.[ATTRIBUTE5],
		  a.[ATTRIBUTE6],
		  a.[ATTRIBUTE7],
		  a.[ATTRIBUTE8],
		  a.[ATTRIBUTE9],
		  a.[ATTRIBUTE10],
		  a.[ATTRIBUTE11],
		  a.[ATTRIBUTE12],
		  a.[ATTRIBUTE13],
		  a.[ATTRIBUTE14],
		  a.[ATTRIBUTE15],
		  a.[SECURITY_GROUP_ID],
		  a.[Fingerprint]
		FROM (
			MERGE Oracle.JTF_RS_SALESREPS b
			USING (SELECT * FROM #SalesReps) a
			ON a.[SALESREP_ID] = b.[SALESREP_ID] AND a.[ORG_ID] = b.[ORG_ID] AND b.CurrentRecord = 1 --swap with business key of table
			WHEN NOT MATCHED --BY TARGET 
			THEN INSERT (
				  --<column-list>
				  [SALESREP_ID],
				  [RESOURCE_ID],
				  [LAST_UPDATE_DATE],
				  [LAST_UPDATED_BY],
				  [CREATION_DATE],
				  [CREATED_BY],
				  [LAST_UPDATE_LOGIN],
				  [SALES_CREDIT_TYPE_ID],
				  [NAME],
				  [STATUS],
				  [START_DATE_ACTIVE],
				  [END_DATE_ACTIVE],
				  [GL_ID_REV],
				  [GL_ID_FREIGHT],
				  [GL_ID_REC],
				  [SET_OF_BOOKS_ID],
				  [SALESREP_NUMBER],
				  [ORG_ID],
				  [EMAIL_ADDRESS],
				  [WH_UPDATE_DATE],
				  [PERSON_ID],
				  [SALES_TAX_GEOCODE],
				  [SALES_TAX_INSIDE_CITY_LIMITS],
				  [OBJECT_VERSION_NUMBER],
				  [ATTRIBUTE_CATEGORY],
				  [ATTRIBUTE1],
				  [ATTRIBUTE2],
				  [ATTRIBUTE3],
				  [ATTRIBUTE4],
				  [ATTRIBUTE5],
				  [ATTRIBUTE6],
				  [ATTRIBUTE7],
				  [ATTRIBUTE8],
				  [ATTRIBUTE9],
				  [ATTRIBUTE10],
				  [ATTRIBUTE11],
				  [ATTRIBUTE12],
				  [ATTRIBUTE13],
				  [ATTRIBUTE14],
				  [ATTRIBUTE15],
				  [SECURITY_GROUP_ID],
				  [Fingerprint]
			)
			VALUES (
				  --a.<column-list>
				  a.[SALESREP_ID],
				  a.[RESOURCE_ID],
				  a.[LAST_UPDATE_DATE],
				  a.[LAST_UPDATED_BY],
				  a.[CREATION_DATE],
				  a.[CREATED_BY],
				  a.[LAST_UPDATE_LOGIN],
				  a.[SALES_CREDIT_TYPE_ID],
				  a.[NAME],
				  a.[STATUS],
				  a.[START_DATE_ACTIVE],
				  a.[END_DATE_ACTIVE],
				  a.[GL_ID_REV],
				  a.[GL_ID_FREIGHT],
				  a.[GL_ID_REC],
				  a.[SET_OF_BOOKS_ID],
				  a.[SALESREP_NUMBER],
				  a.[ORG_ID],
				  a.[EMAIL_ADDRESS],
				  a.[WH_UPDATE_DATE],
				  a.[PERSON_ID],
				  a.[SALES_TAX_GEOCODE],
				  a.[SALES_TAX_INSIDE_CITY_LIMITS],
				  a.[OBJECT_VERSION_NUMBER],
				  a.[ATTRIBUTE_CATEGORY],
				  a.[ATTRIBUTE1],
				  a.[ATTRIBUTE2],
				  a.[ATTRIBUTE3],
				  a.[ATTRIBUTE4],
				  a.[ATTRIBUTE5],
				  a.[ATTRIBUTE6],
				  a.[ATTRIBUTE7],
				  a.[ATTRIBUTE8],
				  a.[ATTRIBUTE9],
				  a.[ATTRIBUTE10],
				  a.[ATTRIBUTE11],
				  a.[ATTRIBUTE12],
				  a.[ATTRIBUTE13],
				  a.[ATTRIBUTE14],
				  a.[ATTRIBUTE15],
				  a.[SECURITY_GROUP_ID],
				  a.[Fingerprint]
			)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
			THEN UPDATE SET b.EndDate=GETDATE()
				,b.CurrentRecord=0
			OUTPUT 
				  --a.<column-list>
				  a.[SALESREP_ID],
				  a.[RESOURCE_ID],
				  a.[LAST_UPDATE_DATE],
				  a.[LAST_UPDATED_BY],
				  a.[CREATION_DATE],
				  a.[CREATED_BY],
				  a.[LAST_UPDATE_LOGIN],
				  a.[SALES_CREDIT_TYPE_ID],
				  a.[NAME],
				  a.[STATUS],
				  a.[START_DATE_ACTIVE],
				  a.[END_DATE_ACTIVE],
				  a.[GL_ID_REV],
				  a.[GL_ID_FREIGHT],
				  a.[GL_ID_REC],
				  a.[SET_OF_BOOKS_ID],
				  a.[SALESREP_NUMBER],
				  a.[ORG_ID],
				  a.[EMAIL_ADDRESS],
				  a.[WH_UPDATE_DATE],
				  a.[PERSON_ID],
				  a.[SALES_TAX_GEOCODE],
				  a.[SALES_TAX_INSIDE_CITY_LIMITS],
				  a.[OBJECT_VERSION_NUMBER],
				  a.[ATTRIBUTE_CATEGORY],
				  a.[ATTRIBUTE1],
				  a.[ATTRIBUTE2],
				  a.[ATTRIBUTE3],
				  a.[ATTRIBUTE4],
				  a.[ATTRIBUTE5],
				  a.[ATTRIBUTE6],
				  a.[ATTRIBUTE7],
				  a.[ATTRIBUTE8],
				  a.[ATTRIBUTE9],
				  a.[ATTRIBUTE10],
				  a.[ATTRIBUTE11],
				  a.[ATTRIBUTE12],
				  a.[ATTRIBUTE13],
				  a.[ATTRIBUTE14],
				  a.[ATTRIBUTE15],
				  a.[SECURITY_GROUP_ID],
				  a.[Fingerprint]
				  ,$Action AS Action
		) a
		WHERE Action = 'Update'
		;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #SalesReps

END
GO
