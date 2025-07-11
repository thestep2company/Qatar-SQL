USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[XLA_AR]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[XLA_AR] AS BEGIN

	SELECT * FROM OPENQUERY(PROD,'	
		SELECT DISTINCT
			--gir.JE_BATCH_ID
			--,gir.JE_HEADER_ID
			--,gir.JE_LINE_NUM
			--,xal.DESCRIPTION AS AE_LINE_DESCRIPTION
			--,xal.ACCOUNTING_CLASS_CODE
			--,xal.ACCOUNTED_DR
			--,xal.ACCOUNTED_CR
			--,xal.UNROUNDED_ACCOUNTED_DR
			--,xal.UNROUNDED_ACCOUNTED_CR
			--,xal.ACCOUNTING_DATE
			--,xah.JE_CATEGORY_NAME
			--,xah.PRODUCT_RULE_CODE
			--,xah.DESCRIPTION AS AE_HEADER_DESCRIPTION
			--,xte.ENTITY_CODE
			--,xte.TRANSACTION_NUMBER
			--,xdl.SOURCE_DISTRIBUTION_TYPE
			--,xdl.ACCOUNTING_LINE_CODE
			--,xdl.LINE_DEFINITION_CODE
			--,xdl.EVENT_TYPE_CODE
			--,xdl.APPLIED_TO_ENTITY_CODE
			--,xdl.APPLIED_TO_DISTRIBUTION_TYPE
			--,glcc.Segment1
			--,glcc.Segment2
			--,glcc.Segment3
			--,glcc.Segment4
			--,gjl.DESCRIPTION AS JE_LINE_DESCRIPTION
			--,gjh.NAME AS JE_HEADER_NAME
			--,gjh.DESCRIPTION AS JE_HEADER_DESCRIPTION
			--,xdl.AE_HEADER_ID
			--,xdl.AE_LINE_NUM
			arra.*
		FROM GL_IMPORT_REFERENCES gir 
			LEFT JOIN XLA_AE_LINES xal					ON xal.gl_sl_link_id = gir.gl_sl_link_id AND xal.gl_sl_link_table = gir.gl_sl_link_table	
			LEFT JOIN XLA_AE_HEADERS xah				ON xah.ae_header_id = xal.ae_header_id AND xah.application_id = xal.application_id
			LEFT JOIN xla.XLA_TRANSACTION_ENTITIES xte	ON xal.application_id = xte.application_id AND xah.entity_id = xte.entity_id
			LEFT JOIN XLA_DISTRIBUTION_LINKS xdl		ON xte.application_id = xdl.application_id AND xah.ae_header_id = xdl.ae_header_id AND xah.event_id = xdl.event_id AND xal.ae_line_num = xdl.ae_line_num 
			LEFT JOIN GL_CODE_COMBINATIONS glcc			ON xal.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID
			LEFT JOIN gl_je_lines gjl					ON gir.je_header_id = gjl.je_header_id AND gir.je_line_num = gjl.je_line_num
			LEFT JOIN gl_je_headers gjh					ON gjh.je_header_id = gjl.je_header_id
			LEFT JOIN AR_DISTRIBUTIONS_ALL ard			ON xdl.source_distribution_id_num_1 = ard.line_id 
			LEFT JOIN AR_RECEIVABLE_APPLICATIONS_ALL arra ON ard.source_id = arra.receivable_application_id
		WHERE 
			gjl.PERIOD_NAME = ''Jul-22'' 
			AND gjh.ledger_id = ''2022''
			AND xdl.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
			AND (xal.UNROUNDED_ACCOUNTED_CR <> 0 OR xal.UNROUNDED_ACCOUNTED_DR <> 0)
			AND gir.JE_HEADER_ID = ''9050123''
			AND glcc.Segment4 = ''7720''
	'
	)

	/*	
	XLA_DISTRIBUTION_LINKS table join based on Source Distribution Types
	xdl.source_distribution_type = 'AP_PMT_DIST '
	and xdl.source_distribution_id_num_1 = AP_PAYMENT_HIST_DISTS.payment_hist_dist_id
		---------------
		xdl.source_distribution_type = 'AP_INV_DIST'
		and xdl.source_distribution_id_num_1 = AP_INVOICE_DISTRIBUTIONS_ALL.invoice_distribution_id
		---------------
		xdl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
		and xdl.source_distribution_id_num_1 = AR_DISTRIBUTIONS_ALL.line_id
		and AR_DISTRIBUTIONS_ALL.source_id = AR_RECEIVABLE_APPLICATIONS_ALL.receivable_application_id
		---------------
		xdl.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
		and xdl.source_distribution_id_num_1 = RA_CUST_TRX_LINE_GL_DIST_ALL.cust_trx_line_gl_dist_id
		---------------
		xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
		and xdl.source_distribution_id_num_1 = MTL_TRANSACTION_ACCOUNTS.inv_sub_ledger_id
	---------------
	xdl.source_distribution_type = 'WIP_TRANSACTION_ACCOUNTS'
	and xdl.source_distribution_id_num_1 = WIP_TRANSACTION_ACCOUNTS.wip_sub_ledger_id
		---------------
		xdl.source_distribution_type = 'RCV_RECEIVING_SUB_LEDGER'
		and xdl.source_distribution_id_num_1 = RCV_RECEIVING_SUB_LEDGER.rcv_sub_ledger_id
	*/


END
GO
