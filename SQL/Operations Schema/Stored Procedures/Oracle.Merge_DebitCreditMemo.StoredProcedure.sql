USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_DebitCreditMemo]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_DebitCreditMemo]
AS BEGIN

	CREATE TABLE #memo (
		[ID] INT IDENTITY(1,1) NOT NULL,
		[ACCOUNT_NUMBER] [nvarchar](30) NULL,
		[ACCOUNT_NAME] [nvarchar](240) NULL,
		[INV_TYPE] [nvarchar](20) NULL,
		[PURCHASE_ORDER] [nvarchar](50) NULL,
		[GL_POSTED_DATE] [datetime2](7) NULL,
		[SPECIAL_INSTR] [nvarchar](240) NULL,
		[COMMENTS] [nvarchar](1760) NULL,
		[CT_REFERENCE] [nvarchar](150) NULL,
		[INVOICE_NUMBER] [nvarchar](20) NOT NULL,
		[INVOICE_DATE] [nvarchar](10) NULL,
		[INV_LINE] [float] NULL,
		[LINE_TYPE] [nvarchar](20) NULL,
		[DESCRIPTION] [nvarchar](240) NULL,
		[QUANTITY_CREDITED] [float] NULL,
		[QUANTITY_INVOICED] [float] NULL,
		[UNIT_SELLING_PRICE] [float] NULL,
		[ACCTD_USD] [float] NULL,
		[GL_ACCOUNT] [nvarchar](129) NULL,
		[PERCENT] [float] NULL,
		[CUSTOMER_TRX_LINE_ID] [numeric](15, 0) NULL,
		[USER_NAME] [nvarchar](100) NULL,
		[FULL_NAME] [nvarchar](240) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #memo
	SELECT [ACCOUNT_NUMBER]
      ,[ACCOUNT_NAME]
      ,[INV_TYPE]
      ,[PURCHASE_ORDER]
      ,[GL_POSTED_DATE]
      ,[SPECIAL_INSTR]
      ,[COMMENTS]
      ,[CT_REFERENCE]
      ,[INVOICE_NUMBER]
      ,[INVOICE_DATE]
      ,[INV_LINE]
      ,[LINE_TYPE]
      ,[DESCRIPTION]
      ,[QUANTITY_CREDITED]
      ,[QUANTITY_INVOICED]
      ,[UNIT_SELLING_PRICE]
      ,[ACCTD_USD]
      ,[GL_ACCOUNT]
      ,[PERCENT]
      ,[CUSTOMER_TRX_LINE_ID]
      ,[USER_NAME]
      ,[FULL_NAME]
      ,'XXX' AS [Fingerprint]
	FROM OPENQUERY(PROD,'
	select
		 hzca.account_number 
		,hzca.account_name
		,txtype.name inv_type
		,rct.purchase_order
		,gldist.gl_posted_date
		,rct.INTERNAL_NOTES Special_Instr
		,rct.comments
		,rct.ct_reference
		,rct.trx_number invoice_number 
		,to_char(rct.trx_date,''MM/DD/YYYY'') invoice_date 
		,rctl.line_number Inv_Line
		,rctl.LINE_TYPE
		,rctl.DESCRIPTION
		,nvl(rctl.QUANTITY_CREDITED,0) as Quantity_Credited
		,nvl(rctl.QUANTITY_INVOICED,0) as Quantity_Invoiced
		,nvl(rctl.UNIT_SELLING_PRICE,0) as Unit_Selling_Price
		,nvl(gldist.ACCTD_AMOUNT,0) AS ACCTD_USD
		,ca.segment1 || ''.'' || ca.segment2 || ''.'' || ca.segment3 || ''.'' || ca.segment4 || ''.'' || ca.segment5 as GL_ACCOUNT
		,gldist.PERCENT
		,rctl.customer_trx_line_id
		,fu.user_name
		,fu.Description Full_name
	from 
		ar.ra_customer_trx_all rct 
		LEFT JOIN ar.ra_customer_trx_lines_all rctl ON rct.customer_trx_id = rctl.customer_trx_id
		LEFT JOIN ar.ar_payment_schedules_all arps ON arps.trx_number=rct.trx_number and arps.org_id=rct.org_id and rct.cust_trx_type_id = arps.cust_trx_type_id 
		LEFT JOIN ar.hz_cust_accounts hzca ON hzca.cust_account_id=rct.sold_to_customer_id 
		LEFT JOIN ra_cust_trx_types_all txtype ON txtype.cust_trx_type_id = rct.cust_trx_type_id
		LEFT JOIN ar.ra_cust_trx_line_gl_dist_all gldist ON rctl.customer_trx_line_id = gldist.customer_trx_line_id 
		LEFT JOIN gl.gl_code_combinations ca ON gldist.code_combination_id = ca.code_combination_id
		LEFT JOIN fnd_user fu ON rct.created_by = fu.user_id --(+)
		LEFT JOIN gl.gl_periods gl ON rct.trx_date >= gl.start_date and rct.trx_date < gl.end_date+1
	where 
		rct.org_id=83
		and rct.org_id=83 
		--and rct.trx_number=:inv_number1
		-- and hzca.account_number=:acct_number
		and gl.period_set_name = ''S2H 4-4-5'' 
		and gl.adjustment_period_flag = ''N'' 
		and rct.cust_trx_type_id in (1001,1006)
		--and gl.period_year >= 2019 
		and rct.trx_date >= sysdate - 60
	')

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('DebitCreditMemo','Oracle') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #memo
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			CAST(ISNULL([ACCOUNT_NUMBER],'') AS VARCHAR(30)) +  CAST(ISNULL([ACCOUNT_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([INV_TYPE],'') AS VARCHAR(20)) +  CAST(ISNULL([PURCHASE_ORDER],'') AS VARCHAR(50)) +  CAST(ISNULL([GL_POSTED_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([SPECIAL_INSTR],'') AS VARCHAR(240)) +  CAST(ISNULL([COMMENTS],'') AS VARCHAR(1760)) +  CAST(ISNULL([CT_REFERENCE],'') AS VARCHAR(150)) +  CAST(ISNULL([INVOICE_NUMBER],'') AS VARCHAR(20)) +  CAST(ISNULL([INVOICE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([INV_LINE],'0') AS VARCHAR(100)) +  CAST(ISNULL([LINE_TYPE],'') AS VARCHAR(20)) +  CAST(ISNULL([DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([QUANTITY_CREDITED],'0') AS VARCHAR(100)) +  CAST(ISNULL([QUANTITY_INVOICED],'0') AS VARCHAR(100)) +  CAST(ISNULL([UNIT_SELLING_PRICE],'0') AS VARCHAR(100)) +  CAST(ISNULL([ACCTD_USD],'0') AS VARCHAR(100)) +  CAST(ISNULL([GL_ACCOUNT],'') AS VARCHAR(129)) +  CAST(ISNULL([PERCENT],'0') AS VARCHAR(100)) +  CAST(ISNULL([CUSTOMER_TRX_LINE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([USER_NAME],'') AS VARCHAR(100)) +  CAST(ISNULL([FULL_NAME],'') AS VARCHAR(240)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.DebitCreditMemo (
		  [ACCOUNT_NUMBER]
		  ,[ACCOUNT_NAME]
		  ,[INV_TYPE]
		  ,[PURCHASE_ORDER]
		  ,[GL_POSTED_DATE]
		  ,[SPECIAL_INSTR]
		  ,[COMMENTS]
		  ,[CT_REFERENCE]
		  ,[INVOICE_NUMBER]
		  ,[INVOICE_DATE]
		  ,[INV_LINE]
		  ,[LINE_TYPE]
		  ,[DESCRIPTION]
		  ,[QUANTITY_CREDITED]
		  ,[QUANTITY_INVOICED]
		  ,[UNIT_SELLING_PRICE]
		  ,[ACCTD_USD]
		  ,[GL_ACCOUNT]
		  ,[PERCENT]
		  ,[CUSTOMER_TRX_LINE_ID]
		  ,[USER_NAME]
		  ,[FULL_NAME]
		  ,[Fingerprint]
	)
		SELECT 
			  a.[ACCOUNT_NUMBER]
			  ,a.[ACCOUNT_NAME]
			  ,a.[INV_TYPE]
			  ,a.[PURCHASE_ORDER]
			  ,a.[GL_POSTED_DATE]
			  ,a.[SPECIAL_INSTR]
			  ,a.[COMMENTS]
			  ,a.[CT_REFERENCE]
			  ,a.[INVOICE_NUMBER]
			  ,a.[INVOICE_DATE]
			  ,a.[INV_LINE]
			  ,a.[LINE_TYPE]
			  ,a.[DESCRIPTION]
			  ,a.[QUANTITY_CREDITED]
			  ,a.[QUANTITY_INVOICED]
			  ,a.[UNIT_SELLING_PRICE]
			  ,a.[ACCTD_USD]
			  ,a.[GL_ACCOUNT]
			  ,a.[PERCENT]
			  ,a.[CUSTOMER_TRX_LINE_ID]
			  ,a.[USER_NAME]
			  ,a.[FULL_NAME]
			  ,a.[Fingerprint]
		FROM (
			MERGE Oracle.DebitCreditMemo b
			USING (SELECT * FROM #memo) a
			ON a.CUSTOMER_TRX_LINE_ID = b.CUSTOMER_TRX_LINE_ID AND b.CurrentRecord = 1 --swap with business key of table
			WHEN NOT MATCHED --BY TARGET 
			THEN INSERT (
				   [ACCOUNT_NUMBER]
				  ,[ACCOUNT_NAME]
				  ,[INV_TYPE]
				  ,[PURCHASE_ORDER]
				  ,[GL_POSTED_DATE]
				  ,[SPECIAL_INSTR]
				  ,[COMMENTS]
				  ,[CT_REFERENCE]
				  ,[INVOICE_NUMBER]
				  ,[INVOICE_DATE]
				  ,[INV_LINE]
				  ,[LINE_TYPE]
				  ,[DESCRIPTION]
				  ,[QUANTITY_CREDITED]
				  ,[QUANTITY_INVOICED]
				  ,[UNIT_SELLING_PRICE]
				  ,[ACCTD_USD]
				  ,[GL_ACCOUNT]
				  ,[PERCENT]
				  ,[CUSTOMER_TRX_LINE_ID]
				  ,[USER_NAME]
				  ,[FULL_NAME]
				  ,[Fingerprint]
			)
			VALUES (
				  a.[ACCOUNT_NUMBER]
				  ,a.[ACCOUNT_NAME]
				  ,a.[INV_TYPE]
				  ,a.[PURCHASE_ORDER]
				  ,a.[GL_POSTED_DATE]
				  ,a.[SPECIAL_INSTR]
				  ,a.[COMMENTS]
				  ,a.[CT_REFERENCE]
				  ,a.[INVOICE_NUMBER]
				  ,a.[INVOICE_DATE]
				  ,a.[INV_LINE]
				  ,a.[LINE_TYPE]
				  ,a.[DESCRIPTION]
				  ,a.[QUANTITY_CREDITED]
				  ,a.[QUANTITY_INVOICED]
				  ,a.[UNIT_SELLING_PRICE]
				  ,a.[ACCTD_USD]
				  ,a.[GL_ACCOUNT]
				  ,a.[PERCENT]
				  ,a.[CUSTOMER_TRX_LINE_ID]
				  ,a.[USER_NAME]
				  ,a.[FULL_NAME]
				  ,a.[Fingerprint]
			)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
			THEN UPDATE SET b.EndDate=GETDATE()
				,b.CurrentRecord=0
			OUTPUT 
				  a.[ACCOUNT_NUMBER]
				  ,a.[ACCOUNT_NAME]
				  ,a.[INV_TYPE]
				  ,a.[PURCHASE_ORDER]
				  ,a.[GL_POSTED_DATE]
				  ,a.[SPECIAL_INSTR]
				  ,a.[COMMENTS]
				  ,a.[CT_REFERENCE]
				  ,a.[INVOICE_NUMBER]
				  ,a.[INVOICE_DATE]
				  ,a.[INV_LINE]
				  ,a.[LINE_TYPE]
				  ,a.[DESCRIPTION]
				  ,a.[QUANTITY_CREDITED]
				  ,a.[QUANTITY_INVOICED]
				  ,a.[UNIT_SELLING_PRICE]
				  ,a.[ACCTD_USD]
				  ,a.[GL_ACCOUNT]
				  ,a.[PERCENT]
				  ,a.[CUSTOMER_TRX_LINE_ID]
				  ,a.[USER_NAME]
				  ,a.[FULL_NAME]
				  ,a.[Fingerprint]
				  ,$Action AS Action
		) a
		WHERE Action = 'Update'
		;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #memo

END
GO
