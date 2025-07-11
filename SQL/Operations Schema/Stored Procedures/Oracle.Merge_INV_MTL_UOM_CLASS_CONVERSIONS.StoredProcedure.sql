USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_INV_MTL_UOM_CLASS_CONVERSIONS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_INV_MTL_UOM_CLASS_CONVERSIONS] AS BEGIN

	CREATE TABLE #UOM(
		[INVENTORY_ITEM_ID] [float] NOT NULL,
		[FROM_UNIT_OF_MEASURE] [nvarchar](25) NOT NULL,
		[FROM_UOM_CODE] [nvarchar](3) NOT NULL,
		[FROM_UOM_CLASS] [nvarchar](10) NOT NULL,
		[TO_UNIT_OF_MEASURE] [nvarchar](25) NOT NULL,
		[TO_UOM_CODE] [nvarchar](3) NOT NULL,
		[TO_UOM_CLASS] [nvarchar](10) NOT NULL,
		[LAST_UPDATE_DATE] [datetime2](7) NOT NULL,
		[LAST_UPDATED_BY] [float] NOT NULL,
		[CREATION_DATE] [datetime2](7) NOT NULL,
		[CREATED_BY] [float] NOT NULL,
		[LAST_UPDATE_LOGIN] [float] NULL,
		[CONVERSION_RATE] [float] NOT NULL,
		[DISABLE_DATE] [datetime2](7) NULL,
		[REQUEST_ID] [float] NULL,
		[PROGRAM_APPLICATION_ID] [float] NULL,
		[PROGRAM_ID] [float] NULL,
		[PROGRAM_UPDATE_DATE] [datetime2](7) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) ON [PRIMARY]
		
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #UOM
	SELECT [INVENTORY_ITEM_ID]
		  ,[FROM_UNIT_OF_MEASURE]
		  ,[FROM_UOM_CODE]
		  ,[FROM_UOM_CLASS]
		  ,[TO_UNIT_OF_MEASURE]
		  ,[TO_UOM_CODE]
		  ,[TO_UOM_CLASS]
		  ,[LAST_UPDATE_DATE]
		  ,[LAST_UPDATED_BY]
		  ,[CREATION_DATE]
		  ,[CREATED_BY]
		  ,[LAST_UPDATE_LOGIN]
		  ,[CONVERSION_RATE]
		  ,[DISABLE_DATE]
		  ,[REQUEST_ID]
		  ,[PROGRAM_APPLICATION_ID]
		  ,[PROGRAM_ID]
		  ,[PROGRAM_UPDATE_DATE]
		  ,'XXX' AS [Fingerprint]
	FROM OPENQUERY(PROD,'select * from MTL_UOM_CLASS_CONVERSIONS mucc where 1=1 and mucc.to_uom_code = ''CA''') a

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('INV_MTL_UOM_CLASS_CONVERSIONS','Oracle') SELECT @columnList
	*/
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #uom
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			  CAST(ISNULL([INVENTORY_ITEM_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([FROM_UNIT_OF_MEASURE],'') AS VARCHAR(25)) +  CAST(ISNULL([FROM_UOM_CODE],'') AS VARCHAR(3)) +  CAST(ISNULL([FROM_UOM_CLASS],'') AS VARCHAR(10)) +  CAST(ISNULL([TO_UNIT_OF_MEASURE],'') AS VARCHAR(25)) +  CAST(ISNULL([TO_UOM_CODE],'') AS VARCHAR(3)) +  CAST(ISNULL([TO_UOM_CLASS],'') AS VARCHAR(10)) +  CAST(ISNULL([LAST_UPDATE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATED_BY],'0') AS VARCHAR(100)) +  CAST(ISNULL([CREATION_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([CREATED_BY],'0') AS VARCHAR(100)) +  CAST(ISNULL([LAST_UPDATE_LOGIN],'0') AS VARCHAR(100)) +  CAST(ISNULL([CONVERSION_RATE],'0') AS VARCHAR(100)) +  CAST(ISNULL([DISABLE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([REQUEST_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PROGRAM_APPLICATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PROGRAM_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PROGRAM_UPDATE_DATE],'') AS VARCHAR(100)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.INV_MTL_UOM_CLASS_CONVERSIONS (
		   [INVENTORY_ITEM_ID]
		  ,[FROM_UNIT_OF_MEASURE]
		  ,[FROM_UOM_CODE]
		  ,[FROM_UOM_CLASS]
		  ,[TO_UNIT_OF_MEASURE]
		  ,[TO_UOM_CODE]
		  ,[TO_UOM_CLASS]
		  ,[LAST_UPDATE_DATE]
		  ,[LAST_UPDATED_BY]
		  ,[CREATION_DATE]
		  ,[CREATED_BY]
		  ,[LAST_UPDATE_LOGIN]
		  ,[CONVERSION_RATE]
		  ,[DISABLE_DATE]
		  ,[REQUEST_ID]
		  ,[PROGRAM_APPLICATION_ID]
		  ,[PROGRAM_ID]
		  ,[PROGRAM_UPDATE_DATE]
		  ,[FINGERPRINT]
		)
			SELECT 
			   a.[INVENTORY_ITEM_ID]
			  ,a.[FROM_UNIT_OF_MEASURE]
			  ,a.[FROM_UOM_CODE]
			  ,a.[FROM_UOM_CLASS]
			  ,a.[TO_UNIT_OF_MEASURE]
			  ,a.[TO_UOM_CODE]
			  ,a.[TO_UOM_CLASS]
			  ,a.[LAST_UPDATE_DATE]
			  ,a.[LAST_UPDATED_BY]
			  ,a.[CREATION_DATE]
			  ,a.[CREATED_BY]
			  ,a.[LAST_UPDATE_LOGIN]
			  ,a.[CONVERSION_RATE]
			  ,a.[DISABLE_DATE]
			  ,a.[REQUEST_ID]
			  ,a.[PROGRAM_APPLICATION_ID]
			  ,a.[PROGRAM_ID]
			  ,a.[PROGRAM_UPDATE_DATE]
			  ,a.[FINGERPRINT]
			FROM (
				MERGE Oracle.INV_MTL_UOM_CLASS_CONVERSIONS b
				USING (SELECT * FROM #UOM) a
				ON a.Inventory_Item_ID = b.Inventory_Item_ID AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					  [INVENTORY_ITEM_ID]
					  ,[FROM_UNIT_OF_MEASURE]
					  ,[FROM_UOM_CODE]
					  ,[FROM_UOM_CLASS]
					  ,[TO_UNIT_OF_MEASURE]
					  ,[TO_UOM_CODE]
					  ,[TO_UOM_CLASS]
					  ,[LAST_UPDATE_DATE]
					  ,[LAST_UPDATED_BY]
					  ,[CREATION_DATE]
					  ,[CREATED_BY]
					  ,[LAST_UPDATE_LOGIN]
					  ,[CONVERSION_RATE]
					  ,[DISABLE_DATE]
					  ,[REQUEST_ID]
					  ,[PROGRAM_APPLICATION_ID]
					  ,[PROGRAM_ID]
					  ,[PROGRAM_UPDATE_DATE]
					  ,[FINGERPRINT]
				)
				VALUES (
					   a.[INVENTORY_ITEM_ID]
					  ,a.[FROM_UNIT_OF_MEASURE]
					  ,a.[FROM_UOM_CODE]
					  ,a.[FROM_UOM_CLASS]
					  ,a.[TO_UNIT_OF_MEASURE]
					  ,a.[TO_UOM_CODE]
					  ,a.[TO_UOM_CLASS]
					  ,a.[LAST_UPDATE_DATE]
					  ,a.[LAST_UPDATED_BY]
					  ,a.[CREATION_DATE]
					  ,a.[CREATED_BY]
					  ,a.[LAST_UPDATE_LOGIN]
					  ,a.[CONVERSION_RATE]
					  ,a.[DISABLE_DATE]
					  ,a.[REQUEST_ID]
					  ,a.[PROGRAM_APPLICATION_ID]
					  ,a.[PROGRAM_ID]
					  ,a.[PROGRAM_UPDATE_DATE]
					  ,a.[FINGERPRINT]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						 a.[INVENTORY_ITEM_ID]
						,a.[FROM_UNIT_OF_MEASURE]
						,a.[FROM_UOM_CODE]
						,a.[FROM_UOM_CLASS]
						,a.[TO_UNIT_OF_MEASURE]
						,a.[TO_UOM_CODE]
						,a.[TO_UOM_CLASS]
						,a.[LAST_UPDATE_DATE]
						,a.[LAST_UPDATED_BY]
						,a.[CREATION_DATE]
						,a.[CREATED_BY]
						,a.[LAST_UPDATE_LOGIN]
						,a.[CONVERSION_RATE]
						,a.[DISABLE_DATE]
						,a.[REQUEST_ID]
						,a.[PROGRAM_APPLICATION_ID]
						,a.[PROGRAM_ID]
						,a.[PROGRAM_UPDATE_DATE]
						,a.[FINGERPRINT]
					    ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
	
	DROP TABLE #UOM
END

GO
