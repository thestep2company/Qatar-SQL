USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_XLA_AP_DIST]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_XLA_AP_DIST] AS BEGIN
	
	BEGIN TRY 
		BEGIN TRAN
		
			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()

			DELETE FROM Oracle.XLA_AP_DIST
			WHERE ACCOUNTING_DATE >= DATEADD(DAY,-7,CAST(GETDATE() AS DATE))

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

			INSERT INTO Oracle.XLA_AP_DIST
			SELECT * 
			FROM OPENQUERY(PROD,
				'
				SELECT DISTINCT 
						gir.JE_BATCH_ID
					,gir.JE_HEADER_ID
					,gir.JE_LINE_NUM
					,xal.DESCRIPTION AS AE_LINE_DESCRIPTION
					,xal.ACCOUNTING_CLASS_CODE
					,xal.ACCOUNTED_DR
					,xal.ACCOUNTED_CR
					,xdl.UNROUNDED_ACCOUNTED_DR AS Debit
					,xdl.UNROUNDED_ACCOUNTED_CR AS Credit
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
		
					,aid.INVOICE_ID
					,aid.Description AS INVOICE_DISTRIBUTION_DESCRIPTION
			
					,aila.DESCRIPTION AS INVOICE_LINE_DESCRIPTION 
					,aia.INVOICE_NUM
		
					,aila.LINE_SOURCE
					,aila.WFAPPROVAL_STATUS
					,aia.VENDOR_ID
					,aia.INVOICE_AMOUNT
					,aia.AMOUNT_PAID
					,aia.DISCOUNT_AMOUNT_TAKEN
					,aia.APPROVED_AMOUNT
					,aia.GL_DATE
					,aia.PAYMENT_METHOD_CODE
					,aia.PARTY_ID
					,aia.PARTY_SITE_ID
					,aipa.CHECK_ID
					,aipa.INVOICE_PAYMENT_ID
					,aipa.POSTED_FLAG
					,aipa.REMIT_TO_SUPPLIER_NAME
					,aipa.REMIT_TO_SUPPLIER_ID
					,aipa.REMIT_TO_SUPPLIER_SITE
					,aphd.PAY_DIST_LOOKUP_CODE
					,aps.VENDOR_ID AS APS_VENDOR_NAME
					,aps.VENDOR_NAME
					,aps.VENDOR_NAME_ALT
					,aps.SEGMENT1 AS SUPPLIER_SEGMENT1
					,aps.VENDOR_TYPE_LOOKUP_CODE
					,aps.NUM_1099
					,aps.ORGANIZATION_TYPE_LOOKUP_CODE
					,aps.ATTRIBUTE1 AS APS_ATTRIBUTE1
					,aps.TAX_REPORTING_NAME
					,aps.TCA_SYNC_NUM_1099
					,aps.TCA_SYNC_VENDOR_NAME
					,aps.INDIVIDUAL_1099			
			
					,pda.PO_HEADER_ID
					,pda.PO_LINE_ID
					,pda.LINE_LOCATION_ID
					,pda.QUANTITY_ORDERED
					,pda.QUANTITY_DELIVERED
					,pda.QUANTITY_BILLED
					,pda.QUANTITY_CANCELLED
					,pda.ACCRUAL_ACCOUNT_ID
					,pda.VARIANCE_ACCOUNT_ID
					,pda.BOM_RESOURCE_ID
					,pda.REQ_DISTRIBUTION_ID
					,pda.CREATED_BY AS PO_DIST_CREATED_BY
					,msi.segment1 item
					,msi.description item_description



				FROM  gl_je_headers gjh
					LEFT JOIN gl_je_lines gjl					ON gjh.je_header_id = gjl.je_header_id
					LEFT JOIN GL_IMPORT_REFERENCES gir			ON gir.je_header_id = gjl.je_header_id AND gir.je_line_num = gjl.je_line_num

					LEFT JOIN XLA_AE_LINES xal					ON xal.gl_sl_link_id = gir.gl_sl_link_id AND xal.gl_sl_link_table = gir.gl_sl_link_table	
					LEFT JOIN XLA_AE_HEADERS xah				ON xah.ae_header_id = xal.ae_header_id AND xah.application_id = xal.application_id
					LEFT JOIN xla.XLA_TRANSACTION_ENTITIES xte	ON xal.application_id = xte.application_id AND xah.entity_id = xte.entity_id
					LEFT JOIN XLA_DISTRIBUTION_LINKS xdl		ON xte.application_id = xdl.application_id AND xah.ae_header_id = xdl.ae_header_id AND xah.event_id = xdl.event_id AND xal.ae_line_num = xdl.ae_line_num 
					LEFT JOIN GL_CODE_COMBINATIONS glcc			ON xal.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID

					LEFT JOIN ap.ap_checks_all ac ON NVL(xte.source_id_int_1, (-99)) = TO_CHAR (ac.check_id)
					LEFT JOIN AP_INVOICE_DISTRIBUTIONS_ALL aid	ON xdl.source_distribution_id_num_1 = aid.invoice_distribution_id

					LEFT JOIN ap_invoice_lines_all aila ON aila.line_number = aid.invoice_line_number AND aila.invoice_id = aid.invoice_id
					LEFT JOIn ap_invoices_all aia ON aia.invoice_id = aila.invoice_id
					LEFT JOIN ap_invoice_payments_all aipa ON aipa.invoice_id = aia.invoice_id AND ac.check_id = aipa.check_id--aipa.accounting_event_id = xah.event_id AND 
					LEFT JOIN ap_payment_hist_dists aphd ON aipa.invoice_payment_id = aphd.invoice_payment_id --AND xdl.source_distribution_id_num_1 = aphd.payment_hist_dist_id
					LEFT JOIN ap_suppliers aps ON aia.vendor_id = aps.vendor_id

					LEFT JOIN po_distributions_all pda			ON aid.PO_DISTRIBUTION_ID = pda.PO_DISTRIBUTION_ID
					LEFT JOIN po_line_locations_all plla		ON pda.line_location_id=plla.line_location_id
					LEFT JOIN po_lines_all pl					ON pda.po_line_id = pl.po_line_id
					LEFT JOIN mtl_system_items msi				ON msi.inventory_item_id = pl.item_id AND msi.organization_id = pda.destination_organization_id
				WHERE 
					xal.ACCOUNTING_DATE >= TRUNC(SYSDATE-7)
					AND gjh.ledger_id = ''2022''
					--AND glcc.SEGMENT4 = ''1618''
					AND xdl.source_distribution_type = ''AP_INV_DIST''
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
