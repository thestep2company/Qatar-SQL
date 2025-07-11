USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_FGLookup]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_FGLookup] AS BEGIN

		DELETE FROM Oracle.Production20220328 WHERE Trans_DATE_TIME > '2022-03-29'
		
		INSERT INTO Oracle.Production20220328
		SELECT 
				[TRANS_DATE_TIME]
				,[PART_NUMBER]
				,LEFT([PART_DESCRIPTION],100) AS [PART_DESCRIPTION]
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
					where MMT.TRANSACTION_DATE >= TO_DATE(''20220329'',''YYYYMMDD'') 
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
						mmt.organization_id                  as ORG_ID 
						, ptg.Part_Number                    as PART_NUMBER  
						, abs(SUM( mmt.primary_quantity ))   as TOTAL_RESIN  
						, PTG.TRANS_DATE_TIME                as wgt_transaction_date 
						, mmt.transaction_source_id          as wgt_transaction_source_id   
				from	prod_trx_groups               ptg 	
						, INV.mtl_material_transactions    mmt 
						, INV.mtl_system_items_b           msib  
				where	1 = 1 	
						and  ptg.mmt_transaction_source_id = mmt.transaction_source_id  
						and mmt.inventory_item_id = msib.inventory_item_id  
						and mmt.organization_id = msib.organization_id   
						--and msib.item_type = ''STEP2 PIGMENTED RESIN MFG'' 
						and substr(msib.segment1,1,3) = ''120''
						and msib.inventory_item_flag = ''Y''
				group by ptg.Part_Number 		
						, mmt.organization_id 
						, PTG.TRANS_DATE_TIME  
						, mmt.transaction_source_id  

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
		'
		)

END
GO
