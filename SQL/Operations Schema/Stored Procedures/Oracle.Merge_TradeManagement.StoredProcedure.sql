USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_TradeManagement]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_TradeManagement] AS BEGIN

	----accruals
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()

	DELETE FROM Oracle.TMAccruals WHERE PERIOD_YEAR*100 + PERIOD_NUM >= 202310

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Accrual Download', GETDATE()

	INSERT INTO Oracle.TMAccruals
	SELECT *
	FROM OPENQUERY(PROD,
		'select
			gl.period_year
		  , gl.PERIOD_NUM
		  , ofuab.utilization_type
		  , to_char(gcc.segment1)||''.''||to_char(gcc.segment2)||''.''||to_char(gcc.segment3)||''.''||to_char(gcc.segment4) AS AR_ACCOUNT
		  , hca.account_number        as CUSTOMER_NUM
		  , hca.account_name          as CUSTOMER_NAME
		  , sum(ofuab.acctd_amount)   as ACCT_AMT
		  , ofdv.short_name           AS FUND_NAME
		  , ofdv.description          AS FUND_DESC
		from OZF_FUNDS_UTILIZED_ALL_B ofuab
			inner join gl.gl_periods gl on gl.period_set_name = ''S2H 4-4-5'' and gl.adjustment_period_flag = ''N'' and ofuab.gl_date >= gl.start_date and ofuab.gl_date < gl.end_date+1      
			inner join ar.hz_cust_accounts hca on nvl(ofuab.cust_account_id,0) = hca.cust_account_id
			left join ozf_fund_details_v ofdv ON ofuab.fund_id = ofdv.fund_id
			left join gl.gl_code_combinations gcc ON ofdv.accrued_liable_account = gcc.code_combination_id
		WHERE gl_posted_flag = ''Y''
			and gl.PERIOD_YEAR*100 + gl.PERIOD_NUM >= 202310
		group by
			to_char(gcc.segment1)||''.''||to_char(gcc.segment2)||''.''||to_char(gcc.segment3)||''.''||to_char(gcc.segment4)
			, gl.period_year
			, gl.PERIOD_NUM
			, ofuab.utilization_type
			, hca.account_number 
			, hca.account_name 
			, ofdv.short_name
			, ofdv.description  
	'
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()
	DELETE FROM Oracle.TMAccrualOrders WHERE PERIOD_YEAR*100 + PERIOD_NUM >= 202310

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Accrual Order Download', GETDATE()
	INSERT INTO Oracle.TMAccrualOrders
	SELECT *
	FROM OPENQUERY(PROD,
		'select
			gl.period_year
		  , gl.PERIOD_NUM
		  , ofuab.utilization_type
		  , to_char(gcc.segment1)||''.''||to_char(gcc.segment2)||''.''||to_char(gcc.segment3)||''.''||to_char(gcc.segment4) AS AR_ACCOUNT
		  , hca.account_number        as CUSTOMER_NUM
		  , hca.account_name          as CUSTOMER_NAME
		  , ofuab.ORDER_LINE_ID --added for the link back to orders
		  , sum(ofuab.acctd_amount)   as ACCT_AMT
		  , ofdv.short_name           AS FUND_NAME
		  , ofdv.description          AS FUND_DESC
		from OZF_FUNDS_UTILIZED_ALL_B ofuab
			inner join gl.gl_periods gl on gl.period_set_name = ''S2H 4-4-5'' and gl.adjustment_period_flag = ''N'' and ofuab.gl_date >= gl.start_date and ofuab.gl_date < gl.end_date+1      
			inner join ar.hz_cust_accounts hca on nvl(ofuab.cust_account_id,0) = hca.cust_account_id
			left join ozf_fund_details_v ofdv ON ofuab.fund_id = ofdv.fund_id
			left join gl.gl_code_combinations gcc ON ofdv.accrued_liable_account = gcc.code_combination_id
		WHERE gl_posted_flag = ''Y''
			and gl.PERIOD_YEAR*100 + gl.PERIOD_NUM >= 202310
		group by
			to_char(gcc.segment1)||''.''||to_char(gcc.segment2)||''.''||to_char(gcc.segment3)||''.''||to_char(gcc.segment4)
			, gl.period_year
			, gl.PERIOD_NUM
			, ofuab.utilization_type
			, hca.account_number 
			, hca.account_name 
			, ofuab.ORDER_LINE_ID
			, ofdv.short_name
			, ofdv.description  
	'
	)


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
	/*
		and ofuab.utilization_type = ''ACCRUAL''
		and hca.cust_account_id IN (3851,186075,155101)
	*/
		
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()

	DELETE FROM Oracle.TMClaims WHERE PERIOD_YEAR*100 + PERIOD_NUM >= 202310

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Accrual Download', GETDATE()

	INSERT INTO Oracle.TMClaims
	SELECT *
	FROM OPENQUERY(PROD,
		'select 
			 gl.period_year
			, gl.PERIOD_NUM
			, hca.account_number AS CUSTOMER_NUM
			, hca.account_name AS CUSTOMER_NAME 
			, ocla.offer_type
			, oca.claim_id
			, oca.claim_date AS CLAIM_DATE 
			, oca.acctd_amount AS AMOUNT 
			, ofdv.description AS FUND_DESC     
			, oca.acctd_amount AS CLAIM_AMOUNT 
			, sum(clu.acctd_amount) AS acctd_detail_amount
			, sum(clu.acctd_amount) -  oca.acctd_amount AS amount_dif
			, to_char(gcc.segment1)||''.''||to_char(gcc.segment2)||''.''||to_char(gcc.segment3)||''.''||to_char(gcc.segment4) AS AR_ACCOUNT
		from ozf_claims_all oca
		   inner join gl.gl_periods gl on gl.period_set_name = ''S2H 4-4-5'' and gl.adjustment_period_flag = ''N'' and oca.gl_date >= gl.start_date and oca.gl_date < gl.end_date+1      
		   inner join ar.hz_cust_accounts hca on nvl(oca.cust_account_id,0) = hca.cust_account_id
		   left join ozf_claim_lines_all ocla on nvl(oca.claim_id,0) = ocla.claim_id
		   left join mtl_system_items msi on ocla.item_id = msi.inventory_item_id and msi.organization_id = 85  
		   left join APPS.OZF_CLAIM_LINES_UTIL_ALL CLU on ocla.claim_line_id = CLU.CLAIM_LINE_ID
		   left join APPS.OZF_FUNDS_UTILIZED_ALL_B UTIL on CLU.UTILIZATION_ID = UTIL.UTILIZATION_ID
		   left join ozf_fund_details_v ofdv on util.fund_id = ofdv.fund_id
		   left join gl.gl_code_combinations gcc on ofdv.accrued_liable_account = gcc.code_combination_id
		where 1=1
			and gl.PERIOD_YEAR*100 + gl.PERIOD_NUM >= 202310
		group by 
			hca.account_name                    
			, hca.account_number      
			, ocla.offer_type
			, oca.claim_id
			, oca.claim_date                       
			, oca.acctd_amount                    
			, ofdv.description         
			, to_char(gcc.segment1)||''.''||to_char(gcc.segment2)||''.''||to_char(gcc.segment3)||''.''||to_char(gcc.segment4)
			, gl.period_year
			, gl.PERIOD_NUM
		order by 
			hca.account_number              
			, hca.account_name  
			, ofdv.description 
			, ocla.offer_type
	'
	)
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END
GO
