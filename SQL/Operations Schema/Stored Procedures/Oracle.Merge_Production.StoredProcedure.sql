USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Production]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Production] AS BEGIN

		CREATE TABLE #Production (
				[TRANS_DATE_TIME] [datetime] NOT NULL,
				[PART_NUMBER] [varchar](50) NULL,
				[PART_DESCRIPTION] [varchar](100) NULL,
				[PRODUCTION_QTY] [int] NULL,
				[LIST_LESS_7] [real] NULL,
				[TOTAL_PRICE] [real] NULL,
				[PLANNER_CODE] [varchar](50) NULL,
				[RESOURCE_HOURS] [real] NULL,
				[TOTAL_MACHINE_HOURS] [real] NULL,
				[FG_RESIN_WGT] [real] NULL,
				[FG_TOTAL_RESIN] [real] NULL,
				[UNIT_VOLUME] [real] NULL,
				[TOTAL_VOLUME] [real] NULL,
				[ORG_CODE] [varchar](3) NULL,
				[ORG_NAME] [varchar](50) NULL,
				[STD_COST] [real] NULL,
				[RESOURCE_COST] [real] NULL,
				[EARNED_OVERHEAD] [real] NULL,
				[MATERIAL_COST] [real] NULL,
				[MATERIAL_OVERHEAD_COST] [real] NULL,
				[OUTSIDE_PROCESSING_COST] [real] NULL,
				[TRANSACTION_ID] [INT] NULL,
				[LINE_CODE] [VARCHAR](25) NULL,
				[LINE_DESCRIPTION] [VARCHAR](50) NULL,
				[SUBINVENTORY] [VARCHAR](50) NULL,
				[ITEM_TYPE] [VARCHAR](50) NULL,
				[COSTED_MACHINE_HOURS] [real] NULL,
				[TRANSACTION_SET_ID] [INT] NOT NULL,
				[SHIFT] [nvarchar](150) NULL,
				[SHIFT_ID] [INT] NULL,
				[Fingerprint] [varchar](32) NULL,
		)

		INSERT INTO #Production (
			   [TRANS_DATE_TIME]
			  ,[PART_NUMBER]
			  ,[PART_DESCRIPTION]
			  ,[PRODUCTION_QTY]
			  ,[LIST_LESS_7]
			  ,[TOTAL_PRICE]
			  ,[PLANNER_CODE]
			  ,[RESOURCE_HOURS]
			  ,[TOTAL_MACHINE_HOURS]
			  ,[FG_RESIN_WGT]
			  ,[FG_TOTAL_RESIN]
			  ,[UNIT_VOLUME]
			  ,[TOTAL_VOLUME]
			  ,[ORG_CODE]
			  ,[ORG_NAME]
			  ,[STD_COST]
			  ,[RESOURCE_COST]
			  ,[EARNED_OVERHEAD]
			  ,[MATERIAL_COST]
			  ,[MATERIAL_OVERHEAD_COST]
			  ,[OUTSIDE_PROCESSING_COST]
			  ,[TRANSACTION_ID]
			  ,[LINE_CODE]
			  ,[LINE_DESCRIPTION]
			  ,[SUBINVENTORY]
			  ,[ITEM_TYPE]
			  ,[COSTED_MACHINE_HOURS]
			  ,[TRANSACTION_SET_ID]
			  ,[Fingerprint]
		)
		SELECT 
				[TRANS_DATE_TIME]
				,[PART_NUMBER]
				,LEFT([PART_DESCRIPTION],100)
				,[PRODUCTION_QTY]
				,[LIST_LESS_7]
				,[TOTAL_PRICE]
				,[PLANNER_CODE]
				,[RESOURCE_HOURS]
				,[TOTAL_MACHINE_HOURS]
				,[FG_RESIN_WGT]
				,[FG_TOTAL_RESIN]
				,[UNIT_VOLUME]
				,[TOTAL_VOLUME]
				,[ORG_CODE]
				,[ORG_NAME]
				,[STD_COST]
				,[RESOURCE_COST]
				,[EARNED_OVERHEAD]
				,[MATERIAL_COST]
				,[MATERIAL_OVERHEAD_COST]
				,[OUTSIDE_PROCESSING_COST]
				,[TRANSACTION_ID]
				,[LINE_CODE]
				,[LINE_DESCRIPTION]
			    ,[SUBINVENTORY]
			    ,[ITEM_TYPE]
			    ,[COSTED_MACHINE_HOURS]
			    ,[TRANSACTION_SET_ID]
				,'XXX' AS Fingerprint
FROM OPENQUERY(PROD,
'	with prod_trx_groups as    
	(  
		SELECT	ood.organization_code					ORG_CODE
				,ood.organization_name					ORG_NAME
				,MSI.SEGMENT1							PART_NUMBER
				,MSI.DESCRIPTION						PART_DESCRIPTION
				,SUM(NVL(MMT.TRANSACTION_QUANTITY,0))	PRODUCTION_QTY
				,msi.PLANNER_CODE						PLANNER_CODE
				,msi.unit_volume						UNIT_VOLUME
				,mmt.transaction_date					TRANS_DATE_TIME
				,mmt.organization_id					mmt_org_id
				,mmt.inventory_item_id					mmt_inventory_item_id
				,mmt.transaction_source_id				mmt_transaction_source_id
				,mmt.Transaction_id						mmt_transaction_id
				,wl.line_code							wl_line_code
				,wl.description							wl_line_desc
				,UPPER(mmt.subinventory_code)			SubInventory
				,msi.item_type							Item_type
				,mmt.TRANSACTION_SET_ID					mmt_TRANSACTION_SET_ID
		from
				MTL_SYSTEM_ITEMS_B MSI
				LEFT JOIN MTL_MATERIAL_TRANSACTIONS MMT ON msi.organization_id = mmt.organization_id AND msi.inventory_item_id = mmt.inventory_item_id
				LEFT JOIN WIP_FLOW_SCHEDULES WFS ON mmt.transaction_source_id = wfs.wip_entity_id
				LEFT JOIN wip_lines wl ON to_number(mmt.attribute15) = wl.line_id AND mmt.organization_id = wl.organization_id
				LEFT JOIN MTL_TRANSACTION_TYPES MTT ON mmt.transaction_type_id = mtt.transaction_type_id
				LEFT JOIN ORG_ORGANIZATION_DEFINITIONS OOD ON msi.organization_id = ood.organization_id
				LEFT JOIN HR_OPERATING_UNITS HOU ON ood.operating_unit = hou.organization_id AND hou.short_code = ''S2C US''
		where	
				MMT.TRANSACTION_DATE >= sysdate - 1 
				AND (substr(msi.item_type,1,8)= ''STEP2 FG'' or substr(msi.item_type,1,20) = ''STEP2 SUB PROCESSING'')
				AND mtt.transaction_type_name = ''WIP Completion''
				AND msi.segment1 BETWEEN NVL(null, MSI.SEGMENT1) AND NVL(null, MSI.SEGMENT1)
		GROUP BY ood.organization_code  
				,ood.organization_name
				,msi.segment1
				,MSI.DESCRIPTION
				,PLANNER_CODE
				,msi.unit_volume
				,mmt.transaction_date  
				,mmt.organization_id
				,mmt.inventory_item_id
				,mmt.transaction_source_id
				,mmt.Transaction_id
				,wl.line_code
				,wl.description
				,UPPER(mmt.subinventory_code)
				,msi.item_type
				,mmt.TRANSACTION_SET_ID
	)
	, pricing as (
		select
			nvl( qll.operand, 0.00) AS LIST_LESS_7
			,qll.product_attr_val_disp
		from qp_secu_list_headers_v qsl
			,qp_list_lines_v qll
		where qsl.LIST_HEADER_ID = qll.LIST_HEADER_ID
			and qsl.name = ''NSP LESS 7%''
    )  
	, hours as (
		select  
			 itcdv.ORGANIZATION_ID ORGANIZATION_ID  
			,itcdv.inventory_item_id inventory_item_id 
			,sum(itcdv.usage_rate_or_amount) usage_hours 
			,sum(case when substr(itcdv.resource_code,1,7) = ''Machine'' then itcdv.usage_rate_or_amount else 0 end) Machine_hours
		from CST_ITEM_COST_DETAILS_V itcdv 
		where 1 = 1
			and itcdv.cost_type_id = 1  
			and itcdv.level_type = 1
			and itcdv.UNIT_OF_MEASURE = ''HR''
			and itcdv.organization_id NOT IN (88, 144, 145)
		group by
			itcdv.ORGANIZATION_ID
			,itcdv.inventory_item_id
	) 
	, resin_wgt AS (
		select  
			mmt.organization_id					ORG_ID
			,ptg.Part_Number					PART_NUMBER
			,abs(SUM( mmt.primary_quantity))	TOTAL_RESIN
			,PTG.TRANS_DATE_TIME				wgt_transaction_date
			,mmt.transaction_source_id			wgt_transaction_source_id
			,mmt.TRANSACTION_SET_ID             wgt_mmt_TRANSACTION_SET_ID
		from prod_trx_groups ptg
			LEFT JOIN INV.mtl_material_transactions mmt ON ptg.mmt_transaction_set_id = mmt.transaction_set_id
			LEFT JOIN INV.mtl_system_items_b msib ON mmt.inventory_item_id = msib.inventory_item_id and mmt.organization_id = msib.organization_id
		where 1 = 1
			and msib.item_type = ''STEP2 PIGMENTED RESIN MFG''
		group by ptg.Part_Number
			,mmt.organization_id
			,PTG.TRANS_DATE_TIME
			,mmt.transaction_source_id
			,mmt.TRANSACTION_SET_ID 
    )  
	select  
		 ptg.mmt_inventory_item_id
		,ptg.mmt_org_id
		,PTG.TRANS_DATE_TIME							TRANS_DATE_TIME
		,ptg.org_code									ORG_CODE
		,ptg.org_name									ORG_NAME    
		,ptg.part_number								PART_NUMBER
		,ptg.part_description							PART_DESCRIPTION
		,ptg.production_qty								PRODUCTION_QTY
		,nvl(ql.LIST_LESS_7,0)							LIST_LESS_7
		,(ptg.production_qty * nvl(ql.LIST_LESS_7,0))	TOTAL_PRICE 
		,nvl(ptg.planner_code,''MISSING'')				PLANNER_CODE
		,nvl(hrs.usage_hours,0)							RESOURCE_HOURS
		,nvl(ptg.production_qty * nvl(hrs.usage_hours,0),0) TOTAL_MACHINE_HOURS
		,nvl((rwgt.TOTAL_RESIN / ptg.production_qty),0) FG_RESIN_WGT
		,nvl(rwgt.TOTAL_RESIN,0)						FG_TOTAL_RESIN
		,nvl(ptg.unit_volume,0)							UNIT_VOLUME 
		,nvl((ptg.production_qty * ptg.unit_volume),0)	TOTAL_VOLUME
		,itcv.item_cost									STD_COST
		,itcv.resource_cost								RESOURCE_COST 
		,itcv.overhead_cost								EARNED_OVERHEAD
		,itcv.material_cost								MATERIAL_COST
		,itcv.material_overhead_cost					MATERIAL_OVERHEAD_COST
		,itcv.outside_processing_cost					OUTSIDE_PROCESSING_COST
		,ptg.mmt_transaction_id                         TRANSACTION_ID
		,ptg.wl_line_code                               line_code
		,ptg.wl_line_desc								line_description
		,UPPER(ptg.subinventory)						SubInventory
		,ptg.item_type									Item_type
		,hrs.Machine_hours								Costed_Machine_Hours
		,ptg.mmt_TRANSACTION_SET_ID						TRANSACTION_SET_ID
	from prod_trx_groups ptg
		--left join resin_wgt rwgt on ptg.mmt_transaction_source_id = rwgt.wgt_transaction_source_id
		left join resin_wgt rwgt on ptg.mmt_TRANSACTION_SET_ID = rwgt.wgt_mmt_TRANSACTION_SET_ID
		left join pricing ql on ptg.part_number = ql.product_attr_val_disp
		left join CST_ITEM_COST_TYPE_V itcv on ptg.mmt_org_id = itcv.organization_id
			and ptg.mmt_inventory_item_id = itcv.inventory_item_id and itcv.cost_type = ''Frozen''
		left join pricing ql on ptg.part_number = ql.product_attr_val_disp
		left join hours hrs on ptg.mmt_org_id = hrs.organization_id and ptg.mmt_inventory_item_id = hrs.inventory_item_id'
	)

			--assign ShiftID
		UPDATE pro
		SET pro.Shift = s2.Shift
			,pro.SHIFT_ID = s2.Shift_ID
		FROM #Production pro
			LEFT JOIN Manufacturing.Shift s2 ON  pro.ORG_CODE = s2.Org AND pro.TRANS_DATE_TIME >= s2.Start_Date_Time AND pro.TRANS_DATE_TIME < s2.End_Date_Time AND s2.CurrentRecord = 1

		--move shift if not mapped to ShiftID
		UPDATE pro
		SET SHIFT_ID = s2.Shift_ID
			,Shift = s2.Shift
		FROM #Production pro 
			LEFT JOIN Manufacturing.Shift s2 ON pro.ORG_CODE = s2.Org AND pro.TRANS_DATE_TIME >= s2.Start_Date_Time AND pro.TRANS_DATE_TIME < s2.End_Date_Time AND s2.CurrentRecord = 1
		WHERE pro.Shift_ID IS NULL
		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Production','Oracle') SELECT @columnList
		*/
		UPDATE #Production
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				   CAST(ISNULL([TRANS_DATE_TIME],'') AS VARCHAR(100)) +  CAST(ISNULL([PART_NUMBER],'') AS VARCHAR(50)) +  CAST(ISNULL([PART_DESCRIPTION],'') AS VARCHAR(100)) +  CAST(ISNULL([PRODUCTION_QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([LIST_LESS_7],'0') AS VARCHAR(100)) +  CAST(ISNULL([TOTAL_PRICE],'0') AS VARCHAR(100)) +  CAST(ISNULL([PLANNER_CODE],'') AS VARCHAR(50)) +  CAST(ISNULL([RESOURCE_HOURS],'0') AS VARCHAR(100)) +  CAST(ISNULL([TOTAL_MACHINE_HOURS],'0') AS VARCHAR(100)) +  CAST(ISNULL([FG_RESIN_WGT],'0') AS VARCHAR(100)) +  CAST(ISNULL([FG_TOTAL_RESIN],'0') AS VARCHAR(100)) +  CAST(ISNULL([UNIT_VOLUME],'0') AS VARCHAR(100)) +  CAST(ISNULL([TOTAL_VOLUME],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORG_CODE],'') AS VARCHAR(3)) +  CAST(ISNULL([ORG_NAME],'') AS VARCHAR(50)) +  CAST(ISNULL([STD_COST],'0') AS VARCHAR(100)) +  CAST(ISNULL([RESOURCE_COST],'0') AS VARCHAR(100)) +  CAST(ISNULL([EARNED_OVERHEAD],'0') AS VARCHAR(100)) +  CAST(ISNULL([MATERIAL_COST],'0') AS VARCHAR(100)) +  CAST(ISNULL([MATERIAL_OVERHEAD_COST],'0') AS VARCHAR(100)) +  CAST(ISNULL([OUTSIDE_PROCESSING_COST],'0') AS VARCHAR(100)) +  CAST(ISNULL([TRANSACTION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([LINE_CODE],'') AS VARCHAR(25)) +  CAST(ISNULL([LINE_DESCRIPTION],'') AS VARCHAR(50)) +  CAST(ISNULL([SUBINVENTORY],'') AS VARCHAR(50)) +  CAST(ISNULL([ITEM_TYPE],'') AS VARCHAR(50)) +  CAST(ISNULL([COSTED_MACHINE_HOURS],'0') AS VARCHAR(100)) +  CAST(ISNULL([TRANSACTION_SET_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([SHIFT],'') AS VARCHAR(150)) +  CAST(ISNULL([SHIFT_ID],'0') AS VARCHAR(100)) 
			),1)),3,32);

		--expire records outside the merge

		INSERT INTO Oracle.Production (
				 [TRANS_DATE_TIME]
				,[PART_NUMBER]
				,[PART_DESCRIPTION]
				,[PRODUCTION_QTY]
				,[LIST_LESS_7]
				,[TOTAL_PRICE]
				,[PLANNER_CODE]
				,[RESOURCE_HOURS]
				,[TOTAL_MACHINE_HOURS]
				,[FG_RESIN_WGT]
				,[FG_TOTAL_RESIN]
				,[UNIT_VOLUME]
				,[TOTAL_VOLUME]
				,[ORG_CODE]
				,[ORG_NAME]
				,[STD_COST]
				,[RESOURCE_COST]
				,[EARNED_OVERHEAD]
				,[MATERIAL_COST]
				,[MATERIAL_OVERHEAD_COST]
				,[OUTSIDE_PROCESSING_COST]
				,[TRANSACTION_ID]
				,[LINE_CODE]
				,[LINE_DESCRIPTION]
			    ,[SUBINVENTORY]
			    ,[ITEM_TYPE]
			    ,[COSTED_MACHINE_HOURS]
			    ,[TRANSACTION_SET_ID]
			    ,[SHIFT]
			    ,[SHIFT_ID]
				,[Fingerprint]
		)
			SELECT 
				 a.[TRANS_DATE_TIME]
				,a.[PART_NUMBER]
				,a.[PART_DESCRIPTION]
				,a.[PRODUCTION_QTY]
				,a.[LIST_LESS_7]
				,a.[TOTAL_PRICE]
				,a.[PLANNER_CODE]
				,a.[RESOURCE_HOURS]
				,a.[TOTAL_MACHINE_HOURS]
				,a.[FG_RESIN_WGT]
				,a.[FG_TOTAL_RESIN]
				,a.[UNIT_VOLUME]
				,a.[TOTAL_VOLUME]
				,a.[ORG_CODE]
				,a.[ORG_NAME]
				,a.[STD_COST]
				,a.[RESOURCE_COST]
				,a.[EARNED_OVERHEAD]
				,a.[MATERIAL_COST]
				,a.[MATERIAL_OVERHEAD_COST]
				,a.[OUTSIDE_PROCESSING_COST]
				,a.[TRANSACTION_ID]
				,a.[LINE_CODE]
				,a.[LINE_DESCRIPTION]
			    ,a.[SUBINVENTORY]
			    ,a.[ITEM_TYPE]
			    ,a.[COSTED_MACHINE_HOURS]
			    ,a.[TRANSACTION_SET_ID]
			    ,a.[SHIFT]
			    ,a.[SHIFT_ID]
				,a.[Fingerprint]
			FROM (
				MERGE Oracle.Production b
				USING (SELECT * FROM #Production) a
				ON a.Transaction_SET_ID = b.Transaction_SET_ID AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
						 [TRANS_DATE_TIME]
						,[PART_NUMBER]
						,[PART_DESCRIPTION]
						,[PRODUCTION_QTY]
						,[LIST_LESS_7]
						,[TOTAL_PRICE]
						,[PLANNER_CODE]
						,[RESOURCE_HOURS]
						,[TOTAL_MACHINE_HOURS]
						,[FG_RESIN_WGT]
						,[FG_TOTAL_RESIN]
						,[UNIT_VOLUME]
						,[TOTAL_VOLUME]
						,[ORG_CODE]
						,[ORG_NAME]
						,[STD_COST]
						,[RESOURCE_COST]
						,[EARNED_OVERHEAD]
						,[MATERIAL_COST]
						,[MATERIAL_OVERHEAD_COST]
						,[OUTSIDE_PROCESSING_COST]
						,[TRANSACTION_ID]
						,[LINE_CODE]
						,[LINE_DESCRIPTION]
						,[SUBINVENTORY]
						,[ITEM_TYPE]
						,[COSTED_MACHINE_HOURS]
						,[TRANSACTION_SET_ID]
						,[SHIFT]
						,[SHIFT_ID]
						,[Fingerprint]
				)
				VALUES (
						 a.[TRANS_DATE_TIME]
						,a.[PART_NUMBER]
						,a.[PART_DESCRIPTION]
						,a.[PRODUCTION_QTY]
						,a.[LIST_LESS_7]
						,a.[TOTAL_PRICE]
						,a.[PLANNER_CODE]
						,a.[RESOURCE_HOURS]
						,a.[TOTAL_MACHINE_HOURS]
						,a.[FG_RESIN_WGT]
						,a.[FG_TOTAL_RESIN]
						,a.[UNIT_VOLUME]
						,a.[TOTAL_VOLUME]
						,a.[ORG_CODE]
						,a.[ORG_NAME]
						,a.[STD_COST]
						,a.[RESOURCE_COST]
						,a.[EARNED_OVERHEAD]
						,a.[MATERIAL_COST]
						,a.[MATERIAL_OVERHEAD_COST]
						,a.[OUTSIDE_PROCESSING_COST]
						,a.[TRANSACTION_ID]
						,a.[LINE_CODE]
						,a.[LINE_DESCRIPTION]
						,a.[SUBINVENTORY]
						,a.[ITEM_TYPE]
						,a.[COSTED_MACHINE_HOURS]
						,a.[TRANSACTION_SET_ID]
						,a.[SHIFT]
						,a.[SHIFT_ID]
						,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						 a.[TRANS_DATE_TIME]
						,a.[PART_NUMBER]
						,a.[PART_DESCRIPTION]
						,a.[PRODUCTION_QTY]
						,a.[LIST_LESS_7]
						,a.[TOTAL_PRICE]
						,a.[PLANNER_CODE]
						,a.[RESOURCE_HOURS]
						,a.[TOTAL_MACHINE_HOURS]
						,a.[FG_RESIN_WGT]
						,a.[FG_TOTAL_RESIN]
						,a.[UNIT_VOLUME]
						,a.[TOTAL_VOLUME]
						,a.[ORG_CODE]
						,a.[ORG_NAME]
						,a.[STD_COST]
						,a.[RESOURCE_COST]
						,a.[EARNED_OVERHEAD]
						,a.[MATERIAL_COST]
						,a.[MATERIAL_OVERHEAD_COST]
						,a.[OUTSIDE_PROCESSING_COST]
						,a.[TRANSACTION_ID]
						,a.[LINE_CODE]
						,a.[LINE_DESCRIPTION]
					    ,a.[SUBINVENTORY]
					    ,a.[ITEM_TYPE]
					    ,a.[COSTED_MACHINE_HOURS]
					    ,a.[TRANSACTION_SET_ID]
					    ,a.[SHIFT]
					    ,a.[SHIFT_ID]
						,a.[Fingerprint]
						,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		DROP TABLE #Production
	
	END 

	
GO
