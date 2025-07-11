USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_BOM]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_BOM] AS BEGIN
	
	CREATE TABLE #BOM(
		[PARENT_SKU] [nvarchar](40) NULL,
		[CHILD_SKU] [nvarchar](40) NULL,
		[ITEM_TYPE] [nvarchar](50) NULL,
		[ITEM_NUM] [float] NULL,
		[LEVEL] [float] NULL,
		[COMPONENT_QUANTITY] [float] NOT NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) ON [PRIMARY]

	INSERT INTO #BOM
	SELECT d.*, 'XXXXXXX'
	FROM OPENQUERY(PROD,'
	select
		k.Segment1 AS Parent_SKU,
		c.Segment1 AS Child_SKU,
		c.Attribute4 AS Item_Type,
		bic.item_num,
		level,
		bic.component_quantity
	from
		bom_inventory_components bic
		INNER JOIN (select * from bom_bill_of_materials where organization_id=85 ) bom ON bom.bill_sequence_id=bic.bill_sequence_id
		LEFT JOIN MTL_SYSTEM_ITEMS_B k ON bom.Assembly_Item_ID = k.Inventory_Item_ID AND bom.Organization_ID = k.Organization_ID
		LEFT JOIN MTL_SYSTEM_ITEMS_B c ON bic.component_item_id = c.Inventory_Item_ID AND bom.Organization_ID = c.Organization_ID
	WHERE Level = 1 
		 AND effectivity_date <= sysdate AND NVL(disable_date, sysdate ) >= sysdate
	connect by nocycle prior bic.component_item_id=bom.assembly_item_id
	'
	) d


		/*	
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('BillOfMaterial','Oracle') SELECT @columnList
		*/
		UPDATE #BOM
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				 CAST(ISNULL(PARENT_SKU,'') AS VARCHAR(40)) +  CAST(ISNULL(CHILD_SKU,'') AS VARCHAR(40)) +  CAST(ISNULL(ITEM_TYPE,'') AS VARCHAR(50)) +  CAST(ISNULL(ITEM_NUM,'0') AS VARCHAR(100)) +  CAST(ISNULL(LEVEL,'0') AS VARCHAR(100)) +  CAST(ISNULL(COMPONENT_QUANTITY,'0') AS VARCHAR(100)) 
			),1)),3,32);

		UPDATE target 
		SET CurrentRecord = 0, EndDate = GETDATE()
		FROM Oracle.BillOfMaterial target
			LEFT JOIN #BOM source ON target.PARENT_SKU = source.PARENT_SKU AND target.CHILD_SKU = source.CHILD_SKU 
		WHERE (ISNULL(target.COMPONENT_QUANTITY,0) <> ISNULL(source.COMPONENT_QUANTITY,0)
				OR ISNULL(target.LEVEL,0) <> ISNULL(source.Level,0)
				OR ISNULL(target.ITEM_NUM,0) <> ISNULL(source.ITEM_NUM,0)
			)

		--expire records outside the merge

		INSERT INTO Oracle.BillOfMaterial (
			[PARENT_SKU]
			,[CHILD_SKU] 
			,[ITEM_TYPE]
			,[ITEM_NUM]
			,[LEVEL]
			,[COMPONENT_QUANTITY]
			,[FINGERPRINT]
		)
			SELECT 
				    a.[PARENT_SKU]
					,a.[CHILD_SKU] 
					,a.[ITEM_TYPE]
					,a.[ITEM_NUM]
					,a.[LEVEL]
					,a.[COMPONENT_QUANTITY]
					,a.[FINGERPRINT]
			FROM (
				MERGE Oracle.BillOfMaterial b
				USING (SELECT * FROM #BOM) a
				ON a.PARENT_SKU = b.PARENT_SKU AND a.CHILD_SKU = b.CHILD_SKU AND b.CurrentRecord = 1 -- AND a.ITEM_NUM = b.ITEM_NUM
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					[PARENT_SKU]
					,[CHILD_SKU]
					,[ITEM_TYPE]
					,[ITEM_NUM]
					,[LEVEL]
					,[COMPONENT_QUANTITY]
					,[FINGERPRINT]
				)
				VALUES (
						a.[PARENT_SKU]
						,a.[CHILD_SKU] 
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
						,a.[ITEM_TYPE]
						,a.[ITEM_NUM]
						,a.[LEVEL]
						,a.[COMPONENT_QUANTITY]
						,a.[FINGERPRINT]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	DROP TABLE #BOM

END

GO
