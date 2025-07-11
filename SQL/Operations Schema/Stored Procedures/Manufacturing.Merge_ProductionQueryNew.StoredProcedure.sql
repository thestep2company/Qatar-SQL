USE [Operations]
GO
/****** Object:  StoredProcedure [Manufacturing].[Merge_ProductionQueryNew]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Manufacturing].[Merge_ProductionQueryNew] AS BEGIN

SELECT * FROM OPENQUERY(PROD,
'	with prod_trx_groups as    
	(  
		SELECT	ood.organization_code              ORG_CODE  
				,ood.organization_name                    ORG_NAME  
				,MSI.SEGMENT1                             PART_NUMBER  
				,MSI.DESCRIPTION                          PART_DESCRIPTION  
				,SUM( NVL( MMT.TRANSACTION_QUANTITY,0 ) ) PRODUCTION_QTY  
				,msi.PLANNER_CODE                         PLANNER_CODE  
				,msi.unit_volume                          UNIT_VOLUME  
				,mmt.transaction_date                     TRANS_DATE_TIME  
				, mmt.organization_id                     mmt_org_id  
				, mmt.inventory_item_id                   mmt_inventory_item_id  
				, mmt.transaction_source_id               mmt_transaction_source_id  
				, mmt.Transaction_id                      mmt_transaction_id 
				, wl.line_code                            wl_line_code 
				, wl.description                          wl_line_desc             
				, UPPER(mmt.subinventory_code)            SubInventory 
				, msi.item_type                           Item_type 
		from  
				MTL_SYSTEM_ITEMS_B MSI  
				,MTL_MATERIAL_TRANSACTIONS MMT left outer join WIP_FLOW_SCHEDULES WFS ON mmt.transaction_source_id = wfs.wip_entity_id  
				left outer join wip_lines wl ON to_number(mmt.attribute15) = wl.line_id AND mmt.organization_id = wl.organization_id  
				,MTL_TRANSACTION_TYPES        MTT  
				,ORG_ORGANIZATION_DEFINITIONS OOD  
				,HR_OPERATING_UNITS           HOU  
		where msi.inventory_item_id = mmt.inventory_item_id   
				AND msi.organization_id = mmt.organization_id  
				AND MMT.TRANSACTION_DATE >=  sysdate - 3 
				AND mmt.transaction_type_id = mtt.transaction_type_id   
				and (substr(msi.item_type,1,8)= ''STEP2 FG'' or  substr(msi.item_type,1,20) = ''STEP2 SUB PROCESSING'') 
				AND mtt.transaction_type_name = ''WIP Completion''  
				AND msi.organization_id = ood.organization_id  
				AND ood.operating_unit = hou.organization_id  
				AND hou.short_code = ''S2C US''  
				and msi.segment1 BETWEEN NVL(null, MSI.SEGMENT1 ) AND NVL( null, MSI.SEGMENT1 )  
		GROUP BY ood.organization_code  
				,ood.organization_name  
				,msi.segment1  
				,MSI.DESCRIPTION   
				,PLANNER_CODE  
				,msi.unit_volume  
				,mmt.transaction_date  
				, mmt.organization_id  
				, mmt.inventory_item_id  
				, mmt.transaction_source_id  
				, mmt.Transaction_id  
				, wl.line_code 
				, wl.description   
				, UPPER(mmt.subinventory_code) 
				, msi.item_type  
	)  
    , pricing as  
    ( 
		select  
				nvl( qll.operand, 0.00 )              AS LIST_LESS_7  
				, qll.product_attr_val_disp  
		from	qp_secu_list_headers_v qsl  
				,qp_list_lines_v        qll  
		where	qsl.LIST_HEADER_ID = qll.LIST_HEADER_ID  
				and qsl.name = ''NSP LESS 7%''  
    )  
    , hours as  
	(
		select  
				 itcdv.ORGANIZATION_ID        ORGANIZATION_ID  
				 ,itcdv.inventory_item_id     inventory_item_id 
				, sum(itcdv.usage_rate_or_amount)  usage_hours 
				, sum(case when substr(itcdv.resource_code,1,7) = ''Machine'' then itcdv.usage_rate_or_amount else 0 end)  Machine_hours 
		from   CST_ITEM_COST_DETAILS_V itcdv 
		where 1 = 1 
				and itcdv.cost_type_id = 1    
				and itcdv.level_type =  1   
				and itcdv.UNIT_OF_MEASURE = ''HR'' 
				and  itcdv.organization_id  not in ( 88, 144, 145) 
		group by  
				itcdv.ORGANIZATION_ID 
				, itcdv.inventory_item_id  
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
				and msib.item_type = ''STEP2 PIGMENTED RESIN MFG'' 
		group by ptg.Part_Number 
				, mmt.organization_id 
				, PTG.TRANS_DATE_TIME  
				, mmt.transaction_source_id  
    )  
		select  
				ptg.mmt_inventory_item_id, 
				ptg.mmt_org_id, 
				PTG.TRANS_DATE_TIME                                   AS TRANS_DATE_TIME  
				, ptg.org_code                                        AS ORG_CODE  
				, ptg.org_name                                        AS ORG_NAME       
				, ptg.part_number                                     AS PART_NUMBER 
				, ptg.part_description                                AS PART_DESCRIPTION  
				, ptg.production_qty                                  AS PRODUCTION_QTY  
				, nvl( ql.LIST_LESS_7, 0 )                            AS LIST_LESS_7  
				, ( ptg.production_qty * nvl(ql.LIST_LESS_7, 0 ) )    AS TOTAL_PRICE  
				, nvl( ptg.planner_code, ''MISSING'' )                  AS PLANNER_CODE  
				, nvl(hrs.usage_hours,0 )                             AS RESOURCE_HOURS  
				, nvl( ptg.production_qty * nvl(hrs.usage_hours,0 ), 0 ) AS TOTAL_MACHINE_HOURS  
				, nvl( ( rwgt.TOTAL_RESIN / ptg.production_qty ), 0 ) AS FG_RESIN_WGT  
				, nvl(rwgt.TOTAL_RESIN , 0 )                          AS FG_TOTAL_RESIN 
				, nvl( ptg.unit_volume, 0 )                           AS UNIT_VOLUME  
				, nvl( ( ptg.production_qty * ptg.unit_volume ), 0 )  AS TOTAL_VOLUME  
				, itcv.item_cost                                      AS STD_COST   
				, itcv.resource_cost                                  AS RESOURCE_COST   
				, itcv.overhead_cost                                  AS EARNED_OVERHEAD  
				, itcv.material_cost                                  AS MATERIAL_COST   
				, itcv.material_overhead_cost                         AS MATERIAL_OVERHEAD_COST 
				, itcv.outside_processing_cost                        AS OUTSIDE_PROCESSING_COST   
				, ptg.mmt_transaction_id                              AS TRANSACTION_ID 
				, ptg.wl_line_code                                    line_code 
				, ptg.wl_line_desc                                    line_description 
				, UPPER(ptg.subinventory)                             SubInventory 
				, ptg.item_type                                       Item_type 
				, hrs.Machine_hours                                   Costed_Machine_Hrs  
		from prod_trx_groups ptg  
				left outer join resin_wgt rwgt on ptg.mmt_transaction_source_id = rwgt.wgt_transaction_source_id   
				left outer join pricing ql on ptg.part_number = ql.product_attr_val_disp  
				left outer join CST_ITEM_COST_TYPE_V   itcv on ptg.mmt_org_id = itcv.organization_id    
				and ptg.mmt_inventory_item_id = itcv.inventory_item_id  and itcv.cost_type = ''Frozen''     
				left outer join pricing ql on ptg.part_number = ql.product_attr_val_disp  
				left outer join hours   hrs on ptg.mmt_org_id = hrs.organization_id  and ptg.mmt_inventory_item_id = hrs.inventory_item_id       
'
)
ORDER BY TRANS_DATE_TIME DESC
END
GO
