USE [Operations]
GO
/****** Object:  StoredProcedure [Manufacturing].[Merge_ProductionQuery]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--DELETE FROM Testing.Production WHERE TRANS_DATE_TIME >= '2021-01-01'
	
	CREATE PROCEDURE [Manufacturing].[Merge_ProductionQuery] AS BEGIN

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
				,'XXX' AS Fingerprint
		FROM OPENQUERY(PROD,
			'with prod_trx_groups as 
            ( 
					SELECT ood.organization_code                    AS ORG_CODE 
						  ,ood.organization_name                    AS ORG_NAME 
						  ,MSI.SEGMENT1                             AS PART_NUMBER 
						  ,MSI.DESCRIPTION                          AS PART_DESCRIPTION 
						  ,SUM( NVL( MMT.TRANSACTION_QUANTITY,0 ) ) AS PRODUCTION_QTY 
						  ,msi.PLANNER_CODE                         AS PLANNER_CODE 
						  ,CRH.RESOURCE_DEPARTMENT_HOURS            AS RESOURCE_HOURS 
						  ,msi.unit_volume                          AS UNIT_VOLUME 
						  ,mmt.transaction_date						AS TRANS_DATE_TIME --to_char(mmt.transaction_date,''YYYY-MM-DD'') --to_char(mmt.transaction_date,''YYYY-MM-DD HH:MI:SS'')                      
						  --, EXTRACT(HOUR FROM mmt.transaction_date) AS Trans_TIME
						  , mmt.organization_id                     AS mmt_org_id 
						  , mmt.inventory_item_id                   AS mmt_inventory_item_id 
						  , mmt.transaction_source_id               AS mmt_transaction_source_id
						  , mmt.Transaction_id                      AS mmt_transaction_id 
						  , wl.line_code                            AS wl_line_code 
						  , wl.description                          AS wl_line_desc  
					from MTL_SYSTEM_ITEMS_B						MSI 
						LEFT JOIN CRP_RESOURCE_HOURS			CRH		ON msi.ORGANIZATION_ID = CRH.ORGANIZATION_ID and msi.inventory_item_id = crh.assembly_item_id 
						LEFT JOIN MTL_MATERIAL_TRANSACTIONS		MMT		ON msi.inventory_item_id = mmt.inventory_item_id 
						LEFT JOIN WIP_FLOW_SCHEDULES			WFS		ON mmt.transaction_source_id = wfs.wip_entity_id 
						LEFT JOIN MTL_TRANSACTION_TYPES			MTT     ON msi.organization_id = mmt.organization_id AND mmt.transaction_type_id = mtt.transaction_type_id
						LEFT JOIN wip_lines						WL		ON to_number(mmt.attribute15) = wl.line_id AND mmt.organization_id = wl.organization_id
						LEFT JOIN ORG_ORGANIZATION_DEFINITIONS	OOD		ON msi.organization_id = ood.organization_id 
						LEFT JOIN HR_OPERATING_UNITS			HOU		ON ood.operating_unit = hou.organization_id 
					where MMT.TRANSACTION_DATE >= SYSDATE - 35  --TO_DATE(''20210315'',''YYYYMMDD'') --AND MMT.TRANSACTION_DATE < TO_DATE(''20210101'',''YYYYMMDD'')
						  AND UPPER(mmt.subinventory_code) like ''%WIP%''  
						  AND mtt.transaction_type_name = ''WIP Completion'' 
						  AND hou.short_code = ''S2C US'' 
						  and msi.segment1 BETWEEN NVL(null, MSI.SEGMENT1 ) AND NVL( null, MSI.SEGMENT1 ) 
					GROUP BY ood.organization_code 
						  , ood.organization_name 
						  , msi.segment1 
						  , MSI.DESCRIPTION  
						  , PLANNER_CODE 
						  , CRH.RESOURCE_DEPARTMENT_HOURS 
						  , msi.unit_volume 
						  , mmt.transaction_date 
						  --, EXTRACT(HOUR FROM mmt.transaction_date)
						  , mmt.organization_id 
						  , mmt.inventory_item_id 
						  , mmt.transaction_source_id 
						  , mmt.Transaction_id
						  , wl.line_code
						  , wl.description
            ) 
            , pricing as 
            ( 
				  select 
					  nvl( qll.operand, 0.00) AS LIST_LESS_7 
					  , qll.product_attr_val_disp 
				  from qp_secu_list_headers_v	  qsl 
						LEFT JOIN qp_list_lines_v qll ON qsl.LIST_HEADER_ID = qll.LIST_HEADER_ID 
				  where qsl.name = ''NSP LESS 7%'' 
            ) 
            , resin_wgt AS 
            ( 
				select  
					  msib.organization_id				   AS ORG_ID 
					  , msib.segment1                      AS PART_NUMBER 
					  , abs(SUM( mmt_1.primary_quantity))  AS TOTAL_RESIN 
					  , mmt.transaction_date 
					  , mmt.transaction_source_id          AS wgt_transaction_source_id  
				FROM  INV.mtl_material_transactions				 mmt 
					  LEFT JOIN MTL_TRANSACTION_TYPES            MTT ON mmt.transaction_type_id = mtt.transaction_type_id 
					  LEFT JOIN INV.mtl_system_items_b           msib ON msib.inventory_item_id = mmt.inventory_item_id  and msib.organization_id = mmt.organization_id  
					  LEFT JOIN INV.mtl_material_transactions    mmt_1 ON mmt.transaction_source_id = mmt_1.transaction_source_id  
					  LEFT JOIN INV.mtl_system_items_b           msib_1 ON msib_1.inventory_item_id = mmt_1.inventory_item_id and msib_1.organization_id = mmt_1.organization_id   
				where UPPER(mmt.subinventory_code) like ''%WIP%''  
					  AND mtt.transaction_type_name = ''WIP Completion''
					  AND MMT.TRANSACTION_DATE >= SYSDATE - 35 --TO_DATE(''20210201'',''YYYYMMDD'') --AND MMT.TRANSACTION_DATE < TO_DATE(''20200101'',''YYYYMMDD'')
					  AND substr(msib_1.segment1,1,3) = ''120''  
					  --and mmt.organization_id in ( ''86'', ''87'' ) 
				group by msib.segment1, msib.organization_id, mmt.transaction_date, mmt.transaction_source_id  
            ) 
            select 
                  PTG.TRANS_DATE_TIME                                   AS TRANS_DATE_TIME     
				  , ptg.part_number                                     AS PART_NUMBER 
                  , ptg.part_description                                AS PART_DESCRIPTION 
                  , ptg.production_qty                                  AS PRODUCTION_QTY 
                  , nvl( ql.LIST_LESS_7, 0 )                            AS LIST_LESS_7 
				  , ( ptg.production_qty * nvl(ql.LIST_LESS_7, 0 ) )    AS TOTAL_PRICE 
				  , nvl( ptg.planner_code, ''MISSING'' )                AS PLANNER_CODE 
                  , nvl( ptg.resource_hours, 0 )                        AS RESOURCE_HOURS 
                  , nvl( ( ptg.production_qty * ptg.resource_hours ), 0 ) AS TOTAL_MACHINE_HOURS 
                  , nvl( ( rwgt.TOTAL_RESIN / ptg.production_qty ), 0 ) AS FG_RESIN_WGT 
                  , nvl(rwgt.TOTAL_RESIN , 0 )                          AS FG_TOTAL_RESIN 
                  , nvl( ptg.unit_volume, 0 )                           AS UNIT_VOLUME 
                  , nvl( ( ptg.production_qty * ptg.unit_volume ), 0 )  AS TOTAL_VOLUME 
				  , ptg.org_code                                        AS ORG_CODE 
                  , ptg.org_name                                        AS ORG_NAME   
                  , itcv.item_cost                                      AS STD_COST  
                  , itcv.resource_cost                                  AS RESOURCE_COST  
                  , itcv.overhead_cost                                  AS EARNED_OVERHEAD 
                  , itcv.material_cost                                  AS MATERIAL_COST  
                  , itcv.material_overhead_cost                         AS MATERIAL_OVERHEAD_COST 
                  , itcv.outside_processing_cost                        AS OUTSIDE_PROCESSING_COST  
				  , ptg.mmt_transaction_id                              AS TRANSACTION_ID
				  , ptg.wl_line_code                                    AS LINE_CODE
				  , ptg.wl_line_desc                                    AS LINE_DESCRIPTION  
            from  prod_trx_groups ptg 
                  left outer join resin_wgt				 rwgt ON ptg.mmt_transaction_source_id = rwgt.wgt_transaction_source_id  
                  left outer join pricing				 ql   ON ptg.part_number = ql.product_attr_val_disp  
                  left outer join CST_ITEM_COST_TYPE_V   itcv ON ptg.mmt_org_id = itcv.organization_id AND ptg.mmt_inventory_item_id = itcv.inventory_item_id  and itcv.cost_type = ''Frozen''    
                  left outer join pricing				 ql   ON ptg.part_number = ql.product_attr_val_disp 
				  --and rwgt.ORG_ID in (86,87) 
                  
            --GROUP BY PTG.TRANS_DATE_TIME
            --ORDER BY PTG.TRANS_DATE_TIME
		'
		)

		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Production','Manufacturing') SELECT @columnList
		*/
		UPDATE #Production
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				 CAST(ISNULL(TRANS_DATE_TIME,'') AS VARCHAR(100)) +  CAST(ISNULL(PART_NUMBER,'') AS VARCHAR(50)) +  CAST(ISNULL(PART_DESCRIPTION,'') AS VARCHAR(100)) +  CAST(ISNULL(PRODUCTION_QTY,'0') AS VARCHAR(100)) +  CAST(ISNULL(LIST_LESS_7,'0') AS VARCHAR(100)) +  CAST(ISNULL(TOTAL_PRICE,'0') AS VARCHAR(100)) +  CAST(ISNULL(PLANNER_CODE,'') AS VARCHAR(50)) +  CAST(ISNULL(RESOURCE_HOURS,'0') AS VARCHAR(100)) +  CAST(ISNULL(TOTAL_MACHINE_HOURS,'0') AS VARCHAR(100)) +  CAST(ISNULL(FG_RESIN_WGT,'0') AS VARCHAR(100)) +  CAST(ISNULL(FG_TOTAL_RESIN,'0') AS VARCHAR(100)) +  CAST(ISNULL(UNIT_VOLUME,'0') AS VARCHAR(100)) +  CAST(ISNULL(TOTAL_VOLUME,'0') AS VARCHAR(100)) +  CAST(ISNULL(ORG_CODE,'') AS VARCHAR(3)) +  CAST(ISNULL(ORG_NAME,'') AS VARCHAR(50)) +  CAST(ISNULL(STD_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(RESOURCE_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(EARNED_OVERHEAD,'0') AS VARCHAR(100)) +  CAST(ISNULL(MATERIAL_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(MATERIAL_OVERHEAD_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(OUTSIDE_PROCESSING_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(TRANSACTION_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(LINE_CODE,'') AS VARCHAR(25)) +  CAST(ISNULL(LINE_DESCRIPTION,'') AS VARCHAR(50)) 
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
				,a.[Fingerprint]
			FROM (
				MERGE Oracle.Production b
				USING (SELECT * FROM #Production) a
				ON a.Transaction_ID = b.Transaction_ID AND b.CurrentRecord = 1 --swap with business key of table
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
						,a.[Fingerprint]
						,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		DROP TABLE #Production
	
	END 

	

GO
