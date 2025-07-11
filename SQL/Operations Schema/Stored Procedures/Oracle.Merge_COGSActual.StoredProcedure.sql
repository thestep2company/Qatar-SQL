USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_COGSActual]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Oracle].[Merge_COGSActual] AS BEGIN

	CREATE TABLE #COGSActual(
		[ORGANIZATION_ID] [float] NOT NULL,
		[SKU] [nvarchar](40) NULL,
		[DESCRIPTION] [nvarchar](240) NULL,
		[SHIPMENT_NUMBER] [nvarchar](30) NULL,
		[COST_ELEMENT_ID] [float] NULL,
		[TRANSACTION_ID] [float] NOT NULL,
		[TRANSACTION_DATE] [datetime2](7) NULL,
		[TRANSACTION_TYPE_NAME] [nvarchar](80) NOT NULL,
		[GL_ACCOUNT] [nvarchar](129) NULL,
		[MATERIAL] [float] NULL,
		[MATERIAL_OH] [float] NULL,
		[RESOURCE_COST] [float] NULL,
		[OUTSIDE_PROCESSING] [float] NULL,
		[OVERHEAD] [float] NULL,
		[MATERIALQTY] [float] NULL,
		[MATERIALOHQTY] [float] NULL,
		[RESOURCECOSTQTY] [float] NULL,
		[OUTSIDEPROCESSINGQTY] [float] NULL,
		[OVERHEADQTY] [float] NULL,
		[FINGERPRINT] [varchar](32) NOT NULL,
		UNIQUE ([TRANSACTION_ID], [COST_ELEMENT_ID], [GL_ACCOUNT])
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	--grab the cogs from the inventory transaction that occurred
	INSERT INTO #COGSActual
	SELECT *, 'XXXXXXXX'
	FROM OPENQUERY(PROD,
	'
	SELECT
		  msib.organization_id
		, msib.segment1 AS SKU
		, msib.description
		, mmt.SHIPMENT_NUMBER
		, 0 AS COST_ELEMENT_ID
		, mmt.transaction_id
		, mta.transaction_date
		, mtt.transaction_type_name
		, ca.segment1 || ''.'' || ca.segment2 || ''.'' || ca.segment3 || ''.'' || ca.segment4 || ''.'' || ca.segment5 as GL_ACCOUNT
		, sum(case when nvl(mta.COST_ELEMENT_ID,1) = 1 then nvl(mta.base_transaction_value,0) else 0 end)  as Material
		, sum(case when mta.COST_ELEMENT_ID = 2 then nvl(mta.base_transaction_value,0) else 0 end)  as Material_OH
		, sum(case when mta.COST_ELEMENT_ID = 3 then nvl(mta.base_transaction_value,0) else 0 end)  as Resource_cost
		, sum(case when mta.COST_ELEMENT_ID = 4 then nvl(mta.base_transaction_value,0) else 0 end)  as OutSide_Processing
		, sum(case when mta.COST_ELEMENT_ID = 5 then nvl(mta.base_transaction_value,0) else 0 end)  as OverHead
		, sum(case when nvl(mta.COST_ELEMENT_ID,1) = 1 then nvl(mta.primary_quantity,0) else 0 end)  as MaterialQty
		, sum(case when mta.COST_ELEMENT_ID = 2 then nvl(mta.primary_quantity,0) else 0 end)  as MaterialOHQty
		, sum(case when mta.COST_ELEMENT_ID = 3 then nvl(mta.primary_quantity,0) else 0 end)  as ResourceCostQty
		, sum(case when mta.COST_ELEMENT_ID = 4 then nvl(mta.primary_quantity,0) else 0 end)  as OutSideProcessingQty
		, sum(case when mta.COST_ELEMENT_ID = 5 then nvl(mta.primary_quantity,0) else 0 end)  as OverHeadQty
	FROM 
	  INV.mtl_system_items_b msib
	  LEFT JOIN INV.mtl_material_transactions mmt	ON msib.inventory_item_id = mmt.inventory_item_id and msib.organization_id = mmt.organization_id
	  LEFT JOIN INV.mtl_transaction_accounts mta	ON mmt.transaction_id = mta.transaction_id
	  LEFT JOIN GL.gl_code_combinations ca			ON mta.reference_account = ca.code_combination_id
	  LEFT JOIN INV.mtl_transaction_types mtt		ON mmt.transaction_type_id = mtt.transaction_type_id
	WHERE 
		mmt.transaction_date >= SYSDATE - 3
		AND (mtt.transaction_type_name = ''COGS Recognition'' OR mtt.transaction_type_name = ''Sales order issue'')
	GROUP BY
		  msib.organization_id
		, msib.segment1
		, msib.description
		, mmt.SHIPMENT_NUMBER
		, mmt.transaction_id
		, mta.transaction_date
		, mtt.transaction_type_name
		, ca.segment1 || ''.'' || ca.segment2 || ''.'' || ca.segment3 || ''.'' || ca.segment4 || ''.'' || ca.segment5
	'
	)


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()
	
	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('COGSActual','Oracle') SELECT @columnList
	*/
	UPDATE #COGSActual
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
				 CAST(ISNULL([ORGANIZATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([SKU],'') AS VARCHAR(40)) +  CAST(ISNULL([DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIPMENT_NUMBER],'') AS VARCHAR(30)) +  CAST(ISNULL([COST_ELEMENT_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([TRANSACTION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([TRANSACTION_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([TRANSACTION_TYPE_NAME],'') AS VARCHAR(80)) +  CAST(ISNULL([GL_ACCOUNT],'') AS VARCHAR(129)) +  CAST(ISNULL([MATERIAL],'0') AS VARCHAR(100)) +  CAST(ISNULL([MATERIAL_OH],'0') AS VARCHAR(100)) +  CAST(ISNULL([RESOURCE_COST],'0') AS VARCHAR(100)) +  CAST(ISNULL([OUTSIDE_PROCESSING],'0') AS VARCHAR(100)) +  CAST(ISNULL([OVERHEAD],'0') AS VARCHAR(100)) +  CAST(ISNULL([MATERIALQTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([MATERIALOHQTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([RESOURCECOSTQTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([OUTSIDEPROCESSINGQTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([OVERHEADQTY],'0') AS VARCHAR(100)) 
		),1)),3,32);


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.COGSActual (
			  [ORGANIZATION_ID]
			  ,[SKU]
			  ,[DESCRIPTION]
			  ,[SHIPMENT_NUMBER]
			  ,[COST_ELEMENT_ID]
			  ,[TRANSACTION_ID]
			  ,[TRANSACTION_DATE]
			  ,[TRANSACTION_TYPE_NAME]
			  ,[GL_ACCOUNT]
			  ,[MATERIAL]
			  ,[MATERIAL_OH]
			  ,[RESOURCE_COST]
			  ,[OUTSIDE_PROCESSING]
			  ,[OVERHEAD]
			  ,[MATERIALQTY]
			  ,[MATERIALOHQTY]
			  ,[RESOURCECOSTQTY]
			  ,[OUTSIDEPROCESSINGQTY]
			  ,[OVERHEADQTY]
			  ,[Fingerprint]
	)
		SELECT 
				a.[ORGANIZATION_ID]
			  ,a.[SKU]
			  ,a.[DESCRIPTION]
			  ,a.[SHIPMENT_NUMBER]
			  ,a.[COST_ELEMENT_ID]
			  ,a.[TRANSACTION_ID]
			  ,a.[TRANSACTION_DATE]
			  ,a.[TRANSACTION_TYPE_NAME]
			  ,a.[GL_ACCOUNT]
			  ,a.[MATERIAL]
			  ,a.[MATERIAL_OH]
			  ,a.[RESOURCE_COST]
			  ,a.[OUTSIDE_PROCESSING]
			  ,a.[OVERHEAD]
			  ,a.[MATERIALQTY]
			  ,a.[MATERIALOHQTY]
			  ,a.[RESOURCECOSTQTY]
			  ,a.[OUTSIDEPROCESSINGQTY]
			  ,a.[OVERHEADQTY]
			  ,a.[Fingerprint]
		FROM (
			MERGE Oracle.COGSActual b
			USING (SELECT * FROM #COGSActual) a
			ON a.[TRANSACTION_ID] = b.[TRANSACTION_ID] 
				AND a.[COST_ELEMENT_ID] = b.[COST_ELEMENT_ID] 
				AND a.[GL_ACCOUNT] = b.[GL_ACCOUNT]
				AND b.CurrentRecord = 1 --swap with business key of table
			WHEN NOT MATCHED --BY TARGET 
			THEN INSERT (
				[ORGANIZATION_ID]
			   ,[SKU]
			   ,[DESCRIPTION]
			   ,[SHIPMENT_NUMBER]
			   ,[COST_ELEMENT_ID]
			   ,[TRANSACTION_ID]
			   ,[TRANSACTION_DATE]
			   ,[TRANSACTION_TYPE_NAME]
			   ,[GL_ACCOUNT]
			   ,[MATERIAL]
			   ,[MATERIAL_OH]
			   ,[RESOURCE_COST]
			   ,[OUTSIDE_PROCESSING]
			   ,[OVERHEAD]
			   ,[MATERIALQTY]
			   ,[MATERIALOHQTY]
			   ,[RESOURCECOSTQTY]
			   ,[OUTSIDEPROCESSINGQTY]
			   ,[OVERHEADQTY]
			   ,[Fingerprint]
			)
			VALUES (
				   a.[ORGANIZATION_ID]
				  ,a.[SKU]
				  ,a.[DESCRIPTION]
				  ,a.[SHIPMENT_NUMBER]
				  ,a.[COST_ELEMENT_ID]
				  ,a.[TRANSACTION_ID]
				  ,a.[TRANSACTION_DATE]
				  ,a.[TRANSACTION_TYPE_NAME]
				  ,a.[GL_ACCOUNT]
				  ,a.[MATERIAL]
				  ,a.[MATERIAL_OH]
				  ,a.[RESOURCE_COST]
				  ,a.[OUTSIDE_PROCESSING]
				  ,a.[OVERHEAD]
				  ,a.[MATERIALQTY]
				  ,a.[MATERIALOHQTY]
				  ,a.[RESOURCECOSTQTY]
				  ,a.[OUTSIDEPROCESSINGQTY]
				  ,a.[OVERHEADQTY]
				  ,a.[Fingerprint]
			)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
			THEN UPDATE SET b.EndDate=GETDATE()
				,b.CurrentRecord=0
			OUTPUT 
					a.[ORGANIZATION_ID]
				    ,a.[SKU]
				    ,a.[DESCRIPTION]
				    ,a.[SHIPMENT_NUMBER]
				    ,a.[COST_ELEMENT_ID]
				    ,a.[TRANSACTION_ID]
				    ,a.[TRANSACTION_DATE]
				    ,a.[TRANSACTION_TYPE_NAME]
				    ,a.[GL_ACCOUNT]
				    ,a.[MATERIAL]
				    ,a.[MATERIAL_OH]
				    ,a.[RESOURCE_COST]
				    ,a.[OUTSIDE_PROCESSING]
				    ,a.[OVERHEAD]
				    ,a.[MATERIALQTY]
				    ,a.[MATERIALOHQTY]
				    ,a.[RESOURCECOSTQTY]
				    ,a.[OUTSIDEPROCESSINGQTY]
				    ,a.[OVERHEADQTY]
				    ,a.[Fingerprint]
					,$Action AS Action
		) a
		WHERE Action = 'Update'
		;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #COGSActual

END


GO
