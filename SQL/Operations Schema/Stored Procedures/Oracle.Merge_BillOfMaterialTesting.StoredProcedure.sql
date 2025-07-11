USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_BillOfMaterialTesting]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_BillOfMaterialTesting] 
AS BEGIN

			CREATE TABLE #BOM(
				[ORDER_LEVEL] [nvarchar](4000) NULL,
				[ASSEMBLY_ITEM] [nvarchar](40) NULL,
				[ASSEMBLY_DESCRIPTION] [nvarchar](240) NULL,
				[ASSEMBLY_ITEM_STATUS] [nvarchar](10) NOT NULL,
				[PATH] [nvarchar](4000) NULL,
				[NEW_PATH] [nvarchar](4000) NULL,
				[COMPONENT_ITEM] [nvarchar](40) NULL,
				[COMPONENT_ITEM_DESCRIPTION] [nvarchar](240) NULL,
				[COMPONENT_ITEM_STATUS] [nvarchar](10) NOT NULL,
				[ITEM_NUM] [float] NULL,
				[OPERATION_SEQ_NUM] [float] NOT NULL,
				[COMPONENT_QUANTITY] [float] NOT NULL,
				[Fingerprint] [varchar](32) NOT NULL
			) ON [PRIMARY]


			--15 4s
			--9 5s
			--4 6s
			--11 7s
			--40m 8s


			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

			INSERT INTO #BOM
			SELECT *, 'XXXXX'
			FROM OPENQUERY(PROD,'
				SELECT DISTINCT LPAD ( '' '', LEVEL * 2 ) || LEVEL AS ORDER_LEVEL
					   , msib.segment1 AS ASSEMBLY_ITEM
					   , msib.description AS ASSEMBLY_DESCRIPTION
					   , msib.inventory_item_status_code  AS ASSEMBLY_ITEM_STATUS
					   , SYS_CONNECT_BY_PATH (msib.segment1, ''/'')  AS PATH
					   , (SYS_CONNECT_BY_PATH (msib.segment1, ''/'') || ''/'' || msib2.segment1) AS NEW_PATH
					   , msib2.segment1  AS COMPONENT_ITEM
					   , msib2.description AS COMPONENT_ITEM_DESCRIPTION
					   , msib2.inventory_item_status_code AS COMPONENT_ITEM_STATUS
					   , bic.item_num AS ITEM_NUM
					   , bic.operation_seq_num AS OPERATION_SEQ_NUM
					   , bic.component_quantity AS COMPONENT_QUANTITY
				FROM     bom.bom_components_b   bic
					   , bom.bom_structures_b   bom
					   , inv.mtl_system_items_b msib
					   , inv.mtl_system_items_b msib2
					   , mtl_parameters         mp
				WHERE	1 = 1
						AND bic.bill_sequence_id = bom.bill_sequence_id
						AND SYSDATE BETWEEN bic.effectivity_date AND Nvl(bic.disable_date, SYSDATE)
						AND bom.assembly_item_id = msib.inventory_item_id
						AND bom.organization_id = msib.organization_id
						AND bic.component_item_id = msib2.inventory_item_id
						AND bom.organization_id = msib2.organization_id
						AND mp.organization_id = msib.organization_id
						AND mp.organization_code = ''999'' 
						AND bom.alternate_bom_designator IS NULL
				START WITH  msib.segment1 >= ''400000'' AND SYSDATE BETWEEN bic.effectivity_date AND Nvl(bic.disable_date, SYSDATE)
				CONNECT BY NOCYCLE PRIOR bic.component_item_id = msib.inventory_item_id 
			'
			)


			/*
				DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('BillOfMaterialTesting','Oracle') SELECT @columnList
			*/

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

			UPDATE #bom
			SET Fingerprint = 
				SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
					--replace @columnList result here
						 CAST(ISNULL([ORDER_LEVEL],'') AS VARCHAR(4000)) +  CAST(ISNULL([ASSEMBLY_ITEM],'') AS VARCHAR(40)) +  CAST(ISNULL([ASSEMBLY_DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([ASSEMBLY_ITEM_STATUS],'') AS VARCHAR(10)) +  CAST(ISNULL([PATH],'') AS VARCHAR(4000)) +  CAST(ISNULL([NEW_PATH],'') AS VARCHAR(4000)) +  CAST(ISNULL([COMPONENT_ITEM],'') AS VARCHAR(40)) +  CAST(ISNULL([COMPONENT_ITEM_DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([COMPONENT_ITEM_STATUS],'') AS VARCHAR(10)) +  CAST(ISNULL([ITEM_NUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([OPERATION_SEQ_NUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([COMPONENT_QUANTITY],'0') AS VARCHAR(100)) 
				),1)),3,32);

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Expire', GETDATE()

			--expire records outside the merge
			UPDATE t
			SET t.EndDate = GETDATE()
				,t.CurrentRecord = 0
			FROM Oracle.BillOfMaterialTesting t
				LEFT JOIN #BOM s ON t.NEW_PATH = s.NEW_PATH
			WHERE s.NEW_PATH IS NULL

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

			INSERT INTO Oracle.BillOfMaterialTesting (
			   [ORDER_LEVEL]
			  ,[ASSEMBLY_ITEM]
			  ,[ASSEMBLY_DESCRIPTION]
			  ,[ASSEMBLY_ITEM_STATUS]
			  ,[PATH]
			  ,[NEW_PATH]
			  ,[COMPONENT_ITEM]
			  ,[COMPONENT_ITEM_DESCRIPTION]
			  ,[COMPONENT_ITEM_STATUS]
			  ,[ITEM_NUM]
			  ,[OPERATION_SEQ_NUM]
			  ,[COMPONENT_QUANTITY]
			  ,[Fingerprint]
			)
			SELECT 
			   a.[ORDER_LEVEL]
			  ,a.[ASSEMBLY_ITEM]
			  ,a.[ASSEMBLY_DESCRIPTION]
			  ,a.[ASSEMBLY_ITEM_STATUS]
			  ,a.[PATH]
			  ,a.[NEW_PATH]
			  ,a.[COMPONENT_ITEM]
			  ,a.[COMPONENT_ITEM_DESCRIPTION]
			  ,a.[COMPONENT_ITEM_STATUS]
			  ,a.[ITEM_NUM]
			  ,a.[OPERATION_SEQ_NUM]
			  ,a.[COMPONENT_QUANTITY]
			  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.BillOfMaterialTesting b
				USING (SELECT * FROM #BOM) a
				ON a.NEW_PATH = b.NEW_PATH AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [ORDER_LEVEL]
					  ,[ASSEMBLY_ITEM]
					  ,[ASSEMBLY_DESCRIPTION]
					  ,[ASSEMBLY_ITEM_STATUS]
					  ,[PATH]
					  ,[NEW_PATH]
					  ,[COMPONENT_ITEM]
					  ,[COMPONENT_ITEM_DESCRIPTION]
					  ,[COMPONENT_ITEM_STATUS]
					  ,[ITEM_NUM]
					  ,[OPERATION_SEQ_NUM]
					  ,[COMPONENT_QUANTITY]
					  ,[Fingerprint]
				)
				VALUES (
					   a.[ORDER_LEVEL]
					  ,a.[ASSEMBLY_ITEM]
					  ,a.[ASSEMBLY_DESCRIPTION]
					  ,a.[ASSEMBLY_ITEM_STATUS]
					  ,a.[PATH]
					  ,a.[NEW_PATH]
					  ,a.[COMPONENT_ITEM]
					  ,a.[COMPONENT_ITEM_DESCRIPTION]
					  ,a.[COMPONENT_ITEM_STATUS]
					  ,a.[ITEM_NUM]
					  ,a.[OPERATION_SEQ_NUM]
					  ,a.[COMPONENT_QUANTITY]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[ORDER_LEVEL]
					  ,a.[ASSEMBLY_ITEM]
					  ,a.[ASSEMBLY_DESCRIPTION]
					  ,a.[ASSEMBLY_ITEM_STATUS]
					  ,a.[PATH]
					  ,a.[NEW_PATH]
					  ,a.[COMPONENT_ITEM]
					  ,a.[COMPONENT_ITEM_DESCRIPTION]
					  ,a.[COMPONENT_ITEM_STATUS]
					  ,a.[ITEM_NUM]
					  ,a.[OPERATION_SEQ_NUM]
					  ,a.[COMPONENT_QUANTITY]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()


		DROP TABLE #BOM

END	
GO
