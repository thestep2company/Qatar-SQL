USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_WIP]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROCEDURE [Oracle].[Merge_WIP] AS BEGIN

	CREATE TABLE #WIP (
		[From] [nvarchar](9) NULL,
		[4_digit_acct] [nvarchar](25) NULL,
		[ORG] [nvarchar](3) NULL,
		[SKU] [nvarchar](40) NULL,
		[DESCRIPTION] [nvarchar](240) NULL,
		[TRANSACTION_ID] [float] NOT NULL,
		[WIP_SUB_LEDGER_ID] [float] NULL,
		[ORGANIZATION_ID] [float] NOT NULL,
		[PRIMARY_ITEM_ID] [float] NULL,
		[PART_ID] [nvarchar](40) NULL,
		[PART_DESCRIPTION] [nvarchar](240) NULL,
		[SUB_INV] [nvarchar](2) NULL,
		[LOCATOR] [nvarchar](2) NULL,
		[TRANSACTION_DATE] [datetime2](7) NOT NULL,
		[TRANSACTION_TYPE] [nvarchar](3) NULL,
		[TRANSACTION_QUANTITY] [float] NULL,
		[PRIAMARY_QTY] [float] NULL,
		[TRANSACTION_VALUE] [float] NULL,
		[BASE_TRANS_VALUE] [float] NULL,
		[AMOUNT] [float] NULL,
		[USAGE_RATE_OR_AMOUNT] [float] NULL,
		[CODE_COMBINATION_ID] [numeric](15, 0) NULL,
		[GL_ACCOUNT] [nvarchar](129) NULL,
		[RESOURCE_CODE] [nvarchar](10) NULL,
		[GROUP_ID] [float] NULL,
		[WIP_ENTITY_ID] [float] NOT NULL,
		[REQUEST_ID] [float] NULL,
		[COMPLETION_TRANSACTION_ID] [float] NULL,
		[ACCT_PERIOD_ID] [float] NOT NULL,
		[OVERHEAD_BASIS_FACTOR] [float] NULL,
		[Fingerprint] [varchar](32) NOT NULL
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #WIP ( 
		   [From]
		  ,[4_digit_acct]
		  ,[ORG]
		  ,[SKU]
		  ,[DESCRIPTION]
		  ,[TRANSACTION_ID]
		  ,[WIP_SUB_LEDGER_ID]
		  ,[ORGANIZATION_ID]
		  ,[PRIMARY_ITEM_ID]
		  ,[PART_ID]
		  ,[PART_DESCRIPTION]
		  ,[SUB_INV]
		  ,[LOCATOR]
		  ,[TRANSACTION_DATE]
		  ,[TRANSACTION_TYPE]
		  ,[TRANSACTION_QUANTITY]
		  ,[PRIAMARY_QTY]
		  ,[TRANSACTION_VALUE]
		  ,[BASE_TRANS_VALUE]
		  ,[AMOUNT]
		  ,[USAGE_RATE_OR_AMOUNT]
		  ,[CODE_COMBINATION_ID]
		  ,[GL_ACCOUNT]
		  ,[RESOURCE_CODE]
		  ,[GROUP_ID]
		  ,[WIP_ENTITY_ID]
		  ,[REQUEST_ID]
		  ,[COMPLETION_TRANSACTION_ID]
		  ,[ACCT_PERIOD_ID]
		  ,[OVERHEAD_BASIS_FACTOR]
		  ,[Fingerprint]
	)
	SELECT *, 'XXXXXXXXXX' 
	FROM OPENQUERY(PROD,'
	select
		''WIP Trans''               "From"
		, ca.segment4				"4_digit_acct"
		, ood.organization_code     ORG
		, msib.segment1             SKU
		, msib.description          Description
		, wt.transaction_id
		, wta.wip_sub_ledger_id	
		, wt.organization_id
		, wt.primary_item_id
		, msib.segment1				part_id
		, msib.description			part_description
		, '''' Sub_Inv
		, '''' Locator
		, wt.transaction_date  Transaction_date
		, ''WIP''                         Transaction_Type
		, wt.transaction_quantity
		, wt.primary_quantity            Priamary_QTY
		, wta.transaction_value           
		, wta.base_transaction_value      Base_trans_value 
		, wta.rate_or_amount                Amount
		, wt.usage_rate_or_amount
		, ca.code_combination_id
		, ca.segment1 || ''.'' || ca.segment2 || ''.'' || ca.segment3 || ''.'' || ca.segment4 || ''.'' || ca.segment5 as GL_ACCOUNT
		, br.resource_code
		, wt.group_id
		, wt.WIP_ENTITY_ID
		, wt.REQUEST_ID
		, wt.COMPLETION_TRANSACTION_ID
		, wt.ACCT_PERIOD_ID
		, wta.OVERHEAD_BASIS_FACTOR
	from 
		  WIP.wip_transactions wt
		  LEFT JOIN WIP.wip_transaction_accounts wta ON wt.transaction_id = wta.transaction_id
		  LEFT JOIN GL.gl_code_combinations ca		 ON wta.reference_account = ca.code_combination_id
		  LEFT JOIN INV.mtl_system_items_b msib		 ON wt.primary_item_id = msib.inventory_item_id and wt.organization_id = msib.organization_id
		  LEFT JOIN org_organization_definitions ood ON wt.organization_id = ood.organization_id
		  LEFT JOIN BOM_RESOURCES br				 ON wt.RESOURCE_ID = br.resource_id
	where 1=1 
		AND wt.transaction_date >= SYSDATE - 3
	'
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('WipTransactions','Oracle') SELECT @columnList
	*/
	UPDATE #WIP
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
				   CAST(ISNULL([From],'') AS VARCHAR(9)) +  CAST(ISNULL([4_digit_acct],'') AS VARCHAR(25)) +  CAST(ISNULL([ORG],'') AS VARCHAR(3)) +  CAST(ISNULL([SKU],'') AS VARCHAR(40)) +  CAST(ISNULL([DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([TRANSACTION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([WIP_SUB_LEDGER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORGANIZATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PRIMARY_ITEM_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PART_ID],'') AS VARCHAR(40)) +  CAST(ISNULL([PART_DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([SUB_INV],'') AS VARCHAR(2)) +  CAST(ISNULL([LOCATOR],'') AS VARCHAR(2)) +  CAST(ISNULL([TRANSACTION_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([TRANSACTION_TYPE],'') AS VARCHAR(3)) +  CAST(ISNULL([TRANSACTION_QUANTITY],'0') AS VARCHAR(100)) +  CAST(ISNULL([PRIAMARY_QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([TRANSACTION_VALUE],'0') AS VARCHAR(100)) +  CAST(ISNULL([BASE_TRANS_VALUE],'0') AS VARCHAR(100)) +  CAST(ISNULL([AMOUNT],'0') AS VARCHAR(100)) +  CAST(ISNULL([USAGE_RATE_OR_AMOUNT],'0') AS VARCHAR(100)) +  CAST(ISNULL([CODE_COMBINATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([GL_ACCOUNT],'') AS VARCHAR(129)) +  CAST(ISNULL([RESOURCE_CODE],'') AS VARCHAR(10)) +  CAST(ISNULL([GROUP_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([WIP_ENTITY_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([REQUEST_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([COMPLETION_TRANSACTION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ACCT_PERIOD_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([OVERHEAD_BASIS_FACTOR],'0') AS VARCHAR(100)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO #WIP (
		   [From]
		  ,[4_digit_acct]
		  ,[ORG]
		  ,[SKU]
		  ,[DESCRIPTION]
		  ,[TRANSACTION_ID]
		  ,[WIP_SUB_LEDGER_ID]
		  ,[ORGANIZATION_ID]
		  ,[PRIMARY_ITEM_ID]
		  ,[PART_ID]
		  ,[PART_DESCRIPTION]
		  ,[SUB_INV]
		  ,[LOCATOR]
		  ,[TRANSACTION_DATE]
		  ,[TRANSACTION_TYPE]
		  ,[TRANSACTION_QUANTITY]
		  ,[PRIAMARY_QTY]
		  ,[TRANSACTION_VALUE]
		  ,[BASE_TRANS_VALUE]
		  ,[AMOUNT]
		  ,[USAGE_RATE_OR_AMOUNT]
		  ,[CODE_COMBINATION_ID]
		  ,[GL_ACCOUNT]
		  ,[RESOURCE_CODE]
		  ,[GROUP_ID]
		  ,[WIP_ENTITY_ID]
		  ,[REQUEST_ID]
		  ,[COMPLETION_TRANSACTION_ID]
		  ,[ACCT_PERIOD_ID]
		  ,[OVERHEAD_BASIS_FACTOR]
		  ,[Fingerprint]
		)
			SELECT 
				   a.[From]
				  ,a.[4_digit_acct]
				  ,a.[ORG]
				  ,a.[SKU]
				  ,a.[DESCRIPTION]
				  ,a.[TRANSACTION_ID]
				  ,a.[WIP_SUB_LEDGER_ID]
				  ,a.[ORGANIZATION_ID]
				  ,a.[PRIMARY_ITEM_ID]
				  ,a.[PART_ID]
				  ,a.[PART_DESCRIPTION]
				  ,a.[SUB_INV]
				  ,a.[LOCATOR]
				  ,a.[TRANSACTION_DATE]
				  ,a.[TRANSACTION_TYPE]
				  ,a.[TRANSACTION_QUANTITY]
				  ,a.[PRIAMARY_QTY]
				  ,a.[TRANSACTION_VALUE]
				  ,a.[BASE_TRANS_VALUE]
				  ,a.[AMOUNT]
				  ,a.[USAGE_RATE_OR_AMOUNT]
				  ,a.[CODE_COMBINATION_ID]
				  ,a.[GL_ACCOUNT]
				  ,a.[RESOURCE_CODE]
				  ,a.[GROUP_ID]
				  ,a.[WIP_ENTITY_ID]
				  ,a.[REQUEST_ID]
				  ,a.[COMPLETION_TRANSACTION_ID]
				  ,a.[ACCT_PERIOD_ID]
				  ,a.[OVERHEAD_BASIS_FACTOR]
				  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.WIPTransactions b
				USING (SELECT * FROM #WIP) a
				ON a.[TRANSACTION_ID] = b.[TRANSACTION_ID] 
					AND a.[4_digit_acct] = b.[4_digit_acct]
					AND ISNULL(a.[wip_sub_ledger_id],0) = ISNULL(b.[wip_sub_ledger_id],0)
					AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
				   [From]
				  ,[4_digit_acct]
				  ,[ORG]
				  ,[SKU]
				  ,[DESCRIPTION]
				  ,[TRANSACTION_ID]
				  ,[WIP_SUB_LEDGER_ID]
				  ,[ORGANIZATION_ID]
				  ,[PRIMARY_ITEM_ID]
				  ,[PART_ID]
				  ,[PART_DESCRIPTION]
				  ,[SUB_INV]
				  ,[LOCATOR]
				  ,[TRANSACTION_DATE]
				  ,[TRANSACTION_TYPE]
				  ,[TRANSACTION_QUANTITY]
				  ,[PRIAMARY_QTY]
				  ,[TRANSACTION_VALUE]
				  ,[BASE_TRANS_VALUE]
				  ,[AMOUNT]
				  ,[USAGE_RATE_OR_AMOUNT]
				  ,[CODE_COMBINATION_ID]
				  ,[GL_ACCOUNT]
				  ,[RESOURCE_CODE]
				  ,[GROUP_ID]
				  ,[WIP_ENTITY_ID]
				  ,[REQUEST_ID]
				  ,[COMPLETION_TRANSACTION_ID]
				  ,[ACCT_PERIOD_ID]
				  ,[OVERHEAD_BASIS_FACTOR]
				  ,[Fingerprint]
				)
				VALUES (
					   a.[From]
					  ,a.[4_digit_acct]
					  ,a.[ORG]
					  ,a.[SKU]
					  ,a.[DESCRIPTION]
					  ,a.[TRANSACTION_ID]
					  ,a.[WIP_SUB_LEDGER_ID]
					  ,a.[ORGANIZATION_ID]
					  ,a.[PRIMARY_ITEM_ID]
					  ,a.[PART_ID]
					  ,a.[PART_DESCRIPTION]
					  ,a.[SUB_INV]
					  ,a.[LOCATOR]
					  ,a.[TRANSACTION_DATE]
					  ,a.[TRANSACTION_TYPE]
					  ,a.[TRANSACTION_QUANTITY]
					  ,a.[PRIAMARY_QTY]
					  ,a.[TRANSACTION_VALUE]
					  ,a.[BASE_TRANS_VALUE]
					  ,a.[AMOUNT]
					  ,a.[USAGE_RATE_OR_AMOUNT]
					  ,a.[CODE_COMBINATION_ID]
					  ,a.[GL_ACCOUNT]
					  ,a.[RESOURCE_CODE]
					  ,a.[GROUP_ID]
					  ,a.[WIP_ENTITY_ID]
					  ,a.[REQUEST_ID]
					  ,a.[COMPLETION_TRANSACTION_ID]
					  ,a.[ACCT_PERIOD_ID]
					  ,a.[OVERHEAD_BASIS_FACTOR]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[From]
					  ,a.[4_digit_acct]
					  ,a.[ORG]
					  ,a.[SKU]
					  ,a.[DESCRIPTION]
					  ,a.[TRANSACTION_ID]
					  ,a.[WIP_SUB_LEDGER_ID]
					  ,a.[ORGANIZATION_ID]
					  ,a.[PRIMARY_ITEM_ID]
					  ,a.[PART_ID]
					  ,a.[PART_DESCRIPTION]
					  ,a.[SUB_INV]
					  ,a.[LOCATOR]
					  ,a.[TRANSACTION_DATE]
					  ,a.[TRANSACTION_TYPE]
					  ,a.[TRANSACTION_QUANTITY]
					  ,a.[PRIAMARY_QTY]
					  ,a.[TRANSACTION_VALUE]
					  ,a.[BASE_TRANS_VALUE]
					  ,a.[AMOUNT]
					  ,a.[USAGE_RATE_OR_AMOUNT]
					  ,a.[CODE_COMBINATION_ID]
					  ,a.[GL_ACCOUNT]
					  ,a.[RESOURCE_CODE]
					  ,a.[GROUP_ID]
					  ,a.[WIP_ENTITY_ID]
					  ,a.[REQUEST_ID]
					  ,a.[COMPLETION_TRANSACTION_ID]
					  ,a.[ACCT_PERIOD_ID]
					  ,a.[OVERHEAD_BASIS_FACTOR]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #WIP

END
GO
