USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Buyer]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Buyer] AS BEGIN

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

			DROP TABLE IF EXISTS #Buyer 

			CREATE TABLE #Buyer(
				[ITEM_NAME] [nvarchar](250) NULL,
				[SUPPLIER_FROM_ASL] [nvarchar](4000) NULL,
				[PLANNER_CODE] [nvarchar](10) NULL,
				[BUYER_NAME] [nvarchar](240) NULL,
				[Fingerprint] [nvarchar](32) NOT NULL
			)

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

			INSERT INTO #Buyer
			SELECT *, 'XXXXXXX'
			FROM OPENQUERY(ASCP,'
				SELECT ITEM_NAME, MAX(SUPPLIER_FROM_ASL) SUPPLIER_FROM_ASL, MAX(PLANNER_CODE) PLANNER_CODE, MAX(BUYER_NAME) BUYER_NAME 
				FROM xxmsc_sup_dem_cum3_mv WHERE TDATE > sysdate
				GROUP BY ITEM_NAME
			') 

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()
	
 			/*
				DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Buyer','Oracle') SELECT @columnList
			*/
			UPDATE #buyer
			SET Fingerprint = 
				SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
					--replace @columnList result here
					 CAST(ISNULL([ITEM_NAME],'') AS VARCHAR(250)) +  CAST(ISNULL([SUPPLIER_FROM_ASL],'') AS VARCHAR(4000)) +  CAST(ISNULL([PLANNER_CODE],'') AS VARCHAR(10)) +  CAST(ISNULL([BUYER_NAME],'') AS VARCHAR(240)) 
				),1)),3,32);

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

			INSERT INTO Oracle.Buyer (
			   [ITEM_NAME]
			  ,[SUPPLIER_FROM_ASL]
			  ,[PLANNER_CODE]
			  ,[BUYER_NAME]
			  ,[Fingerprint]
			)
			SELECT 
				   a.[ITEM_NAME]
				  ,a.[SUPPLIER_FROM_ASL]
				  ,a.[PLANNER_CODE]
				  ,a.[BUYER_NAME]
				  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.Buyer b
				USING (SELECT * FROM #Buyer) a
				ON a.ITEM_NAME = b.ITEM_NAME AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
				   [ITEM_NAME]
				  ,[SUPPLIER_FROM_ASL]
				  ,[PLANNER_CODE]
				  ,[BUYER_NAME]
				  ,[Fingerprint]
				)
				VALUES (
				   a.[ITEM_NAME]
				  ,a.[SUPPLIER_FROM_ASL]
				  ,a.[PLANNER_CODE]
				  ,a.[BUYER_NAME]
				  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					 a.[ITEM_NAME]
					,a.[SUPPLIER_FROM_ASL]
					,a.[PLANNER_CODE]
					,a.[BUYER_NAME]
					,a.[Fingerprint]
					,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		DROP TABLE #Buyer

END
GO
