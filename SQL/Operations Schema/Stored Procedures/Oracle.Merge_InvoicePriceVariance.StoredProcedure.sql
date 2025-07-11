USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_InvoicePriceVariance]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_InvoicePriceVariance] 
AS BEGIN

	DECLARE @startDate DATE = DATEADD(DAY,-7,GETDATE())
	DELETE FROM Oracle.InvoicePriceVariance WHERE invoice_date >= @startDate

		
	--GL->SLA->AP->PO for *R12*
	INSERT INTO Oracle.InvoicePriceVariance
	SELECT *,'XXXXXXXXX',GETDATE(), NULL, 1
	FROM OPENQUERY(PROD,
	'
	select
		 gl.name ledger
		,(select gp.period_name from gl_periods gp where gl.period_set_name=gp.period_set_name and gl.accounted_period_type=gp.period_type and gp.adjustment_period_flag=''N'' and aipvv.accounting_date between gp.start_date and gp.end_date) period_name
		,pla.operating_unit
		,mp.organization_code
		,plla.PO_HEADER_ID 
		,plla.PO_LINE_ID
		,plla.LINE_LOCATION_ID
		,aipvv.invoice_num
		,aipvv.invoice_date
		,aipvv.accounting_date
		--,decode(decode(aipvv.quantity_invoiced,0,0,null,0,nvl(aipvv.quantity_invoiced,1)/abs(nvl(aipvv.quantity_invoiced,1))),0,:cp_adjustment,1,:cp_entry,-1,:cp_reversal) entry_type
		,mck.concatenated_segments category
		,msiv.concatenated_segments item
		,msiv.description item_description
		,gcck1.concatenated_segments variance_account
		,gcck.concatenated_segments charge_account
		--,round((aipvv.quantity_invoiced /(decode(plla.match_option,''R'', po_uom_s.po_uom_convert_p(pla.unit_meas_lookup_code,rt.unit_of_measure,pla.item_id),1))),20) quantity_invoiced
		,nvl(aipvv.invoice_rate,1) invoice_rate
		,aipvv.invoice_amount
		,aipvv.invoice_price
		,aipvv.quantity_invoiced
		,nvl(pda.rate,nvl(pha.rate,1)) po_rate
		,plla.price_override po_price
		,plla.amount_billed
		,rt.unit_of_measure receipt_unit
		,pov.vendor_name vendor
		,case when pha.type_lookup_code in (''BLANKET'',''PLANNED'') then pha.segment1||'' - ''||pra.release_num else pha.segment1 end po_number_release
		,pha.currency_code currency
		,aipvv.invoice_currency
		,pla.line_num
		,pla.unit_meas_lookup_code unit
		,lot.location_code location
		,aipvv.line_amount
		--,round(decode(nvl(aipvv.quantity_invoiced,0),0,decode(aipvv.price_var,null,decode(aipvv.invoice_rate,null,aipvv.invoice_amount,aipvv.invoice_base_amount),aipvv.price_var*nvl(aipvv.invoice_rate,1)),aipvv.invoice_price*nvl(aipvv.invoice_rate,1))*decode(plla.match_option,''R'',po_uom_s.po_uom_convert_p(pla.unit_meas_lookup_code,rt.unit_of_measure,pla.item_id),1),nvl(fc.extended_precision,fc.precision)) invoice_base_price,round(plla.price_override*decode(plla.match_option,''R'',decode(rt.transaction_id,null,nvl(pha.rate,1),nvl(rt.currency_conversion_rate,1)),nvl(pha.rate,1)),nvl(fc.extended_precision,fc.precision)) po_base_price
		--,decode(aipvv.invoice_rate,null, aipvv.price_var,aipvv.base_price_var) base_inv_price_var
		,aipvv.exch_rate_var ex_rate_vari
		,aipvv.base_price_var base_price_vari
		,aipvv.price_var price_vari
		--,aid.base_invoice_price_variance
		,pla.item_id
	from
		ap_invoice_price_var_v				aipvv
		LEFT JOIN po_distributions_all		pda		ON aipvv.po_distribution_id=pda.po_distribution_id
		LEFT JOIN gl_code_combinations_kfv	gcck1	ON pda.variance_account_id=gcck1.code_combination_id
		LEFT JOIN gl_code_combinations_kfv	gcck	ON pda.code_combination_id=gcck.code_combination_id
		LEFT JOIN po_line_locations_all		plla	ON pda.line_location_id=plla.line_location_id
		LEFT JOIN (
			select
				pla.*,
				(select fspa.inventory_organization_id from financials_system_params_all fspa where hou.set_of_books_id=fspa.set_of_books_id and pla.org_id=fspa.org_id) inventory_organization_id,
				hou.name operating_unit,
				hou.set_of_books_id
			from
				po_lines_all					pla
				LEFT JOIN hr_operating_units	hou ON pla.org_id=hou.organization_id				
		)								pla			ON plla.po_line_id=pla.po_line_id
		LEFT JOIN gl_ledgers			gl			ON pla.set_of_books_id=gl.ledger_id
		LEFT JOIN fnd_currencies		fc			ON gl.currency_code=fc.currency_code
		LEFT JOIN mtl_parameters		mp			ON pla.inventory_organization_id=mp.organization_id
		LEFT JOIN mtl_system_items_vl	msiv		ON pla.item_id=msiv.inventory_item_id AND pla.inventory_organization_id=msiv.organization_id
		LEFT JOIN mtl_categories_kfv	mck			ON pla.category_id=mck.category_id
		LEFT JOIN po_headers_all		pha			ON pla.po_header_id=pha.po_header_id
		LEFT JOIN ap_suppliers			pov			ON pha.vendor_id=pov.vendor_id
		LEFT JOIN po_releases_all		pra			ON plla.po_release_id=pra.po_release_id
		LEFT JOIN hr_locations_all_tl	lot			ON plla.ship_to_location_id=lot.location_id
		LEFT JOIN rcv_transactions		rt			ON aipvv.rcv_transaction_id=rt.transaction_id
	where
		1=1 and
		aipvv.accounting_date>=sysdate-365*5 and
		--pda.org_id in (select mgoat.organization_id from mo_glob_org_access_tmp mgoat union select fnd_global.org_id from dual where fnd_release.major_version=11) and
		pda.destination_type_code in(''INVENTORY'',''SHOP FLOOR'') and
		plla.shipment_type in(''STANDARD'',''BLANKET'',''SCHEDULED'') and
		pha.type_lookup_code in(''STANDARD'',''BLANKET'',''PLANNED'') and
		plla.ship_to_location_id is not null and
		aipvv.invoice_date >= trunc(sysdate-7)
		--and aipvv.invoice_num = ''913462792''
		--lot.language=userenv(''lang'')
	'
	)

END
GO
