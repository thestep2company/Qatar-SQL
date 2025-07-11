USE [Operations]
GO
/****** Object:  StoredProcedure [QA].[Merge_QUALITY_ROTO_RESIN_WEIGHTS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [QA].[Merge_QUALITY_ROTO_RESIN_WEIGHTS] AS BEGIN

	CREATE TABLE #resinWeights (
		[INDEX_ID] [int] NOT NULL,
		[DATE] [datetime] NULL,
		[USER_NAME] [varchar](80) NULL,
		[LOCATION_CODE] [varchar](3) NULL,
		[LOCATION_NAME] [varchar](50) NULL,
		[SHIFT] [varchar](1) NULL,
		[MACHINE] [varchar](50) NULL,
		[ASSEMBLY_ITEM] [varchar](50) NULL,
		[ASSEMBLY_DESCRIPTION] [varchar](80) NULL,
		[COMPONENT_QUANTITY] [numeric](18, 2) NULL,
		[ACTUAL_COMPONENT_QUANTITY] [numeric](18, 2) NULL,
		[PRODUCT_NUMBER] [varchar](50) NULL,
		[COMMENTS] [varchar](200) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) 

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

	INSERT INTO #resinWeights
	SELECT *, 'XXXXXXXX'
	FROM OPENQUERY(FINDLAND,'
	SELECT [INDEX_ID]
		  ,[DATE]
		  ,[USER_NAME]
		  ,[LOCATION_CODE]
		  ,[LOCATION_NAME]
		  ,[SHIFT]
		  ,[MACHINE]
		  ,[ASSEMBLY_ITEM]
		  ,[ASSEMBLY_DESCRIPTION]
		  ,[COMPONENT_QUANTITY]
		  ,[ACTUAL_COMPONENT_QUANTITY]
		  ,[PRODUCT_NUMBER]
		  ,[COMMENTS]
	  FROM [Quality].[dbo].[QUALITY_ROTO_RESIN_WEIGHTS]
	  WHERE Date >= DATEADD(DAY,-30,GETDATE())
	')

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('QUALITY_ROTO_RESIN_WEIGHTS','QA') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #resinWeights
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
				    CAST(ISNULL([INDEX_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([USER_NAME],'') AS VARCHAR(80)) +  CAST(ISNULL([LOCATION_CODE],'') AS VARCHAR(3)) +  CAST(ISNULL([LOCATION_NAME],'') AS VARCHAR(50)) +  CAST(ISNULL([SHIFT],'') AS VARCHAR(1)) +  CAST(ISNULL([MACHINE],'') AS VARCHAR(50)) +  CAST(ISNULL([ASSEMBLY_ITEM],'') AS VARCHAR(50)) +  CAST(ISNULL([ASSEMBLY_DESCRIPTION],'') AS VARCHAR(80)) +  CAST(ISNULL([COMPONENT_QUANTITY],'0') AS VARCHAR(100)) +  CAST(ISNULL([ACTUAL_COMPONENT_QUANTITY],'0') AS VARCHAR(100)) +  CAST(ISNULL([PRODUCT_NUMBER],'') AS VARCHAR(50)) +  CAST(ISNULL([COMMENTS],'') AS VARCHAR(200)) 
		),1)),3,32);


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO QA.[QUALITY_ROTO_RESIN_WEIGHTS] (
			[INDEX_ID]
		  ,[DATE]
		  ,[USER_NAME]
		  ,[LOCATION_CODE]
		  ,[LOCATION_NAME]
		  ,[SHIFT]
		  ,[MACHINE]
		  ,[ASSEMBLY_ITEM]
		  ,[ASSEMBLY_DESCRIPTION]
		  ,[COMPONENT_QUANTITY]
		  ,[ACTUAL_COMPONENT_QUANTITY]
		  ,[PRODUCT_NUMBER]
		  ,[COMMENTS]
		  ,[Fingerprint]
		)
			SELECT 
				a.[INDEX_ID]
			  ,a.[DATE]
			  ,a.[USER_NAME]
			  ,a.[LOCATION_CODE]
			  ,a.[LOCATION_NAME]
			  ,a.[SHIFT]
			  ,a.[MACHINE]
			  ,a.[ASSEMBLY_ITEM]
			  ,a.[ASSEMBLY_DESCRIPTION]
			  ,a.[COMPONENT_QUANTITY]
			  ,a.[ACTUAL_COMPONENT_QUANTITY]
			  ,a.[PRODUCT_NUMBER]
			  ,a.[COMMENTS]
			  ,a.[Fingerprint]
			FROM (
				MERGE QA.[QUALITY_ROTO_RESIN_WEIGHTS] b
				USING (SELECT * FROM #resinWeights) a
				ON a.[Index_ID] = b.[Index_ID] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					[INDEX_ID]
				  ,[DATE]
				  ,[USER_NAME]
				  ,[LOCATION_CODE]
				  ,[LOCATION_NAME]
				  ,[SHIFT]
				  ,[MACHINE]
				  ,[ASSEMBLY_ITEM]
				  ,[ASSEMBLY_DESCRIPTION]
				  ,[COMPONENT_QUANTITY]
				  ,[ACTUAL_COMPONENT_QUANTITY]
				  ,[PRODUCT_NUMBER]
				  ,[COMMENTS]
				  ,[Fingerprint]
				)
				VALUES (
						a.[INDEX_ID]
					  ,a.[DATE]
					  ,a.[USER_NAME]
					  ,a.[LOCATION_CODE]
					  ,a.[LOCATION_NAME]
					  ,a.[SHIFT]
					  ,a.[MACHINE]
					  ,a.[ASSEMBLY_ITEM]
					  ,a.[ASSEMBLY_DESCRIPTION]
					  ,a.[COMPONENT_QUANTITY]
					  ,a.[ACTUAL_COMPONENT_QUANTITY]
					  ,a.[PRODUCT_NUMBER]
					  ,a.[COMMENTS]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						a.[INDEX_ID]
					  ,a.[DATE]
					  ,a.[USER_NAME]
					  ,a.[LOCATION_CODE]
					  ,a.[LOCATION_NAME]
					  ,a.[SHIFT]
					  ,a.[MACHINE]
					  ,a.[ASSEMBLY_ITEM]
					  ,a.[ASSEMBLY_DESCRIPTION]
					  ,a.[COMPONENT_QUANTITY]
					  ,a.[ACTUAL_COMPONENT_QUANTITY]
					  ,a.[PRODUCT_NUMBER]
					  ,a.[COMMENTS]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #resinWeights
END
GO
