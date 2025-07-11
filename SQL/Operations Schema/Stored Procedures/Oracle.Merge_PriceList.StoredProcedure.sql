USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_PriceList]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_PriceList] AS BEGIN

	DROP TABLE IF EXISTS Oracle.PriceList 

    ;
	WITH CTE AS (
			  SELECT '1000769' AS ACCT_NUM, 'S2C DSF HOME DEPOT.COM' AS ACCT_NAME
		UNION SELECT '1000020', 'S2C DSF WAYFAIR'
		UNION SELECT '1000993', 'S2C DSF KOHLS.COM'
		UNION SELECT '1001000', 'S2C DSF TARGET.COM'
		UNION SELECT '1000925', 'Aldi '
		UNION SELECT '1008531', 'Smyths'
		UNION SELECT '1000189', 'S2C DSF AMAZON.COM'
		--UNION SELECT '1000283', 'S2C DSF WALMART CANADA'
		UNION SELECT '1000283', 'S2C DSF WAL-MART.COM (Ship to Home)'
		--UNION SELECT '1000283', 'S2C PPD WALMART CANADA'
	)
	, Data AS (
		SELECT ISNULL(ACCOUNT_NUMBER,ACCT_NUM) AS ACCOUNT_NUMBER
			,ISNULL(CUSTOMER_NAME,CustomerName) AS CUSTOMER_NAME
			,PRICE_LIST
			,PRICE_LIST_ID
			,LIST_LINE_ID
			,LIST_LINE_TYPE
			,DESCRIPTION
			,ISNULL(PRODUCT_ATTRIBUTE,LEFT(DESCRIPTION,7)) AS PRODUCT_ATTRIBUTE
			,CURRENCY
			,MULTI_CURRENCY_NAME
			,ROUNDING_FACTOR
			,START_DATE 
			,END_DATE
			,PRODUCT_CONTEXT
			,a.UOM
			,ITEM
			,ISNULL(ITEM_DESCRIPTION,pm.ProductName) AS ITEM_DESCRIPTION
			,VALUE
			,PRECEDENCE
			,PRICING_TRANSACTION_ENTITY
			,SOURCE_SYSTEM_CODE
			,LIST_TYPE_CODE
			,FORMULA
			,PAYMENT_TERM
			,OPERATING_UNIT
		FROM OPENQUERY(PROD,'
			select distinct
				hca.account_number,
				hp.party_name customer_name,
				qlhv.name price_list,
				qlhv.list_header_id price_list_id, 
				NVL(qllv.list_line_id,mod.list_line_id) list_line_id,
				mod.list_line_type,
				qlhv.description,
				NVL(qllv.product_attribute,mod.Product_attr) AS Product_attribute,
				qlhv.currency_code currency,
				fcv.name currency_name,
				qclv.name multi_currency_name,
				qlhv.rounding_factor,
				NVL(qllv.start_date_active,mod.start_date_active) start_date,
				NVL(qllv.end_date_active,mod.end_date_active) end_date,
				qllv.product_attribute_context product_context,
				qllv.product_uom_code uom,
				NVL(qllv.product_attr_val_disp,mod.product_attr_value) item,
				msiv.description item_description,
				NVL(qllv.operand,mod.operand) value,
				NVL(qllv.product_precedence,mod.product_precedence) precedence,
				qlhv.pte_code pricing_transaction_entity,
				qlhv.source_system_code,
				qlhv.list_type_code list_type_code,
				qpfv.name formula,
				rtt.name payment_term,
				haouv.name operating_unit
			from
				qp_list_headers_vl qlhv	
				LEFT JOIN hz_cust_accounts hca					ON qlhv.list_header_id=hca.price_list_id
				LEFT JOIN qp_list_lines_v qllv					ON qlhv.list_header_id=qllv.list_header_id 	AND sysdate >= NVL(qllv.start_date_active,qllv.creation_date) AND sysdate <= NVL(qllv.end_date_active,sysdate) 
				LEFT JOIN mtl_system_items_vl msiv				ON msiv.organization_id=85 AND case when qllv.product_attribute_context=''ITEM'' and qllv.product_attribute=''PRICING_ATTRIBUTE1'' then qllv.product_attr_value end=msiv.inventory_item_id
				LEFT JOIN qp_currency_lists_vl qclv				ON qlhv.currency_header_id=qclv.currency_header_id
				LEFT JOIN fnd_currencies_vl fcv					ON qlhv.currency_code=fcv.currency_code
				LEFT JOIN ra_terms_tl rtt						ON qlhv.terms_id=rtt.term_id AND rtt.language=userenv(''lang'')
				LEFT JOIN hz_parties hp							ON hca.party_id=hp.party_id 
				LEFT JOIN hr_all_organization_units_vl haouv	ON qlhv.orig_org_id=haouv.organization_id
				LEFT JOIN qp_price_formulas_vl qpfv				ON qllv.price_by_formula_id=qpfv.price_formula_id 
				LEFT JOIN qp_modifier_summary_v mod				ON mod.list_header_id = qlhv.list_header_id AND sysdate >= mod.start_date_active AND sysdate <= NVL(mod.end_date_active,sysdate)  --AND mod.product_attr_value = qllv.product_attr_val_disp
			WHERE --
				(hca.account_number IN (''1000189'',''1000769'',''1000020'',''1000993'',''1001000'',''1000925'',''1000812'',''1008531'', ''1000283'')
				OR qlhv.name IN (''S2C DSF AMAZON.COM'',''S2C DSF HOME DEPOT.COM'',	''S2C DSF WAYFAIR'',''S2C DSF KOHLS.COM'',''S2C DSF TARGET.COM'', ''S2C DSF WAL-MART.COM (Ship to Home)'', ''S2C DSF WALMART CANADA'', ''S2C PPD WALMART CANADA'')) --
				--AND (qlhv.list_header_id =416050  OR qllv.list_line_id = 416050)
			'
		) a
			LEFT JOIN CTE ON DESCRIPTION = ACCT_NAME
			LEFT JOIN dbo.DimCustomerMaster cm ON cte.ACCT_NUM = cm.CustomerKey
			LEFT JOIN dbo.DimProductMaster pm ON a.[Item] = pm.ProductKey
	)
	SELECT ACCOUNT_NUMBER AS CUSTOMER_NUMBER, CUSTOMER_NAME, ITEM AS SKU, ITEM_DESCRIPTION AS SKU_NAME, SUM(VALUE) AS Price 
	INTO Oracle.PriceList
	FROM Data GROUP BY  ACCOUNT_NUMBER, CUSTOMER_NAME, ITEM, ITEM_DESCRIPTION

END
GO
