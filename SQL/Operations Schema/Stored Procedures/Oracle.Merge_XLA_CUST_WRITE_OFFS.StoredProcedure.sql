USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_XLA_CUST_WRITE_OFFS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_XLA_CUST_WRITE_OFFS] 
AS BEGIN
	
	BEGIN TRY 
		BEGIN TRAN

			DELETE FROM Oracle.XLA_CST_WRITE_OFFS
			WHERE ACCOUNTING_DATE >= DATEADD(DAY,-7,CAST(GETDATE() AS DATE))

			INSERT INTO ORACLE.XLA_CST_WRITE_OFFS
			SELECT * 
			FROM OPENQUERY(PROD,
			'
			SELECT DISTINCT
				 gir.JE_BATCH_ID
				,gir.JE_HEADER_ID
				,gir.JE_LINE_NUM
				,xal.DESCRIPTION AS AE_LINE_DESCRIPTION
				,xal.ACCOUNTING_CLASS_CODE
				,NVL(xal.ACCOUNTED_DR,0) AS ACCOUNTED_DR
				,NVL(xal.ACCOUNTED_CR,0) AS ACCOUNTED_CR
				--,NVL(xal.UNROUNDED_ACCOUNTED_DR,0) AS UNROUNDED_ACCOUNTED_DR
				--,NVL(xal.UNROUNDED_ACCOUNTED_CR,0) AS UNROUNDED_ACCOUNTED_CR
				,NVL(xdl.UNROUNDED_ACCOUNTED_DR,0) AS Debit
				,NVL(xdl.UNROUNDED_ACCOUNTED_CR,0) AS Credit
				,xal.ACCOUNTING_DATE
				,xah.JE_CATEGORY_NAME
				,xah.PRODUCT_RULE_CODE
				,xah.DESCRIPTION AS AE_HEADER_DESCRIPTION
				,xte.ENTITY_CODE
				,xte.TRANSACTION_NUMBER
				,xdl.SOURCE_DISTRIBUTION_TYPE
				,xdl.SOURCE_DISTRIBUTION_ID_NUM_1
				,xdl.ACCOUNTING_LINE_CODE
				,xdl.LINE_DEFINITION_CODE
				,xdl.EVENT_TYPE_CODE
				,xdl.APPLIED_TO_ENTITY_CODE
				,xdl.APPLIED_TO_DISTRIBUTION_TYPE
				,glcc.Segment1
				,glcc.Segment2
				,glcc.Segment3
				,glcc.Segment4
				,gjl.DESCRIPTION AS JE_LINE_DESCRIPTION
				,gjh.NAME AS JE_HEADER_NAME
				,gjh.DESCRIPTION AS JE_HEADER_DESCRIPTION
				,xdl.AE_HEADER_ID
				,xdl.AE_LINE_NUM
				,hca.cust_account_id AS account_id
				,hca.account_name
				,msi.Segment1 AS SKU
			FROM GL_IMPORT_REFERENCES gir 
				LEFT JOIN XLA_AE_LINES xal					ON xal.gl_sl_link_id = gir.gl_sl_link_id AND xal.gl_sl_link_table = gir.gl_sl_link_table	
				LEFT JOIN XLA_AE_HEADERS xah				ON xah.ae_header_id = xal.ae_header_id AND xah.application_id = xal.application_id
				LEFT JOIN xla.XLA_TRANSACTION_ENTITIES xte	ON xal.application_id = xte.application_id AND xah.entity_id = xte.entity_id
				LEFT JOIN XLA_DISTRIBUTION_LINKS xdl		ON xte.application_id = xdl.application_id AND xah.ae_header_id = xdl.ae_header_id AND xah.event_id = xdl.event_id AND xal.ae_line_num = xdl.ae_line_num 
				LEFT JOIN GL_CODE_COMBINATIONS glcc			ON xal.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID
				LEFT JOIN gl_je_lines gjl					ON gir.je_header_id = gjl.je_header_id AND gir.je_line_num = gjl.je_line_num
				LEFT JOIN gl_je_headers gjh					ON gjh.je_header_id = gjl.je_header_id
				LEFT JOIN ar.ra_customer_trx_all trxh		ON trxh.customer_trx_id = xte.source_id_int_1
				LEFT JOIN ar.ra_cust_trx_line_gl_dist_all trxd ON xdl.SOURCE_DISTRIBUTION_ID_NUM_1 = trxd.CUST_TRX_LINE_GL_DIST_ID
				LEFT JOIN ar.ra_customer_trx_lines_all trxl ON trxd.CUSTOMER_TRX_LINE_ID = trxl.CUSTOMER_TRX_LINE_ID
				LEFT JOIN GL_CODE_COMBINATIONS glcc			ON trxd.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID
				--LEFT JOIN gl.gl_periods gl				ON gl.period_set_name=''S2H 4-4-5''and gl.adjustment_period_flag=''N'' and trxd.gl_date>=gl.start_date and trxd.gl_date<gl.end_date+1 --new
				LEFT JOIN INV.MTL_SYSTEM_ITEMS_B msi		ON msi.inventory_item_id = trxl.INVENTORY_ITEM_ID and 85=msi.organization_id
				LEFT JOIN ar.hz_cust_accounts hca			ON xal.PARTY_ID=hca.cust_account_id
		
			WHERE  
				xal.ACCOUNTING_DATE >= TRUNC(SYSDATE-7)
				AND gjh.ledger_id = ''2022''
				AND xdl.source_distribution_type = ''CST_WRITE_OFFS''
				AND (xal.UNROUNDED_ACCOUNTED_CR <> 0 OR xal.UNROUNDED_ACCOUNTED_DR <> 0)
			')
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		THROW
	END CATCH


END
GO
