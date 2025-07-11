USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_BillOfMaterial]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_BillOfMaterial] 
AS BEGIN
	
	CREATE TABLE #BOM(
		[PARENT_SKU] [nvarchar](40) NULL,
		[CHILD_SKU] [nvarchar](40) NULL,
		[PARENT_PATH] [nvarchar](1000) NULL,
		[CHILD_PATH] [nvarchar](1000) NULL,
		[ITEM_TYPE] [nvarchar](50) NULL,
		[ITEM_NUM] [float] NULL,
		[LEVEL] [float] NULL,
		[COMPONENT_QUANTITY] [float] NOT NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) ON [PRIMARY]


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()


	INSERT INTO #BOM
	SELECT d.*, 'XXXXXXX'
	FROM OPENQUERY(PROD,'
		select distinct
			k.Segment1 AS Parent_SKU,
			c.Segment1 AS Child_SKU,
			SYS_CONNECT_BY_PATH ( k.segment1, ''|'' ) AS PARENT_PATH,
			(SYS_CONNECT_BY_PATH ( k.segment1, ''|'' ) || ''|'' || c.segment1) AS CHILD_PATH,
			c.Attribute4 AS Item_Type,
			bic.item_num,
			level,
			bic.component_quantity
		from
			bom_inventory_components bic
			INNER JOIN (select * from bom_bill_of_materials where organization_id=85 ) bom ON bom.bill_sequence_id=bic.bill_sequence_id
			LEFT JOIN MTL_SYSTEM_ITEMS_B k ON bom.Assembly_Item_ID = k.Inventory_Item_ID AND bom.Organization_ID = k.Organization_ID
			LEFT JOIN MTL_SYSTEM_ITEMS_B c ON bic.component_item_id = c.Inventory_Item_ID AND bom.Organization_ID = c.Organization_ID
		WHERE effectivity_date <= sysdate AND NVL(disable_date, sysdate ) >= sysdate
		connect by nocycle prior bic.component_item_id=bom.assembly_item_id
	'
	) d

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

		/*	
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('BillOfMaterial','Oracle') SELECT @columnList
		*/
		UPDATE #BOM
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				  CAST(ISNULL([PARENT_SKU],'') AS VARCHAR(40)) +  CAST(ISNULL([CHILD_SKU],'') AS VARCHAR(40)) +  CAST(ISNULL([PARENT_PATH],'') AS VARCHAR(1000)) +  CAST(ISNULL([CHILD_PATH],'') AS VARCHAR(1000))  +  CAST(ISNULL([ITEM_TYPE],'') AS VARCHAR(50)) +  CAST(ISNULL([ITEM_NUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([LEVEL],'0') AS VARCHAR(100)) +  CAST(ISNULL([COMPONENT_QUANTITY],'0') AS VARCHAR(100))	  
			),1)),3,32);

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Expire', GETDATE()
	
		--expire records outside the merge
		UPDATE target SET CurrentRecord = 0, EndDate = GETDATE()
		FROM Oracle.BillOfMaterial target
			LEFT JOIN #BOM source ON target.PARENT_PATH = source.PARENT_PATH AND target.CHILD_PATH = source.CHILD_PATH AND target.ITEM_NUM = source.ITEM_NUM
		WHERE (ISNULL(target.COMPONENT_QUANTITY,0) <> ISNULL(source.COMPONENT_QUANTITY,0)
				OR ISNULL(target.LEVEL,0) <> ISNULL(source.Level,0)
			)

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
		
		INSERT INTO Oracle.BillOfMaterial (
			 [PARENT_SKU]
			,[CHILD_SKU] 
			,[PARENT_PATH]
			,[CHILD_PATH]
			,[ITEM_TYPE]
			,[ITEM_NUM]
			,[LEVEL]
			,[COMPONENT_QUANTITY]
			,[FINGERPRINT]
		)
			SELECT 
				     a.[PARENT_SKU]
					,a.[CHILD_SKU] 
					,a.[PARENT_PATH]
					,a.[CHILD_PATH]
					,a.[ITEM_TYPE]
					,a.[ITEM_NUM]
					,a.[LEVEL]
					,a.[COMPONENT_QUANTITY]
					,a.[FINGERPRINT]
			FROM (
				MERGE Oracle.BillOfMaterial b
				USING (SELECT * FROM #BOM) a
				ON a.PARENT_PATH = b.PARENT_PATH AND a.CHILD_PATH = b.CHILD_PATH AND b.CurrentRecord = 1 AND a.ITEM_NUM = b.ITEM_NUM
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					 [PARENT_SKU]
					,[CHILD_SKU]
					,[PARENT_PATH]
					,[CHILD_PATH]
					,[ITEM_TYPE]
					,[ITEM_NUM]
					,[LEVEL]
					,[COMPONENT_QUANTITY]
					,[FINGERPRINT]
				)
				VALUES (
						 a.[PARENT_SKU]
						,a.[CHILD_SKU] 
						,a.[PARENT_PATH]
						,a.[CHILD_PATH]
						,a.[ITEM_TYPE]
						,a.[ITEM_NUM]
						,a.[LEVEL]
						,a.[COMPONENT_QUANTITY]
						,a.[FINGERPRINT]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						 a.[PARENT_SKU]
						,a.[CHILD_SKU] 
						,a.[PARENT_PATH]
						,a.[CHILD_PATH]						
						,a.[ITEM_TYPE]
						,a.[ITEM_NUM]
						,a.[LEVEL]
						,a.[COMPONENT_QUANTITY]
						,a.[FINGERPRINT]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
	
	DROP TABLE #BOM

END


GO
