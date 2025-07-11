USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_MSC_SR_ASSIGNMENTS_V]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_MSC_SR_ASSIGNMENTS_V] 
AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	DROP TABLE IF EXISTS #sourcingRules

	CREATE TABLE #sourcingRules (
		[ROW_ID] [char](18) NULL,
		[ASSIGNMENT_ID] [float] NULL,
		[ASSIGNMENT_SET_ID] [float] NULL,
		[ASSIGNMENT_TYPE] [float] NULL,
		[SR_INSTANCE_ID] [float] NULL,
		[SR_ASSIGNMENT_ID] [float] NULL,
		[SR_ASSIGNMENT_INSTANCE_ID] [float] NULL,
		[ORGANIZATION_ID] [float] NULL,
		[ORGANIZATION_CODE] [nvarchar](4000) NULL,
		[CUSTOMER_ID] [float] NULL,
		[CUSTOMER_NAME] [nvarchar](4000) NULL,
		[SHIP_TO_SITE_ID] [float] NULL,
		[SHIP_TO_ADDRESS] [nvarchar](1600) NULL,
		[ENTITY_NAME] [nvarchar](4000) NULL,
		[DESCRIPTION] [nvarchar](4000) NULL,
		[SOURCING_RULE_TYPE] [float] NULL,
		[SOURCING_RULE_TYPE_TEXT] [nvarchar](80) NULL,
		[SOURCING_RULE_ID] [float] NULL,
		[SOURCING_RULE_NAME] [nvarchar](80) NULL,
		[CATEGORY_NAME] [nvarchar](163) NULL,
		[CATEGORY_SET_ID] [float] NULL,
		[INVENTORY_ITEM_ID] [float] NULL,
		[LAST_UPDATE_DATE] [datetime2](7) NULL,
		[LAST_UPDATED_BY] [float] NULL,
		[CREATION_DATE] [datetime2](7) NULL,
		[CREATED_BY] [float] NULL,
		[LAST_UPDATE_LOGIN] [float] NULL,
		[REQUEST_ID] [float] NULL,
		[PROGRAM_APPLICATION_ID] [float] NULL,
		[PROGRAM_ID] [float] NULL,
		[PROGRAM_UPDATE_DATE] [datetime2](7) NULL,
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
		[REGION_ID] [float] NULL,
		[REGION_CODE] [nvarchar](304) NULL,
		[COLLECTED_FLAG] [float] NULL,
		[ALLOCATION_RULE_ID] [float] NULL,
		[ALLOCATION_RULE_NAME] [nvarchar](30) NULL,
		[ITEM_TYPE_ID] [float] NULL,
		[ITEM_TYPE_VALUE] [float] NULL,
		[ITEM_TYPE_VALUE_TEXT] [nvarchar](4000) NULL,
		[Fingerprint] [VARCHAR](32) NOT NULL
	)

	--SELECT * FROM OPENQUERY(PROD,'SELECT * FROM MSC_SR_ASSIGNMENTS_V')

	INSERT INTO #sourcingRules
	SELECT [ROW_ID]
      ,[ASSIGNMENT_ID]
      ,[ASSIGNMENT_SET_ID]
      ,[ASSIGNMENT_TYPE]
      ,[SR_INSTANCE_ID]
      ,[SR_ASSIGNMENT_ID]
      ,[SR_ASSIGNMENT_INSTANCE_ID]
      ,[ORGANIZATION_ID]
      ,[ORGANIZATION_CODE]
      ,[CUSTOMER_ID]
      ,[CUSTOMER_NAME]
      ,[SHIP_TO_SITE_ID]
      ,[SHIP_TO_ADDRESS]
      ,[ENTITY_NAME]
      ,[DESCRIPTION]
      ,[SOURCING_RULE_TYPE]
      ,[SOURCING_RULE_TYPE_TEXT]
      ,[SOURCING_RULE_ID]
      ,[SOURCING_RULE_NAME]
      ,[CATEGORY_NAME]
      ,[CATEGORY_SET_ID]
      ,[INVENTORY_ITEM_ID]
      ,[LAST_UPDATE_DATE]
      ,[LAST_UPDATED_BY]
      ,[CREATION_DATE]
      ,[CREATED_BY]
      ,[LAST_UPDATE_LOGIN]
      ,[REQUEST_ID]
      ,[PROGRAM_APPLICATION_ID]
      ,[PROGRAM_ID]
      ,[PROGRAM_UPDATE_DATE]
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
      ,[REGION_ID]
      ,[REGION_CODE]
      ,[COLLECTED_FLAG]
      ,[ALLOCATION_RULE_ID]
      ,[ALLOCATION_RULE_NAME]
      ,[ITEM_TYPE_ID]
      ,[ITEM_TYPE_VALUE]
      ,[ITEM_TYPE_VALUE_TEXT]
	  ,'XXX' AS Fingerprint
	FROM OPENQUERY(PROD,
	'SELECT 
	   ROW_ID
      ,ASSIGNMENT_ID
      ,ASSIGNMENT_SET_ID
      ,ASSIGNMENT_TYPE
      ,SR_INSTANCE_ID
      ,SR_ASSIGNMENT_ID
      ,SR_ASSIGNMENT_INSTANCE_ID
      ,ORGANIZATION_ID
      ,ORGANIZATION_CODE
      ,CUSTOMER_ID
      ,CUSTOMER_NAME
      ,SHIP_TO_SITE_ID
      ,SHIP_TO_ADDRESS
      ,ENTITY_NAME
      ,DESCRIPTION
      ,SOURCING_RULE_TYPE
      ,SOURCING_RULE_TYPE_TEXT
      ,SOURCING_RULE_ID
      ,SOURCING_RULE_NAME
      ,CATEGORY_NAME
      ,CATEGORY_SET_ID
      ,INVENTORY_ITEM_ID
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,REQUEST_ID
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_ID
      ,PROGRAM_UPDATE_DATE
      ,ATTRIBUTE_CATEGORY
      ,ATTRIBUTE1
      ,ATTRIBUTE2
      ,ATTRIBUTE3
      ,ATTRIBUTE4
      ,ATTRIBUTE5
      ,ATTRIBUTE6
      ,ATTRIBUTE7
      ,ATTRIBUTE8
      ,ATTRIBUTE9
      ,ATTRIBUTE10
      ,ATTRIBUTE11
      ,ATTRIBUTE12
      ,ATTRIBUTE13
      ,ATTRIBUTE14
      ,ATTRIBUTE15
      ,REGION_ID
      ,REGION_CODE
      ,COLLECTED_FLAG
      ,ALLOCATION_RULE_ID
      ,ALLOCATION_RULE_NAME
      ,ITEM_TYPE_ID
      ,ITEM_TYPE_VALUE
      ,ITEM_TYPE_VALUE_TEXT 
	FROM MSC_SR_ASSIGNMENTS_V
	'
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()
	
 	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('MSC_SR_ASSIGNMENTS_V','Oracle') SELECT @columnList
	*/
	UPDATE #sourcingRules
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			CAST(ISNULL([ROW_ID],'') AS VARCHAR(18)) +  CAST(ISNULL([ASSIGNMENT_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ASSIGNMENT_SET_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ASSIGNMENT_TYPE],'0') AS VARCHAR(100)) +  CAST(ISNULL([SR_INSTANCE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([SR_ASSIGNMENT_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([SR_ASSIGNMENT_INSTANCE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORGANIZATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORGANIZATION_CODE],'') AS VARCHAR(4000)) +  CAST(ISNULL([CUSTOMER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([CUSTOMER_NAME],'') AS VARCHAR(4000)) +  CAST(ISNULL([SHIP_TO_SITE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([SHIP_TO_ADDRESS],'') AS VARCHAR(1600)) +  CAST(ISNULL([ENTITY_NAME],'') AS VARCHAR(4000)) +  CAST(ISNULL([DESCRIPTION],'') AS VARCHAR(4000)) +  CAST(ISNULL([SOURCING_RULE_TYPE],'0') AS VARCHAR(100)) +  CAST(ISNULL([SOURCING_RULE_TYPE_TEXT],'') AS VARCHAR(80)) +  CAST(ISNULL([SOURCING_RULE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([SOURCING_RULE_NAME],'') AS VARCHAR(80)) +  CAST(ISNULL([CATEGORY_NAME],'') AS VARCHAR(163)) +  CAST(ISNULL([CATEGORY_SET_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([INVENTORY_ITEM_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATED_BY],'0') AS VARCHAR(100)) +  CAST(ISNULL([CREATION_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([CREATED_BY],'0') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATE_LOGIN],'0') AS VARCHAR(100)) +  CAST(ISNULL([REQUEST_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PROGRAM_APPLICATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PROGRAM_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PROGRAM_UPDATE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([ATTRIBUTE_CATEGORY],'') AS VARCHAR(30)) +  CAST(ISNULL([ATTRIBUTE1],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE2],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE3],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE4],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE5],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE6],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE7],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE8],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE9],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE10],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE11],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE12],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE13],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE14],'') AS VARCHAR(150)) +  CAST(ISNULL([ATTRIBUTE15],'') AS VARCHAR(150)) +  CAST(ISNULL([REGION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([REGION_CODE],'') AS VARCHAR(304)) +  CAST(ISNULL([COLLECTED_FLAG],'0') AS VARCHAR(100)) +  CAST(ISNULL([ALLOCATION_RULE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ALLOCATION_RULE_NAME],'') AS VARCHAR(30)) +  CAST(ISNULL([ITEM_TYPE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ITEM_TYPE_VALUE],'0') AS VARCHAR(100)) +  CAST(ISNULL([ITEM_TYPE_VALUE_TEXT],'') AS VARCHAR(4000)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.MSC_SR_ASSIGNMENTS_V (
	   [ROW_ID]
      ,[ASSIGNMENT_ID]
      ,[ASSIGNMENT_SET_ID]
      ,[ASSIGNMENT_TYPE]
      ,[SR_INSTANCE_ID]
      ,[SR_ASSIGNMENT_ID]
      ,[SR_ASSIGNMENT_INSTANCE_ID]
      ,[ORGANIZATION_ID]
      ,[ORGANIZATION_CODE]
      ,[CUSTOMER_ID]
      ,[CUSTOMER_NAME]
      ,[SHIP_TO_SITE_ID]
      ,[SHIP_TO_ADDRESS]
      ,[ENTITY_NAME]
      ,[DESCRIPTION]
      ,[SOURCING_RULE_TYPE]
      ,[SOURCING_RULE_TYPE_TEXT]
      ,[SOURCING_RULE_ID]
      ,[SOURCING_RULE_NAME]
      ,[CATEGORY_NAME]
      ,[CATEGORY_SET_ID]
      ,[INVENTORY_ITEM_ID]
      ,[LAST_UPDATE_DATE]
      ,[LAST_UPDATED_BY]
      ,[CREATION_DATE]
      ,[CREATED_BY]
      ,[LAST_UPDATE_LOGIN]
      ,[REQUEST_ID]
      ,[PROGRAM_APPLICATION_ID]
      ,[PROGRAM_ID]
      ,[PROGRAM_UPDATE_DATE]
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
      ,[REGION_ID]
      ,[REGION_CODE]
      ,[COLLECTED_FLAG]
      ,[ALLOCATION_RULE_ID]
      ,[ALLOCATION_RULE_NAME]
      ,[ITEM_TYPE_ID]
      ,[ITEM_TYPE_VALUE]
      ,[ITEM_TYPE_VALUE_TEXT]
	  ,[Fingerprint]
	)
	SELECT 
	   a.[ROW_ID]
      ,a.[ASSIGNMENT_ID]
      ,a.[ASSIGNMENT_SET_ID]
      ,a.[ASSIGNMENT_TYPE]
      ,a.[SR_INSTANCE_ID]
      ,a.[SR_ASSIGNMENT_ID]
      ,a.[SR_ASSIGNMENT_INSTANCE_ID]
      ,a.[ORGANIZATION_ID]
      ,a.[ORGANIZATION_CODE]
      ,a.[CUSTOMER_ID]
      ,a.[CUSTOMER_NAME]
      ,a.[SHIP_TO_SITE_ID]
      ,a.[SHIP_TO_ADDRESS]
      ,a.[ENTITY_NAME]
      ,a.[DESCRIPTION]
      ,a.[SOURCING_RULE_TYPE]
      ,a.[SOURCING_RULE_TYPE_TEXT]
      ,a.[SOURCING_RULE_ID]
      ,a.[SOURCING_RULE_NAME]
      ,a.[CATEGORY_NAME]
      ,a.[CATEGORY_SET_ID]
      ,a.[INVENTORY_ITEM_ID]
      ,a.[LAST_UPDATE_DATE]
      ,a.[LAST_UPDATED_BY]
      ,a.[CREATION_DATE]
      ,a.[CREATED_BY]
      ,a.[LAST_UPDATE_LOGIN]
      ,a.[REQUEST_ID]
      ,a.[PROGRAM_APPLICATION_ID]
      ,a.[PROGRAM_ID]
      ,a.[PROGRAM_UPDATE_DATE]
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
      ,a.[REGION_ID]
      ,a.[REGION_CODE]
      ,a.[COLLECTED_FLAG]
      ,a.[ALLOCATION_RULE_ID]
      ,a.[ALLOCATION_RULE_NAME]
      ,a.[ITEM_TYPE_ID]
      ,a.[ITEM_TYPE_VALUE]
      ,a.[ITEM_TYPE_VALUE_TEXT]
	  ,a.[Fingerprint]
	FROM (
		MERGE Oracle.MSC_SR_ASSIGNMENTS_V b
		USING (SELECT * FROM #sourcingRules) a
		ON a.ROW_ID = b.ROW_ID COLLATE Latin1_General_100_CS_AS AND b.CurrentRecord = 1 --swap with business key of table
		WHEN NOT MATCHED --BY TARGET 
		THEN INSERT (
		   [ROW_ID]
		  ,[ASSIGNMENT_ID]
		  ,[ASSIGNMENT_SET_ID]
		  ,[ASSIGNMENT_TYPE]
		  ,[SR_INSTANCE_ID]
		  ,[SR_ASSIGNMENT_ID]
		  ,[SR_ASSIGNMENT_INSTANCE_ID]
		  ,[ORGANIZATION_ID]
		  ,[ORGANIZATION_CODE]
		  ,[CUSTOMER_ID]
		  ,[CUSTOMER_NAME]
		  ,[SHIP_TO_SITE_ID]
		  ,[SHIP_TO_ADDRESS]
		  ,[ENTITY_NAME]
		  ,[DESCRIPTION]
		  ,[SOURCING_RULE_TYPE]
		  ,[SOURCING_RULE_TYPE_TEXT]
		  ,[SOURCING_RULE_ID]
		  ,[SOURCING_RULE_NAME]
		  ,[CATEGORY_NAME]
		  ,[CATEGORY_SET_ID]
		  ,[INVENTORY_ITEM_ID]
		  ,[LAST_UPDATE_DATE]
		  ,[LAST_UPDATED_BY]
		  ,[CREATION_DATE]
		  ,[CREATED_BY]
		  ,[LAST_UPDATE_LOGIN]
		  ,[REQUEST_ID]
		  ,[PROGRAM_APPLICATION_ID]
		  ,[PROGRAM_ID]
		  ,[PROGRAM_UPDATE_DATE]
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
		  ,[REGION_ID]
		  ,[REGION_CODE]
		  ,[COLLECTED_FLAG]
		  ,[ALLOCATION_RULE_ID]
		  ,[ALLOCATION_RULE_NAME]
		  ,[ITEM_TYPE_ID]
		  ,[ITEM_TYPE_VALUE]
		  ,[ITEM_TYPE_VALUE_TEXT]
		  ,[Fingerprint]
		)
		VALUES (
		   a.[ROW_ID]
		  ,a.[ASSIGNMENT_ID]
		  ,a.[ASSIGNMENT_SET_ID]
		  ,a.[ASSIGNMENT_TYPE]
		  ,a.[SR_INSTANCE_ID]
		  ,a.[SR_ASSIGNMENT_ID]
		  ,a.[SR_ASSIGNMENT_INSTANCE_ID]
		  ,a.[ORGANIZATION_ID]
		  ,a.[ORGANIZATION_CODE]
		  ,a.[CUSTOMER_ID]
		  ,a.[CUSTOMER_NAME]
		  ,a.[SHIP_TO_SITE_ID]
		  ,a.[SHIP_TO_ADDRESS]
		  ,a.[ENTITY_NAME]
		  ,a.[DESCRIPTION]
		  ,a.[SOURCING_RULE_TYPE]
		  ,a.[SOURCING_RULE_TYPE_TEXT]
		  ,a.[SOURCING_RULE_ID]
		  ,a.[SOURCING_RULE_NAME]
		  ,a.[CATEGORY_NAME]
		  ,a.[CATEGORY_SET_ID]
		  ,a.[INVENTORY_ITEM_ID]
		  ,a.[LAST_UPDATE_DATE]
		  ,a.[LAST_UPDATED_BY]
		  ,a.[CREATION_DATE]
		  ,a.[CREATED_BY]
		  ,a.[LAST_UPDATE_LOGIN]
		  ,a.[REQUEST_ID]
		  ,a.[PROGRAM_APPLICATION_ID]
		  ,a.[PROGRAM_ID]
		  ,a.[PROGRAM_UPDATE_DATE]
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
		  ,a.[REGION_ID]
		  ,a.[REGION_CODE]
		  ,a.[COLLECTED_FLAG]
		  ,a.[ALLOCATION_RULE_ID]
		  ,a.[ALLOCATION_RULE_NAME]
		  ,a.[ITEM_TYPE_ID]
		  ,a.[ITEM_TYPE_VALUE]
		  ,a.[ITEM_TYPE_VALUE_TEXT]
		  ,a.[Fingerprint]
		)
		--Existing records that have changed are expired
		WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
		THEN UPDATE SET b.EndDate=GETDATE()
			,b.CurrentRecord=0
		OUTPUT 
			   a.[ROW_ID]
			  ,a.[ASSIGNMENT_ID]
			  ,a.[ASSIGNMENT_SET_ID]
			  ,a.[ASSIGNMENT_TYPE]
			  ,a.[SR_INSTANCE_ID]
			  ,a.[SR_ASSIGNMENT_ID]
			  ,a.[SR_ASSIGNMENT_INSTANCE_ID]
			  ,a.[ORGANIZATION_ID]
			  ,a.[ORGANIZATION_CODE]
			  ,a.[CUSTOMER_ID]
			  ,a.[CUSTOMER_NAME]
			  ,a.[SHIP_TO_SITE_ID]
			  ,a.[SHIP_TO_ADDRESS]
			  ,a.[ENTITY_NAME]
			  ,a.[DESCRIPTION]
			  ,a.[SOURCING_RULE_TYPE]
			  ,a.[SOURCING_RULE_TYPE_TEXT]
			  ,a.[SOURCING_RULE_ID]
			  ,a.[SOURCING_RULE_NAME]
			  ,a.[CATEGORY_NAME]
			  ,a.[CATEGORY_SET_ID]
			  ,a.[INVENTORY_ITEM_ID]
			  ,a.[LAST_UPDATE_DATE]
			  ,a.[LAST_UPDATED_BY]
			  ,a.[CREATION_DATE]
			  ,a.[CREATED_BY]
			  ,a.[LAST_UPDATE_LOGIN]
			  ,a.[REQUEST_ID]
			  ,a.[PROGRAM_APPLICATION_ID]
			  ,a.[PROGRAM_ID]
			  ,a.[PROGRAM_UPDATE_DATE]
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
			  ,a.[REGION_ID]
			  ,a.[REGION_CODE]
			  ,a.[COLLECTED_FLAG]
			  ,a.[ALLOCATION_RULE_ID]
			  ,a.[ALLOCATION_RULE_NAME]
			  ,a.[ITEM_TYPE_ID]
			  ,a.[ITEM_TYPE_VALUE]
			  ,a.[ITEM_TYPE_VALUE_TEXT]
			  ,a.[Fingerprint]
			,$Action AS Action
	) a
	WHERE Action = 'Update'
	;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #sourcingRules

END
GO
