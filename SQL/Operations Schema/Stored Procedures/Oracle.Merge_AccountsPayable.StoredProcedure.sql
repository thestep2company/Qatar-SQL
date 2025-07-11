USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_AccountsPayable]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_AccountsPayable] 
AS BEGIN

	DELETE FROM Oracle.AccountsPayable 
	WHERE [Accounting Date] >= CAST(DATEADD(DAY,-7,GETDATE()) AS DATE)

	INSERT INTO Oracle.AccountsPayable
	SELECT * 
	FROM OPENQUERY(PROD,'
	select 
		   haou.name AS "Organization",
		   to_char(gl.period_year)||''-''||substr(''0''||to_char(gl.period_num),-2,2) AS period,
		   gl.period_num AS GL_Month,
		   gl.period_year AS GL_Year,
		   aida.accounting_date AS "Accounting Date",
		   aida.amount AS "Distr Amount",
		   aida.description AS "Description",
		   to_char(glcc.segment1)||''.''||to_char(glcc.segment2)||''.''||to_char(glcc.segment3)||''.''||
		   to_char(glcc.segment4)||''.''||to_char(glcc.segment5)||''.''||to_char(glcc.segment6)||''.''||
		   to_char(glcc.segment7) AS "AP Account",
		   to_char(glcc.segment1) AS "Company",
		   to_char(glcc.segment2) AS "Location",
		   to_char(glcc.segment3) AS "Dept",  
		   to_char(glcc.segment4) AS "Account",
		   to_char(glcc.segment5) AS "Addback",
		   aps.segment1 AS "Supplier Num",  
		   aps.vendor_name AS "Vendor",
		   apsa.City,
		   apsa.State,
		   apsa.Zip,
		   apsa.Province,
		   apsa.Country,
		   apia.invoice_num AS "Vendor Invoice",
		   apia.invoice_date AS "Invoice Date",
		   aptt.name AS "Terms",
		   apia.doc_sequence_value AS "Voucher Num",
		   apia.doc_category_code AS "Category Code",
		   apia.description AS "APIA Description",
		   apba.batch_name AS "Batch Name",
		   NVL(PH.CLM_DOCUMENT_NUMBER, PH.SEGMENT1) AS "PO_NUMBER",
		   ffvv.description AS "GL_Account_Name"       
	from
		ap.AP_INVOICE_LINES_ALL aila
		LEFT JOIN ap.ap_invoice_distributions_all aida ON aila.invoice_id = aida.invoice_id and aila.line_number = aida.invoice_line_number
		LEFT JOIN gl.gl_code_combinations glcc ON glcc.code_combination_id = aida.dist_code_combination_id
		LEFT JOIN ap.ap_invoices_all apia ON apia.invoice_id = aida.invoice_id
		LEFT JOIN ap.ap_terms_tl aptt ON aptt.term_id = apia.terms_id
		LEFT JOIN ap.ap_suppliers aps ON aps.vendor_id = apia.vendor_id
		LEFT JOIN ap.AP_SUPPLIER_SITES_ALL apsa ON apsa.VENDOR_ID = apia.VENDOR_ID AND apia.VENDOR_SITE_ID = apsa.VENDOR_SITE_ID
		LEFT JOIN ap.ap_batches_all apba ON apba.batch_id = apia.batch_id
		LEFT JOIN hr.hr_all_organization_units haou ON haou.organization_id = aida.org_id
		LEFT JOIN PO_HEADERS_ALL PH ON AILA.po_header_id = PH.po_header_id
		LEFT JOIN gl.gl_periods gl ON aida.accounting_date >= gl.start_date and aida.accounting_date < gl.end_date+1
		LEFT JOIN FND_FLEX_VALUES_VL ffvv ON glcc.segment4  = ffvv.FLEX_VALUE
	where 
		gl.period_set_name = ''S2H 4-4-5'' and gl.adjustment_period_flag = ''N'' 
		--and to_char(gl.period_year) >= ''2023''
		and aida.accounting_date >= sysdate - 7
		--and to_char(gl.period_year)||''-''||substr(''0''||to_char(gl.period_num),-2,2) = ''2025-01''
	'
	) --33280

END
GO
