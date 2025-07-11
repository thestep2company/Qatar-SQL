USE [Operations]
GO
/****** Object:  StoredProcedure [OUTPUT].[Coop]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [OUTPUT].[Coop] AS BEGIN 


--plan/customer?
SELECT * FROM OPENQUERY(PROD,'select * from ozf_funds_utilized_all_b where plan_id = 6197481 and cust_account_id = 3228') 

--accounts
SELECT * FROM OPENQUERY(PROD,'select cust_account_id, account_NUMBER, account_name from hz_cust_accounts_all')  
WHERE account_name like '%lowe''%' or account_name like '%target%' or account_name like '%kohl%'


--costco, amazon


--funds utilized
SELECT * 
FROM OPENQUERY(PROD,
	'select * from ozf_funds_utilized_all_b 
	 where cust_account_id IN (3851,186075,155101)
		AND to_char(GL_DATE, ''yyyy-mm-dd'') BETWEEN ''2021-01-01'' AND ''2021-07-31''
	'
) 

--any adjustments
SELECT * 
FROM OPENQUERY(PROD,
	'select * from ozf_funds_utilized_all_b 
	 where to_char(GL_DATE, ''yyyy-mm-dd'') BETWEEN ''2021-01-01'' AND ''2021-07-31''
	'
) 
WHERE UTILIZATION_TYPE = 'ADJUSTMENT'


--accruals
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
		and gl.PERIOD_NUM >= 1 
		AND gl.PERIOD_NUM <= 7 
		and gl.period_year = 2021 
		
	group by
		to_char(gcc.segment1)||''.''||to_char(gcc.segment2)||''.''||to_char(gcc.segment3)||''.''||to_char(gcc.segment4)
		, gl.period_year
		, gl.PERIOD_NUM
		, ofuab.utilization_type
		, hca.account_number 
		, hca.account_name 
		, ofdv.short_name
		, ofdv.description  
  order by
		to_char(gcc.segment1)||''.''||to_char(gcc.segment2)||''.''||to_char(gcc.segment3)||''.''||to_char(gcc.segment4)  
		, hca.account_name      
		, hca.account_number 
		, ofdv.short_name
		, ofdv.description 
'
)

/*
	and ofuab.utilization_type = ''ACCRUAL''
	and hca.cust_account_id IN (3851,186075,155101)
*/
		
--claims
SELECT *
FROM OPENQUERY(PROD,
	'select 
		hca.account_number AS CUSTOMER_NUM
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
		, gl.period_year
		, gl.PERIOD_NUM
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
		
		and gl.PERIOD_NUM >= 1 AND gl.PERIOD_NUM <= 7
		and gl.period_year = 2021

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
'
)

/*
	and ocla.offer_type = ''ACCRUAL''
	and hca.cust_account_id IN (3851,186075,155101)
*/

END
GO
