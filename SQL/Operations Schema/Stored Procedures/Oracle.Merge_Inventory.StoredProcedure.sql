USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Inventory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_Inventory] AS BEGIN

	CREATE TABLE #Inventory(
		[CC_CD] [nvarchar](25) NULL,
		[Transaction_ID] [float] NOT NULL,
		[INV_SUB_LEDGER_ID] [float] NULL,
		[JE_SOURCE] [nvarchar](9) NULL,
		[JE_CATEGORY] [nvarchar](2) NULL,
		[DESCRIPTION] [nvarchar](240) NULL,
		[ACCOUNT_CODE] [nvarchar](25) NULL,
		[NAME] [nvarchar](14) NULL,
		[ACCOUNTED_DR] [float] NULL,
		[ACCOUNTED_CR] [float] NULL,
		[DOC_SEQUENCE_VALUE] [float] NULL,
		[ACCOUNTING_DATE] [datetime2](7) NULL,
		[JE_HEADER_ID] [float] NULL,
		[JE_LINE_NUM] [float] NULL,
		[INV_ID] [nvarchar](2) NULL,
		[INV_NUM] [nvarchar](2) NULL,
		[LINK_ID] [float] NULL,
		[CODE_COMBINATION_ID] [numeric](15, 0) NOT NULL,
		[SEGMENT2] [nvarchar](25) NULL,
		[REFERENCE_4] [nvarchar](2) NULL,
		[SET_OF_BOOKS_ID] [float] NULL,
		[OPENING_BALANCE] [float] NULL,
		[PO_NUMBER] [nvarchar](2) NULL,
		[PO_LINE_NUM] [float] NULL,
		[PO_LINE_NAME] [nvarchar](150) NULL,
		[VENDOR_NAME] [nvarchar](2) NULL,
		[VOU_NUM] [nvarchar](30) NULL,
		[QUANTITY] [float] NOT NULL,
		[ORGANIZATION_ID] [float] NOT NULL,
		[ITEM_CODE] [nvarchar](40) NULL,
		[USER_NAME] [nvarchar](100) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) ON [PRIMARY]


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #Inventory (
		   [CC_CD]
		  ,[Transaction_ID]
		  ,[INV_SUB_LEDGER_ID]
		  ,[JE_SOURCE]
		  ,[JE_CATEGORY]
		  ,[DESCRIPTION]
		  ,[ACCOUNT_CODE]
		  ,[NAME]
		  ,[ACCOUNTED_DR]
		  ,[ACCOUNTED_CR]
		  ,[DOC_SEQUENCE_VALUE]
		  ,[ACCOUNTING_DATE]
		  ,[JE_HEADER_ID]
		  ,[JE_LINE_NUM]
		  ,[INV_ID]
		  ,[INV_NUM]
		  ,[LINK_ID]
		  ,[CODE_COMBINATION_ID]
		  ,[SEGMENT2]
		  ,[REFERENCE_4]
		  ,[SET_OF_BOOKS_ID]
		  ,[OPENING_BALANCE]
		  ,[PO_NUMBER]
		  ,[PO_LINE_NUM]
		  ,[PO_LINE_NAME]
		  ,[VENDOR_NAME]
		  ,[VOU_NUM]
		  ,[QUANTITY]
		  ,[ORGANIZATION_ID]
		  ,[ITEM_CODE]
		  ,[USER_NAME]
		  ,[Fingerprint]
	)
	SELECT *,'XXXXXXXXXXXX' 
	FROM OPENQUERY(PROD,'
	SELECT                          
			gcc.segment6 cc_cd,
			mta.Transaction_ID,
			mta.INV_SUB_LEDGER_ID,
			 ''INVENTORY'' je_source,
			 NULL je_category,
			 msi.description,
			 gcc.segment4 account_code,
			 ''MTL'' || ''-'' || mmt.CURRENCY_CODE name,
			 CASE
				WHEN mta.base_transaction_value >= 0
				THEN
				   mta.base_transaction_value
				ELSE
				   0
			 END AS accounted_dr,
			 CASE
				WHEN mta.base_transaction_value < 0
				THEN
				   ABS (mta.base_transaction_value)
				ELSE
				   0
			 END AS accounted_cr,
			 0 doc_sequence_value,
			 TRUNC(mmt.transaction_date) accounting_DATE,
			 0 je_header_id,
			 0 je_line_num,
			 NULL inv_id,
			 NULL inv_num,
			 0 link_id,
			 gcc.code_combination_id,
			 gcc.segment2,
			 NULL reference_4,
			 DECODE (mmt.organization_id,
					 3, 1,
					 24, 3,
					 44, 4,
					 45, 2,
					 46, 4,
					 65, 7,
					 144, 8,
					 165, 10,
					 185, 12,
					 999)
				SET_OF_BOOKS_ID,
			 0 opening_balance,
			 NULL po_number,
			 (SELECT   DISTINCT b.LINE_NUMBER
				FROM   apps.mtl_txn_request_lines b
			   WHERE   mmt.move_order_line_id = b.line_id
					   AND mmt.organization_id = B.organization_id)
				po_line_num,
			 (SELECT   DISTINCT attribute12
				FROM   apps.mtl_txn_request_lines b
			   WHERE   mmt.move_order_line_id = b.line_id
					   AND mmt.organization_id = B.organization_id)
				po_line_name,
			 NULL vendor_name,
			 (SELECT   DISTINCT REQUEST_NUMBER
				FROM   apps.mtl_txn_request_headers a,
					   apps.mtl_txn_request_lines b
			   WHERE       a.header_id = b.header_id
					   AND a.organization_id = b.organization_id
					   AND mmt.move_order_line_id = b.line_id
					   AND mmt.organization_id = a.organization_id)
				Vou_Num,
			 mmt.primary_quantity Quantity,
			 mmt.organization_id,
			 msi.segment1 Item_Code,
			 (SELECT   a.user_name
				FROM   apps.fnd_user a
			   WHERE   a.user_id = mmt.created_by)
				user_name
	  FROM   apps.mtl_material_transactions mmt,
			 apps.mtl_transaction_accounts mta,
			 apps.mtl_system_items_b msi,
			 apps.gl_code_combinations gcc
	 WHERE   mmt.TRANSACTION_ID = mta.transaction_id
			 AND mmt.INVENTORY_ITEM_ID = msi.INVENTORY_ITEM_ID
			 AND mmt.ORGANIZATION_ID = msi.ORGANIZATION_ID
			 AND mta.REFERENCE_ACCOUNT = gcc.CODE_COMBINATION_ID
			 AND mmt.TRANSACTION_DATE >= SYSDATE - 3
			 AND (gcc.segment4 = ''4110'' OR gcc.segment4 = ''4125'')
      
	'
	)


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('InventoryTransactions','Oracle') SELECT @columnList
	*/
	UPDATE #Inventory --#InventoryTransactions
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
				     CAST(ISNULL([CC_CD],'') AS VARCHAR(25)) +  CAST(ISNULL([Transaction_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([INV_SUB_LEDGER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([JE_SOURCE],'') AS VARCHAR(9)) +  CAST(ISNULL([JE_CATEGORY],'') AS VARCHAR(2)) +  CAST(ISNULL([DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([ACCOUNT_CODE],'') AS VARCHAR(25)) +  CAST(ISNULL([NAME],'') AS VARCHAR(14)) +  CAST(ISNULL([ACCOUNTED_DR],'0') AS VARCHAR(100)) +  CAST(ISNULL([ACCOUNTED_CR],'0') AS VARCHAR(100)) +  CAST(ISNULL([DOC_SEQUENCE_VALUE],'0') AS VARCHAR(100)) +  CAST(ISNULL([ACCOUNTING_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([JE_HEADER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([JE_LINE_NUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([INV_ID],'') AS VARCHAR(2)) +  CAST(ISNULL([INV_NUM],'') AS VARCHAR(2)) +  CAST(ISNULL([LINK_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([CODE_COMBINATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([SEGMENT2],'') AS VARCHAR(25)) +  CAST(ISNULL([REFERENCE_4],'') AS VARCHAR(2)) +  CAST(ISNULL([SET_OF_BOOKS_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([OPENING_BALANCE],'0') AS VARCHAR(100)) +  CAST(ISNULL([PO_NUMBER],'') AS VARCHAR(2)) +  CAST(ISNULL([PO_LINE_NUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([PO_LINE_NAME],'') AS VARCHAR(150)) +  CAST(ISNULL([VENDOR_NAME],'') AS VARCHAR(2)) +  CAST(ISNULL([VOU_NUM],'') AS VARCHAR(30)) +  CAST(ISNULL([QUANTITY],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORGANIZATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ITEM_CODE],'') AS VARCHAR(40)) +  CAST(ISNULL([USER_NAME],'') AS VARCHAR(100)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.InventoryTransactions (
		   [CC_CD]
		  ,[Transaction_ID]
		  ,[INV_SUB_LEDGER_ID]
		  ,[JE_SOURCE]
		  ,[JE_CATEGORY]
		  ,[DESCRIPTION]
		  ,[ACCOUNT_CODE]
		  ,[NAME]
		  ,[ACCOUNTED_DR]
		  ,[ACCOUNTED_CR]
		  ,[DOC_SEQUENCE_VALUE]
		  ,[ACCOUNTING_DATE]
		  ,[JE_HEADER_ID]
		  ,[JE_LINE_NUM]
		  ,[INV_ID]
		  ,[INV_NUM]
		  ,[LINK_ID]
		  ,[CODE_COMBINATION_ID]
		  ,[SEGMENT2]
		  ,[REFERENCE_4]
		  ,[SET_OF_BOOKS_ID]
		  ,[OPENING_BALANCE]
		  ,[PO_NUMBER]
		  ,[PO_LINE_NUM]
		  ,[PO_LINE_NAME]
		  ,[VENDOR_NAME]
		  ,[VOU_NUM]
		  ,[QUANTITY]
		  ,[ORGANIZATION_ID]
		  ,[ITEM_CODE]
		  ,[USER_NAME]
		  ,[Fingerprint]
		)
			SELECT 
				   a.[CC_CD]
				  ,a.[Transaction_ID]
				  ,a.[INV_SUB_LEDGER_ID]
				  ,a.[JE_SOURCE]
				  ,a.[JE_CATEGORY]
				  ,a.[DESCRIPTION]
				  ,a.[ACCOUNT_CODE]
				  ,a.[NAME]
				  ,a.[ACCOUNTED_DR]
				  ,a.[ACCOUNTED_CR]
				  ,a.[DOC_SEQUENCE_VALUE]
				  ,a.[ACCOUNTING_DATE]
				  ,a.[JE_HEADER_ID]
				  ,a.[JE_LINE_NUM]
				  ,a.[INV_ID]
				  ,a.[INV_NUM]
				  ,a.[LINK_ID]
				  ,a.[CODE_COMBINATION_ID]
				  ,a.[SEGMENT2]
				  ,a.[REFERENCE_4]
				  ,a.[SET_OF_BOOKS_ID]
				  ,a.[OPENING_BALANCE]
				  ,a.[PO_NUMBER]
				  ,a.[PO_LINE_NUM]
				  ,a.[PO_LINE_NAME]
				  ,a.[VENDOR_NAME]
				  ,a.[VOU_NUM]
				  ,a.[QUANTITY]
				  ,a.[ORGANIZATION_ID]
				  ,a.[ITEM_CODE]
				  ,a.[USER_NAME]
				  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.InventoryTransactions b
				USING (SELECT * FROM #Inventory) a
				ON a.[TRANSACTION_ID] = b.[TRANSACTION_ID] 
					AND ISNULL(a.[inv_sub_ledger_id],0) = ISNULL(b.[inv_sub_ledger_id],0)
					AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
				  	   [CC_CD]
					  ,[Transaction_ID]
					  ,[INV_SUB_LEDGER_ID]
					  ,[JE_SOURCE]
					  ,[JE_CATEGORY]
					  ,[DESCRIPTION]
					  ,[ACCOUNT_CODE]
					  ,[NAME]
					  ,[ACCOUNTED_DR]
					  ,[ACCOUNTED_CR]
					  ,[DOC_SEQUENCE_VALUE]
					  ,[ACCOUNTING_DATE]
					  ,[JE_HEADER_ID]
					  ,[JE_LINE_NUM]
					  ,[INV_ID]
					  ,[INV_NUM]
					  ,[LINK_ID]
					  ,[CODE_COMBINATION_ID]
					  ,[SEGMENT2]
					  ,[REFERENCE_4]
					  ,[SET_OF_BOOKS_ID]
					  ,[OPENING_BALANCE]
					  ,[PO_NUMBER]
					  ,[PO_LINE_NUM]
					  ,[PO_LINE_NAME]
					  ,[VENDOR_NAME]
					  ,[VOU_NUM]
					  ,[QUANTITY]
					  ,[ORGANIZATION_ID]
					  ,[ITEM_CODE]
					  ,[USER_NAME]
					  ,[Fingerprint]
				)
				VALUES (
				   a.[CC_CD]
				  ,a.[Transaction_ID]
				  ,a.[INV_SUB_LEDGER_ID]
				  ,a.[JE_SOURCE]
				  ,a.[JE_CATEGORY]
				  ,a.[DESCRIPTION]
				  ,a.[ACCOUNT_CODE]
				  ,a.[NAME]
				  ,a.[ACCOUNTED_DR]
				  ,a.[ACCOUNTED_CR]
				  ,a.[DOC_SEQUENCE_VALUE]
				  ,a.[ACCOUNTING_DATE]
				  ,a.[JE_HEADER_ID]
				  ,a.[JE_LINE_NUM]
				  ,a.[INV_ID]
				  ,a.[INV_NUM]
				  ,a.[LINK_ID]
				  ,a.[CODE_COMBINATION_ID]
				  ,a.[SEGMENT2]
				  ,a.[REFERENCE_4]
				  ,a.[SET_OF_BOOKS_ID]
				  ,a.[OPENING_BALANCE]
				  ,a.[PO_NUMBER]
				  ,a.[PO_LINE_NUM]
				  ,a.[PO_LINE_NAME]
				  ,a.[VENDOR_NAME]
				  ,a.[VOU_NUM]
				  ,a.[QUANTITY]
				  ,a.[ORGANIZATION_ID]
				  ,a.[ITEM_CODE]
				  ,a.[USER_NAME]
				  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[CC_CD]
					  ,a.[Transaction_ID]
					  ,a.[INV_SUB_LEDGER_ID]
					  ,a.[JE_SOURCE]
					  ,a.[JE_CATEGORY]
					  ,a.[DESCRIPTION]
					  ,a.[ACCOUNT_CODE]
					  ,a.[NAME]
					  ,a.[ACCOUNTED_DR]
					  ,a.[ACCOUNTED_CR]
					  ,a.[DOC_SEQUENCE_VALUE]
					  ,a.[ACCOUNTING_DATE]
					  ,a.[JE_HEADER_ID]
					  ,a.[JE_LINE_NUM]
					  ,a.[INV_ID]
					  ,a.[INV_NUM]
					  ,a.[LINK_ID]
					  ,a.[CODE_COMBINATION_ID]
					  ,a.[SEGMENT2]
					  ,a.[REFERENCE_4]
					  ,a.[SET_OF_BOOKS_ID]
					  ,a.[OPENING_BALANCE]
					  ,a.[PO_NUMBER]
					  ,a.[PO_LINE_NUM]
					  ,a.[PO_LINE_NAME]
					  ,a.[VENDOR_NAME]
					  ,a.[VOU_NUM]
					  ,a.[QUANTITY]
					  ,a.[ORGANIZATION_ID]
					  ,a.[ITEM_CODE]
					  ,a.[USER_NAME]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #Inventory

END
GO
