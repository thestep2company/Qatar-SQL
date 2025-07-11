USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[XAL_DISTTYPE]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[XAL_DISTTYPE] AS BEGIN

	SELECT * FROM OPENQUERY(PROD,
	'
		SELECT xdl.source_distribution_type, COUNT(*) AS Records
		FROM  GL_IMPORT_REFERENCES gir 
			LEFT JOIN XLA_AE_LINES xal					ON xal.gl_sl_link_id = gir.gl_sl_link_id AND xal.gl_sl_link_table = gir.gl_sl_link_table	
			LEFT JOIN XLA_AE_HEADERS xah				ON xah.ae_header_id = xal.ae_header_id AND xah.application_id = xal.application_id
			LEFT JOIN xla.XLA_TRANSACTION_ENTITIES xte	ON xal.application_id = xte.application_id AND xah.entity_id = xte.entity_id
			LEFT JOIN XLA_DISTRIBUTION_LINKS xdl		ON xte.application_id = xdl.application_id AND xah.ae_header_id = xdl.ae_header_id AND xah.event_id = xdl.event_id AND xal.ae_line_num = xdl.ae_line_num 
			LEFT JOIN GL_CODE_COMBINATIONS glcc			ON xal.CODE_COMBINATION_ID = glcc.CODE_COMBINATION_ID
		WHERE PERIOD_NAME = ''Jul-22'' AND glcc.SEGMENT4 BETWEEN ''5000'' AND ''8999''
		GROUP BY xdl.source_distribution_type
	'
	)

END
GO
