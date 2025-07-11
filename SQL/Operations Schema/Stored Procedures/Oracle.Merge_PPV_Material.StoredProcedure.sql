USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_PPV_Material]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_PPV_Material] 
AS BEGIN
 
	SELECT * FROM OPENQUERY(PROD,'
	select
		ood.organization_code                        AS ORG_CODE   
		, msib.segment1 SKU
		, msib.description
		, mmt.transaction_id
		, mta.transaction_date
		, mtt.transaction_type_name
		, sum(mta.primary_quantity)
		, sum(mta.base_transaction_value)
		, ca.segment1 || ''.'' || ca.segment2 || ''.'' || ca.segment3 || ''.'' || ca.segment4 || ''.'' || ca.segment5 as GL_ACCOUNT
	from 
		  INV.mtl_system_items_b msib
		, INV.mtl_material_transactions mmt
		, INV.mtl_transaction_accounts mta
		, GL.gl_code_combinations ca
		, INV.mtl_transaction_types mtt
		,ORG_ORGANIZATION_DEFINITIONS   ood
	where 1=1
		and msib.inventory_item_id = mmt.inventory_item_id
		and msib.organization_id = mmt.organization_id
		and mmt.transaction_id = mta.transaction_id (+)
		and mta.reference_account = ca.code_combination_id (+)
		AND mmt.transaction_type_id = mtt.transaction_type_id  (+)
		AND mmt.organization_id = ood.organization_id
		and ca.segment4 = ''1610''--:in_acct_no  --''4826''  --''4112''
		and mmt.transaction_date >= TO_DATE(TO_CHAR(TO_DATE(''2022/01/01'', ''YYYY/MM/DD''), ''YYYY/MM/DD'') || '' 00:00:00'', ''YYYY/MM/DD HH24:MI:SS'')
		---TO_DATE(:p_start_date, ''YYYY/MM/DD HH24:MI:SS'') -- start_date parameterAND TO_DATE(TO_CHAR(TO_DATE(:p_end_date, ''YYYY/MM/DD''), ''YYYY/MM/DD'') || '' 23:59:59'', ''YYYY/MM/DD HH24:MI:SS'') )-- end_date parameter
	group by
		 ood.organization_code
		, msib.segment1
		, msib.description
		, mmt.transaction_id
		, mta.transaction_date
		, mtt.transaction_type_name
		, ca.segment1 || ''.'' || ca.segment2 || ''.'' || ca.segment3 || ''.'' || ca.segment4 || ''.'' || ca.segment5
	order by
		ca.segment1 || ''.'' || ca.segment2 || ''.'' || ca.segment3 || ''.'' || ca.segment4 || ''.'' || ca.segment5 
		,mta.transaction_date
	')
END

/*
	select
	  mmt.organization_id
	, msib.segment1 SKU
	, msib.description
	, mmt.transaction_id
	, mta.transaction_id
	from  INV.mtl_material_transactions mmt
	,  INV.mtl_system_items_b msib 
	, INV.mtl_transaction_accounts mta
	where 1=1
	and msib.inventory_item_id = mmt.inventory_item_id
	and msib.organization_id = mmt.organization_id --- = 87  -- Streetsboro manufacturing 111
	and mmt.transaction_id = mta.transaction_id (+)
	and  mmt.transaction_id = 604838409
	;

	select * from CST_INV_DISTRIBUTION_V 
	where 
	transaction_id = 602946975  -- 604838409 -- 
*/
GO
