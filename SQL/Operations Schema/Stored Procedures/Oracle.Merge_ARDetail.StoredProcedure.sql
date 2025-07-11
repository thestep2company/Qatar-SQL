USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_ARDetail]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_ARDetail] AS BEGIN

/*
;WITH Data AS (
	SELECT ROW_NUMBER() OVER (PARTITION BY AE_HEADER_ID, AE_LINE_NUM ORDER BY ACCOUNT_NUMBER DESC) AS RowVersion, * FROM OPENQUERY(PROD,'
		SELECT DISTINCT
			gjl.PERIOD_NAME
			,gir.JE_BATCH_ID
			,gir.JE_HEADER_ID
			,gir.JE_LINE_NUM
			,xal.DESCRIPTION AS AE_LINE_DESCRIPTION
			,xal.ACCOUNTING_CLASS_CODE
			,NVL(xal.ACCOUNTED_DR,0) AS ACCOUNTED_DR
			,NVL(xal.ACCOUNTED_CR,0) AS ACCOUNTED_CR
			,NVL(xal.UNROUNDED_ACCOUNTED_DR,0) AS UNROUNDED_ACCOUNTED_DR
			,NVL(xal.UNROUNDED_ACCOUNTED_CR,0) AS UNROUNDED_ACCOUNTED_CR
			,xal.ACCOUNTING_DATE
			,xah.JE_CATEGORY_NAME
			,xah.PRODUCT_RULE_CODE
			,xah.DESCRIPTION AS AE_HEADER_DESCRIPTION
			,xte.ENTITY_CODE
			,xte.TRANSACTION_NUMBER
			,xdl.SOURCE_DISTRIBUTION_TYPE
			--,xdl.ACCOUNTING_LINE_CODE
			,xdl.LINE_DEFINITION_CODE
			,xdl.EVENT_TYPE_CODE
			--,xdl.APPLIED_TO_ENTITY_CODE
			--,xdl.APPLIED_TO_DISTRIBUTION_TYPE
			,glcc.Segment1
			,glcc.Segment2
			,glcc.Segment3
			,glcc.Segment4
			,gjl.DESCRIPTION AS JE_LINE_DESCRIPTION
			,gjh.NAME AS JE_HEADER_NAME
			,gjh.DESCRIPTION AS JE_HEADER_DESCRIPTION
			,xdl.AE_HEADER_ID
			,xdl.AE_LINE_NUM
			--,msi.Segment1 AS SKU
			,hca.account_number
			,hca.account_name	
		FROM GL_IMPORT_REFERENCES gir 
			LEFT JOIN gl_je_lines gjl					ON gir.je_header_id = gjl.je_header_id AND gir.je_line_num = gjl.je_line_num
			LEFT JOIN gl_je_headers gjh					ON gjh.je_header_id = gjl.je_header_id
			LEFT JOIN GL_CODE_COMBINATIONS glcc			ON gjl.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID

			LEFT JOIN XLA_AE_LINES xal					ON xal.gl_sl_link_id = gir.gl_sl_link_id AND xal.gl_sl_link_table = gir.gl_sl_link_table	
			LEFT JOIN XLA_AE_HEADERS xah				ON xah.ae_header_id = xal.ae_header_id AND xah.application_id = xal.application_id
			LEFT JOIN xla.XLA_TRANSACTION_ENTITIES xte	ON xal.application_id = xte.application_id AND xah.entity_id = xte.entity_id
			LEFT JOIN XLA_DISTRIBUTION_LINKS xdl		ON xte.application_id = xdl.application_id AND xah.ae_header_id = xdl.ae_header_id AND xah.event_id = xdl.event_id AND xal.ae_line_num = xdl.ae_line_num 
			
			LEFT JOIN ar.ra_customer_trx_all trxh		ON trxh.customer_trx_id = xte.source_id_int_1
			LEFT JOIN ar.ra_cust_trx_line_gl_dist_all trxd ON xdl.SOURCE_DISTRIBUTION_ID_NUM_1 = trxd.CUST_TRX_LINE_GL_DIST_ID
			LEFT JOIN ar.ra_customer_trx_lines_all trxl ON trxd.CUSTOMER_TRX_LINE_ID = trxl.CUSTOMER_TRX_LINE_ID
			
			--LEFT JOIN gl.gl_periods gl				ON gl.period_set_name=''S2H 4-4-5''and gl.adjustment_period_flag=''N'' and trxd.gl_date>=gl.start_date and trxd.gl_date<gl.end_date+1 --new
			
			LEFT JOIN INV.MTL_SYSTEM_ITEMS_B msi		ON msi.inventory_item_id = trxl.INVENTORY_ITEM_ID and 85=msi.organization_id
			LEFT JOIN ar.hz_cust_accounts hca			ON nvl(trxh.sold_to_customer_id,trxh.bill_to_customer_id)=hca.cust_account_id
			LEFT JOIN ar.ar_cons_inv_trx_all ci			on ci.trx_number=nvl(trxh.trx_number,''xxxxx'') and ci.transaction_type=''INVOICE'' and ci.customer_trx_id=nvl(trxh.customer_trx_id,0)
			LEFT JOIN ont.oe_order_lines_all ool		on ool.org_id=83 and nvl(trxl.CUSTOMER_TRX_LINE_ID, 0 )=to_char(ool.line_id)
			LEFT JOIN ont.oe_order_headers_all			ooh on nvl(ool.header_id,0)=ooh.header_id	
		WHERE gjl.PERIOD_NAME = ''Jul-22''
			AND gjh.ledger_id = ''2022''
			AND xdl.source_distribution_type = ''RA_CUST_TRX_LINE_GL_DIST_ALL''
			AND glcc.SEGMENT4 = ''1200''
			AND xte.TRANSACTION_NUMBER = ''ACH20220705''
		')
)
INSERT INTO Output.WFARAudit
SELECT PERIOD_NAME
	, AE_HEADER_DESCRIPTION
	, AE_LINE_DESCRIPTION
	, ENTITY_CODE
	, SOURCE_DISTRIBUTION_TYPE
	, LINE_DEFINITION_CODE
	, EVENT_TYPE_CODE
	, TRANSACTION_NUMBER
	, SEGMENT1 + '.' + SEGMENT2 + '.' + SEGMENT3 + '.' + SEGMENT4 AS GLAccount
	, ACCOUNTING_DATE
	, JE_CATEGORY_NAME
	, JE_HEADER_NAME
	, JE_HEADER_DESCRIPTION
	, ACCOUNT_NUMBER
	, ACCOUNT_NAME
	, SUM(ISNULL(UNROUNDED_ACCOUNTED_DR,0)) AS Debit
	, SUM(ISNULL(UNROUNDED_ACCOUNTED_CR,0)) AS Credit
	, SUM(ISNULL(UNROUNDED_ACCOUNTED_DR,0) - ISNULL(UNROUNDED_ACCOUNTED_CR,0)) AS Activity
FROM Data
WHERE RowVersion = 1
GROUP BY PERIOD_NAME
	, AE_HEADER_DESCRIPTION
	, AE_LINE_DESCRIPTION
	, ENTITY_CODE
	, SOURCE_DISTRIBUTION_TYPE
	, LINE_DEFINITION_CODE
	, EVENT_TYPE_CODE
	, TRANSACTION_NUMBER
	, SEGMENT1 + '.' + SEGMENT2 + '.' + SEGMENT3 + '.' + SEGMENT4
	, ACCOUNTING_DATE
	, JE_CATEGORY_NAME
	, JE_HEADER_NAME
	, JE_HEADER_DESCRIPTION
	, ACCOUNT_NUMBER
	, ACCOUNT_NAME
*/

;WITH Data AS (
	--174949 for June
	--pull out RA condition and customer joins and it keeps data in tact to return correct answer
	--or rank the duplicates based on ae_header_id & ae_line_num
	SELECT ROW_NUMBER() OVER (PARTITION BY AE_HEADER_ID, AE_LINE_NUM ORDER BY ACCOUNT_NUMBER DESC) AS RowVersion, *--JE_BATCH_ID, JE_HEADER_ID, JE_LINE_NUM, AE_HEADER_ID, AE_LINE_NUM, UNROUNDED_ACCOUNTED_DR, UNROUNDED_ACCOUNTED_CR, COUNT(*)
	FROM OPENQUERY(PROD,'	
		SELECT DISTINCT --xal.DESCRIPTION AS AE_LINE_DESCRIPTION
			--,acr.* 
			----xdl.SOURCE_DISTRIBUTION_ID_NUM_1
			----ard.REF_CUSTOMER_TRX_LINE_ID
			gjl.PERIOD_NAME
			,gir.JE_BATCH_ID
			,gir.JE_HEADER_ID
			,gir.JE_LINE_NUM
			,xal.DESCRIPTION AS AE_LINE_DESCRIPTION
			,xal.ACCOUNTING_CLASS_CODE
			,NVL(xal.ACCOUNTED_DR,0) AS ACCOUNTED_DR
			,NVL(xal.ACCOUNTED_CR,0) AS ACCOUNTED_CR
			,NVL(xal.UNROUNDED_ACCOUNTED_DR,0) AS UNROUNDED_ACCOUNTED_DR
			,NVL(xal.UNROUNDED_ACCOUNTED_CR,0) AS UNROUNDED_ACCOUNTED_CR
			,xal.ACCOUNTING_DATE
			,xah.JE_CATEGORY_NAME
			,xah.PRODUCT_RULE_CODE
			,xah.DESCRIPTION AS AE_HEADER_DESCRIPTION
			,xte.ENTITY_CODE
			,xte.TRANSACTION_NUMBER
			,xdl.SOURCE_DISTRIBUTION_TYPE
			--,xdl.ACCOUNTING_LINE_CODE
			,xdl.LINE_DEFINITION_CODE
			,xdl.EVENT_TYPE_CODE
			--,xdl.APPLIED_TO_ENTITY_CODE
			--,xdl.APPLIED_TO_DISTRIBUTION_TYPE
			,glcc.Segment1
			,glcc.Segment2
			,glcc.Segment3
			,glcc.Segment4
			,gjl.DESCRIPTION AS JE_LINE_DESCRIPTION
			,gjh.NAME AS JE_HEADER_NAME
			,gjh.DESCRIPTION AS JE_HEADER_DESCRIPTION
			,xdl.AE_HEADER_ID
			,xdl.AE_LINE_NUM
			--,msi.Segment1 AS SKU
			,nvl(nvl(nvl(trxh.sold_to_customer_id,trxh.bill_to_customer_id),acr.pay_from_customer),xal.PARTY_ID) AS account_number
			,hca.account_name
			--,trxh.purchase_order
			,ooh.order_number
			--,ool.line_number
		FROM GL_IMPORT_REFERENCES gir 
			LEFT JOIN gl_je_lines gjl					ON gir.je_header_id = gjl.je_header_id AND gir.je_line_num = gjl.je_line_num
			LEFT JOIN gl_je_headers gjh					ON gjh.je_header_id = gjl.je_header_id
			LEFT JOIN GL_CODE_COMBINATIONS glcc			ON gjl.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID

			LEFT JOIN XLA_AE_LINES xal					ON xal.gl_sl_link_id = gir.gl_sl_link_id AND xal.gl_sl_link_table = gir.gl_sl_link_table	
			LEFT JOIN XLA_AE_HEADERS xah				ON xah.ae_header_id = xal.ae_header_id AND xah.application_id = xal.application_id
			LEFT JOIN xla.XLA_TRANSACTION_ENTITIES xte	ON xal.application_id = xte.application_id AND xah.entity_id = xte.entity_id
			LEFT JOIN XLA_DISTRIBUTION_LINKS xdl		ON xte.application_id = xdl.application_id AND xah.ae_header_id = xdl.ae_header_id AND xah.event_id = xdl.event_id AND xal.ae_line_num = xdl.ae_line_num 
			--LEFT JOIN GL_CODE_COMBINATIONS glcc		ON xal.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID
			
			LEFT JOIN AR_DISTRIBUTIONS_ALL ard			ON xdl.source_distribution_id_num_1 = ard.line_id  AND ard.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID 
			--LEFT JOIN apps.AR_CASH_RECEIPT_HISTORY_ALL acrh ON ard.SOURCE_ID = acrh.CASH_RECEIPT_HISTORY_ID
			
			LEFT JOIN AR_RECEIVABLE_APPLICATIONS_ALL ara ON ard.source_id = ara.receivable_application_id AND ara.CODE_COMBINATION_ID = ard.CODE_COMBINATION_ID 
			LEFT JOIN apps.ar_cash_receipts_all acr		ON ara.CASH_RECEIPT_ID = acr.CASH_RECEIPT_ID
			
			LEFT JOIN ar.ra_cust_trx_line_gl_dist_all trxd ON xdl.SOURCE_DISTRIBUTION_ID_NUM_1 = trxd.CUST_TRX_LINE_GL_DIST_ID
			LEFT JOIN ar.ra_customer_trx_lines_all trxl ON trxd.CUST_TRX_LINE_GL_DIST_ID = trxl.CUSTOMER_TRX_LINE_ID
			LEFT JOIN ar.ra_customer_trx_all trxh		ON trxh.customer_trx_id = ara.APPLIED_CUSTOMER_TRX_ID --xte.source_id_int_1
			
			--LEFT JOIN apps.ar_receipt_methods arm		ON acr.RECEIPT_METHOD_ID = arm.RECEIPT_METHOD_ID
			

			--LEFT JOIN INV.MTL_SYSTEM_ITEMS_B msi		ON msi.inventory_item_id = trxl.INVENTORY_ITEM_ID and 85=msi.organization_id
			LEFT JOIN ar.hz_cust_accounts hca			ON hca.cust_account_id=nvl(nvl(nvl(trxh.sold_to_customer_id,trxh.bill_to_customer_id),acr.pay_from_customer),xal.PARTY_ID)
			LEFT JOIN apps.hz_parties hp				ON hca.party_id = hp.party_id
			--LEFT JOIN ar.ar_cons_inv_trx_all ci			on ci.trx_number=nvl(trxh.trx_number,''xxxxx'') and ci.transaction_type=''INVOICE'' and ci.customer_trx_id=nvl(trxh.customer_trx_id,0)
			LEFT JOIN ont.oe_order_lines_all ool		on ool.org_id=83 and nvl(trxl.CUSTOMER_TRX_LINE_ID, 0 )=to_char(ool.line_id)
			LEFT JOIN ont.oe_order_headers_all			ooh on nvl(ool.header_id,0)=ooh.header_id	
		WHERE 
			gjl.PERIOD_NAME = ''Jan-22''
			AND gjh.ledger_id = ''2022''
			AND xdl.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
			AND glcc.SEGMENT4 = ''1200''
			--AND hca.account_name IS NULL
			--AND xte.TRANSACTION_NUMBER = ''TRUC20220630''
			--AND trxh.trx_number = ''271934''

			--AND xdl.AE_HEADER_ID = 353426807
			--AND xdl.AE_LINE_NUM = 2
			--AND ard.source_table = ''RA''
			--AND gir.JE_HEADER_ID = ''9035123''
	'
	)
	--ORDER BY TRANSACTION_NUMBER
)
INSERT INTO Output.WFARAudit
SELECT PERIOD_NAME
	, AE_HEADER_DESCRIPTION
	, AE_LINE_DESCRIPTION
	, ENTITY_CODE
	, SOURCE_DISTRIBUTION_TYPE
	, LINE_DEFINITION_CODE
	, EVENT_TYPE_CODE
	, TRANSACTION_NUMBER
	, SEGMENT1 + '.' + SEGMENT2 + '.' + SEGMENT3 + '.' + SEGMENT4
	, ACCOUNTING_DATE
	, JE_CATEGORY_NAME
	, JE_HEADER_NAME
	, JE_HEADER_DESCRIPTION
	, ACCOUNT_NUMBER
	, ACCOUNT_NAME
	, SUM(ISNULL(UNROUNDED_ACCOUNTED_DR,0)) AS Debit
	, SUM(ISNULL(UNROUNDED_ACCOUNTED_CR,0)) AS Credit
	, SUM(ISNULL(UNROUNDED_ACCOUNTED_DR,0) - ISNULL(UNROUNDED_ACCOUNTED_CR,0)) AS Activity
FROM Data
WHERE RowVersion = 1
GROUP BY PERIOD_NAME
	, AE_HEADER_DESCRIPTION
	, AE_LINE_DESCRIPTION
	, ENTITY_CODE
	, SOURCE_DISTRIBUTION_TYPE
	, LINE_DEFINITION_CODE
	, EVENT_TYPE_CODE
	, TRANSACTION_NUMBER
	, SEGMENT1 + '.' + SEGMENT2 + '.' + SEGMENT3 + '.' + SEGMENT4
	, ACCOUNTING_DATE
	, JE_CATEGORY_NAME
	, JE_HEADER_NAME
	, JE_HEADER_DESCRIPTION
	, ACCOUNT_NUMBER
	, ACCOUNT_NAME


	/* --CFH if needed
	SELECT *--JE_BATCH_ID, JE_HEADER_ID, JE_LINE_NUM, AE_HEADER_ID, AE_LINE_NUM, UNROUNDED_ACCOUNTED_DR, UNROUNDED_ACCOUNTED_CR, COUNT(*)
	FROM OPENQUERY(PROD,'	
		SELECT DISTINCT --xal.DESCRIPTION AS AE_LINE_DESCRIPTION
			--,acr.* 
			----xdl.SOURCE_DISTRIBUTION_ID_NUM_1
			----ard.REF_CUSTOMER_TRX_LINE_ID
			 gir.JE_BATCH_ID
			,gir.JE_HEADER_ID
			,gir.JE_LINE_NUM
			,xal.DESCRIPTION AS AE_LINE_DESCRIPTION
			,xal.ACCOUNTING_CLASS_CODE
			,NVL(xal.ACCOUNTED_DR,0) AS ACCOUNTED_DR
			,NVL(xal.ACCOUNTED_CR,0) AS ACCOUNTED_CR
			,NVL(xal.UNROUNDED_ACCOUNTED_DR,0) AS UNROUNDED_ACCOUNTED_DR
			,NVL(xal.UNROUNDED_ACCOUNTED_CR,0) AS UNROUNDED_ACCOUNTED_CR
			,xal.ACCOUNTING_DATE
			,xah.JE_CATEGORY_NAME
			,xah.PRODUCT_RULE_CODE
			,xah.DESCRIPTION AS AE_HEADER_DESCRIPTION
			,xte.ENTITY_CODE
			,xte.TRANSACTION_NUMBER
			,xdl.SOURCE_DISTRIBUTION_TYPE
			--,xdl.ACCOUNTING_LINE_CODE
			,xdl.LINE_DEFINITION_CODE
			,xdl.EVENT_TYPE_CODE
			--,xdl.APPLIED_TO_ENTITY_CODE
			--,xdl.APPLIED_TO_DISTRIBUTION_TYPE
			,glcc.Segment1
			,glcc.Segment2
			,glcc.Segment3
			,glcc.Segment4
			,gjl.DESCRIPTION AS JE_LINE_DESCRIPTION
			,gjh.NAME AS JE_HEADER_NAME
			,gjh.DESCRIPTION AS JE_HEADER_DESCRIPTION
			,xdl.AE_HEADER_ID
			,xdl.AE_LINE_NUM
			--,msi.Segment1 AS SKU
			,acr.pay_from_customer AS account_number
			,hca.account_name
			--,trxh.trx_number
			--,trxh.purchase_order
			----,ooh.cust_po_number
			----,ooh.order_number
			----,ool.line_number
			----,ard.REF_CUSTOMER_TRX_LINE_ID
			----,ard.*
		FROM GL_IMPORT_REFERENCES gir 
			LEFT JOIN gl_je_lines gjl					ON gir.je_header_id = gjl.je_header_id AND gir.je_line_num = gjl.je_line_num
			LEFT JOIN gl_je_headers gjh					ON gjh.je_header_id = gjl.je_header_id
			LEFT JOIN GL_CODE_COMBINATIONS glcc			ON gjl.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID

			LEFT JOIN XLA_AE_LINES xal					ON xal.gl_sl_link_id = gir.gl_sl_link_id AND xal.gl_sl_link_table = gir.gl_sl_link_table	
			LEFT JOIN XLA_AE_HEADERS xah				ON xah.ae_header_id = xal.ae_header_id AND xah.application_id = xal.application_id
			LEFT JOIN xla.XLA_TRANSACTION_ENTITIES xte	ON xal.application_id = xte.application_id AND xah.entity_id = xte.entity_id
			LEFT JOIN XLA_DISTRIBUTION_LINKS xdl		ON xte.application_id = xdl.application_id AND xah.ae_header_id = xdl.ae_header_id AND xah.event_id = xdl.event_id AND xal.ae_line_num = xdl.ae_line_num 
			--LEFT JOIN GL_CODE_COMBINATIONS glcc		ON xal.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID
			
			LEFT JOIN AR_DISTRIBUTIONS_ALL ard			ON xdl.source_distribution_id_num_1 = ard.line_id  AND ard.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID 
			--LEFT JOIN apps.AR_CASH_RECEIPT_HISTORY_ALL acrh ON ard.SOURCE_ID = acrh.CASH_RECEIPT_HISTORY_ID
			
			--LEFT JOIN AR_RECEIVABLE_APPLICATIONS_ALL ara ON ard.source_id = ara.receivable_application_id AND ara.CODE_COMBINATION_ID = ard.CODE_COMBINATION_ID 
			LEFT JOIN apps.AR_CASH_RECEIPT_HISTORY_ALL acrh ON ard.SOURCE_ID = acrh.CASH_RECEIPT_HISTORY_ID
			LEFT JOIN apps.ar_cash_receipts_all acr		ON acr.cash_receipt_id = acrh.cash_receipt_id
			
         
			--LEFT JOIN ar.ra_customer_trx_lines_all trxl ON ard.REF_CUSTOMER_TRX_LINE_ID = trxl.CUSTOMER_TRX_LINE_ID
			--LEFT JOIN ar.ra_customer_trx_all trxh		ON trxh.customer_trx_id = ara.APPLIED_CUSTOMER_TRX_ID --xte.source_id_int_1
			--LEFT JOIN ar.ra_cust_trx_line_gl_dist_all trxd ON xdl.SOURCE_DISTRIBUTION_ID_NUM_1 = trxd.CUST_TRX_LINE_GL_DIST_ID
			--LEFT JOIN apps.ar_receipt_methods arm		ON acr.RECEIPT_METHOD_ID = arm.RECEIPT_METHOD_ID
			

			--LEFT JOIN INV.MTL_SYSTEM_ITEMS_B msi		ON msi.inventory_item_id = trxl.INVENTORY_ITEM_ID and 85=msi.organization_id
			LEFT JOIN ar.hz_cust_accounts hca			ON acr.pay_from_customer=hca.cust_account_id
			LEFT JOIN apps.hz_parties hp				ON hca.party_id = hp.party_id
			--LEFT JOIN ar.ar_cons_inv_trx_all ci			on ci.trx_number=nvl(trxh.trx_number,''xxxxx'') and ci.transaction_type=''INVOICE'' and ci.customer_trx_id=nvl(trxh.customer_trx_id,0)
			--LEFT JOIN ont.oe_order_lines_all ool		on ool.org_id=83 and nvl(trxl.CUSTOMER_TRX_LINE_ID, 0 )=to_char(ool.line_id)
			--LEFT JOIN ont.oe_order_headers_all			ooh on nvl(ool.header_id,0)=ooh.header_id	
		WHERE 
			gjl.PERIOD_NAME = ''Jan-22''
			AND gjh.ledger_id = ''2022''
			AND xdl.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
			AND (xal.UNROUNDED_ACCOUNTED_CR <> 0 OR xal.UNROUNDED_ACCOUNTED_DR <> 0)
			AND glcc.SEGMENT4 = ''1200''
			AND ard.source_table = ''CRH''
	'
	)
	*/

END
GO
