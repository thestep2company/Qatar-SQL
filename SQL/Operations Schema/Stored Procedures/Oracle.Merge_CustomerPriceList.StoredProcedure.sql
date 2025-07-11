USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_CustomerPriceList]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_CustomerPriceList] AS BEGIN

		SELECT a.* 
		INTO #CustomerPriceList
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
				qlhv.list_type_code list_type_code
				--qpfv.name formula,
				--rtt.name payment_term,
				--haouv.name operating_unit
			from
				qp_list_headers_vl qlhv	
				INNER JOIN hz_cust_accounts hca					ON qlhv.list_header_id=hca.price_list_id
				LEFT JOIN qp_list_lines_v qllv					ON qlhv.list_header_id=qllv.list_header_id 	--AND sysdate >= NVL(qllv.start_date_active,qllv.creation_date) AND sysdate <= NVL(qllv.end_date_active,sysdate) 
				LEFT JOIN mtl_system_items_vl msiv				ON msiv.organization_id=85 AND case when qllv.product_attribute_context=''ITEM'' and qllv.product_attribute=''PRICING_ATTRIBUTE1'' then qllv.product_attr_value end=msiv.inventory_item_id
				LEFT JOIN qp_currency_lists_vl qclv				ON qlhv.currency_header_id=qclv.currency_header_id
				LEFT JOIN fnd_currencies_vl fcv					ON qlhv.currency_code=fcv.currency_code
				LEFT JOIN ra_terms_tl rtt						ON qlhv.terms_id=rtt.term_id AND rtt.language=userenv(''lang'')
				LEFT JOIN hz_parties hp							ON hca.party_id=hp.party_id 
				LEFT JOIN hr_all_organization_units_vl haouv	ON qlhv.orig_org_id=haouv.organization_id
				LEFT JOIN qp_price_formulas_vl qpfv				ON qllv.price_by_formula_id=qpfv.price_formula_id 
				LEFT JOIN qp_modifier_summary_v mod				ON mod.list_header_id = qlhv.list_header_id AND sysdate >= mod.start_date_active AND sysdate <= NVL(mod.end_date_active,sysdate)  --AND mod.product_attr_value = qllv.product_attr_val_disp
			WHERE (NVL(qllv.start_date_active,mod.start_date_active) >= sysdate - 180 OR NVL(qllv.end_date_active,mod.end_date_active) >= sysdate - 180)
		'
		) a

		--list line ID based
		;WITH SameStart AS (
			SELECT Item, Account_Number, LIST_LINE_ID, Start_Date
			FROM Oracle.CustomerPriceList 
			--WHERE Item = '863399' AND Account_Number = '1000020'
			GROUP BY Item, Account_Number, LIST_LINE_ID, Start_Date
			HAVING COUNT(*) > 1
		)
		DELETE FROM t
		--SELECT * 
		FROM Oracle.CustomerPriceList t
			INNER JOIN SameStart ss ON t.Item = ss.Item AND t.Account_Number = ss.Account_Number AND t.Start_Date = ss.Start_Date
			INNER JOIN #CustomerPriceList s ON s.ACCOUNT_NUMBER = t.ACCOUNT_NUMBER AND s.LIST_LINE_ID = t.LIST_LINE_ID AND s.START_DATE = t.START_DATE

		--item based with no end date
		;WITH SameStart AS (
			SELECT Item, Account_Number, Start_Date
			FROM Oracle.CustomerPriceList 
			GROUP BY Item, Account_Number, Start_Date
			HAVING COUNT(*) > 1
		)
		DELETE FROM cpl
		--SELECT * 
		FROM Oracle.CustomerPriceList cpl
			INNER JOIN SameStart ss ON cpl.Item = ss.Item AND cpl.Account_Number = ss.Account_Number AND cpl.Start_Date = ss.Start_Date
		--WHERE End_Date IS NULL

		--IF NO MATCH, INSERT
		INSERT INTO Oracle.CustomerPriceList 
		SELECT s.*
		--SELECT s.PRICE_LIST_ID, s.LIST_LINE_ID, s.ACCOUNT_NUMBER, s.ITEM, s.VALUE, s.START_DATE, s.END_DATE, t.VALUE, t.START_DATE, t.END_DATE
		FROM #CustomerPriceList s
			LEFT JOIN Oracle.CustomerPriceList t ON s.ACCOUNT_NUMBER = t.ACCOUNT_NUMBER AND s.PRICE_LIST_ID = t.PRICE_LIST_ID AND s.LIST_LINE_ID = t.LIST_LINE_ID AND s.ITEM = t.ITEM AND s.START_DATE = t.START_DATE AND ISNULL(s.END_DATE,'9999-12-31') = ISNULL(t.END_DATE,'9999-12-31')
		WHERE t.LIST_LINE_ID IS NULL
		ORDER BY ACCOUNT_NUMBER, LIST_LINE_ID

		--IF MATCH but different price, UPDATE 2025-02-10
		UPDATE t 
		SET t.Value = s.VALUE
		FROM #CustomerPriceList s
			INNER JOIN Oracle.CustomerPriceList t ON s.ACCOUNT_NUMBER = t.ACCOUNT_NUMBER AND s.PRICE_LIST_ID = t.PRICE_LIST_ID AND s.LIST_LINE_ID = t.LIST_LINE_ID AND s.ITEM = t.ITEM AND s.START_DATE = t.START_DATE AND ISNULL(s.END_DATE,'9999-12-31') = ISNULL(t.END_DATE,'9999-12-31')
		WHERE s.VALUE <> t.VALUE

		DROP TABLE #CustomerPriceList

END
GO
