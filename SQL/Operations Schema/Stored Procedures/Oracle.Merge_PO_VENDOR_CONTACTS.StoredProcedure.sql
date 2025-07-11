USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_PO_VENDOR_CONTACTS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_PO_VENDOR_CONTACTS]
AS BEGIN

	CREATE TABLE #contacts(
		--<column-list>
		[VENDOR_CONTACT_ID] [float] NULL,
		[VENDOR_SITE_ID] [float] NULL,
		[LAST_UPDATE_DATE] [datetime2](7) NULL,
		[LAST_UPDATED_BY] [float] NULL,
		[LAST_UPDATE_LOGIN] [float] NULL,
		[CREATION_DATE] [datetime2](7) NULL,
		[CREATED_BY] [float] NULL,
		[FIRST_NAME] [nvarchar](45) NULL,
		[MIDDLE_NAME] [nvarchar](45) NULL,
		[LAST_NAME] [nvarchar](45) NULL,
		[PREFIX] [nvarchar](60) NULL,
		[TITLE] [nvarchar](90) NULL,
		[MAIL_STOP] [nvarchar](60) NULL,
		[AREA_CODE] [nvarchar](10) NULL,
		[PHONE] [nvarchar](40) NULL,
		[REQUEST_ID] [float] NULL,
		[PROGRAM_APPLICATION_ID] [float] NULL,
		[PROGRAM_ID] [float] NULL,
		[PROGRAM_UPDATE_DATE] [datetime2](7) NULL,
		[CONTACT_NAME_ALT] [nvarchar](320) NULL,
		[FIRST_NAME_ALT] [nvarchar](60) NULL,
		[LAST_NAME_ALT] [nvarchar](60) NULL,
		[DEPARTMENT] [nvarchar](60) NULL,
		[EMAIL_ADDRESS] [nvarchar](2000) NULL,
		[URL] [nvarchar](2000) NULL,
		[ALT_AREA_CODE] [nvarchar](10) NULL,
		[ALT_PHONE] [nvarchar](40) NULL,
		[FAX_AREA_CODE] [nvarchar](10) NULL,
		[FAX] [nvarchar](40) NULL,
		[INACTIVE_DATE] [datetime2](7) NULL,
		[PER_PARTY_ID] [numeric](15, 0) NULL,
		[RELATIONSHIP_ID] [numeric](15, 0) NULL,
		[REL_PARTY_ID] [numeric](15, 0) NULL,
		[PARTY_SITE_ID] [numeric](15, 0) NULL,
		[ORG_CONTACT_ID] [numeric](15, 0) NULL,
		[ORG_PARTY_SITE_ID] [numeric](15, 0) NULL,
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
		[VENDOR_ID] [float] NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) ON [PRIMARY]

	--insert steps to log what is happening.  If the job fails, we can check the ETLLog and see where it failed.
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()
	
	INSERT INTO #Contacts (
		  --<column-list>
	   [VENDOR_CONTACT_ID]
      ,[VENDOR_SITE_ID]
      ,[LAST_UPDATE_DATE]
      ,[LAST_UPDATED_BY]
      ,[LAST_UPDATE_LOGIN]
      ,[CREATION_DATE]
      ,[CREATED_BY]
      ,[FIRST_NAME]
      ,[MIDDLE_NAME]
      ,[LAST_NAME]
      ,[PREFIX]
      ,[TITLE]
      ,[MAIL_STOP]
      ,[AREA_CODE]
      ,[PHONE]
      ,[REQUEST_ID]
      ,[PROGRAM_APPLICATION_ID]
      ,[PROGRAM_ID]
      ,[PROGRAM_UPDATE_DATE]
      ,[CONTACT_NAME_ALT]
      ,[FIRST_NAME_ALT]
      ,[LAST_NAME_ALT]
      ,[DEPARTMENT]
      ,[EMAIL_ADDRESS]
      ,[URL]
      ,[ALT_AREA_CODE]
      ,[ALT_PHONE]
      ,[FAX_AREA_CODE]
      ,[FAX]
      ,[INACTIVE_DATE]
      ,[PER_PARTY_ID]
      ,[RELATIONSHIP_ID]
      ,[REL_PARTY_ID]
      ,[PARTY_SITE_ID]
      ,[ORG_CONTACT_ID]
      ,[ORG_PARTY_SITE_ID]
      ,[ATTRIBUTE_CATEGORY]
      ,[ATTRIBUTE1]
      ,[ATTRIBUTE2]
      ,[ATTRIBUTE3]
      ,[ATTRIBUTE4]
      ,[ATTRIBUTE5]
      ,[ATTRIBUTE6]
      ,[ATTRIBUTE7]
      ,[ATTRIBUTE8]
      ,[ATTRIBUTE9]
      ,[ATTRIBUTE10]
      ,[ATTRIBUTE11]
      ,[ATTRIBUTE12]
      ,[ATTRIBUTE13]
      ,[ATTRIBUTE14]
      ,[ATTRIBUTE15]
      ,[VENDOR_ID]
      ,[Fingerprint]
	  )
	SELECT 
		 --<column-list>
		   [VENDOR_CONTACT_ID]
		  ,[VENDOR_SITE_ID]
		  ,[LAST_UPDATE_DATE]
		  ,[LAST_UPDATED_BY]
		  ,[LAST_UPDATE_LOGIN]
		  ,[CREATION_DATE]
		  ,[CREATED_BY]
		  ,[FIRST_NAME]
		  ,[MIDDLE_NAME]
		  ,[LAST_NAME]
		  ,[PREFIX]
		  ,[TITLE]
		  ,[MAIL_STOP]
		  ,[AREA_CODE]
		  ,[PHONE]
		  ,[REQUEST_ID]
		  ,[PROGRAM_APPLICATION_ID]
		  ,[PROGRAM_ID]
		  ,[PROGRAM_UPDATE_DATE]
		  ,[CONTACT_NAME_ALT]
		  ,[FIRST_NAME_ALT]
		  ,[LAST_NAME_ALT]
		  ,[DEPARTMENT]
		  ,[EMAIL_ADDRESS]
		  ,[URL]
		  ,[ALT_AREA_CODE]
		  ,[ALT_PHONE]
		  ,[FAX_AREA_CODE]
		  ,[FAX]
		  ,[INACTIVE_DATE]
		  ,[PER_PARTY_ID]
		  ,[RELATIONSHIP_ID]
		  ,[REL_PARTY_ID]
		  ,[PARTY_SITE_ID]
		  ,[ORG_CONTACT_ID]
		  ,[ORG_PARTY_SITE_ID]
		  ,[ATTRIBUTE_CATEGORY]
		  ,[ATTRIBUTE1]
		  ,[ATTRIBUTE2]
		  ,[ATTRIBUTE3]
		  ,[ATTRIBUTE4]
		  ,[ATTRIBUTE5]
		  ,[ATTRIBUTE6]
		  ,[ATTRIBUTE7]
		  ,[ATTRIBUTE8]
		  ,[ATTRIBUTE9]
		  ,[ATTRIBUTE10]
		  ,[ATTRIBUTE11]
		  ,[ATTRIBUTE12]
		  ,[ATTRIBUTE13]
		  ,[ATTRIBUTE14]
		  ,[ATTRIBUTE15]
		  ,[VENDOR_ID]
		  ,'XXX' AS [Fingerprint]
	FROM OPENQUERY(QA,'
		SELECT povc.* 
		FROM PO_VENDOR_CONTACTS povc 
			LEFT JOIN PO_HEADERS_ALL poh ON povc.VENDOR_CONTACT_ID = poh.VENDOR_CONTACT_ID 
		WHERE poh.ATTRIBUTE1 IS NOT NULL
			OR poh.ATTRIBUTE2 IS NOT NULL
			OR poh.ATTRIBUTE3 IS NOT NULL
			OR poh.ATTRIBUTE4 IS NOT NULL
			OR poh.ATTRIBUTE5 IS NOT NULL
			OR poh.ATTRIBUTE6 IS NOT NULL
			OR poh.ATTRIBUTE7 IS NOT NULL
	') --8000 character limit for openqueries

	/*	--run this and replace @columnList below
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('PO_VENDOR_CONTACTS','Oracle') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #contacts
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			 CAST(ISNULL([VENDOR_CONTACT_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([VENDOR_SITE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATED_BY],'0') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATE_LOGIN],'0') AS VARCHAR(100)) +  CAST(ISNULL([CREATION_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([CREATED_BY],'0') AS VARCHAR(100)) +  CAST(ISNULL([FIRST_NAME],'') AS VARCHAR(45)) +  CAST(ISNULL([MIDDLE_NAME],'') AS VARCHAR(45)) +  CAST(ISNULL([LAST_NAME],'') AS VARCHAR(45)) +  CAST(ISNULL([PREFIX],'') AS VARCHAR(60)) +  CAST(ISNULL([TITLE],'') AS VARCHAR(90)) +  CAST(ISNULL([MAIL_STOP],'') AS VARCHAR(60)) +  CAST(ISNULL([AREA_CODE],'') AS VARCHAR(10)) +  CAST(ISNULL([PHONE],'') AS VARCHAR(40)) +  CAST(ISNULL([REQUEST_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PROGRAM_APPLICATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PROGRAM_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PROGRAM_UPDATE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([CONTACT_NAME_ALT],'') AS VARCHAR(320)) +  CAST(ISNULL([FIRST_NAME_ALT],'') AS VARCHAR(60)) +  CAST(ISNULL([LAST_NAME_ALT],'') AS VARCHAR(60)) +  CAST(ISNULL([DEPARTMENT],'') AS VARCHAR(60)) +  CAST(ISNULL([EMAIL_ADDRESS],'') AS VARCHAR(2000)) +  CAST(ISNULL([URL],'') AS VARCHAR(2000)) +  CAST(ISNULL([ALT_AREA_CODE],'') AS VARCHAR(10)) +  CAST(ISNULL([ALT_PHONE],'') AS VARCHAR(40)) +  CAST(ISNULL([FAX_AREA_CODE],'') AS VARCHAR(10)) +  CAST(ISNULL([FAX],'') AS VARCHAR(40)) +  CAST(ISNULL([INACTIVE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([PER_PARTY_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([RELATIONSHIP_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([REL_PARTY_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PARTY_SITE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORG_CONTACT_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORG_PARTY_SITE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ATTRIBUTE_CATEGORY],'') AS VARCHAR(30)) +  CAST(ISNULL([ATTRIBUTE1],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE2],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE3],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE4],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE5],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE6],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE7],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE8],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE9],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE10],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE11],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE12],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE13],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE14],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE15],'') AS VARCHAR(150)) +  CAST(ISNULL([VENDOR_ID],'0') AS VARCHAR(100)) 
		),1)),3,32);


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO #Contacts (
		  --<column-list>
	   [VENDOR_CONTACT_ID]
      ,[VENDOR_SITE_ID]
      ,[LAST_UPDATE_DATE]
      ,[LAST_UPDATED_BY]
      ,[LAST_UPDATE_LOGIN]
      ,[CREATION_DATE]
      ,[CREATED_BY]
      ,[FIRST_NAME]
      ,[MIDDLE_NAME]
      ,[LAST_NAME]
      ,[PREFIX]
      ,[TITLE]
      ,[MAIL_STOP]
      ,[AREA_CODE]
      ,[PHONE]
      ,[REQUEST_ID]
      ,[PROGRAM_APPLICATION_ID]
      ,[PROGRAM_ID]
      ,[PROGRAM_UPDATE_DATE]
      ,[CONTACT_NAME_ALT]
      ,[FIRST_NAME_ALT]
      ,[LAST_NAME_ALT]
      ,[DEPARTMENT]
      ,[EMAIL_ADDRESS]
      ,[URL]
      ,[ALT_AREA_CODE]
      ,[ALT_PHONE]
      ,[FAX_AREA_CODE]
      ,[FAX]
      ,[INACTIVE_DATE]
      ,[PER_PARTY_ID]
      ,[RELATIONSHIP_ID]
      ,[REL_PARTY_ID]
      ,[PARTY_SITE_ID]
      ,[ORG_CONTACT_ID]
      ,[ORG_PARTY_SITE_ID]
      ,[ATTRIBUTE_CATEGORY]
      ,[ATTRIBUTE1]
      ,[ATTRIBUTE2]
      ,[ATTRIBUTE3]
      ,[ATTRIBUTE4]
      ,[ATTRIBUTE5]
      ,[ATTRIBUTE6]
      ,[ATTRIBUTE7]
      ,[ATTRIBUTE8]
      ,[ATTRIBUTE9]
      ,[ATTRIBUTE10]
      ,[ATTRIBUTE11]
      ,[ATTRIBUTE12]
      ,[ATTRIBUTE13]
      ,[ATTRIBUTE14]
      ,[ATTRIBUTE15]
      ,[VENDOR_ID]
      ,[Fingerprint]
	)
		SELECT 
			  --a.<column-list>
			   a.[VENDOR_CONTACT_ID]
			  ,a.[VENDOR_SITE_ID]
			  ,a.[LAST_UPDATE_DATE]
			  ,a.[LAST_UPDATED_BY]
			  ,a.[LAST_UPDATE_LOGIN]
			  ,a.[CREATION_DATE]
			  ,a.[CREATED_BY]
			  ,a.[FIRST_NAME]
			  ,a.[MIDDLE_NAME]
			  ,a.[LAST_NAME]
			  ,a.[PREFIX]
			  ,a.[TITLE]
			  ,a.[MAIL_STOP]
			  ,a.[AREA_CODE]
			  ,a.[PHONE]
			  ,a.[REQUEST_ID]
			  ,a.[PROGRAM_APPLICATION_ID]
			  ,a.[PROGRAM_ID]
			  ,a.[PROGRAM_UPDATE_DATE]
			  ,a.[CONTACT_NAME_ALT]
			  ,a.[FIRST_NAME_ALT]
			  ,a.[LAST_NAME_ALT]
			  ,a.[DEPARTMENT]
			  ,a.[EMAIL_ADDRESS]
			  ,a.[URL]
			  ,a.[ALT_AREA_CODE]
			  ,a.[ALT_PHONE]
			  ,a.[FAX_AREA_CODE]
			  ,a.[FAX]
			  ,a.[INACTIVE_DATE]
			  ,a.[PER_PARTY_ID]
			  ,a.[RELATIONSHIP_ID]
			  ,a.[REL_PARTY_ID]
			  ,a.[PARTY_SITE_ID]
			  ,a.[ORG_CONTACT_ID]
			  ,a.[ORG_PARTY_SITE_ID]
			  ,a.[ATTRIBUTE_CATEGORY]
			  ,a.[ATTRIBUTE1]
			  ,a.[ATTRIBUTE2]
			  ,a.[ATTRIBUTE3]
			  ,a.[ATTRIBUTE4]
			  ,a.[ATTRIBUTE5]
			  ,a.[ATTRIBUTE6]
			  ,a.[ATTRIBUTE7]
			  ,a.[ATTRIBUTE8]
			  ,a.[ATTRIBUTE9]
			  ,a.[ATTRIBUTE10]
			  ,a.[ATTRIBUTE11]
			  ,a.[ATTRIBUTE12]
			  ,a.[ATTRIBUTE13]
			  ,a.[ATTRIBUTE14]
			  ,a.[ATTRIBUTE15]
			  ,a.[VENDOR_ID]
			  ,a.[Fingerprint]
		FROM (
			MERGE Oracle.PO_VENDOR_CONTACTS b
			USING (SELECT * FROM #Contacts) a
			ON a.[VENDOR_CONTACT_ID] = b.[VENDOR_CONTACT_ID] AND b.CurrentRecord = 1 --swap with business key of table
			WHEN NOT MATCHED --BY TARGET 
			THEN INSERT (
				  --<column-list>
			   [VENDOR_CONTACT_ID]
			  ,[VENDOR_SITE_ID]
			  ,[LAST_UPDATE_DATE]
			  ,[LAST_UPDATED_BY]
			  ,[LAST_UPDATE_LOGIN]
			  ,[CREATION_DATE]
			  ,[CREATED_BY]
			  ,[FIRST_NAME]
			  ,[MIDDLE_NAME]
			  ,[LAST_NAME]
			  ,[PREFIX]
			  ,[TITLE]
			  ,[MAIL_STOP]
			  ,[AREA_CODE]
			  ,[PHONE]
			  ,[REQUEST_ID]
			  ,[PROGRAM_APPLICATION_ID]
			  ,[PROGRAM_ID]
			  ,[PROGRAM_UPDATE_DATE]
			  ,[CONTACT_NAME_ALT]
			  ,[FIRST_NAME_ALT]
			  ,[LAST_NAME_ALT]
			  ,[DEPARTMENT]
			  ,[EMAIL_ADDRESS]
			  ,[URL]
			  ,[ALT_AREA_CODE]
			  ,[ALT_PHONE]
			  ,[FAX_AREA_CODE]
			  ,[FAX]
			  ,[INACTIVE_DATE]
			  ,[PER_PARTY_ID]
			  ,[RELATIONSHIP_ID]
			  ,[REL_PARTY_ID]
			  ,[PARTY_SITE_ID]
			  ,[ORG_CONTACT_ID]
			  ,[ORG_PARTY_SITE_ID]
			  ,[ATTRIBUTE_CATEGORY]
			  ,[ATTRIBUTE1]
			  ,[ATTRIBUTE2]
			  ,[ATTRIBUTE3]
			  ,[ATTRIBUTE4]
			  ,[ATTRIBUTE5]
			  ,[ATTRIBUTE6]
			  ,[ATTRIBUTE7]
			  ,[ATTRIBUTE8]
			  ,[ATTRIBUTE9]
			  ,[ATTRIBUTE10]
			  ,[ATTRIBUTE11]
			  ,[ATTRIBUTE12]
			  ,[ATTRIBUTE13]
			  ,[ATTRIBUTE14]
			  ,[ATTRIBUTE15]
			  ,[VENDOR_ID]
			  ,[Fingerprint]			
			)
			VALUES (
				  --a.<column-list>
				   a.[VENDOR_CONTACT_ID]
				  ,a.[VENDOR_SITE_ID]
				  ,a.[LAST_UPDATE_DATE]
				  ,a.[LAST_UPDATED_BY]
				  ,a.[LAST_UPDATE_LOGIN]
				  ,a.[CREATION_DATE]
				  ,a.[CREATED_BY]
				  ,a.[FIRST_NAME]
				  ,a.[MIDDLE_NAME]
				  ,a.[LAST_NAME]
				  ,a.[PREFIX]
				  ,a.[TITLE]
				  ,a.[MAIL_STOP]
				  ,a.[AREA_CODE]
				  ,a.[PHONE]
				  ,a.[REQUEST_ID]
				  ,a.[PROGRAM_APPLICATION_ID]
				  ,a.[PROGRAM_ID]
				  ,a.[PROGRAM_UPDATE_DATE]
				  ,a.[CONTACT_NAME_ALT]
				  ,a.[FIRST_NAME_ALT]
				  ,a.[LAST_NAME_ALT]
				  ,a.[DEPARTMENT]
				  ,a.[EMAIL_ADDRESS]
				  ,a.[URL]
				  ,a.[ALT_AREA_CODE]
				  ,a.[ALT_PHONE]
				  ,a.[FAX_AREA_CODE]
				  ,a.[FAX]
				  ,a.[INACTIVE_DATE]
				  ,a.[PER_PARTY_ID]
				  ,a.[RELATIONSHIP_ID]
				  ,a.[REL_PARTY_ID]
				  ,a.[PARTY_SITE_ID]
				  ,a.[ORG_CONTACT_ID]
				  ,a.[ORG_PARTY_SITE_ID]
				  ,a.[ATTRIBUTE_CATEGORY]
				  ,a.[ATTRIBUTE1]
				  ,a.[ATTRIBUTE2]
				  ,a.[ATTRIBUTE3]
				  ,a.[ATTRIBUTE4]
				  ,a.[ATTRIBUTE5]
				  ,a.[ATTRIBUTE6]
				  ,a.[ATTRIBUTE7]
				  ,a.[ATTRIBUTE8]
				  ,a.[ATTRIBUTE9]
				  ,a.[ATTRIBUTE10]
				  ,a.[ATTRIBUTE11]
				  ,a.[ATTRIBUTE12]
				  ,a.[ATTRIBUTE13]
				  ,a.[ATTRIBUTE14]
				  ,a.[ATTRIBUTE15]
				  ,a.[VENDOR_ID]
				  ,a.[Fingerprint]
			)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
			THEN UPDATE SET b.EndDate=GETDATE()
				,b.CurrentRecord=0
			OUTPUT 
				  --a.<column-list>
				   a.[VENDOR_CONTACT_ID]
				  ,a.[VENDOR_SITE_ID]
				  ,a.[LAST_UPDATE_DATE]
				  ,a.[LAST_UPDATED_BY]
				  ,a.[LAST_UPDATE_LOGIN]
				  ,a.[CREATION_DATE]
				  ,a.[CREATED_BY]
				  ,a.[FIRST_NAME]
				  ,a.[MIDDLE_NAME]
				  ,a.[LAST_NAME]
				  ,a.[PREFIX]
				  ,a.[TITLE]
				  ,a.[MAIL_STOP]
				  ,a.[AREA_CODE]
				  ,a.[PHONE]
				  ,a.[REQUEST_ID]
				  ,a.[PROGRAM_APPLICATION_ID]
				  ,a.[PROGRAM_ID]
				  ,a.[PROGRAM_UPDATE_DATE]
				  ,a.[CONTACT_NAME_ALT]
				  ,a.[FIRST_NAME_ALT]
				  ,a.[LAST_NAME_ALT]
				  ,a.[DEPARTMENT]
				  ,a.[EMAIL_ADDRESS]
				  ,a.[URL]
				  ,a.[ALT_AREA_CODE]
				  ,a.[ALT_PHONE]
				  ,a.[FAX_AREA_CODE]
				  ,a.[FAX]
				  ,a.[INACTIVE_DATE]
				  ,a.[PER_PARTY_ID]
				  ,a.[RELATIONSHIP_ID]
				  ,a.[REL_PARTY_ID]
				  ,a.[PARTY_SITE_ID]
				  ,a.[ORG_CONTACT_ID]
				  ,a.[ORG_PARTY_SITE_ID]
				  ,a.[ATTRIBUTE_CATEGORY]
				  ,a.[ATTRIBUTE1]
				  ,a.[ATTRIBUTE2]
				  ,a.[ATTRIBUTE3]
				  ,a.[ATTRIBUTE4]
				  ,a.[ATTRIBUTE5]
				  ,a.[ATTRIBUTE6]
				  ,a.[ATTRIBUTE7]
				  ,a.[ATTRIBUTE8]
				  ,a.[ATTRIBUTE9]
				  ,a.[ATTRIBUTE10]
				  ,a.[ATTRIBUTE11]
				  ,a.[ATTRIBUTE12]
				  ,a.[ATTRIBUTE13]
				  ,a.[ATTRIBUTE14]
				  ,a.[ATTRIBUTE15]
				  ,a.[VENDOR_ID]
				  ,a.[Fingerprint]
				  ,$Action AS Action
		) a
		WHERE Action = 'Update'
		;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #Contacts

END
GO
