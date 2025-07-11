USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_PurchasePriceVariance]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_PurchasePriceVariance] AS BEGIN

	--https://www.enginatics.com/reports/po-purchase-price-variance/

		CREATE TABLE #PurchasePriceVariance (
			[Source] [int] NOT NULL,
			[ORG_CODE] [nvarchar](3) NULL,
			[ORG_NAME] [nvarchar](240) NOT NULL,
			[VENDOR_NAME] [nvarchar](240) NULL,
			[PO_NUMBER] [nvarchar](20) NOT NULL,
			[PO_LINE_NUMBER] [float] NOT NULL,
			[SHIPMENT_LINE_NUMBER] [float] NOT NULL,
			[PART_CLASS] [nvarchar](240) NULL,
			[ITEM] [nvarchar](40) NULL,
			[ITEM_DESC] [nvarchar](240) NULL,
			[PLL_ORDER_QTY] [float] NULL,
			[PLL_QTY_REC] [float] NULL,
			[PLL_QTY_BILLED] [float] NULL,
			[PLL_AMT_BILLED] [float] NULL,
			[POL_UNIT_PRICE] [float] NULL,
			[STD_COST] [float] NULL,
			[MOH_UNIT_COST] [float] NULL,
			[COST_VARIANCE] [float] NULL,
			[CUR_STD_COST] [float] NULL,
			[ZERO_COST_IND] [nvarchar](1) NULL,
			[TX_QTY] [float] NULL,
			[TX_EXT_VAR] [float] NULL,
			[TX_DATE] [nvarchar](17) NULL,
			[TX_ID] [float] NOT NULL,
			[INV_ITEM_ID] [float] NOT NULL,
			[ORG_ID] [float] NULL,
			[Fingerprint] [varchar](32) NOT NULL
		)

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

		INSERT INTO #PurchasePriceVariance (
			   [Source]
			  ,[ORG_CODE]
			  ,[ORG_NAME]
			  ,[VENDOR_NAME]
			  ,[PO_NUMBER]
			  ,[PO_LINE_NUMBER]
			  ,[SHIPMENT_LINE_NUMBER]
			  ,[PART_CLASS]
			  ,[ITEM]
			  ,[ITEM_DESC]
			  ,[PLL_ORDER_QTY]
			  ,[PLL_QTY_REC]
			  ,[PLL_QTY_BILLED]
			  ,[PLL_AMT_BILLED]
			  ,[POL_UNIT_PRICE]
			  ,[STD_COST]
			  ,[MOH_UNIT_COST]
			  ,[COST_VARIANCE]
			  ,[CUR_STD_COST]
			  ,[ZERO_COST_IND]
			  ,[TX_QTY]
			  ,[TX_EXT_VAR]
			  ,[TX_DATE]
			  ,[TX_ID]
			  ,[INV_ITEM_ID]
			  ,[ORG_ID]
			  ,[Fingerprint]
		)
		SELECT 1 AS Source, *, 'XXXXXXX'
		FROM OPENQUERY(PROD, 
		'
		SELECT ood.organization_code org_code
			,ood.organization_name org_name
			,pov.vendor_name vendor_name
			,poh.segment1 po_number
			,pol.line_num po_line_number
			,pll.shipment_num shipment_line_number
			,msi.attribute4 part_class
			,msi.segment1 item
			,msi.description item_desc
			,NVL(pll.quantity, 0) pll_order_qty
			,NVL(pll.quantity_received, 0) pll_qty_rec
			,NVL(pll.quantity_billed, 0) pll_qty_billed
			,NVL(pll.amount_billed, 0) pll_amt_billed
			,NVL(pol.unit_price, 0) pol_unit_price
			,NVL(mmt.actual_cost, 0) std_cost
			,DECODE(mta.accounting_line_type, 3, NVL(mcacd.actual_cost, 0), 0) moh_unit_cost 
			,NVL(pol.unit_price, 0) - (NVL(mmt.actual_cost, 0) - DECODE(mta.accounting_line_type, 3, NVL(mcacd.actual_cost, 0), 0)) cost_variance
			,NVL(cic.material_cost, 0) cur_std_cost
			,CASE WHEN NVL(mmt.actual_cost, 0) = 0 THEN ''Y'' ELSE NULL END zero_cost_ind
			,mmt.primary_quantity tx_qty
			,ROUND(mmt.primary_quantity * (NVL(pol.unit_price, 0) - (NVL(mmt.actual_cost, 0) - DECODE(mta.accounting_line_type, 3, NVL(mcacd.actual_cost, 0), 0))), 2) tx_ext_var
			,TO_CHAR(TRUNC(mmt.transaction_date), ''DD-MON-YYYY'') tx_date
			,mmt.transaction_id tx_id
			,mmt.inventory_item_id inv_item_id
			,mmt.organization_id org_id
		FROM po_distributions_ALL pod
			,po_line_locations_ALL pll
			,po_lines_ALL pol
			,po_headers_ALL poh
			,po_releases_ALL por
			,mtl_material_transactions mmt
			,mtl_transaction_accounts mta
			,mtl_cst_actual_cost_details mcacd
			,mtl_parameters mtp
			,rcv_shipment_headers rsh
			,rcv_transactions rct
			,po_vendors pov
			,mtl_system_items msi
			,mtl_categories mca
			,hr_locations_no_join hrl
			,per_all_people_f papf
			,org_organization_definitions ood
			,hr_operating_units hou
			,cst_item_costs cic
			,cst_cost_types cct
		WHERE 1 = 1
			AND ood.operating_unit = hou.organization_id
			--AND hou.organization_id = ''87'' -- org_id from main query, required in case no data returned so report heading values are populated
			AND rct.organization_id = ood.organization_id
			AND msi.organization_id = rct.organization_id
			AND mmt.rcv_transaction_id = rct.transaction_id
			AND mmt.organization_id = rct.organization_id
			AND mmt.transaction_id = mta.transaction_id(+)
			AND mta.accounting_line_type(+) = 3
			AND mcacd.transaction_id(+) = mmt.transaction_id
			AND mcacd.organization_id(+) = mmt.organization_id
			AND mcacd.layer_id(+) = - 1
			AND mcacd.cost_element_id(+) = 2
			AND mcacd.level_type(+) = 1
			AND mcacd.transaction_action_id(+) = mmt.transaction_action_id
			AND mtp.organization_id = rct.organization_id
			AND mtp.PROCESS_ENABLED_FLAG = ''N''
			AND rct.shipment_header_id = rsh.shipment_header_id
			AND rct.po_line_id = pol.po_line_id
			AND rct.po_header_id = poh.po_header_id
			AND rct.po_line_location_id = pll.line_location_id
			AND rct.po_distribution_id = pod.po_distribution_id
			AND pod.line_location_id = pll.line_location_id
			AND pod.destination_type_code = ''INVENTORY''
			AND pll.po_release_id = por.po_release_id(+)
			AND pol.item_id = msi.inventory_item_id(+)
			AND pol.category_id = mca.category_id
			AND rsh.vendor_id = poh.vendor_id
			AND poh.vendor_id = pov.vendor_id
			AND papf.person_id = poh.agent_id
			AND PAPF.EMPLOYEE_NUMBER IS NOT NULL
			AND TRUNC(SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
			--AND DECODE(HR_SECURITY.VIEW_ALL, ''Y'', ''TRUE'', HR_SECURITY.SHOW_RECORD(''PER_ALL_PEOPLE_F'', PAPF.PERSON_ID, PAPF.PERSON_TYPE_ID, PAPF.EMPLOYEE_NUMBER, PAPF.APPLICANT_NUMBER)) = ''TRUE''
			--AND DECODE(HR_GENERAL.GET_XBG_PROFILE, ''Y'', PAPF.BUSINESS_GROUP_ID, HR_GENERAL.GET_BUSINESS_GROUP_ID) = PAPF.BUSINESS_GROUP_ID
			AND pod.deliver_to_location_id = hrl.location_id(+)
			AND cic.inventory_item_id = msi.inventory_item_id
			AND cic.organization_id = msi.organization_id
			AND cct.cost_type_id = cic.cost_type_id
			AND cct.cost_type = ''Frozen''
			AND TRUNC(rct.transaction_date)  > sysdate - 35 --BETWEEN TO_DATE(''2019-01-01'', ''YYYY-MM-DD'') AND TO_DATE(''2022-07-02'', ''YYYY-MM-DD'')
			AND EXISTS (SELECT 1 FROM mtl_transaction_accounts mta1 WHERE mta1.transaction_id = mmt.transaction_id AND mta1.accounting_line_type = 6)
		'
		)
		UNION
		SELECT 2 AS Source, *, 'XXXXXXX' 
		FROM OPENQUERY(PROD, 
		'
		SELECT ood.organization_code org_code
			   , ood.organization_name org_name
			   , pov.vendor_name vendor_name
			   , poh.segment1 po_number
			   , pol.line_num po_line_number
			   , pll.shipment_num shipment_line_number
			   , msi.attribute4 part_class
			   , msi.segment1 item
			   , msi.description item_desc
			   , NVL(pll.quantity, 0) pll_order_qty
			   , NVL(pll.quantity_received, 0) pll_qty_rec
			   , NVL(pll.quantity_billed, 0) pll_qty_billed
			   , NVL(pll.amount_billed, 0) pll_amt_billed
			   , NVL(pol.unit_price, 0) pol_unit_price
			   , NVL(wt.standard_resource_rate * DECODE(msi.outside_operation_uom_type, ''ASSEMBLY'', DECODE(wt.usage_rate_or_amount, 0, 1, wt.usage_rate_or_amount), 1), 0) std_cost
			   , 0 moh_unit_cost
			   , NVL(pol.unit_price, 0) - NVL(wt.standard_resource_rate * DECODE(msi.outside_operation_uom_type, ''ASSEMBLY'', DECODE(wt.usage_rate_or_amount, 0, 1, wt.usage_rate_or_amount), 1), 0) cost_variance
			   , NVL(cic.material_cost, 0) cur_std_cost
			   , CASE WHEN NVL(wt.standard_resource_rate * DECODE(msi.outside_operation_uom_type, ''ASSEMBLY'', DECODE(wt.usage_rate_or_amount, 0, 1, wt.usage_rate_or_amount), 1), 0) = 0 THEN ''Y'' ELSE NULL END zero_cost_ind
			   , DECODE(rct.transaction_type, ''RETURN TO RECEIVING'', rct.primary_quantity * - 1, rct.primary_quantity) tx_qty
			   , ROUND(DECODE(rct.transaction_type, ''RETURN TO RECEIVING'', rct.primary_quantity * - 1, rct.primary_quantity) * (NVL(pol.unit_price, 0) - NVL(wt.standard_resource_rate * DECODE(msi.outside_operation_uom_type, ''ASSEMBLY'', DECODE(wt.usage_rate_or_amount, 0, 1, wt.usage_rate_or_amount), 1), 0)), 2) tx_ext_var
			   , TO_CHAR(TRUNC(rct.transaction_date), ''DD-MON-YYYY'') tx_date
			   , rct.transaction_id tx_id
			   , msi.inventory_item_id inv_item_id
			   , rct.organization_id org_id
		FROM po_distributions_all pod
			, po_line_locations_all pll
			, po_lines_all pol
			, po_headers_all poh
			, po_releases_all por
			, rcv_transactions rct
			, rcv_shipment_headers rsh
			, po_vendors pov
			, mtl_system_items msi
			, mtl_categories mca
			, hr_locations_no_join hrl
			, per_all_people_f papf
			, mtl_parameters mtp
			, wip_transactions wt
			, org_organization_definitions ood
			, hr_operating_units hou
			, cst_item_costs cic
			, cst_cost_types cct
		WHERE 1 = 1
			AND ood.operating_unit = hou.organization_id
			--AND hou.organization_id = ''87'' -- org_id from main query, required in case no data returned so report heading values are populated
			AND rct.organization_id = ood.organization_id
			AND msi.organization_id = rct.organization_id
			AND rct.shipment_header_id = rsh.shipment_header_id
			AND rct.po_line_id = pol.po_line_id
			AND rct.po_header_id = poh.po_header_id
			AND rct.po_line_location_id = pll.line_location_id
			AND pod.line_location_id = pll.line_location_id
			AND pod.po_distribution_id = rct.po_distribution_id
			AND pod.destination_type_code = ''SHOP FLOOR''
			AND pll.po_release_id = por.po_release_id(+)
			AND pol.item_id = msi.inventory_item_id(+)
			AND pol.category_id = mca.category_id
			AND rsh.vendor_id = poh.vendor_id
			AND poh.vendor_id = pov.vendor_id
			AND papf.person_id = poh.agent_id
			AND PAPF.EMPLOYEE_NUMBER IS NOT NULL
			AND TRUNC(SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
			--AND DECODE(HR_SECURITY.VIEW_ALL, ''Y'', ''TRUE'', HR_SECURITY.SHOW_RECORD(''PER_ALL_PEOPLE_F'', PAPF.PERSON_ID, PAPF.PERSON_TYPE_ID, PAPF.EMPLOYEE_NUMBER, PAPF.APPLICANT_NUMBER)) = ''TRUE''
			--AND DECODE(HR_GENERAL.GET_XBG_PROFILE, ''Y'', PAPF.BUSINESS_GROUP_ID, HR_GENERAL.GET_BUSINESS_GROUP_ID) = PAPF.BUSINESS_GROUP_ID
			AND pod.deliver_to_location_id = hrl.location_id(+)
			AND cic.inventory_item_id = msi.inventory_item_id
			AND cic.organization_id = msi.organization_id
			AND cct.cost_type_id = cic.cost_type_id
			AND cct.cost_type = ''Frozen''
			AND rct.transaction_date > sysdate - 35 --BETWEEN TO_DATE(''2019-01-01'', ''YYYY-MM-DD'') AND TO_DATE(''2022-07-02'', ''YYYY-MM-DD'')
			AND rct.transaction_id = wt.rcv_transaction_id
			AND wt.standard_rate_flag = 1
			AND wt.transaction_type = 3
			AND EXISTS (
							SELECT 1
							FROM wip_transaction_accounts wta
							WHERE wta.transaction_id = wt.transaction_id
											AND wta.accounting_line_type = 6
							)
			AND mtp.organization_id = rct.organization_id
			AND mtp.PROCESS_ENABLED_FLAG = ''N''
		')
		UNION ALL
		SELECT 3 AS Source, *, 'XXXXXXX' 
		FROM OPENQUERY(PROD, 
		'
		SELECT ood.organization_code org_code
			, ood.organization_name org_name
			, pov.vendor_name vendor_name
			, poh.segment1 po_number
			, pol.line_num po_line_number
			, pll.shipment_num shipment_line_number
			, msi.attribute4 part_class
			, msi.segment1 item
			, msi.description item_desc
			, NVL(pll.quantity, 0) pll_order_qty
			, NVL(pll.quantity_received, 0) pll_qty_rec
			, NVL(pll.quantity_billed, 0) pll_qty_billed
			, NVL(pll.amount_billed, 0) pll_amt_billed
			, NVL(pol.unit_price, 0) pol_unit_price
			, 0 std_cost
			, 0 moh_unit_cost
			, NVL(pol.unit_price, 0) - 0 cost_variance
			, NVL(cic.material_cost, 0) cur_std_cost
			, ''Y''  zero_cost_ind
			, DECODE(rct.transaction_type, ''RETURN TO RECEIVING'', rct.primary_quantity * - 1, ''RETURN TO  VENDOR'', rct.primary_quantity * - 1, rct.primary_quantity) tx_qty
			, ROUND(DECODE(rct.transaction_type, ''RETURN TO RECEIVING'', rct.primary_quantity * - 1, ''RETURN TO  VENDOR'', rct.primary_quantity * - 1, rct.primary_quantity) * (NVL(pol.unit_price, 0) - 0), 2) tx_ext_var
			, TO_CHAR(TRUNC(rct.transaction_date), ''DD-MON-YYYY'') tx_date
			, rct.transaction_id tx_id
			, msi.inventory_item_id inv_item_id
			, rct.organization_id org_id
		FROM po_distributions_all pod
			, po_line_locations_all pll
			, po_lines_all pol
			, po_headers_all poh
			, po_releases_all por
			, rcv_shipment_headers rsh
			, rcv_transactions rct
			, po_vendors pov
			, mtl_system_items msi
			, mtl_categories mca
			, hr_locations_no_join hrl
			, per_all_people_f papf
			, mtl_parameters mpa
			, org_organization_definitions ood
			, hr_operating_units hou
			, cst_item_costs cic
			, cst_cost_types cct
		WHERE 1 = 1
			AND ood.operating_unit = hou.organization_id
			--AND hou.organization_id = :hou_org_id -- org_id from main query, required in case no data returned so report heading values are populated
			AND rct.organization_id = ood.organization_id
			AND msi.organization_id = rct.organization_id
			AND rct.shipment_header_id = rsh.shipment_header_id
			AND rct.po_line_id = pol.po_line_id
			AND rct.po_header_id = poh.po_header_id
			AND rct.po_line_location_id = pll.line_location_id
			AND rct.po_distribution_id = pod.po_distribution_id
			AND pod.line_location_id = pll.line_location_id
			AND NVL(pll.lcm_flag, ''N'') = ''N''
			AND pod.destination_type_code IN (''INVENTORY'', ''SHOP FLOOR'')
			AND rct.destination_type_code <> ''RECEIVING''
			AND pll.po_release_id = por.po_release_id(+)
			AND pol.item_id = msi.inventory_item_id(+)
			AND pol.category_id = mca.category_id
			AND rsh.vendor_id = poh.vendor_id
			AND poh.vendor_id = pov.vendor_id
			AND papf.person_id = poh.agent_id
			AND PAPF.EMPLOYEE_NUMBER IS NOT NULL
			AND TRUNC(SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
			--AND DECODE(HR_SECURITY.VIEW_ALL, ''Y'', ''TRUE'', HR_SECURITY.SHOW_RECORD(''PER_ALL_PEOPLE_F'', PAPF.PERSON_ID, PAPF.PERSON_TYPE_ID, PAPF.EMPLOYEE_NUMBER, PAPF.APPLICANT_NUMBER)) = ''TRUE''
			--AND DECODE(HR_GENERAL.GET_XBG_PROFILE, ''Y'', PAPF.BUSINESS_GROUP_ID, HR_GENERAL.GET_BUSINESS_GROUP_ID) = PAPF.BUSINESS_GROUP_ID
			AND pod.deliver_to_location_id = hrl.location_id(+)
			AND cic.inventory_item_id = msi.inventory_item_id
			AND cic.organization_id = msi.organization_id
			AND cct.cost_type_id = cic.cost_type_id
			AND cct.cost_type = ''Frozen''
			AND rct.transaction_date > sysdate - 35 --BETWEEN TO_DATE(''2019-01-01'', ''YYYY-MM-DD'') AND TO_DATE(''2022-07-02'', ''YYYY-MM-DD'')
			AND rct.organization_id = mpa.organization_id
			AND mpa.process_enabled_flag = ''Y''
		'
		)
		UNION ALL
		SELECT 4 AS Source, *, 'XXXXXXX' 
		FROM OPENQUERY(PROD, 
		'
		SELECT ood.organization_code org_code
			,ood.organization_name org_name
			,pov.vendor_name vendor_name
			,poh.segment1 po_number
			,pol.line_num po_line_number
			,pll.shipment_num shipment_line_number
			,msi.attribute4 part_class
			,msi.segment1 item
			,msi.description item_desc
			,NVL(pll.quantity, 0) pll_order_qty
			,NVL(pll.quantity_received, 0) pll_qty_rec
			,NVL(pll.quantity_billed, 0) pll_qty_billed
			,NVL(pll.amount_billed, 0) pll_amt_billed
			,NVL(pol.unit_price, 0) pol_unit_price
			,NVL(rct.prior_unit_price, 0) std_cost
			,0 moh_unit_cost
			,NVL(pol.unit_price, 0) - NVL(rct.prior_unit_price, 0) cost_variance
			,NVL(cic.material_cost, 0) cur_std_cost
			,CASE WHEN NVL(rct.prior_unit_price, 0) = 0 THEN ''Y'' ELSE NULL END zero_cost_ind
			,rct.primary_quantity tx_qty
			,ROUND(rct.primary_quantity * (NVL(pol.unit_price, 0) - NVL(rct.prior_unit_price, 0)), 2) tx_ext_var
			,TO_CHAR(TRUNC(rct.transaction_date), ''DD-MON-YYYY'') tx_date
			,rct.accounting_event_id tx_id
			,msi.inventory_item_id inv_item_id
			,rct.organization_id org_id
		FROM po_line_locations_all pll
			,po_lines_all pol
			,po_headers_all poh
			,po_releases_all por
			,rcv_accounting_events rct
			,mtl_parameters mtp
			,rcv_shipment_headers rsh
			,rcv_transactions rt
			,po_vendors pov
			,mtl_system_items msi
			,mtl_categories mca
			,per_all_people_f papf
			,org_organization_definitions ood
			,hr_operating_units hou
			,cst_item_costs cic
			,cst_cost_types cct
		WHERE 1 = 1
			AND ood.operating_unit = hou.organization_id
			--AND hou.organization_id = :hou_org_id -- org_id from main query, required in case no data returned so report heading values are populated
			AND rct.organization_id = ood.organization_id
			AND msi.organization_id = rct.organization_id
			AND rct.rcv_transaction_id = rt.transaction_id
			AND rct.organization_id = rt.organization_id
			AND rct.event_type_id IN (16)
			AND mtp.organization_id = rct.organization_id
			AND mtp.PROCESS_ENABLED_FLAG = ''N''
			AND rt.shipment_header_id = rsh.shipment_header_id
			AND rct.po_line_id = pol.po_line_id
			AND rct.po_header_id = poh.po_header_id
			AND rct.po_line_location_id = pll.line_location_id
			AND pll.po_release_id = por.po_release_id(+)
			AND pol.item_id = msi.inventory_item_id(+)
			AND pol.category_id = mca.category_id
			AND rsh.vendor_id = poh.vendor_id
			AND poh.vendor_id = pov.vendor_id
			AND papf.person_id = poh.agent_id
			AND PAPF.EMPLOYEE_NUMBER IS NOT NULL
			AND TRUNC(SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
			--AND DECODE(HR_SECURITY.VIEW_ALL, ''Y'', ''TRUE'', HR_SECURITY.SHOW_RECORD(''PER_ALL_PEOPLE_F'', PAPF.PERSON_ID, PAPF.PERSON_TYPE_ID, PAPF.EMPLOYEE_NUMBER, PAPF.APPLICANT_NUMBER)) = ''TRUE''
			--AND DECODE(HR_GENERAL.GET_XBG_PROFILE, ''Y'', PAPF.BUSINESS_GROUP_ID, HR_GENERAL.GET_BUSINESS_GROUP_ID) = PAPF.BUSINESS_GROUP_ID
			AND cic.inventory_item_id = msi.inventory_item_id
			AND cic.organization_id = msi.organization_id
			AND cct.cost_type_id = cic.cost_type_id
			AND cct.cost_type = ''Frozen''
			AND rct.transaction_date > sysdate - 35 -- BETWEEN TO_DATE(''2019-01-01'', ''YYYY-MM-DD'') AND TO_DATE(''2022-07-02'', ''YYYY-MM-DD'')
		'
		)
		UNION ALL
		SELECT 5 AS Source, *, 'XXXXXXX' 
		FROM OPENQUERY(PROD, 
		'
		SELECT DISTINCT ood.organization_code org_code
			, ood.organization_name org_name
			, pov.vendor_name vendor_name
			, poh.segment1 po_number
			, pol.line_num po_line_number
			, pll.shipment_num shipment_line_number
			, msi.attribute4 part_class
			, msi.segment1 item
			, msi.description item_desc
			, NVL(pll.quantity, 0) pll_order_qty
			, NVL(pll.quantity_received, 0) pll_qty_rec
			, NVL(pll.quantity_billed, 0) pll_qty_billed
			, NVL(pll.amount_billed, 0) pll_amt_billed
			, NVL(pol.unit_price, 0) pol_unit_price
			, 0 std_cost
			, 0 moh_unit_cost
			, NVL(pol.unit_price, 0) - 0 cost_variance
			, NVL(cic.material_cost, 0) cur_std_cost
			, ''Y'' zero_cost_ind
			, glat.primary_quantity tx_qty
			, ROUND(glat.primary_quantity * (NVL(pol.unit_price, 0) - 0), 2) tx_ext_var
			, TO_CHAR(TRUNC(rct.transaction_date), ''DD-MON-YYYY'') tx_date
			, rct.transaction_id tx_id
			, msi.inventory_item_id inv_item_id
			, rct.organization_id org_id
		FROM po_distributions_all pod
			,po_line_locations_all pll
			,po_lines_all pol
			,po_headers_all poh
			,po_releases_all por
			,gmf_lc_adj_transactions glat
			,mtl_parameters mp
			,rcv_shipment_headers rsh
			,rcv_transactions rct
			,po_vendors pov
			,mtl_system_items msi
			,mtl_categories mca
			,per_all_people_f papf
			,org_organization_definitions ood
			,hr_operating_units hou
			,cst_item_costs cic
			,cst_cost_types cct
		WHERE 1 = 1
			AND ood.operating_unit = hou.organization_id
			--AND hou.organization_id = :hou_org_id -- org_id from main query, required in case no data returned so report heading values are populated
			AND rct.organization_id = ood.organization_id
			AND msi.organization_id = rct.organization_id
			AND glat.rcv_transaction_id = rct.transaction_id
			AND glat.event_type IN (16, 17)
			AND mp.organization_id = glat.organization_id
			AND mp.PROCESS_ENABLED_FLAG = ''Y''
			AND rct.shipment_header_id = rsh.shipment_header_id
			AND rct.po_line_id = pol.po_line_id
			AND rct.po_header_id = poh.po_header_id
			AND rct.po_line_location_id = pll.line_location_id
			AND nvl(pll.lcm_flag, ''N'') = ''Y''
			AND rct.po_distribution_id = pod.po_distribution_id
			AND pll.po_release_id = por.po_release_id(+)
			AND pod.destination_type_code IN (''INVENTORY'')
			AND rct.destination_type_code <> ''RECEIVING''
			AND pol.item_id = msi.inventory_item_id(+)
			AND pol.category_id = mca.category_id
			AND rsh.vendor_id = poh.vendor_id
			AND poh.vendor_id = pov.vendor_id
			AND papf.person_id = poh.agent_id
			AND PAPF.EMPLOYEE_NUMBER IS NOT NULL
			AND TRUNC(SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
			--AND DECODE(HR_SECURITY.VIEW_ALL, ''Y'', ''TRUE'', HR_SECURITY.SHOW_RECORD(''PER_ALL_PEOPLE_F'', PAPF.PERSON_ID, PAPF.PERSON_TYPE_ID, PAPF.EMPLOYEE_NUMBER, PAPF.APPLICANT_NUMBER)) = ''TRUE''
			--AND DECODE(HR_GENERAL.GET_XBG_PROFILE, ''Y'', PAPF.BUSINESS_GROUP_ID, HR_GENERAL.GET_BUSINESS_GROUP_ID) = PAPF.BUSINESS_GROUP_ID
			AND cic.inventory_item_id = msi.inventory_item_id
			AND cic.organization_id = msi.organization_id
			AND cct.cost_type_id = cic.cost_type_id
			AND cct.cost_type = ''Frozen''
			AND rct.transaction_date > sysdate - 35 --BETWEEN TO_DATE(''2019-01-01'', ''YYYY-MM-DD'') AND TO_DATE(''2022-07-02'', ''YYYY-MM-DD'') -- end_date parameter
		'
		)

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('PurchasePriceVariance','Oracle') SELECT @columnList
		*/
		UPDATE #PurchasePriceVariance
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here					    
						CAST(ISNULL([Source],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORG_CODE],'') AS VARCHAR(3)) +  CAST(ISNULL([ORG_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([VENDOR_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([PO_NUMBER],'') AS VARCHAR(20)) +  CAST(ISNULL([PO_LINE_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([SHIPMENT_LINE_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([PART_CLASS],'') AS VARCHAR(240)) +  CAST(ISNULL([ITEM],'') AS VARCHAR(40)) +  CAST(ISNULL([ITEM_DESC],'') AS VARCHAR(240)) +  CAST(ISNULL([PLL_ORDER_QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([PLL_QTY_REC],'0') AS VARCHAR(100)) +  CAST(ISNULL([PLL_QTY_BILLED],'0') AS VARCHAR(100)) +  CAST(ISNULL([PLL_AMT_BILLED],'0') AS VARCHAR(100)) +  CAST(ISNULL([POL_UNIT_PRICE],'0') AS VARCHAR(100)) +  CAST(ISNULL([STD_COST],'0') AS VARCHAR(100)) +  CAST(ISNULL([MOH_UNIT_COST],'0') AS VARCHAR(100)) +  CAST(ISNULL([COST_VARIANCE],'0') AS VARCHAR(100)) +  CAST(ISNULL([CUR_STD_COST],'0') AS VARCHAR(100)) +  CAST(ISNULL([ZERO_COST_IND],'') AS VARCHAR(1)) +  CAST(ISNULL([TX_QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([TX_EXT_VAR],'0') AS VARCHAR(100)) +  CAST(ISNULL([TX_DATE],'') AS VARCHAR(17)) +  CAST(ISNULL([TX_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([INV_ITEM_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORG_ID],'0') AS VARCHAR(100)) 
			),1)),3,32);


		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO Oracle.[PurchasePriceVariance] (
			   [Source]
			  ,[ORG_CODE]
			  ,[ORG_NAME]
			  ,[VENDOR_NAME]
			  ,[PO_NUMBER]
			  ,[PO_LINE_NUMBER]
			  ,[SHIPMENT_LINE_NUMBER]
			  ,[PART_CLASS]
			  ,[ITEM]
			  ,[ITEM_DESC]
			  ,[PLL_ORDER_QTY]
			  ,[PLL_QTY_REC]
			  ,[PLL_QTY_BILLED]
			  ,[PLL_AMT_BILLED]
			  ,[POL_UNIT_PRICE]
			  ,[STD_COST]
			  ,[MOH_UNIT_COST]
			  ,[COST_VARIANCE]
			  ,[CUR_STD_COST]
			  ,[ZERO_COST_IND]
			  ,[TX_QTY]
			  ,[TX_EXT_VAR]
			  ,[TX_DATE]
			  ,[TX_ID]
			  ,[INV_ITEM_ID]
			  ,[ORG_ID]
			  ,[Fingerprint]
		)
			SELECT 
				a.[Source]
			  ,a.[ORG_CODE]
			  ,a.[ORG_NAME]
			  ,a.[VENDOR_NAME]
			  ,a.[PO_NUMBER]
			  ,a.[PO_LINE_NUMBER]
			  ,a.[SHIPMENT_LINE_NUMBER]
			  ,a.[PART_CLASS]
			  ,a.[ITEM]
			  ,a.[ITEM_DESC]
			  ,a.[PLL_ORDER_QTY]
			  ,a.[PLL_QTY_REC]
			  ,a.[PLL_QTY_BILLED]
			  ,a.[PLL_AMT_BILLED]
			  ,a.[POL_UNIT_PRICE]
			  ,a.[STD_COST]
			  ,a.[MOH_UNIT_COST]
			  ,a.[COST_VARIANCE]
			  ,a.[CUR_STD_COST]
			  ,a.[ZERO_COST_IND]
			  ,a.[TX_QTY]
			  ,a.[TX_EXT_VAR]
			  ,a.[TX_DATE]
			  ,a.[TX_ID]
			  ,a.[INV_ITEM_ID]
			  ,a.[ORG_ID]
			  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.[PurchasePriceVariance] b
				USING (SELECT * FROM #PurchasePriceVariance) a
				ON a.[TX_ID] = b.[TX_ID]  
					AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					[Source]
				  ,[ORG_CODE]
				  ,[ORG_NAME]
				  ,[VENDOR_NAME]
				  ,[PO_NUMBER]
				  ,[PO_LINE_NUMBER]
				  ,[SHIPMENT_LINE_NUMBER]
				  ,[PART_CLASS]
				  ,[ITEM]
				  ,[ITEM_DESC]
				  ,[PLL_ORDER_QTY]
				  ,[PLL_QTY_REC]
				  ,[PLL_QTY_BILLED]
				  ,[PLL_AMT_BILLED]
				  ,[POL_UNIT_PRICE]
				  ,[STD_COST]
				  ,[MOH_UNIT_COST]
				  ,[COST_VARIANCE]
				  ,[CUR_STD_COST]
				  ,[ZERO_COST_IND]
				  ,[TX_QTY]
				  ,[TX_EXT_VAR]
				  ,[TX_DATE]
				  ,[TX_ID]
				  ,[INV_ITEM_ID]
				  ,[ORG_ID]
				  ,[Fingerprint]
				)
				VALUES (
					a.[Source]
				  ,a.[ORG_CODE]
				  ,a.[ORG_NAME]
				  ,a.[VENDOR_NAME]
				  ,a.[PO_NUMBER]
				  ,a.[PO_LINE_NUMBER]
				  ,a.[SHIPMENT_LINE_NUMBER]
				  ,a.[PART_CLASS]
				  ,a.[ITEM]
				  ,a.[ITEM_DESC]
				  ,a.[PLL_ORDER_QTY]
				  ,a.[PLL_QTY_REC]
				  ,a.[PLL_QTY_BILLED]
				  ,a.[PLL_AMT_BILLED]
				  ,a.[POL_UNIT_PRICE]
				  ,a.[STD_COST]
				  ,a.[MOH_UNIT_COST]
				  ,a.[COST_VARIANCE]
				  ,a.[CUR_STD_COST]
				  ,a.[ZERO_COST_IND]
				  ,a.[TX_QTY]
				  ,a.[TX_EXT_VAR]
				  ,a.[TX_DATE]
				  ,a.[TX_ID]
				  ,a.[INV_ITEM_ID]
				  ,a.[ORG_ID]
				  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						a.[Source]
					  ,a.[ORG_CODE]
					  ,a.[ORG_NAME]
					  ,a.[VENDOR_NAME]
					  ,a.[PO_NUMBER]
					  ,a.[PO_LINE_NUMBER]
					  ,a.[SHIPMENT_LINE_NUMBER]
					  ,a.[PART_CLASS]
					  ,a.[ITEM]
					  ,a.[ITEM_DESC]
					  ,a.[PLL_ORDER_QTY]
					  ,a.[PLL_QTY_REC]
					  ,a.[PLL_QTY_BILLED]
					  ,a.[PLL_AMT_BILLED]
					  ,a.[POL_UNIT_PRICE]
					  ,a.[STD_COST]
					  ,a.[MOH_UNIT_COST]
					  ,a.[COST_VARIANCE]
					  ,a.[CUR_STD_COST]
					  ,a.[ZERO_COST_IND]
					  ,a.[TX_QTY]
					  ,a.[TX_EXT_VAR]
					  ,a.[TX_DATE]
					  ,a.[TX_ID]
					  ,a.[INV_ITEM_ID]
					  ,a.[ORG_ID]
					  ,a.[Fingerprint]
					   ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;
	
		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #PurchasePriceVariance


END
GO
