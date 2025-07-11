USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_CancelledOrdersReasonDetail]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_CancelledOrdersReasonDetail] AS BEGIN

BEGIN TRY
	BEGIN TRAN

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()
		
		DELETE FROM Oracle.CancelledOrdersReasonDetail WHERE canDate >= DATEADD(DAY,-7,GETDATE()) 

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

		INSERT INTO Oracle.CancelledOrdersReasonDetail
		SELECT * 
		FROM OPENQUERY(PROD,
		'
		SELECT DISTINCT
			--decode(upper(:p_order_by),''SALESREP'', sr.name,''CANCEL_REASON'',lu.meaning,  NULL)  dummy_salesrep_reason,
			--decode(upper(:p_order_by),''ORDER_DATE'', h.ordered_date,''CANCEL_DATE'', to_date(lh.hist_creation_date,''DD-MON-YYYY''), NULL)  dummy_order_cancel_date,
			--decode(upper(:p_order_by),''ORDER_NUMBER'', h.order_number, NULL) dummy_order_number,
			--decode(upper(:p_order_by),''CANCEL_BY'', fnd_user.user_name, NULL) dummy_cancelled_by,
			--lh.line_id hist_line_id,
			--lh.last_update_date,
			org.customer_number cust_no,
			org.name cust,
			h.order_number  ordnum,
			lh.line_id lineid,
			h.ordered_date ord_date,
			nvl(lh.cancelled_quantity,0)*nvl(lh.unit_selling_price,0) amount,
			si.Segment1 AS Part,
			SI.description AS Name,
			lh.inventory_item_id  Inventory_Item_ID,
			--DECODE(l.ITEM_TYPE_CODE,''SERVICE'',L.LINE_NUMBER ||''.''|| L.SHIPMENT_NUMBER||''.''|| L.OPTION_NUMBER ||''.''||L.COMPONENT_NUMBER || decode(L.SERVICE_NUMBER,null,null,''.''||L.SERVICE_NUMBER),
			--''INCLUDED'',L.LINE_NUMBER ||''.''|| L.SHIPMENT_NUMBER||''.''|| L.OPTION_NUMBER ||''.''||L.COMPONENT_NUMBER ||decode(L.SERVICE_NUMBER,null,null,''.''||L.SERVICE_NUMBER),
			--L.LINE_NUMBER || ''.'' || L.SHIPMENT_NUMBER || decode(L.OPTION_NUMBER,null,null,''.''||L.OPTION_NUMBER)) linenum,
			--lh.shipment_number shipnum,
			--lh.option_number optionnum,
			lh.ordered_quantity ordered_qty,
			lh.cancelled_quantity  cancelled_qty,
			--lh.cancelled_quantity2 cancelled_qty2,
			lh.order_quantity_uom unit1,
			--lh.ordered_quantity_uom2 unit2,
			lu.meaning  cancel_reason ,
			--h.salesrep_id hsalesrep_id,
			--lh.salesrep_id lsalesrep_id,
			--sr2.name lsalesrep,
			--sr.name salesrep,
  			lh.hist_creation_date candate,	
			fnd_user.user_name username,
			lh.item_identifier_type,
			lh.ordered_item_id,
			lh.ordered_item,
			--&rp_item_flex_all_seg item_flex,
			h.conversion_rate conversion_rate,
			h.conversion_type_code  conversion_type_code,
			h.transactional_curr_code currency_code,
			lh.line_category_code cat_code
			--NULL
			--ONT_OEXOEOCR_XMLP_PKG.c_currency_codeformula(h.transactional_curr_code) C_CURRENCY_CODE,
			--ONT_OEXOEOCR_XMLP_PKG.c_gl_conv_rateformula(h.transactional_curr_code, h.ordered_date, h.conversion_type_code, h.conversion_rate) C_GL_CONV_RATE,
			--ONT_OEXOEOCR_XMLP_PKG.c_amountformula(:Calc_amount, :C_GL_CONV_RATE, :C_precision) C_AMOUNT,
			--ONT_OEXOEOCR_XMLP_PKG.c_amountformula(ONT_OEXOEOCR_XMLP_PKG.calc_amountformula(lh.line_id, lh.cancelled_quantity), ONT_OEXOEOCR_XMLP_PKG.c_gl_conv_rateformula(h.transactional_curr_code, h.ordered_date, h.conversion_type_code, h.conversion_rate), ONT_OEXOEOCR_XMLP_PKG.c_precisionformula(h.transactional_curr_code)) C_AMOUNT,
			--ONT_OEXOEOCR_XMLP_PKG.cf_unit1formula(lh.order_quantity_uom) CF_unit1,
			--ONT_OEXOEOCR_XMLP_PKG.cf_unit2formula(lh.ordered_quantity_uom2) CF_unit2,
			--&item_dsp item_dsp,
			--ONT_OEXOEOCR_XMLP_PKG.c_cancelled_qtyformula(lh.line_id, lh.cancelled_quantity) C_cancelled_qty
			--ONT_OEXOEOCR_XMLP_PKG.calc_amountformula(lh.line_id, lh.cancelled_quantity) Calc_amount,
			--ONT_OEXOEOCR_XMLP_PKG.item_dspFormula(lh.item_identifier_type,lh.inventory_item_id,SI.ORGANIZATION_ID,SI.INVENTORY_ITEM_ID,lh.ordered_item_id,lh.ordered_item)  item_dsp,
			--ONT_OEXOEOCR_XMLP_PKG.c_precisionformula(h.transactional_curr_code) C_precision
			--sr.SALES_REP_NUMBER, sr.Name, COUNT(*) --DISTINCT h.ORDER_NUMBER, lh.SALESREP_ID, lh.REASON_ID, lh.hist_type_Code, r.REASON_TYPE, r.REASON_CODE, r.COMMENTS, r.LINE_ID
		FROM
			oe_order_lines_history lh,
			oe_order_lines_all l,
			oe_order_headers_all h,
			oe_reasons r,
			mtl_system_items_vl SI,
			ra_salesreps sr,
			ra_salesreps sr2,
			oe_lookups lu,
			oe_sold_to_orgs_v org,
			fnd_user 
		WHERE lh.header_id = h.header_id
			and l.header_id = h.header_id
			and l.line_id = lh.line_id
			AND lh.hist_type_code=''CANCELLATION''
			AND h.salesrep_id=sr.salesrep_id(+)
			AND lh.salesrep_id=sr2.salesrep_id(+)
			AND r.reason_id=lh.reason_id
			AND r.reason_code = lu.lookup_code
			AND lu.lookup_type = ''CANCEL_CODE''
			--AND nvl(SI.organization_id,0) = ''999'' --nvl(oe_sys_parameters.value(''999'',mo_global.get_current_org_id()),0)
			AND lh.inventory_item_id=SI.inventory_item_id
			AND org.organization_id=lh.sold_to_org_id
			AND lh.hist_created_by=fnd_user.user_id
			--AND nvl(h.org_id,0)= ''85'' --nvl(:p_organization_id,0)
			--AND ROWNUM <= 10000
			AND lh.hist_creation_date >= sysdate-7 -- >= TO_DATE(''20190101'',''YYYYMMDD'')
		'
		)

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	COMMIT TRAN
END TRY

BEGIN CATCH
	ROLLBACK TRAN
	THROW
END CATCH

END
GO
