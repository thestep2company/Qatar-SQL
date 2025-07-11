USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_PPV_WIP]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_PPV_WIP] AS BEGIN

SELECT * FROM OPENQUERY(PROD,'
select
	''WIP Trans'' "From"
	, ca.segment4 "4_digit_acct"
	, ood.organization_code  ORG
	, msib.segment1  SKU
	, msib.description Description
	, wt.transaction_id
	, wt.organization_id
	, wt.primary_item_id
	, '''' Sub_Inv
	, '''' Locator
	, wt.transaction_date Transaction_date
	, ''WIP'' Transaction_Type
	, wt.primary_quantity Priamary_QTY
	, wta.base_transaction_value Base_trans_value 
	, wta.rate_or_amount Amount
	, wt.usage_rate_or_amount
	, wt.primary_quantity
	, ca.segment1 || ''.'' || ca.segment2 || ''.'' || ca.segment3 || ''.'' || ca.segment4 || ''.'' || ca.segment5 as GL_ACCOUNT
	, br.resource_code
	, wt.group_id
	, wt.WIP_ENTITY_ID
	, wt.REQUEST_ID
	, wt.COMPLETION_TRANSACTION_ID
	, wt.ACCT_PERIOD_ID
	, wta.OVERHEAD_BASIS_FACTOR
from 
	  WIP.wip_transactions wt
	, WIP.wip_transaction_accounts wta
	, GL.gl_code_combinations ca
	, INV.mtl_system_items_b msib
	, org_organization_definitions ood
	, BOM_RESOURCES br
where 1=1
	and wt.transaction_id = wta.transaction_id (+)
	and wta.reference_account = ca.code_combination_id
	and wt.RESOURCE_ID = br.resource_id (+)
	and ca.segment4 = ''1610''
	and wt.primary_item_id = msib.inventory_item_id (+)
	and wt.organization_id = msib.organization_id   (+)
	and wt.organization_id = ood.organization_id
	and wt.transaction_date >= TO_DATE(''2022-01-01'', ''YYYY/MM/DD HH24:MI:SS'') 
	--AND TO_DATE(TO_CHAR(TO_DATE(:p_end_date, ''YYYY/MM/DD HH24:MI:SS''), ''YYYY/MM/DD'') || '' 23:59:59'', ''YYYY/MM/DD HH24:MI:SS'') )-- end_date parameter
'
)

END
GO
