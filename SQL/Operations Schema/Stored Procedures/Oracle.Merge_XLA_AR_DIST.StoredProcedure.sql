USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_XLA_AR_DIST]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_XLA_AR_DIST] AS BEGIN
	
	BEGIN TRY 
		BEGIN TRAN

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()
	
			DELETE FROM Oracle.XLA_ARDIST
			WHERE ACCOUNTING_DATE >= DATEADD(DAY,-7,CAST(GETDATE() AS DATE))

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

			INSERT INTO Oracle.XLA_ARDIST 
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
				--ard.*
				--ra.*
				--rt.*
				--pd.*
				--poh.*
				--pol.*
				--msib.*
				--pov.*
				--povs.*
				--hrls.*
				--hrlb.*
				--ppf.*
				--polt.*
			FROM GL_IMPORT_REFERENCES gir 
				LEFT JOIN XLA_AE_LINES xal					ON xal.gl_sl_link_id = gir.gl_sl_link_id AND xal.gl_sl_link_table = gir.gl_sl_link_table	
				LEFT JOIN XLA_AE_HEADERS xah				ON xah.ae_header_id = xal.ae_header_id AND xah.application_id = xal.application_id
				LEFT JOIN xla.XLA_TRANSACTION_ENTITIES xte	ON xal.application_id = xte.application_id AND xah.entity_id = xte.entity_id
				LEFT JOIN XLA_DISTRIBUTION_LINKS xdl		ON xte.application_id = xdl.application_id AND xah.ae_header_id = xdl.ae_header_id AND xah.event_id = xdl.event_id AND xal.ae_line_num = xdl.ae_line_num 
				LEFT JOIN GL_CODE_COMBINATIONS glcc			ON xal.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID
				LEFT JOIN gl_je_lines gjl					ON gir.je_header_id = gjl.je_header_id AND gir.je_line_num = gjl.je_line_num
				LEFT JOIN gl_je_headers gjh					ON gjh.je_header_id = gjl.je_header_id
				LEFT JOIN AR_DISTRIBUTIONS_ALL ard			ON ard.line_id = xdl.source_distribution_id_num_1
				--LEFT JOIN AR_MISC_CASH_DISTRIBUTIONS_ALL MCD ON ard.SOURCE_ID = MCD.MISC_CASH_DISTRIBUTION_ID
				--LEFT JOIN AR_CASH_RECEIPTS_ALL ACR			ON MCD.CASH_RECEIPT_ID = ACR.CASH_RECEIPT_ID
				LEFT JOIN AR_RECEIVABLE_APPLICATIONS_ALL ra	ON ard.source_id = ra.receivable_application_id
				 --AR_DISTRIBUTIONS_ALL.source_id = AR_RECEIVABLE_APPLICATIONS_ALL.receivable_application_id

				--LEFT JOIN RCV_RECEIVING_SUB_LEDGER rrsl		ON xdl.source_distribution_id_num_1 = rrsl.rcv_sub_ledger_id
				--LEFT JOIn rcv_transactions rt				ON rt.transaction_id = rrsl.rcv_transaction_id and rt.PO_DISTRIBUTION_ID = rrsl.reference3
				--LEFT JOIN po_distributions_all pd			ON pd.po_distribution_id = rt.PO_DISTRIBUTION_ID
				--LEFT JOIN PO_HEADERS_ALL poh				ON pd.PO_HEADER_ID = poh.PO_HEADER_ID
				--LEFT JOIN PO_LINES_ALL pol					ON poh.po_header_id = pol.po_header_id
				--LEFT JOIN mtl_system_items_b msib			ON pol.item_id = msib.inventory_item_id	
				--LEFT JOIN po_vendors pov					ON pov.vendor_id = poh.vendor_id
				--LEFT JOIN po_vendor_sites_All povs			ON povs.vendor_site_id = poh.vendor_site_id
				--LEFT JOIN hr_locations_all hrls				ON poh.ship_to_location_id = hrls.location_id
				--LEFT JOIN hr_locations_all hrlb				ON poh.Bill_to_Location_ID = hrlb.location_id -- for bill to name
				--LEFT JOIN per_all_people_f ppf				ON poh.agent_id = ppf.person_id
				--LEFT JOIN po_line_types polt				ON polt.line_type_id = pol.line_type_id
			WHERE 
				xal.ACCOUNTING_DATE >= TRUNC(SYSDATE-7)
				AND gjh.ledger_id = ''2022''
				AND xdl.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
			')

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		COMMIT TRAN

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		THROW
	END CATCH

 END
 
GO
