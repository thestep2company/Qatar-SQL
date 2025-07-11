USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_BOMTesting]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_BOMTesting] 
AS BEGIN

		TRUNCATE TABLE Oracle.BOMTesting

		INSERT INTO Oracle.BOMTesting
		SELECT * 
		FROM OPENQUERY(PROD,'
		with roto_items (
			ORDER_LEVEL,
			ASSEMBLY_ITEM,
			item_type,
			msib,
			msib2,
			assembly_ID,
			ASSEMBLY_DESCRIPTION,
			ASSEMBLY_ITEM_STATUS,
			PATH,
			NEW_PATH,
			comp_qty,
			FinshedGood,
			FinshedGood_ID,
			roto,
			roto_assm_id,
			level_path,
			org_path,
			org_path2,
			COMPONENT_ITEM,
			component_id,
			COMPONENT_ITEM_DESCRIPTION,
			COMPONENT_ITEM_STATUS,
			ITEM_NUM,
			OPERATION_SEQ_NUM,
			COMPONENT_QUANTITY,
			qty_lbs_used,
			bom_bill_sequence_id,
			bic_bill_sequence_id,
			bom_org_id
		) AS
		(
		SELECT
			LPAD ( '' '', LEVEL * 2 ) || LEVEL AS ORDER_LEVEL
			, msib.segment1 AS ASSEMBLY_ITEM
			, msib.item_type as item_type
			, msib.organization_id as msib
			, msib2.organization_id as msib2
			, bom.assembly_item_id as assembly_ID
			, msib.description AS ASSEMBLY_DESCRIPTION
			, msib.inventory_item_status_code AS ASSEMBLY_ITEM_STATUS
			, SYS_CONNECT_BY_PATH ( msib.segment1, ''/'' )  AS PATH
			, (SYS_CONNECT_BY_PATH ( msib.segment1, ''/'' ) || ''/'' || msib2.segment1)     AS NEW_PATH
			, SYS_CONNECT_BY_PATH (bic.component_quantity, ''*'')  AS comp_qty
			, CONNECT_BY_root msib.segment1 AS FinshedGood
			, CONNECT_BY_root bom.assembly_item_id AS FinshedGood_ID
			, trim(SYS_CONNECT_BY_PATH (case when msib.item_type = ''STEP2 PHANTOM'' then msib.segment1 else null end, '' ''))  AS roto
			, trim(SYS_CONNECT_BY_PATH (case when msib.item_type = ''STEP2 PHANTOM'' then bom.assembly_item_id else null end, '' ''))  AS roto_assm_id
			, ( SYS_CONNECT_BY_PATH ( level, ''/'' ) || ''/'' || level )     AS level_path
			, SYS_CONNECT_BY_PATH (bom.organization_id, ''/'')  AS org_path
			, SYS_CONNECT_BY_PATH (bom.organization_id, ''/'') || ''/'' || bom.organization_id     AS org_path2
			, msib2.segment1 AS COMPONENT_ITEM
			, bic.component_item_id as component_id
			, msib2.description AS COMPONENT_ITEM_DESCRIPTION
			, msib2.inventory_item_status_code AS COMPONENT_ITEM_STATUS
			, bic.item_num AS ITEM_NUM
			, bic.operation_seq_num AS OPERATION_SEQ_NUM
			, bic.component_quantity AS COMPONENT_QUANTITY

			, ( prior  bic.component_quantity / abs ( prior  bic.component_quantity )) *bic.component_quantity as qty_lbs_used
           
			, bom.bill_sequence_id as bom_bill_sequence_id
			, bic.bill_sequence_id as bic_bill_sequence_id
			, bom.organization_id as bom_org_id
		FROM bom.bom_components_b bic
			, bom.bom_structures_b bom
			, inv.mtl_system_items_b msib
			, inv.mtl_system_items_b msib2
			, mtl_parameters         mp
		WHERE 1 = 1
			AND bic.bill_sequence_id = bom.bill_sequence_id
			AND SYSDATE BETWEEN bic.effectivity_date AND Nvl ( bic.disable_date, SYSDATE )
			AND bom.assembly_item_id = msib.inventory_item_id
			AND bom.organization_id = msib.organization_id
			AND bic.component_item_id = msib2.inventory_item_id
			AND bom.organization_id = msib2.organization_id
			AND mp.organization_id = msib.organization_id
			AND bom.alternate_bom_designator IS NULL
			and substr (msib2.segment1,1,2) = ''12''
			and substr (msib.segment1,1,2) = ''13''
			AND (prior bic.component_quantity) <> 0 
		START WITH  msib.segment1 >= ''400000'' AND bom.organization_id = ''86'' AND  SYSDATE BETWEEN bic.effectivity_date AND Nvl ( bic.disable_date, SYSDATE )
		CONNECT BY NOCYCLE PRIOR  bic.component_item_id = bom.assembly_item_id 
			AND bom.organization_id = ''86''
			AND SYSDATE BETWEEN PRIOR bic.effectivity_date AND PRIOR Nvl ( bic.disable_date, SYSDATE)
		ORDER BY PATH
		)
		Select
			rt.FinshedGood,
			rt.FinshedGood_ID,
			msibFG.description,
			rt.roto as ASSEMBLY_ITEM,
			rt.roto_assm_id,
			msibROTO.description as ASSEMBLY_DESCRIPTION ,
			rt.COMPONENT_ITEM,
			rt.component_id,
			rt.COMPONENT_ITEM_DESCRIPTION,
			rt.COMPONENT_ITEM_STATUS,
			sum ( rt.qty_lbs_used ) as COMPONENT_QUANTITY
		from roto_items rt
			, inv.mtl_system_items_b msibFG
			, inv.mtl_system_items_b msibROTO
		where 1 = 1
			and rt.FinshedGood_ID = msibFG.inventory_item_id
			AND rt.bom_org_id = msibFG.organization_id
			and rt.roto_assm_id = msibROTO.inventory_item_id
			AND rt.bom_org_id = msibROTO.organization_id
			and substr ( rt.roto,1,2) = ''13''
		group by
			rt.FinshedGood,
			rt.FinshedGood_ID,
			msibFG.description,
			rt.roto,
			rt.roto_assm_id,
			msibROTO.description,
			rt.COMPONENT_ITEM,
			rt.component_id,
			rt.COMPONENT_ITEM_DESCRIPTION,
			rt.COMPONENT_ITEM_STATUS,
			rt.bom_org_id
		order by
			rt.FinshedGood,
			rt.roto
		')
END
GO
