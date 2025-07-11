USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_IPV_AP]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_IPV_AP] 
AS BEGIN

	DELETE FROM Oracle.InvoicePriceVariance WHERE PERIOD_NAME = 'Sep-22'

	--GL->SLA->AP->PO for *R12*
	INSERT INTO Oracle.InvoicePriceVariance 
	SELECT * 
	FROM OPENQUERY(PROD,
		'
		SELECT 
			 aid.DIST_CODE_COMBINATION_ID
			,aid.INVOICE_ID
			,aid.INVOICE_LINE_NUMBER
			,aid.LINE_TYPE_LOOKUP_CODE
			,pda.PO_HEADER_ID
			,pda.PO_LINE_ID
			,pda.LINE_LOCATION_ID
			,aid.PERIOD_NAME
			,aid.AMOUNT
			--,aid.DESCRIPTION AS AID_DESCRIPTION
			,aid.PO_DISTRIBUTION_ID AS AID_PO_DISTRIBUTION_ID
			,aid.INVOICE_DISTRIBUTION_ID
			,aid.RCV_TRANSACTION_ID
			--,pda.CODE_COMBINATION_ID
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

			LEFT JOIN AP_INVOICE_DISTRIBUTIONS_ALL aid	ON xdl.source_distribution_id_num_1 = aid.invoice_distribution_id
			LEFT JOIN po_distributions_all pda			ON aid.PO_DISTRIBUTION_ID = pda.PO_DISTRIBUTION_ID
			LEFT JOIN po_line_locations_all plla		ON pda.line_location_id=plla.line_location_id
			LEFT JOIN po_lines_all pl					ON pda.po_line_id = pl.po_line_id
			LEFT JOIN mtl_system_items msi				ON msi.inventory_item_id = pl.item_id AND msi.organization_id = pda.destination_organization_id
		WHERE 
			gjl.PERIOD_NAME = ''Sep-22''
			AND gjh.ledger_id = ''2022''
			AND glcc.SEGMENT4 = ''1618''
			AND xdl.source_distribution_type = ''AP_INV_DIST''
		'
	)

END
GO
