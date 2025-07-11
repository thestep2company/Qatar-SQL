USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_XLA_SUMMARY]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM Oracle.XLA_Summary WHERE PERIOD_NAME = 'Jan-23' AND SEGMENT4 IN ('4112') ORDER BY SEGMENT4

CREATE PROCEDURE [Oracle].[Merge_XLA_SUMMARY] AS BEGIN

			DELETE FROM Oracle.XLA_Summary WHERE Period_Name = 'Jan-23'

			INSERT INTO Oracle.XLA_Summary
			SELECT * 
			FROM OPENQUERY(PROD,
			'
			select /*+ parallel*/
				xah.period_name,
				gl.name ledger,
				fav.application_short_name,
				fav.application_name,
				glcc.Segment1,
				  glcc.Segment2,
				  glcc.Segment3,
				  glcc.Segment4,
				count(*) count,
				xte.entity_code,
				xdl.source_distribution_type,
				coalesce(
				decode(xdl.source_distribution_type,
				''AP_INV_DIST'',''ap_invoice_distributions_all'',
				''AP_PMT_DIST'',''ap_payment_hist_dists'',
				''AP_PREPAY'',''ap_prepay_app_dists'',
				''XLA_MANUAL'',''ap_self_assessed_tax_dist_all'',
				--FA
				''TRX'',''fa_adjustments'',
				''DEPRN'',''fa_deprn_detail'',
				''IAC'',''fa_deprn_detail'',
				--PA
				''R'',''pa_cost_distribution_lines_all'',
				''C'',''pa_cost_distribution_lines_all'',
				''D'',''pa_cost_distribution_lines_all'',
				''BL'',''pa_cc_dist_lines_all'',
				''Revenue - Normal Revenue'',''pa_cust_rev_dist_lines_all'',
				''Revenue - Event Revenue'',''pa_cust_event_rdl_all'',
				''Revenue - UBR'',''pa_draft_revenues_all'',
				''Revenue - UER'',''pa_draft_revenues_all''
				),
				--GMF
				decode(xdl.application_id,555,''gmf_xla_extract_lines''),
				--other
				case when xdl.source_distribution_type in
				(
				''PO_REQ_DISTRIBUTIONS_ALL'',
				''AR_DISTRIBUTIONS_ALL'',
				''RCV_RECEIVING_SUB_LEDGER'',
				''RA_CUST_TRX_LINE_GL_DIST_ALL'',
				''OKL_TRNS_ACC_DSTRS'',
				''MTL_TRANSACTION_ACCOUNTS'',
				''WIP_TRANSACTION_ACCOUNTS'',
				''PO_DISTRIBUTIONS_ALL''
				) then lower(xdl.source_distribution_type) end
				--(select lower(ds.table_name) from dba_synonyms ds where ds.owner=''APPS'' and xdl.source_distribution_type=ds.synonym_name)
				) source_table,
				coalesce(
				decode(xdl.source_distribution_type,
				--AP
				''AP_INV_DIST'',''invoice_distribution_id'',
				''AP_PMT_DIST'',''payment_hist_dist_id'',
				''AP_PREPAY'',''prepay_app_dist_id'',
				''XLA_MANUAL'',''invoice_distribution_id'',
				--FA
				''TRX'',''transaction_header_id,adjustment_line_id'',
				''DEPRN'',''book_type_code, asset_id, period_counter, deprn_run_id, distribution_id'',
				''IAC'',''book_type_code, asset_id, period_counter, deprn_run_id, distribution_id'',
				--PA
				''R'',''expenditure_item_id, line_num'',
				''C'',''expenditure_item_id, line_num'',
				''D'',''expenditure_item_id, line_num'',
				''BL'',''expenditure_item_id, line_num'',
				''Revenue - Normal Revenue'',''expenditure_item_id, line_num'',
				''Revenue - Event Revenue'',''event_id, line_num'',
				''Revenue - UBR'',''project_id, draft_revenue_num'',
				''Revenue - UER'',''project_id, draft_revenue_num''
				),
				--GMF
				decode(xdl.application_id,555,''line_id''),
				--other
				decode(xdl.source_distribution_type,
				''PO_REQ_DISTRIBUTIONS_ALL'',''distribution_id'',
				''AR_DISTRIBUTIONS_ALL'',''line_id'',
				''RCV_RECEIVING_SUB_LEDGER'',''rcv_sub_ledger_id'',
				''RA_CUST_TRX_LINE_GL_DIST_ALL'',''cust_trx_line_gl_dist_id'',
				''OKL_TRNS_ACC_DSTRS'',''id'',
				''MTL_TRANSACTION_ACCOUNTS'',''inv_sub_ledger_id'',
				''WIP_TRANSACTION_ACCOUNTS'',''wip_sub_ledger_id'',
				''PO_DISTRIBUTIONS_ALL'',''po_distribution_id''
				)
				) source_columns,
				xal.accounting_class_code,
				xdl.event_class_code,
				xdl.event_type_code,
				xdl.accounting_line_code,
				xdl.accounting_line_type_code,
				nvl2(xdl.tax_line_ref_id,''not null'',null) tax_line_ref_id,
				nvl2(xdl.tax_rec_nrec_dist_ref_id,''not null'',null) tax_rec_nrec_dist_ref_id,
				nvl2(xdl.tax_summary_line_ref_id,''not null'',null) tax_summary_line_ref_id,
				xdl.applied_to_entity_code,
				nvl2(xdl.applied_to_entity_id,''not null'',null) applied_to_entity_id,
				xdl.applied_to_distribution_type,
				nvl2(xdl.applied_to_dist_id_char_1,''not null'',null) applied_to_dist_id_char_1,
				nvl2(xdl.applied_to_dist_id_num_1,''not null'',null) applied_to_dist_id_num_1,
				nvl2(xdl.applied_to_source_id_char_1,''not null'',null) applied_to_source_id_char_1,
				nvl2(xdl.applied_to_source_id_num_1,''not null'',null) applied_to_source_id_num_1,
				nvl2(xdl.source_distribution_id_char_1,''not null'',null) source_distribution_id_char_1,
				nvl2(xdl.source_distribution_id_char_2,''not null'',null) source_distribution_id_char_2,
				nvl2(xdl.source_distribution_id_char_3,''not null'',null) source_distribution_id_char_3,
				nvl2(xdl.source_distribution_id_char_4,''not null'',null) source_distribution_id_char_4,
				nvl2(xdl.source_distribution_id_char_5,''not null'',null) source_distribution_id_char_5,
				nvl2(xdl.source_distribution_id_num_1,''not null'',null) source_distribution_id_num_1,
				nvl2(xdl.source_distribution_id_num_2,''not null'',null) source_distribution_id_num_2,
				nvl2(xdl.source_distribution_id_num_3,''not null'',null) source_distribution_id_num_3,
				nvl2(xdl.source_distribution_id_num_4,''not null'',null) source_distribution_id_num_4,
				nvl2(xdl.source_distribution_id_num_5,''not null'',null) source_distribution_id_num_5,
				xdl.merge_duplicate_code,
				xdl.line_definition_owner_code,
				xdl.line_definition_code,
				sum(xdl.unrounded_entered_cr) unrounded_entered_cr,
				sum(xdl.unrounded_accounted_cr) unrounded_accounted_cr,
				nvl2(xdl.upg_batch_id,''not null'',null) upg_batch_id,
				xdl.application_id
			from
				gl_ledgers gl,
				xla_ae_lines xal,
				xla_ae_headers xah,
				xla.xla_transaction_entities xte,
				xla_distribution_links xdl,
				fnd_application_vl fav,
				GL_CODE_COMBINATIONS glcc 
			where
				1=1 and
				PERIOD_NAME = ''Jan-23'' and
				xal.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID and
				gl.ledger_id=xal.ledger_id and
				xal.ae_header_id=xah.ae_header_id(+) and
				xal.application_id=xah.application_id(+) and
				xah.gl_transfer_status_code(+)=''Y'' and
				xah.accounting_entry_status_code(+)=''F'' and
				xah.entity_id=xte.entity_id(+) and
				xah.application_id=xte.application_id(+) and
				xal.ae_header_id=xdl.ae_header_id and
				xal.ae_line_num=xdl.ae_line_num and
				xal.application_id=xdl.application_id and
				xal.application_id=fav.application_id(+)
			group by
				xah.period_name,
				gl.name,
				fav.application_short_name,
				glcc.Segment1,
				  glcc.Segment2,
				  glcc.Segment3,
				  glcc.Segment4,
				fav.application_name,
				xte.entity_code,
				xdl.source_distribution_type,
				xal.accounting_class_code,
				xdl.event_class_code,
				xdl.event_type_code,
				xdl.accounting_line_code,
				xdl.accounting_line_type_code,
				nvl2(xdl.tax_line_ref_id,''not null'',null),
				nvl2(xdl.tax_rec_nrec_dist_ref_id,''not null'',null),
				nvl2(xdl.tax_summary_line_ref_id,''not null'',null),
				xdl.applied_to_entity_code,
				nvl2(xdl.applied_to_entity_id,''not null'',null),
				xdl.applied_to_distribution_type,
				nvl2(xdl.applied_to_dist_id_char_1,''not null'',null),
				nvl2(xdl.applied_to_dist_id_num_1,''not null'',null),
				nvl2(xdl.applied_to_source_id_char_1,''not null'',null),
				nvl2(xdl.applied_to_source_id_num_1,''not null'',null),
				nvl2(xdl.source_distribution_id_char_1,''not null'',null),
				nvl2(xdl.source_distribution_id_char_2,''not null'',null),
				nvl2(xdl.source_distribution_id_char_3,''not null'',null),
				nvl2(xdl.source_distribution_id_char_4,''not null'',null),
				nvl2(xdl.source_distribution_id_char_5,''not null'',null),
				nvl2(xdl.source_distribution_id_num_1,''not null'',null),
				nvl2(xdl.source_distribution_id_num_2,''not null'',null),
				nvl2(xdl.source_distribution_id_num_3,''not null'',null),
				nvl2(xdl.source_distribution_id_num_4,''not null'',null),
				nvl2(xdl.source_distribution_id_num_5,''not null'',null),
				xdl.merge_duplicate_code,
				xdl.line_definition_owner_code,
				xdl.line_definition_code,
				nvl2(xdl.upg_batch_id,''not null'',null),
				xdl.application_id
			order by
				fav.application_short_name,
				fav.application_name,
				count(*) desc
			')


END
GO
