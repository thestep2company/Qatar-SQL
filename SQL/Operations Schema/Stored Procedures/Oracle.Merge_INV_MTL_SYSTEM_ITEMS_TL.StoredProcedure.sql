USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_INV_MTL_SYSTEM_ITEMS_TL]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_INV_MTL_SYSTEM_ITEMS_TL]
AS BEGIN
	
	CREATE TABLE #systemItems (
		[INVENTORY_ITEM_ID] [float] NOT NULL,
		[ORGANIZATION_ID] [float] NOT NULL,	
		[LANGUAGE] [nvarchar](4) NOT NULL,
		[SOURCE_LANG] [nvarchar](4) NOT NULL,
		[DESCRIPTION] [nvarchar](240) NULL,
		[LAST_UPDATE_DATE] [datetime2](7) NOT NULL,
		[LAST_UPDATED_BY] [float] NOT NULL,
		[CREATION_DATE] [datetime2](7) NOT NULL,
		[CREATED_BY] [float] NOT NULL,
		[LAST_UPDATE_LOGIN] [float] NULL,
		[LONG_DESCRIPTION] [nvarchar](4000) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) ON [PRIMARY]

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #SystemItems
	SELECT [INVENTORY_ITEM_ID]
		  ,[ORGANIZATION_ID]
		  ,[LANGUAGE]
		  ,[SOURCE_LANG]
		  ,[DESCRIPTION]
		  ,[LAST_UPDATE_DATE]
		  ,[LAST_UPDATED_BY]
		  ,[CREATION_DATE]
		  ,[CREATED_BY]
		  ,[LAST_UPDATE_LOGIN]
		  ,[LONG_DESCRIPTION]
		  ,'XXX' AS [Fingerprint]
	FROM OPENQUERY(PROD,'SELECT * FROM INV.MTL_SYSTEM_ITEMS_TL WHERE LAST_UPDATE_DATE >= SYSDATE - 5 OR CREATION_DATE >= SYSDATE - 5') -- AND CREATION_DATE >= TO_DATE(''20210101'',''YYYYMMDD'')')

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('INV_MTL_SYSTEM_ITEMS_TL','Oracle') SELECT @columnList
	*/
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #SystemItems
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			 CAST(ISNULL([INVENTORY_ITEM_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORGANIZATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([LANGUAGE],'') AS VARCHAR(4)) +  CAST(ISNULL([SOURCE_LANG],'') AS VARCHAR(4)) +  CAST(ISNULL([DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([LAST_UPDATE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATED_BY],'0') AS VARCHAR(100)) +  CAST(ISNULL([CREATION_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([CREATED_BY],'0') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATE_LOGIN],'0') AS VARCHAR(100)) +  CAST(ISNULL([LONG_DESCRIPTION],'') AS VARCHAR(4000))
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.INV_MTL_SYSTEM_ITEMS_TL (
		   [INVENTORY_ITEM_ID]
		  ,[ORGANIZATION_ID]
		  ,[LANGUAGE]
		  ,[SOURCE_LANG]
		  ,[DESCRIPTION]
		  ,[LAST_UPDATE_DATE]
		  ,[LAST_UPDATED_BY]
		  ,[CREATION_DATE]
		  ,[CREATED_BY]
		  ,[LAST_UPDATE_LOGIN]
		  ,[LONG_DESCRIPTION]
		  ,[Fingerprint]
		)
			SELECT 
			   a.[INVENTORY_ITEM_ID]
			  ,a.[ORGANIZATION_ID]
			  ,a.[LANGUAGE]
			  ,a.[SOURCE_LANG]
			  ,a.[DESCRIPTION]
			  ,a.[LAST_UPDATE_DATE]
			  ,a.[LAST_UPDATED_BY]
			  ,a.[CREATION_DATE]
			  ,a.[CREATED_BY]
			  ,a.[LAST_UPDATE_LOGIN]
			  ,a.[LONG_DESCRIPTION]
			  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.INV_MTL_SYSTEM_ITEMS_TL b
				USING (SELECT * FROM #SystemItems) a
				ON a.Inventory_Item_ID = b.Inventory_Item_ID AND a.Organization_ID = b.Organization_ID AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [INVENTORY_ITEM_ID]
					  ,[ORGANIZATION_ID]
					  ,[LANGUAGE]
					  ,[SOURCE_LANG]
					  ,[DESCRIPTION]
					  ,[LAST_UPDATE_DATE]
					  ,[LAST_UPDATED_BY]
					  ,[CREATION_DATE]
					  ,[CREATED_BY]
					  ,[LAST_UPDATE_LOGIN]
					  ,[LONG_DESCRIPTION]
					  ,[Fingerprint]
				)
				VALUES (
					   a.[INVENTORY_ITEM_ID]
					  ,a.[ORGANIZATION_ID]
					  ,a.[LANGUAGE]
					  ,a.[SOURCE_LANG]
					  ,a.[DESCRIPTION]
					  ,a.[LAST_UPDATE_DATE]
					  ,a.[LAST_UPDATED_BY]
					  ,a.[CREATION_DATE]
					  ,a.[CREATED_BY]
					  ,a.[LAST_UPDATE_LOGIN]
					  ,a.[LONG_DESCRIPTION]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						 a.[INVENTORY_ITEM_ID]
						,a.[ORGANIZATION_ID]
						,a.[LANGUAGE]
						,a.[SOURCE_LANG]
						,a.[DESCRIPTION]
						,a.[LAST_UPDATE_DATE]
						,a.[LAST_UPDATED_BY]
						,a.[CREATION_DATE]
						,a.[CREATED_BY]
						,a.[LAST_UPDATE_LOGIN]
						,a.[LONG_DESCRIPTION]
						,a.[Fingerprint]
					    ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
	
	DROP TABLE #SystemItems

END



GO
