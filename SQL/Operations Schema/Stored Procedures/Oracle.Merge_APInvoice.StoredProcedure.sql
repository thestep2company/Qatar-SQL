USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_APInvoice]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_APInvoice]
AS BEGIN

	CREATE TABLE #APInvoice (
		[INVOICE_ID] [numeric](15, 0) NOT NULL,
		[VENDOR_ID] [numeric](15, 0) NULL,
		[INVOICE_NUM] [nvarchar](50) NOT NULL,
		[LINE_NUMBER] [float] NOT NULL,
		[INVOICE_DISTRIBUTION_ID] [numeric](15, 0) NOT NULL,
		[INVOICE_DATE] [datetime2](7) NULL,
		[INVOICE_AMOUNT] [float] NULL,
		[LINE_AMOUNT] [float] NOT NULL,
		[AMOUNT_PAID] [float] NULL,
		[APPROVED_AMOUNT] [float] NULL,
		[LINE_TYPE_LOOKUP_CODE] [nvarchar](25) NOT NULL,
		[LINE_SOURCE] [nvarchar](30) NULL,
		[MATCH_TYPE] [nvarchar](25) NULL,
		[CREATION_DATE] [datetime2](7) NULL,
		[QUANTITY_INVOICED] [float] NULL,
		[UNIT_PRICE] [float] NULL,
		[PO_HEADER_ID] [float] NULL,
		[PO_LINE_ID] [float] NULL,
		[PO_LINE_LOCATION_ID] [float] NULL,
		[PO_DISTRIBUTION_ID] [float] NULL,
		[RCV_TRANSACTION_ID] [float] NULL,
		[RCV_SHIPMENT_LINE_ID] [numeric](15, 0) NULL,
		[ITEM] [nvarchar](40) NULL,
		[ACCOUNTING_DATE] [datetime2](7) NOT NULL,
		[AMOUNT] [float] NULL,
		[DESCRIPTION] [nvarchar](240) NULL,
		[ACCOUNT_COMBO] [nvarchar](181) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #APInvoice
	SELECT *, 'XXXX' AS Fingerprint
	FROM OPENQUERY(PROD,'
		SELECT
			-- aia.ORG_ID 
			 aia.INVOICE_ID
			,aia.VENDOR_ID
			,aia.INVOICE_NUM
			,aila.LINE_NUMBER
			,aida.INVOICE_DISTRIBUTION_ID
			,aia.INVOICE_DATE
			,aia.INVOICE_AMOUNT --header
			,aila.AMOUNT AS LINE_AMOUNT
			,aia.AMOUNT_PAID
			,aia.APPROVED_AMOUNT
			,aila.LINE_TYPE_LOOKUP_CODE
			,aila.LINE_SOURCE
			,aila.MATCH_TYPE
			,aila.CREATION_DATE
		
			,aila.QUANTITY_INVOICED
			,aila.UNIT_PRICE
			--,msib.SEGMENT1 AS SKU --aila.INVENTORY_ITEM_ID --look this up
			,aila.PO_HEADER_ID
			,aila.PO_LINE_ID
			,aila.PO_LINE_LOCATION_ID
			,aila.PO_DISTRIBUTION_ID
			,aila.RCV_TRANSACTION_ID
			,aila.RCV_SHIPMENT_LINE_ID
			,msib.SEGMENT1 AS ITEM
			,aida.ACCOUNTING_DATE
			,aida.AMOUNT
			,aida.DESCRIPTION
			,gcc.segment1||''.''||gcc.segment2||''.''||gcc.segment3||''.''||gcc.segment4||''.''||gcc.segment5||''.''||gcc.segment6||''.''||gcc.segment7 AS Account_Combo
			--aida.*
		FROM AP_Invoices_ALL aia 
			LEFT JOIN AP_Invoice_LINES_ALL aila			ON aila.invoice_id=aia.invoice_id
			LEFT JOIN AP_INVOICE_DISTRIBUTIONS_ALL aida ON aila.invoice_id=aida.invoice_id and aila.line_number=aida.invoice_line_number 
			LEFT JOIN mtl_system_items_b msib			ON aila.INVENTORY_ITEM_ID = msib.inventory_item_id AND 85 = msib.ORGANIZATION_ID
			LEFT JOIN gl_code_combinations gcc			ON aida.dist_code_combination_id=gcc.code_combination_id
		WHERE aida.ACCOUNTING_DATE >= sysdate - 7 --''2019-01-01''
	')

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	/*	
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('APInvoice','Oracle') SELECT @columnList
	*/
	UPDATE #APInvoice
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
				 CAST(ISNULL([INVOICE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([VENDOR_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([INVOICE_NUM],'') AS VARCHAR(50)) +  CAST(ISNULL([LINE_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([INVOICE_DISTRIBUTION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([INVOICE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([INVOICE_AMOUNT],'0') AS VARCHAR(100)) +  CAST(ISNULL([LINE_AMOUNT],'0') AS VARCHAR(100)) +  CAST(ISNULL([AMOUNT_PAID],'0') AS VARCHAR(100)) +  CAST(ISNULL([APPROVED_AMOUNT],'0') AS VARCHAR(100)) +  CAST(ISNULL([LINE_TYPE_LOOKUP_CODE],'') AS VARCHAR(25)) +  CAST(ISNULL([LINE_SOURCE],'') AS VARCHAR(30)) +  CAST(ISNULL([MATCH_TYPE],'') AS VARCHAR(25)) +  CAST(ISNULL([CREATION_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([QUANTITY_INVOICED],'0') AS VARCHAR(100)) +  CAST(ISNULL([UNIT_PRICE],'0') AS VARCHAR(100)) +  CAST(ISNULL([PO_HEADER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PO_LINE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PO_LINE_LOCATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PO_DISTRIBUTION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([RCV_TRANSACTION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([RCV_SHIPMENT_LINE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ITEM],'') AS VARCHAR(40)) +  CAST(ISNULL([ACCOUNTING_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([AMOUNT],'0') AS VARCHAR(100)) +  CAST(ISNULL([DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([ACCOUNT_COMBO],'') AS VARCHAR(181)) 
		),1)),3,32)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
	INSERT INTO Oracle.APInvoice (
		   [INVOICE_ID]
		  ,[VENDOR_ID]
		  ,[INVOICE_NUM]
		  ,[LINE_NUMBER]
		  ,[INVOICE_DISTRIBUTION_ID]
		  ,[INVOICE_DATE]
		  ,[INVOICE_AMOUNT]
		  ,[LINE_AMOUNT]
		  ,[AMOUNT_PAID]
		  ,[APPROVED_AMOUNT]
		  ,[LINE_TYPE_LOOKUP_CODE]
		  ,[LINE_SOURCE]
		  ,[MATCH_TYPE]
		  ,[CREATION_DATE]
		  ,[QUANTITY_INVOICED]
		  ,[UNIT_PRICE]
		  ,[PO_HEADER_ID]
		  ,[PO_LINE_ID]
		  ,[PO_LINE_LOCATION_ID]
		  ,[PO_DISTRIBUTION_ID]
		  ,[RCV_TRANSACTION_ID]
		  ,[RCV_SHIPMENT_LINE_ID]
		  ,[ITEM]
		  ,[ACCOUNTING_DATE]
		  ,[AMOUNT]
		  ,[DESCRIPTION]
		  ,[ACCOUNT_COMBO]
		  ,[Fingerprint]
	)
			SELECT 
			   a.[INVOICE_ID]
			  ,a.[VENDOR_ID]
			  ,a.[INVOICE_NUM]
			  ,a.[LINE_NUMBER]
			  ,a.[INVOICE_DISTRIBUTION_ID]
			  ,a.[INVOICE_DATE]
			  ,a.[INVOICE_AMOUNT]
			  ,a.[LINE_AMOUNT]
			  ,a.[AMOUNT_PAID]
			  ,a.[APPROVED_AMOUNT]
			  ,a.[LINE_TYPE_LOOKUP_CODE]
			  ,a.[LINE_SOURCE]
			  ,a.[MATCH_TYPE]
			  ,a.[CREATION_DATE]
			  ,a.[QUANTITY_INVOICED]
			  ,a.[UNIT_PRICE]
			  ,a.[PO_HEADER_ID]
			  ,a.[PO_LINE_ID]
			  ,a.[PO_LINE_LOCATION_ID]
			  ,a.[PO_DISTRIBUTION_ID]
			  ,a.[RCV_TRANSACTION_ID]
			  ,a.[RCV_SHIPMENT_LINE_ID]
			  ,a.[ITEM]
			  ,a.[ACCOUNTING_DATE]
			  ,a.[AMOUNT]
			  ,a.[DESCRIPTION]
			  ,a.[ACCOUNT_COMBO]
			  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.APInvoice b
				USING (SELECT * FROM #APInvoice) a
				ON a.[INVOICE_DISTRIBUTION_ID] = b.[INVOICE_DISTRIBUTION_ID] AND b.CurrentRecord = 1
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
				   [INVOICE_ID]
				  ,[VENDOR_ID]
				  ,[INVOICE_NUM]
				  ,[LINE_NUMBER]
				  ,[INVOICE_DISTRIBUTION_ID]
				  ,[INVOICE_DATE]
				  ,[INVOICE_AMOUNT]
				  ,[LINE_AMOUNT]
				  ,[AMOUNT_PAID]
				  ,[APPROVED_AMOUNT]
				  ,[LINE_TYPE_LOOKUP_CODE]
				  ,[LINE_SOURCE]
				  ,[MATCH_TYPE]
				  ,[CREATION_DATE]
				  ,[QUANTITY_INVOICED]
				  ,[UNIT_PRICE]
				  ,[PO_HEADER_ID]
				  ,[PO_LINE_ID]
				  ,[PO_LINE_LOCATION_ID]
				  ,[PO_DISTRIBUTION_ID]
				  ,[RCV_TRANSACTION_ID]
				  ,[RCV_SHIPMENT_LINE_ID]
				  ,[ITEM]
				  ,[ACCOUNTING_DATE]
				  ,[AMOUNT]
				  ,[DESCRIPTION]
				  ,[ACCOUNT_COMBO]
				  ,[Fingerprint]
				)
				VALUES (
				   a.[INVOICE_ID]
				  ,a.[VENDOR_ID]
				  ,a.[INVOICE_NUM]
				  ,a.[LINE_NUMBER]
				  ,a.[INVOICE_DISTRIBUTION_ID]
				  ,a.[INVOICE_DATE]
				  ,a.[INVOICE_AMOUNT]
				  ,a.[LINE_AMOUNT]
				  ,a.[AMOUNT_PAID]
				  ,a.[APPROVED_AMOUNT]
				  ,a.[LINE_TYPE_LOOKUP_CODE]
				  ,a.[LINE_SOURCE]
				  ,a.[MATCH_TYPE]
				  ,a.[CREATION_DATE]
				  ,a.[QUANTITY_INVOICED]
				  ,a.[UNIT_PRICE]
				  ,a.[PO_HEADER_ID]
				  ,a.[PO_LINE_ID]
				  ,a.[PO_LINE_LOCATION_ID]
				  ,a.[PO_DISTRIBUTION_ID]
				  ,a.[RCV_TRANSACTION_ID]
				  ,a.[RCV_SHIPMENT_LINE_ID]
				  ,a.[ITEM]
				  ,a.[ACCOUNTING_DATE]
				  ,a.[AMOUNT]
				  ,a.[DESCRIPTION]
				  ,a.[ACCOUNT_COMBO]
				  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[INVOICE_ID]
					  ,a.[VENDOR_ID]
					  ,a.[INVOICE_NUM]
					  ,a.[LINE_NUMBER]
					  ,a.[INVOICE_DISTRIBUTION_ID]
					  ,a.[INVOICE_DATE]
					  ,a.[INVOICE_AMOUNT]
					  ,a.[LINE_AMOUNT]
					  ,a.[AMOUNT_PAID]
					  ,a.[APPROVED_AMOUNT]
					  ,a.[LINE_TYPE_LOOKUP_CODE]
					  ,a.[LINE_SOURCE]
					  ,a.[MATCH_TYPE]
					  ,a.[CREATION_DATE]
					  ,a.[QUANTITY_INVOICED]
					  ,a.[UNIT_PRICE]
					  ,a.[PO_HEADER_ID]
					  ,a.[PO_LINE_ID]
					  ,a.[PO_LINE_LOCATION_ID]
					  ,a.[PO_DISTRIBUTION_ID]
					  ,a.[RCV_TRANSACTION_ID]
					  ,a.[RCV_SHIPMENT_LINE_ID]
					  ,a.[ITEM]
					  ,a.[ACCOUNTING_DATE]
					  ,a.[AMOUNT]
					  ,a.[DESCRIPTION]
					  ,a.[ACCOUNT_COMBO]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
	
	DROP TABLE #APInvoice
END
GO
