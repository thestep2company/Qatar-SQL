USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_RotoParts]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [Oracle].[Merge_RotoParts] AS BEGIN


	CREATE TABLE #RotoParts(
		[PARENT_SKU] [nvarchar](40) NULL,
		[CHILD_SKU] [nvarchar](40) NULL,
		[ITEM_NUM] [float] NULL,
		[LEVEL] [float] NULL,
		[COMPONENT_QUANTITY] [float] NOT NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) ON [PRIMARY]



	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #RotoParts
	SELECT d.*, 'XXXXXXX'
	FROM OPENQUERY(PROD,'
	select
		--bom.assembly_item_id,
		k.Segment1 AS Parent_SKU,
		--bic.component_item_id child_item_id,
		c.Segment1 AS Child_SKU,
		--bic.bill_sequence_id,
		--bic.operation_seq_num,
		--bic.bom_item_type,
		bic.item_num,
		level,
		bic.component_quantity
	from
		bom_inventory_components bic
		INNER JOIN (select * from bom_bill_of_materials where organization_id=85 ) bom ON bom.bill_sequence_id=bic.bill_sequence_id
		LEFT JOIN MTL_SYSTEM_ITEMS_B k ON bom.Assembly_Item_ID = k.Inventory_Item_ID AND bom.Organization_ID = k.Organization_ID
		LEFT JOIN MTL_SYSTEM_ITEMS_B c ON bic.component_item_id = c.Inventory_Item_ID AND bom.Organization_ID = c.Organization_ID
	WHERE Level = 1  AND c.Attribute4 = ''ROTO MOLDED PARTS'' --AND k.segment1 = ''867501''
		 AND effectivity_date <= sysdate AND NVL(disable_date, sysdate ) >= sysdate
	connect by nocycle prior bic.component_item_id=bom.assembly_item_id
	'
	) d


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	/*	
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('RotoParts','Oracle') SELECT @columnList
	*/
		UPDATE #rotoParts
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				CAST(ISNULL(PARENT_SKU,'') AS VARCHAR(40)) +  CAST(ISNULL(CHILD_SKU,'') AS VARCHAR(40)) +  CAST(ISNULL(ITEM_NUM,'0') AS VARCHAR(100)) +  CAST(ISNULL(LEVEL,'0') AS VARCHAR(100)) +  CAST(ISNULL(COMPONENT_QUANTITY,'0') AS VARCHAR(100))
			),1)),3,32);


			
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.BOM (
		[PARENT_SKU]
		,[CHILD_SKU] 
		,[ITEM_NUM]
		,[LEVEL]
		,[COMPONENT_QUANTITY]
		,[FINGERPRINT]
	)
		SELECT 
				a.[PARENT_SKU]
				,a.[CHILD_SKU] 
				,a.[ITEM_NUM]
				,a.[LEVEL]
				,a.[COMPONENT_QUANTITY]
				,a.[FINGERPRINT]
		FROM (
			MERGE Oracle.BOM b
			USING (SELECT * FROM #RotoParts) a
			ON a.PARENT_SKU = b.PARENT_SKU AND a.CHILD_SKU = b.CHILD_SKU AND b.CurrentRecord = 1 --swap with business key of table
			WHEN NOT MATCHED --BY TARGET 
			THEN INSERT (
				[PARENT_SKU]
				,[CHILD_SKU] 
				,[ITEM_NUM]
				,[LEVEL]
				,[COMPONENT_QUANTITY]
				,[FINGERPRINT]
			)
			VALUES (
					a.[PARENT_SKU]
					,a.[CHILD_SKU] 
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
					,a.[ITEM_NUM]
					,a.[LEVEL]
					,a.[COMPONENT_QUANTITY]
					,a.[FINGERPRINT]
					,$Action AS Action
		) a
		WHERE Action = 'Update'
		;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #RotoParts

END

GO
