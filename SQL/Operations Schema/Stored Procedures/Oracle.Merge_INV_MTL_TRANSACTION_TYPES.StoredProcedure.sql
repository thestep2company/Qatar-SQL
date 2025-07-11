USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_INV_MTL_TRANSACTION_TYPES]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_INV_MTL_TRANSACTION_TYPES]
AS BEGIN

	CREATE TABLE #TransactionType (
		[TRANSACTION_TYPE_ID] [float] NOT NULL,
		[LAST_UPDATE_DATE] [datetime2](7) NOT NULL,
		[LAST_UPDATED_BY] [float] NOT NULL,
		[CREATION_DATE] [datetime2](7) NOT NULL,
		[CREATED_BY] [float] NOT NULL,
		[TRANSACTION_TYPE_NAME] [nvarchar](80) NOT NULL,
		[DESCRIPTION] [nvarchar](240) NULL,
		[TRANSACTION_ACTION_ID] [float] NOT NULL,
		[TRANSACTION_SOURCE_TYPE_ID] [float] NOT NULL,
		[SHORTAGE_MSG_BACKGROUND_FLAG] [nvarchar](1) NULL,
		[SHORTAGE_MSG_ONLINE_FLAG] [nvarchar](1) NULL,
		[DISABLE_DATE] [datetime2](7) NULL,
		[USER_DEFINED_FLAG] [nvarchar](1) NOT NULL,
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
		[ATTRIBUTE_CATEGORY] [nvarchar](30) NULL,
		[TYPE_CLASS] [float] NULL,
		[STATUS_CONTROL_FLAG] [float] NULL,
		[LOCATION_REQUIRED_FLAG] [nvarchar](1) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()
	
	INSERT INTO #TransactionType 
	SELECT [TRANSACTION_TYPE_ID]
		  ,[LAST_UPDATE_DATE]
		  ,[LAST_UPDATED_BY]
		  ,[CREATION_DATE]
		  ,[CREATED_BY]
		  ,[TRANSACTION_TYPE_NAME]
		  ,[DESCRIPTION]
		  ,[TRANSACTION_ACTION_ID]
		  ,[TRANSACTION_SOURCE_TYPE_ID]
		  ,[SHORTAGE_MSG_BACKGROUND_FLAG]
		  ,[SHORTAGE_MSG_ONLINE_FLAG]
		  ,[DISABLE_DATE]
		  ,[USER_DEFINED_FLAG]
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
		  ,[ATTRIBUTE_CATEGORY]
		  ,[TYPE_CLASS]
		  ,[STATUS_CONTROL_FLAG]
		  ,[LOCATION_REQUIRED_FLAG]
		  ,'XXX' AS [Fingerprint]
	FROM OPENQUERY(PROD,'SELECT * FROM INV.MTL_TRANSACTION_TYPES')

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('INV_MTL_TRANSACTION_TYPES','Oracle') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #TransactionType
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
				  CAST(ISNULL(TRANSACTION_TYPE_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(LAST_UPDATE_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(LAST_UPDATED_BY,'0') AS VARCHAR(100)) +  CAST(ISNULL(CREATION_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(CREATED_BY,'0') AS VARCHAR(100)) +  CAST(ISNULL(TRANSACTION_TYPE_NAME,'') AS VARCHAR(80)) +  CAST(ISNULL(DESCRIPTION,'') AS VARCHAR(240)) +  CAST(ISNULL(TRANSACTION_ACTION_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(TRANSACTION_SOURCE_TYPE_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(SHORTAGE_MSG_BACKGROUND_FLAG,'') AS VARCHAR(1)) +  CAST(ISNULL(SHORTAGE_MSG_ONLINE_FLAG,'') AS VARCHAR(1)) +  CAST(ISNULL(DISABLE_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(USER_DEFINED_FLAG,'') AS VARCHAR(1)) +  CAST(ISNULL(ATTRIBUTE1,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE2,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE3,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE4,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE5,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE6,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE7,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE8,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE9,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE10,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE11,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE12,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE13,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE14,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE15,'') AS VARCHAR(150)) +  CAST(ISNULL(ATTRIBUTE_CATEGORY,'') AS VARCHAR(30)) +  CAST(ISNULL(TYPE_CLASS,'0') AS VARCHAR(100)) +  CAST(ISNULL(STATUS_CONTROL_FLAG,'0') AS VARCHAR(100)) +  CAST(ISNULL(LOCATION_REQUIRED_FLAG,'') AS VARCHAR(1)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
	INSERT INTO Oracle.INV_MTL_TRANSACTION_TYPES (
			  [TRANSACTION_TYPE_ID]
			  ,[LAST_UPDATE_DATE]
			  ,[LAST_UPDATED_BY]
			  ,[CREATION_DATE]
			  ,[CREATED_BY]
			  ,[TRANSACTION_TYPE_NAME]
			  ,[DESCRIPTION]
			  ,[TRANSACTION_ACTION_ID]
			  ,[TRANSACTION_SOURCE_TYPE_ID]
			  ,[SHORTAGE_MSG_BACKGROUND_FLAG]
			  ,[SHORTAGE_MSG_ONLINE_FLAG]
			  ,[DISABLE_DATE]
			  ,[USER_DEFINED_FLAG]
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
			  ,[ATTRIBUTE_CATEGORY]
			  ,[TYPE_CLASS]
			  ,[STATUS_CONTROL_FLAG]
			  ,[LOCATION_REQUIRED_FLAG]
			  ,[Fingerprint]
		)
			SELECT 
			  a.[TRANSACTION_TYPE_ID]
			  ,a.[LAST_UPDATE_DATE]
			  ,a.[LAST_UPDATED_BY]
			  ,a.[CREATION_DATE]
			  ,a.[CREATED_BY]
			  ,a.[TRANSACTION_TYPE_NAME]
			  ,a.[DESCRIPTION]
			  ,a.[TRANSACTION_ACTION_ID]
			  ,a.[TRANSACTION_SOURCE_TYPE_ID]
			  ,a.[SHORTAGE_MSG_BACKGROUND_FLAG]
			  ,a.[SHORTAGE_MSG_ONLINE_FLAG]
			  ,a.[DISABLE_DATE]
			  ,a.[USER_DEFINED_FLAG]
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
			  ,a.[ATTRIBUTE_CATEGORY]
			  ,a.[TYPE_CLASS]
			  ,a.[STATUS_CONTROL_FLAG]
			  ,a.[LOCATION_REQUIRED_FLAG]
			  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.INV_MTL_TRANSACTION_TYPES b
				USING (SELECT * FROM #TransactionType) a
				ON a.Transaction_Type_ID = b.Transaction_Type_ID AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [TRANSACTION_TYPE_ID]
					  ,[LAST_UPDATE_DATE]
					  ,[LAST_UPDATED_BY]
					  ,[CREATION_DATE]
					  ,[CREATED_BY]
					  ,[TRANSACTION_TYPE_NAME]
					  ,[DESCRIPTION]
					  ,[TRANSACTION_ACTION_ID]
					  ,[TRANSACTION_SOURCE_TYPE_ID]
					  ,[SHORTAGE_MSG_BACKGROUND_FLAG]
					  ,[SHORTAGE_MSG_ONLINE_FLAG]
					  ,[DISABLE_DATE]
					  ,[USER_DEFINED_FLAG]
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
					  ,[ATTRIBUTE_CATEGORY]
					  ,[TYPE_CLASS]
					  ,[STATUS_CONTROL_FLAG]
					  ,[LOCATION_REQUIRED_FLAG]
					  ,[Fingerprint]
				)
				VALUES (
					   a.[TRANSACTION_TYPE_ID]
					  ,a.[LAST_UPDATE_DATE]
					  ,a.[LAST_UPDATED_BY]
					  ,a.[CREATION_DATE]
					  ,a.[CREATED_BY]
					  ,a.[TRANSACTION_TYPE_NAME]
					  ,a.[DESCRIPTION]
					  ,a.[TRANSACTION_ACTION_ID]
					  ,a.[TRANSACTION_SOURCE_TYPE_ID]
					  ,a.[SHORTAGE_MSG_BACKGROUND_FLAG]
					  ,a.[SHORTAGE_MSG_ONLINE_FLAG]
					  ,a.[DISABLE_DATE]
					  ,a.[USER_DEFINED_FLAG]
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
					  ,a.[ATTRIBUTE_CATEGORY]
					  ,a.[TYPE_CLASS]
					  ,a.[STATUS_CONTROL_FLAG]
					  ,a.[LOCATION_REQUIRED_FLAG]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[TRANSACTION_TYPE_ID]
					  ,a.[LAST_UPDATE_DATE]
					  ,a.[LAST_UPDATED_BY]
					  ,a.[CREATION_DATE]
					  ,a.[CREATED_BY]
					  ,a.[TRANSACTION_TYPE_NAME]
					  ,a.[DESCRIPTION]
					  ,a.[TRANSACTION_ACTION_ID]
					  ,a.[TRANSACTION_SOURCE_TYPE_ID]
					  ,a.[SHORTAGE_MSG_BACKGROUND_FLAG]
					  ,a.[SHORTAGE_MSG_ONLINE_FLAG]
					  ,a.[DISABLE_DATE]
					  ,a.[USER_DEFINED_FLAG]
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
					  ,a.[ATTRIBUTE_CATEGORY]
					  ,a.[TYPE_CLASS]
					  ,a.[STATUS_CONTROL_FLAG]
					  ,a.[LOCATION_REQUIRED_FLAG]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;
	

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #TransactionType

END
GO
