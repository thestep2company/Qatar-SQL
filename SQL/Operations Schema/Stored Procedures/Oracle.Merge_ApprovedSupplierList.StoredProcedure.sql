USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_ApprovedSupplierList]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_ApprovedSupplierList] AS BEGIN

			CREATE TABLE #ASL (
				[ASL_ID] [INT] NOT NULL,
				[ITEM_NUMBER] [nvarchar](40) NULL,
				[ITEM_DESCRIPTION] [nvarchar](240) NULL,
				[OWNING ORGANIZATION CODE] [nvarchar](3) NULL,
				[PRIMARY_UNIT_OF_MEASURE] [nvarchar](3) NULL,
				[ITEM_STATUS] [nvarchar](8) NULL,
				[ITEM_CREATION_DATE] [datetime] NOT NULL,
				[VENDOR_NUMBER] [nvarchar](30) NOT NULL,
				[VENDOR_NAME] [nvarchar](240) NULL,
				[VENDOR_SITE_CODE] [nvarchar](45) NULL,
				[INACTIVE_DATE] [datetime] NULL,
				[PRIMARY_VENDOR_ITEM] [nvarchar](25) NULL,
				[DISABLE_FLAG] [nvarchar](1) NULL,
				[ASL_STATUS] [nvarchar](25) NOT NULL,
				[Fingerprint] [varchar](32) NOT NULL
			)


			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

			INSERT INTO #ASL
			SELECT *, 'XXXXXXX'
			FROM OPENQUERY(PROD,'
			select   DISTINCT 
					 asl.ASL_ID,
					 msib.segment1 "ITEM_NUMBER",
					 msib.description "ITEM_DESCRIPTION",
					 ood.organization_code "OWNING ORGANIZATION CODE",
					 msib.primary_uom_code "PRIMARY_UNIT_OF_MEASURE",
					 DECODE (MSIB.enabled_flag, ''Y'', ''Active'', ''Inactive'') "ITEM_STATUS",
					 msib.CREATION_DATE "ITEM_CREATION_DATE",
					 pv.segment1 "VENDOR_NUMBER",
					 pv.vendor_name "VENDOR_NAME",
					 pvsa.vendor_site_code,
					 pvsa.INACTIVE_DATE " INACTIVE_DATE",
					 asl.PRIMARY_VENDOR_ITEM,
					 asl.DISABLE_FLAG,
					 pas.status "ASL_STATUS"
			from APPS.po_approved_supplier_list asl
					 , APPS.po_vendors pv
					 , APPS.po_vendor_sites_all pvsa
					 , APPS.org_organization_definitions ood 
					 , APPS.mtl_system_items_b msib
					 , APPS.po_asl_attributes paa
					 , APPS.po_asl_statuses pas
			where 1=1
				and pv.vendor_id = asl.vendor_id
				AND asl.vendor_site_id = pvsa.vendor_site_id   (+)
				AND ood.organization_id = asl.owning_organization_id
				AND asl.item_id = msib.inventory_item_id
				AND asl.owning_organization_id = msib.organization_id
				AND asl.asl_id = paa.asl_id   
				AND asl.asl_status_id = pas.status_id
				AND pas.status = ''Approved''
			'
			)


			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()
	
 			/*
				DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('ApprovedSupplierList','Oracle') SELECT @columnList
			*/
			UPDATE #asl
			SET Fingerprint = 
				SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
					--replace @columnList result here
					    CAST(ISNULL([ASL_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ITEM_NUMBER],'') AS VARCHAR(40)) +  CAST(ISNULL([ITEM_DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([OWNING ORGANIZATION CODE],'') AS VARCHAR(3)) +  CAST(ISNULL([PRIMARY_UNIT_OF_MEASURE],'') AS VARCHAR(3)) +  CAST(ISNULL([ITEM_STATUS],'') AS VARCHAR(8)) +  CAST(ISNULL([ITEM_CREATION_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([VENDOR_NUMBER],'') AS VARCHAR(30)) +  CAST(ISNULL([VENDOR_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([VENDOR_SITE_CODE],'') AS VARCHAR(45)) +  CAST(ISNULL([INACTIVE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([PRIMARY_VENDOR_ITEM],'') AS VARCHAR(25)) +  CAST(ISNULL([DISABLE_FLAG],'') AS VARCHAR(1)) +  CAST(ISNULL([ASL_STATUS],'') AS VARCHAR(25)) 
				),1)),3,32);

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Expire', GETDATE()
			
			UPDATE target 
			SET EndDate = GETDATE(), CurrentRecord = 0 
			FROM Oracle.ApprovedSupplierList target
				LEFT JOIN #ASL source ON target.ASL_ID = source.ASL_ID
			WHERE target.CurrentRecord = 1 AND source.ASL_ID IS NULL
			

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

			INSERT INTO Oracle.ApprovedSupplierList (
			   [ASL_ID]
		      ,[ITEM_NUMBER]
			  ,[ITEM_DESCRIPTION]
			  ,[OWNING ORGANIZATION CODE]
			  ,[PRIMARY_UNIT_OF_MEASURE]
			  ,[ITEM_STATUS]
			  ,[ITEM_CREATION_DATE]
			  ,[VENDOR_NUMBER]
			  ,[VENDOR_NAME]
			  ,[VENDOR_SITE_CODE]
			  ,[INACTIVE_DATE]
			  ,[PRIMARY_VENDOR_ITEM]
			  ,[DISABLE_FLAG]
			  ,[ASL_STATUS]
			  ,[Fingerprint]
			)
			SELECT 
		       a.[ASL_ID]
		      ,a.[ITEM_NUMBER]
			  ,a.[ITEM_DESCRIPTION]
			  ,a.[OWNING ORGANIZATION CODE]
			  ,a.[PRIMARY_UNIT_OF_MEASURE]
			  ,a.[ITEM_STATUS]
			  ,a.[ITEM_CREATION_DATE]
			  ,a.[VENDOR_NUMBER]
			  ,a.[VENDOR_NAME]
			  ,a.[VENDOR_SITE_CODE]
			  ,a.[INACTIVE_DATE]
			  ,a.[PRIMARY_VENDOR_ITEM]
			  ,a.[DISABLE_FLAG]
			  ,a.[ASL_STATUS]
			  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.ApprovedSupplierList b
				USING (SELECT * FROM #ASL) a
				ON a.ASL_ID = b.ASL_ID AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [ASL_ID]
					  ,[ITEM_NUMBER]
					  ,[ITEM_DESCRIPTION]
					  ,[OWNING ORGANIZATION CODE]
					  ,[PRIMARY_UNIT_OF_MEASURE]
					  ,[ITEM_STATUS]
					  ,[ITEM_CREATION_DATE]
					  ,[VENDOR_NUMBER]
					  ,[VENDOR_NAME]
					  ,[VENDOR_SITE_CODE]
					  ,[INACTIVE_DATE]
					  ,[PRIMARY_VENDOR_ITEM]
					  ,[DISABLE_FLAG]
					  ,[ASL_STATUS]
					  ,[Fingerprint]
				)
				VALUES (
					   a.[ASL_ID]
					  ,a.[ITEM_NUMBER]
					  ,a.[ITEM_DESCRIPTION]
					  ,a.[OWNING ORGANIZATION CODE]
					  ,a.[PRIMARY_UNIT_OF_MEASURE]
					  ,a.[ITEM_STATUS]
					  ,a.[ITEM_CREATION_DATE]
					  ,a.[VENDOR_NUMBER]
					  ,a.[VENDOR_NAME]
					  ,a.[VENDOR_SITE_CODE]
					  ,a.[INACTIVE_DATE]
					  ,a.[PRIMARY_VENDOR_ITEM]
					  ,a.[DISABLE_FLAG]
					  ,a.[ASL_STATUS]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT a.[ASL_ID]
					  ,a.[ITEM_NUMBER]
					  ,a.[ITEM_DESCRIPTION]
					  ,a.[OWNING ORGANIZATION CODE]
					  ,a.[PRIMARY_UNIT_OF_MEASURE]
					  ,a.[ITEM_STATUS]
					  ,a.[ITEM_CREATION_DATE]
					  ,a.[VENDOR_NUMBER]
					  ,a.[VENDOR_NAME]
					  ,a.[VENDOR_SITE_CODE]
					  ,a.[INACTIVE_DATE]
					  ,a.[PRIMARY_VENDOR_ITEM]
					  ,a.[DISABLE_FLAG]
					  ,a.[ASL_STATUS]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		DROP TABLE #ASL

END
GO
