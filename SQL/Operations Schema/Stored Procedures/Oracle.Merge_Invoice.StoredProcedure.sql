USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Invoice]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Invoice] 
AS BEGIN

	CREATE TABLE #Invoice (
		[REVENUE_TYPE] [nvarchar](15) NULL,
		[CUSTOMER_TRX_ID] [nvarchar](15) NULL,
		[CUSTOMER_TRX_LINE_ID] [nvarchar](15) NULL,
		[SALES_CHANNEL_CODE] [nvarchar](30) NULL,
		[CUST_GROUP] [nvarchar](150) NULL,
		[DEM_CLASS] [nvarchar](30) NULL,
		[BUSINESS_SEGMENT] [nvarchar](150) NULL,
		[FINANCE_CHANNEL] [nvarchar](150) NULL,
		[ACCT_NUM] [nvarchar](30) NULL,
		[ACCT_NAME] [nvarchar](240) NULL,
		[SHIP_TO_ADDRESS1] [nvarchar](240) NULL,
		[SHIP_TO_ADDRESS2] [nvarchar](240) NULL,
		[SHIP_TO_ADDRESS3] [nvarchar](240) NULL,
		[SHIP_TO_ADDRESS4] [nvarchar](240) NULL,
		[SHIP_TO_CITY] [nvarchar](60) NULL,
		[SHIP_TO_STATE] [nvarchar](60) NULL,
		[SHIP_TO_POSTAL_CODE] [nvarchar](60) NULL,
		[SHIP_TO_COUNTRY] [nvarchar](60) NULL,
		[SHIP_TO_PROVINCE] [nvarchar](60) NULL,
		[CUST_PO_NUM] [nvarchar](50) NULL,
		[ORDER_NUM] [int] NULL,
		[SO_LINE_NUM] [int] NULL,
		[AR_TYPE] [nvarchar](30) NULL,
		[CONSOL_INV] [int] NULL,
		[TRX_NUMBER] [NVARCHAR](20) NULL,
		[SKU] [nvarchar](30) NULL,
		[INV_DESCRIPTION] [nvarchar](240) NULL,
		[ITEM_TYPE] [nvarchar](30) NULL,
		[SIOP_FAMILY] [nvarchar](30) NULL,
		[CATEGORY] [nvarchar](30) NULL,
		[SUBCATEGORY] [nvarchar](30) NULL,
		[INVENTORY_ITEM_STATUS_CODE] [nvarchar](30) NULL,
		[WH_CODE] [nvarchar](3) NULL,
		[ITEM_FROZEN_COST] [money] NULL,
		[GL_PERIOD] [nvarchar](30) NULL,
		[PERIOD_NUM] [int] NULL,
		[PERIOD_YEAR] [int] NULL,
		[GL_DATE] [datetime] NULL,
		[QTY_INVOICED] [int] NULL,
		[UOM] [nvarchar](15) NULL,
		[GL_REVENUE_DISTRIBUTION] [nvarchar](30) NULL,
		[ENTERED_AMOUNT] [money] NULL,
		[CURRENCY] [nvarchar](15) NULL,
		[ACCTD_USD] [money] NULL,
		[GL_COGS_DISTRIBUTION] [nvarchar](30) NULL,
		[COGS_AMOUNT] [money] NULL,
		[MARGIN_USD] [money] NULL,
		[MARGIN_PCT] [float] NULL,
		[SO_LINE_ID] [VARCHAR](150) NULL,
		[FRZ_COST] [float] NULL,
		[FRZ_MAT_COST] [float] NULL,
		[FRZ_MAT_OH] [float] NULL,
		[FRZ_RESOUCE] [float] NULL,
		[FRZ_OUT_PROC] [float] NULL,
		[FRZ_OH] [float] NULL,
		[REPORTING_REVENUE_TYPE] [varchar](50) NULL,
		[Fingerprint] [varchar](32) NULL
	)



	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #Invoice (
		   [REVENUE_TYPE]
		  ,[CUSTOMER_TRX_ID]
		  ,[CUSTOMER_TRX_LINE_ID]
		  ,[SALES_CHANNEL_CODE]
		  ,[CUST_GROUP]
		  ,[DEM_CLASS]
		  ,[BUSINESS_SEGMENT]
		  ,[FINANCE_CHANNEL]
		  ,[ACCT_NUM]
		  ,[ACCT_NAME]
		  ,[SHIP_TO_ADDRESS1]
		  ,[SHIP_TO_ADDRESS2]
		  ,[SHIP_TO_ADDRESS3]
		  ,[SHIP_TO_ADDRESS4]
		  ,[SHIP_TO_CITY]
		  ,[SHIP_TO_STATE]
		  ,[SHIP_TO_POSTAL_CODE]
		  ,[SHIP_TO_COUNTRY]
		  ,[SHIP_TO_PROVINCE]
		  ,[CUST_PO_NUM]
		  ,[ORDER_NUM]
		  ,[SO_LINE_NUM]
		  ,[AR_TYPE]
		  ,[CONSOL_INV]
		  ,[TRX_NUMBER]
		  ,[SKU]
		  ,[INV_DESCRIPTION]
		  ,[ITEM_TYPE]
		  ,[SIOP_FAMILY]
		  ,[CATEGORY]
		  ,[SUBCATEGORY]
		  ,[INVENTORY_ITEM_STATUS_CODE]
		  ,[WH_CODE]
		  ,[ITEM_FROZEN_COST]
		  ,[GL_PERIOD]
		  ,[PERIOD_NUM]
		  ,[PERIOD_YEAR]
		  ,[GL_DATE]
		  ,[QTY_INVOICED]
		  ,[UOM]
		  ,[GL_REVENUE_DISTRIBUTION]
		  ,[ENTERED_AMOUNT]
		  ,[CURRENCY]
		  ,[ACCTD_USD]
		  ,[GL_COGS_DISTRIBUTION]
		  ,[COGS_AMOUNT]
		  ,[MARGIN_USD]
		  ,[MARGIN_PCT]
		  ,[SO_LINE_ID]
		  ,[FRZ_COST]
		  ,[FRZ_MAT_COST]
		  ,[FRZ_MAT_OH]
		  ,[FRZ_RESOUCE]
		  ,[FRZ_OUT_PROC]
		  ,[FRZ_OH]
)

SELECT * FROM OPENQUERY(PROD,
'with trx AS (
select gl.period_name period
	,trunc(gldist.gl_date) gl_date
	,case when substr(nvl(trxl.description,''xxxxxxxxxxxxxx''),1,14)=''MANUALOVERIDE.'' then 0 when substr(trxl.description,1,4)=''S2C '' then 0 when gldist.acctd_amount<0 and nvl(trxl.quantity_invoiced,0)>0 then trxl.quantity_invoiced*-1 when gldist.acctd_amount<0 and nvl(trxl.quantity_credited,0)>0 then trxl.quantity_credited*-1 when trxl.quantity_invoiced is not null then trxl.quantity_invoiced when trxl.quantity_credited is not null then trxl.quantity_credited else 0 end qty
	,gldist.amount Rev
	,gldist.acctd_amount USD
	,substr(ca.segment4,1,2) gl_filter
	,ca.segment1||''.''||ca.segment2||''.''||ca.segment3||''.''||ca.segment4||''.''||ca.segment5||''.''||ca.segment6||''.''||ca.segment7 salesAcc
	,case when trxl.interface_line_attribute6 is null then ''0'' when trxl.quantity_invoiced is null and trxl.quantity_credited is not null then ''-''||trxl.interface_line_attribute6 else trxl.interface_line_attribute6 end so_line_id
	,case when trxl.interface_line_attribute6 is null then trxl.description when substr(nvl(trxl.description,''xxxxxxxxxxxxxx''),1,14)=''MANUALOVERIDE.'' then null when substr(trxl.description,1,4)=''S2C '' then trxl.description else null end invDesc
	,nvl(trxl.inventory_item_id,0) itemID
	,trxl.warehouse_id orgID
	,trxl.customer_trx_id trxID
	,trxl.customer_trx_line_id trxLineID
	,trxl.uom_code UOM
	,gl.period_num month
	,gl.period_year year
from ar.ra_customer_trx_lines_all trxl
	inner join ar.ra_cust_trx_line_gl_dist_all gldist on trxl.org_id=83 and gldist.customer_trx_line_id=trxl.customer_trx_line_id
	inner join gl.gl_code_combinations ca on gldist.code_combination_id=ca.code_combination_id
	inner join gl.gl_periods gl on gl.period_set_name=''S2H 4-4-5''and gl.adjustment_period_flag=''N'' and gldist.gl_date>=gl.start_date and gldist.gl_date<gl.end_date+1
where (trxl.creation_date>sysdate-7 OR trxl.last_update_date>sysdate-7) 
	and nvl(trxl.interface_line_context,''xx'')<>''AR Conversion''
)
,override AS (
select period
	,gl_date
	,sum(qty) QTY
	,sum(Rev) REV
	,sum(USD) USD
	,gl_filter
	,salesAcc
	,so_line_id
	,invDesc
	,itemID
	,orgID
	,trxID
	,trxLineID
	,uom
	,month
	,year
from trx
group by period
	,gl_date
	,gl_filter
	,salesAcc
	,so_line_id
	,invDesc
	,itemID
	,orgID
	,trxID
	,trxLineID
	,uom
	,month
	,year
)
,rev AS (
select g.period
	,g.gl_date
	,case when msib.segment1 in (''ZFFF'',''ZFRT'',''ZHND'',''ZTAX'',''D2UINS'') then 0 else g.qty end qty
	,g.REV
	,g.USD
	,case when msib.segment1 in (''ZFFF'',''ZFRT'',''ZHND'',''D2UINS'') then ''SHIPHANDLING'' when msib.segment1=''ZTAX'' then ''ZTAX'' when g.invDesc LIKE ''%FRT%MBS%'' THEN ''FRTMBS'' when substr(g.invDesc,1,7) in (''S2C DSF'',''S2C FRT'') OR g.salesAcc LIKE ''%3300%'' then ''SHIPHANDLING'' when substr(g.invDesc,1,7) in (''S2C DEF'',''S2C COO'') then ''ALLOWANCE'' when substr(g.invDesc,1,7) = ''S2C TPI'' THEN ''TPI'' when substr(g.invDesc,1,4)=''S2C '' then ''S2C_ADJ_OTHER'' when g.gl_filter not in (''30'',''31'',''32'') then ''OTHER'' else ''AAA-SALES'' end revType
	,g.salesAcc
	,case when g.so_line_id is null then ''xx'' when substr(g.so_line_id, 1, 1)=''-'' then substr(g.so_line_id, 2) else g.so_line_id end so_line_id
	,msib.segment1 sku
	,nvl(g.invDesc, msib.description) invDesc
	,case when msib.segment1 in (''ZFFF'',''ZFRT'',''ZHND'',''ZTAX'',''D2UINS'') then 0 when substr(g.invDesc,1,7) in (''S2C DSF'',''S2C FRT'',''S2C DEF'',''S2C COO'') then 0 else nvl(cic.item_cost,0) end item_frozen_cost
	,case when g.itemID is null then 0 when msib.segment1 is null then 0 else g.itemID end itemID
	,nvl(g.orgID,0) orgID
	,g.trxID
	,g.trxLineID
	,uom
	,month
	,year
from override g
	left join inv.mtl_system_items_b msib on nvl(g.itemID,0)=msib.inventory_item_id and nvl(g.orgid,85)=msib.organization_id
	left join bom.cst_item_costs cic on cic.cost_type_id=1 and nvl(msib.inventory_item_id,0)=cic.inventory_item_id and nvl(g.orgID,185)=cic.organization_id
)
, cogs AS (
select crcml.revenue_om_line_id
	,min(ca.segment1||''.''||ca.segment2||''.''||ca.segment3||''.''||ca.segment4||''.''||ca.segment5||''.''||ca.segment6||''.''||ca.segment7) cogsAcc
	,sum(nvl(mta.base_transaction_value,0)) cost
from rev
	inner join bom.cst_revenue_cogs_match_lines crcml on crcml.pac_cost_type_id is null and crcml.operating_unit_id=83 and crcml.revenue_om_line_id=rev.so_line_id
	inner join bom.cst_cogs_events cce on crcml.cogs_om_line_id=cce.cogs_om_line_id and cce.event_type=3
	inner join inv.mtl_material_transactions mmt on cce.mmt_transaction_id=mmt.transaction_id
	inner join inv.mtl_transaction_accounts mta on mmt.transaction_id=mta.transaction_id
	inner join gl.gl_code_combinations ca on mta.reference_account=ca.code_combination_id
where mta.accounting_line_type=35
	and mta.reference_account in (3077,4212,4213,4214,4215,15161,103126,204148,234148,242155,248148,252151)
	and rev.revType=''AAA-SALES''
	and rev.qty>0
group by crcml.revenue_om_line_id
)
select case when r.revType=''ZTAX'' then ''ZTAX-''||nvl(shipto_l.state,''NULL'') else r.revType end
	,r.trxID
	,r.trxLineID
	,hca.sales_channel_code
	,hca.attribute5
	,billto.demand_class_code
	,hca.attribute1
	,hca.attribute8
	,hca.account_number
	,hca.account_name
	,shipto_l.Address1
	,shipto_l.Address2
	,shipto_l.Address3
	,shipto_l.Address4
	,shipto_l.city
	,shipto_l.state
	,shipto_l.postal_code
	,shipto_l.country
	,shipto_l.province
	,ooh.cust_po_number
	,ooh.order_number
	,ool.line_number
	,trxtype.name
	,ci.cons_inv_id
	,trxh.trx_number
	,r.sku
	,r.invDesc
	,nvl(msib.item_type,'''')
	,nvl(msib.attribute9,'''')
	,nvl(msib.attribute1,'''')
	,nvl(msib.attribute2,'''')
	,nvl(msib.inventory_item_status_code,'''')
	,wh.organization_code
	,r.item_frozen_cost
	,r.period 
	,r.month
	,r.year 
	,r.gl_date
	,r.qty
	,uom
	,r.salesAcc
	,r.REV
	,trxh.invoice_currency_code
	,r.USD
	,c.cogsAcc
	,c.cost
	,r.rev-c.cost
	,case when r.rev=0 then null when c.cost=0 then null else round((r.rev-c.cost)/r.rev*100,1) end
	,r.so_line_id
	,cic.item_cost
	,cic.material_cost 
	,cic.material_overhead_cost
	,cic.resource_cost
	,cic.Outside_processing_cost
	,cic.overhead_cost
from rev r
	inner join ar.ra_customer_trx_all trxh on trxh.org_id=83 and r.trxID=trxh.customer_trx_id
	inner join ar.ra_cust_trx_types_all trxtype on trxh.cust_trx_type_id=trxtype.cust_trx_type_id
	inner join ar.hz_cust_accounts hca on nvl(trxh.sold_to_customer_id,trxh.bill_to_customer_id)=hca.cust_account_id
	left join ar.ar_cons_inv_trx_all ci on ci.trx_number=nvl(trxh.trx_number,''xxxxx'') and ci.transaction_type=''INVOICE'' and ci.customer_trx_id=nvl(trxh.customer_trx_id,0)
	left join ont.oe_order_lines_all ool on ool.org_id=83 and nvl(r.so_line_id,0)=to_char(ool.line_id)
	left join ont.oe_order_headers_all ooh on nvl(ool.header_id,0)=ooh.header_id
	left join cogs c on nvl(to_char(r.so_line_id),''xx'')=to_char(c.revenue_om_line_id) and r.qty>0
	left join ar.hz_cust_site_uses_all billto on nvl(trxh.bill_to_site_use_id,0)=billto.site_use_id
	left join ar.hz_cust_acct_sites_all billto_a on billto.cust_acct_site_id=billto_a.cust_acct_site_id 
	left join ar.hz_party_sites billto_p on billto_p.party_site_id=billto_a.party_site_id
	left join ar.hz_locations billto_l on billto_p.location_id=billto_l.location_id
	left join ar.hz_cust_site_uses_all shipto on nvl(trxh.ship_to_site_use_id,0)=shipto.site_use_id
	left join ar.hz_cust_acct_sites_all shipto_a on shipto.cust_acct_site_id=shipto_a.cust_acct_site_id
	left join ar.hz_party_sites shipto_p on shipto_p.party_site_id=shipto_a.party_site_id
	left join ar.hz_locations shipto_l on shipto_p.location_id=shipto_l.location_id
	left join apps.org_organization_definitions wh on nvl(r.orgID,0)=wh.organization_id
	left join inv.mtl_system_items_b msib on nvl(r.itemID,0)=msib.inventory_item_id and 85=msib.organization_id
	left join bom.cst_item_costs cic on cic.cost_type_id=1 and nvl(msib.inventory_item_id,0)=cic.inventory_item_id and nvl(r.orgID,87)=cic.organization_id
'
)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Rev Types', GETDATE()

	--sales
	UPDATE i 
	SET i.REPORTING_REVENUE_TYPE = 
	    CASE  WHEN REVENUE_TYPE LIKE 'ZTAX%' THEN 'ZTAX' 
			WHEN INV_DESCRIPTION LIKE '%FRT%MBS%' THEN 'FRTMBS' 
			WHEN INV_DESCRIPTION LIKE '%DSF%' AND REVENUE_TYPE = 'SHIPHANDLING' THEN 'DSF' 
			WHEN SKU = 'ZFRT' AND GL_REVENUE_DISTRIBUTION NOT LIKE '%3300%' THEN 'ZFRT' 
			WHEN GL_REVENUE_DISTRIBUTION LIKE '%3300%' THEN 'INVFRT' 
			WHEN INV_DESCRIPTION LIKE 'S2C PPD%' THEN 'PPDFRT'
			ELSE REVENUE_TYPE 
		END
	FROM #Invoice i
		LEFT JOIN dbo.DimRevenueType r ON i.REVENUE_TYPE = r.RevenueKey
		LEFT JOIN dbo.DimCalendarFiscal cf ON i.GL_DATE = cf.DateKey
	WHERE (i.GL_REVENUE_DISTRIBUTION LIKE '%3000%' OR i.GL_REVENUE_DISTRIBUTION LIKE '%3200%' OR i.GL_REVENUE_DISTRIBUTION LIKE '%3250%')
	

	--invoiced freight
	UPDATE i 
	SET i.REPORTING_REVENUE_TYPE = 
		CASE WHEN Revenue_TYPE LIKE 'ZTAX%' THEN 'ZTAX' 
			WHEN INV_DESCRIPTION LIKE '%FRT%MBS%' THEN 'FRTMBS' 
			WHEN INV_DESCRIPTION LIKE '%DSF%' THEN 'DSF' 
			WHEN SKU = 'ZFRT' THEN 'ZFRT' 
			WHEN GL_REVENUE_DISTRIBUTION LIKE '%3300%' THEN 'INVFRT' 
			ELSE Revenue_TYPE 
		END
	FROM #Invoice i
	WHERE (
		CASE  WHEN Revenue_TYPE LIKE 'ZTAX%' THEN 'ZTAX' 
			WHEN INV_DESCRIPTION LIKE '%FRT%MBS%' THEN 'FRTMBS' 
			WHEN INV_DESCRIPTION LIKE '%DSF%' THEN 'DSF' 
			WHEN i.SKU = 'ZFRT' AND GL_REVENUE_DISTRIBUTION NOT LIKE '%3300%' THEN 'ZFRT' 
			WHEN GL_REVENUE_DISTRIBUTION LIKE '%3300%' THEN 'INVFRT' 
			WHEN INV_DESCRIPTION LIKE 'S2C PPD%' THEN 'PPDFRT'
			ELSE Revenue_TYPE 
		END IN ('DSF', 'ZFRT', 'INVFRT')
		AND i.GL_REVENUE_DISTRIBUTION LIKE '%3300%'
	)

	--sql command is too long to add another condition so do it out side of the procedure
	UPDATE i
	SET REVENUE_TYPE = 'SHIPHANDLING'
	FROM #invoice i
	WHERE REPORTING_REVENUE_TYPE = 'PPDFRT'

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Invoice','Oracle') SELECT @columnList
	*/
	UPDATE #invoice
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			 CAST(ISNULL(REVENUE_TYPE,'') AS VARCHAR(15)) +  CAST(ISNULL(CUSTOMER_TRX_ID,'') AS VARCHAR(15)) +  CAST(ISNULL(CUSTOMER_TRX_LINE_ID,'') AS VARCHAR(15)) +  CAST(ISNULL(SALES_CHANNEL_CODE,'') AS VARCHAR(30)) +  CAST(ISNULL(CUST_GROUP,'') AS VARCHAR(150)) +  CAST(ISNULL(DEM_CLASS,'') AS VARCHAR(30)) +  CAST(ISNULL(BUSINESS_SEGMENT,'') AS VARCHAR(150)) +  CAST(ISNULL(FINANCE_CHANNEL,'') AS VARCHAR(150)) +  CAST(ISNULL(ACCT_NUM,'') AS VARCHAR(30)) +  CAST(ISNULL(ACCT_NAME,'') AS VARCHAR(240)) +  CAST(ISNULL(SHIP_TO_ADDRESS1,'') AS VARCHAR(240)) +  CAST(ISNULL(SHIP_TO_ADDRESS2,'') AS VARCHAR(240)) +  CAST(ISNULL(SHIP_TO_ADDRESS3,'') AS VARCHAR(240)) +  CAST(ISNULL(SHIP_TO_ADDRESS4,'') AS VARCHAR(240)) +  CAST(ISNULL(SHIP_TO_CITY,'') AS VARCHAR(60)) +  CAST(ISNULL(SHIP_TO_STATE,'') AS VARCHAR(60)) +  CAST(ISNULL(SHIP_TO_POSTAL_CODE,'') AS VARCHAR(60)) +  CAST(ISNULL(SHIP_TO_COUNTRY,'') AS VARCHAR(60)) +  CAST(ISNULL(SHIP_TO_PROVINCE,'') AS VARCHAR(60)) +  CAST(ISNULL(CUST_PO_NUM,'') AS VARCHAR(50)) +  CAST(ISNULL(ORDER_NUM,'0') AS VARCHAR(100)) +  CAST(ISNULL(SO_LINE_NUM,'0') AS VARCHAR(100)) +  CAST(ISNULL(AR_TYPE,'') AS VARCHAR(30)) +  CAST(ISNULL(CONSOL_INV,'0') AS VARCHAR(100)) +  CAST(ISNULL(TRX_NUMBER,'') AS VARCHAR(20)) +  CAST(ISNULL(SKU,'') AS VARCHAR(30)) +  CAST(ISNULL(INV_DESCRIPTION,'') AS VARCHAR(240)) +  CAST(ISNULL(ITEM_TYPE,'') AS VARCHAR(30)) +  CAST(ISNULL(SIOP_FAMILY,'') AS VARCHAR(30)) +  CAST(ISNULL(CATEGORY,'') AS VARCHAR(30)) +  CAST(ISNULL(SUBCATEGORY,'') AS VARCHAR(30)) +  CAST(ISNULL(INVENTORY_ITEM_STATUS_CODE,'') AS VARCHAR(30)) +  CAST(ISNULL(WH_CODE,'') AS VARCHAR(3)) +  CAST(ISNULL(ITEM_FROZEN_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(GL_PERIOD,'') AS VARCHAR(30)) +  CAST(ISNULL(PERIOD_NUM,'0') AS VARCHAR(100)) +  CAST(ISNULL(PERIOD_YEAR,'0') AS VARCHAR(100)) +  CAST(ISNULL(GL_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(QTY_INVOICED,'0') AS VARCHAR(100)) +  CAST(ISNULL(UOM,'') AS VARCHAR(15)) +  CAST(ISNULL(GL_REVENUE_DISTRIBUTION,'') AS VARCHAR(30)) +  CAST(ISNULL(ENTERED_AMOUNT,'0') AS VARCHAR(100)) +  CAST(ISNULL(CURRENCY,'') AS VARCHAR(15)) +  CAST(ISNULL(ACCTD_USD,'0') AS VARCHAR(100)) +  CAST(ISNULL(GL_COGS_DISTRIBUTION,'') AS VARCHAR(30)) +  CAST(ISNULL(COGS_AMOUNT,'0') AS VARCHAR(100)) +  CAST(ISNULL(MARGIN_USD,'0') AS VARCHAR(100)) +  CAST(ISNULL(MARGIN_PCT,'0') AS VARCHAR(100)) +  CAST(ISNULL(SO_LINE_ID,'') AS VARCHAR(150)) +  CAST(ISNULL(FRZ_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(FRZ_MAT_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(FRZ_MAT_OH,'0') AS VARCHAR(100)) +  CAST(ISNULL(FRZ_RESOUCE,'0') AS VARCHAR(100)) +  CAST(ISNULL(FRZ_OUT_PROC,'0') AS VARCHAR(100)) +  CAST(ISNULL(FRZ_OH,'0') AS VARCHAR(100)) 
		),1)),3,32);


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Dedupe', GETDATE()


	;WITH CTE AS (
		SELECT [CUSTOMER_TRX_LINE_ID] FROM #Invoice WITH(NOLOCK) GROUP BY [CUSTOMER_TRX_LINE_ID] HAVING COUNT(*) > 1
	)
	DELETE FROM i
	FROM #Invoice i
		INNER JOIN CTE ON cte.CUSTOMER_TRX_LINE_ID = i.CUSTOMER_TRX_LINE_ID
	WHERE QTY_INVOICED = 0 AND ENTERED_AMOUNT = 0 AND ISNULL(COGS_AMOUNT,0) = 0 --CUSTOMER_TRX_LINE_ID = '47319571'

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
	--expire records outside the merge
	INSERT INTO Oracle.Invoice (
		   [REVENUE_TYPE]
		  ,[CUSTOMER_TRX_ID]
		  ,[CUSTOMER_TRX_LINE_ID]
		  ,[SALES_CHANNEL_CODE]
		  ,[CUST_GROUP]
		  ,[DEM_CLASS]
		  ,[BUSINESS_SEGMENT]
		  ,[FINANCE_CHANNEL]
		  ,[ACCT_NUM]
		  ,[ACCT_NAME]
		  ,[SHIP_TO_ADDRESS1]
		  ,[SHIP_TO_ADDRESS2]
		  ,[SHIP_TO_ADDRESS3]
		  ,[SHIP_TO_ADDRESS4]
		  ,[SHIP_TO_CITY]
		  ,[SHIP_TO_STATE]
		  ,[SHIP_TO_POSTAL_CODE]
		  ,[SHIP_TO_COUNTRY]
		  ,[SHIP_TO_PROVINCE]
		  ,[CUST_PO_NUM]
		  ,[ORDER_NUM]
		  ,[SO_LINE_NUM]
		  ,[AR_TYPE]
		  ,[CONSOL_INV]
		  ,[TRX_NUMBER]
		  ,[SKU]
		  ,[INV_DESCRIPTION]
		  ,[ITEM_TYPE]
		  ,[SIOP_FAMILY]
		  ,[CATEGORY]
		  ,[SUBCATEGORY]
		  ,[INVENTORY_ITEM_STATUS_CODE]
		  ,[WH_CODE]
		  ,[ITEM_FROZEN_COST]
		  ,[GL_PERIOD]
		  ,[PERIOD_NUM]
		  ,[PERIOD_YEAR]
		  ,[GL_DATE]
		  ,[QTY_INVOICED]
		  ,[UOM]
		  ,[GL_REVENUE_DISTRIBUTION]
		  ,[ENTERED_AMOUNT]
		  ,[CURRENCY]
		  ,[ACCTD_USD]
		  ,[GL_COGS_DISTRIBUTION]
		  ,[COGS_AMOUNT]
		  ,[MARGIN_USD]
		  ,[MARGIN_PCT]
		  ,[SO_LINE_ID]
		  ,[FRZ_COST]
		  ,[FRZ_MAT_COST]
		  ,[FRZ_MAT_OH]
		  ,[FRZ_RESOUCE]
		  ,[FRZ_OUT_PROC]
		  ,[FRZ_OH]	
		  ,[REPORTING_REVENUE_TYPE]
		  ,[FINGERPRINT]
	 )
		SELECT 
			   a.[REVENUE_TYPE]
			  ,a.[CUSTOMER_TRX_ID]
			  ,a.[CUSTOMER_TRX_LINE_ID]
			  ,a.[SALES_CHANNEL_CODE]
			  ,a.[CUST_GROUP]
			  ,a.[DEM_CLASS]
			  ,a.[BUSINESS_SEGMENT]
			  ,a.[FINANCE_CHANNEL]
			  ,a.[ACCT_NUM]
			  ,a.[ACCT_NAME]
			  ,a.[SHIP_TO_ADDRESS1]
			  ,a.[SHIP_TO_ADDRESS2]
			  ,a.[SHIP_TO_ADDRESS3]
			  ,a.[SHIP_TO_ADDRESS4]
			  ,a.[SHIP_TO_CITY]
			  ,a.[SHIP_TO_STATE]
			  ,a.[SHIP_TO_POSTAL_CODE]
			  ,a.[SHIP_TO_COUNTRY]
			  ,a.[SHIP_TO_PROVINCE]
			  ,a.[CUST_PO_NUM]
			  ,a.[ORDER_NUM]
			  ,a.[SO_LINE_NUM]
			  ,a.[AR_TYPE]
			  ,a.[CONSOL_INV]
			  ,a.[TRX_NUMBER]
			  ,a.[SKU]
			  ,a.[INV_DESCRIPTION]
			  ,a.[ITEM_TYPE]
			  ,a.[SIOP_FAMILY]
			  ,a.[CATEGORY]
			  ,a.[SUBCATEGORY]
			  ,a.[INVENTORY_ITEM_STATUS_CODE]
			  ,a.[WH_CODE]
			  ,a.[ITEM_FROZEN_COST]
			  ,a.[GL_PERIOD]
			  ,a.[PERIOD_NUM]
			  ,a.[PERIOD_YEAR]
			  ,a.[GL_DATE]
			  ,a.[QTY_INVOICED]
			  ,a.[UOM]
			  ,a.[GL_REVENUE_DISTRIBUTION]
			  ,a.[ENTERED_AMOUNT]
			  ,a.[CURRENCY]
			  ,a.[ACCTD_USD]
			  ,a.[GL_COGS_DISTRIBUTION]
			  ,a.[COGS_AMOUNT]
			  ,a.[MARGIN_USD]
			  ,a.[MARGIN_PCT]
			  ,a.[SO_LINE_ID]
			  ,a.[FRZ_COST]
			  ,a.[FRZ_MAT_COST]
			  ,a.[FRZ_MAT_OH]
			  ,a.[FRZ_RESOUCE]
			  ,a.[FRZ_OUT_PROC]
			  ,a.[FRZ_OH]	
			  ,a.[REPORTING_REVENUE_TYPE]
			  ,a.[FINGERPRINT]
			FROM (
				MERGE Oracle.Invoice b
				USING (SELECT * FROM #invoice) a
				ON a.[CUSTOMER_TRX_LINE_ID] = b.[CUSTOMER_TRX_LINE_ID] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [REVENUE_TYPE]
					  ,[CUSTOMER_TRX_ID]
					  ,[CUSTOMER_TRX_LINE_ID]
					  ,[SALES_CHANNEL_CODE]
					  ,[CUST_GROUP]
					  ,[DEM_CLASS]
					  ,[BUSINESS_SEGMENT]
					  ,[FINANCE_CHANNEL]
					  ,[ACCT_NUM]
					  ,[ACCT_NAME]
					  ,[SHIP_TO_ADDRESS1]
					  ,[SHIP_TO_ADDRESS2]
					  ,[SHIP_TO_ADDRESS3]
					  ,[SHIP_TO_ADDRESS4]
					  ,[SHIP_TO_CITY]
					  ,[SHIP_TO_STATE]
					  ,[SHIP_TO_POSTAL_CODE]
					  ,[SHIP_TO_COUNTRY]
					  ,[SHIP_TO_PROVINCE]
					  ,[CUST_PO_NUM]
					  ,[ORDER_NUM]
					  ,[SO_LINE_NUM]
					  ,[AR_TYPE]
					  ,[CONSOL_INV]
					  ,[TRX_NUMBER]
					  ,[SKU]
					  ,[INV_DESCRIPTION]
					  ,[ITEM_TYPE]
					  ,[SIOP_FAMILY]
					  ,[CATEGORY]
					  ,[SUBCATEGORY]
					  ,[INVENTORY_ITEM_STATUS_CODE]
					  ,[WH_CODE]
					  ,[ITEM_FROZEN_COST]
					  ,[GL_PERIOD]
					  ,[PERIOD_NUM]
					  ,[PERIOD_YEAR]
					  ,[GL_DATE]
					  ,[QTY_INVOICED]
					  ,[UOM]
					  ,[GL_REVENUE_DISTRIBUTION]
					  ,[ENTERED_AMOUNT]
					  ,[CURRENCY]
					  ,[ACCTD_USD]
					  ,[GL_COGS_DISTRIBUTION]
					  ,[COGS_AMOUNT]
					  ,[MARGIN_USD]
					  ,[MARGIN_PCT]
					  ,[SO_LINE_ID]
					  ,[FRZ_COST]
					  ,[FRZ_MAT_COST]
					  ,[FRZ_MAT_OH]
					  ,[FRZ_RESOUCE]
					  ,[FRZ_OUT_PROC]
					  ,[FRZ_OH]	
					  ,[REPORTING_REVENUE_TYPE]
					  ,[FINGERPRINT]
			)
			VALUES (
				   a.[REVENUE_TYPE]
				  ,a.[CUSTOMER_TRX_ID]
				  ,a.[CUSTOMER_TRX_LINE_ID]
				  ,a.[SALES_CHANNEL_CODE]
				  ,a.[CUST_GROUP]
				  ,a.[DEM_CLASS]
				  ,a.[BUSINESS_SEGMENT]
				  ,a.[FINANCE_CHANNEL]
				  ,a.[ACCT_NUM]
				  ,a.[ACCT_NAME]
				  ,a.[SHIP_TO_ADDRESS1]
				  ,a.[SHIP_TO_ADDRESS2]
				  ,a.[SHIP_TO_ADDRESS3]
				  ,a.[SHIP_TO_ADDRESS4]
				  ,a.[SHIP_TO_CITY]
				  ,a.[SHIP_TO_STATE]
				  ,a.[SHIP_TO_POSTAL_CODE]
				  ,a.[SHIP_TO_COUNTRY]
				  ,a.[SHIP_TO_PROVINCE]
				  ,a.[CUST_PO_NUM]
				  ,a.[ORDER_NUM]
				  ,a.[SO_LINE_NUM]
				  ,a.[AR_TYPE]
				  ,a.[CONSOL_INV]
				  ,a.[TRX_NUMBER]
				  ,a.[SKU]
				  ,a.[INV_DESCRIPTION]
				  ,a.[ITEM_TYPE]
				  ,a.[SIOP_FAMILY]
				  ,a.[CATEGORY]
				  ,a.[SUBCATEGORY]
				  ,a.[INVENTORY_ITEM_STATUS_CODE]
				  ,a.[WH_CODE]
				  ,a.[ITEM_FROZEN_COST]
				  ,a.[GL_PERIOD]
				  ,a.[PERIOD_NUM]
				  ,a.[PERIOD_YEAR]
				  ,a.[GL_DATE]
				  ,a.[QTY_INVOICED]
				  ,a.[UOM]
				  ,a.[GL_REVENUE_DISTRIBUTION]
				  ,a.[ENTERED_AMOUNT]
				  ,a.[CURRENCY]
				  ,a.[ACCTD_USD]
				  ,a.[GL_COGS_DISTRIBUTION]
				  ,a.[COGS_AMOUNT]
				  ,a.[MARGIN_USD]
				  ,a.[MARGIN_PCT]
				  ,a.[SO_LINE_ID]
				  ,a.[FRZ_COST]
				  ,a.[FRZ_MAT_COST]
				  ,a.[FRZ_MAT_OH]
				  ,a.[FRZ_RESOUCE]
				  ,a.[FRZ_OUT_PROC]
				  ,a.[FRZ_OH]	
				  ,a.[REPORTING_REVENUE_TYPE]
				  ,a.[FINGERPRINT]
			)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
			THEN UPDATE SET b.EndDate=GETDATE()
				,b.CurrentRecord=0
			OUTPUT 
				   a.[REVENUE_TYPE]
				  ,a.[CUSTOMER_TRX_ID]
				  ,a.[CUSTOMER_TRX_LINE_ID]
				  ,a.[SALES_CHANNEL_CODE]
				  ,a.[CUST_GROUP]
				  ,a.[DEM_CLASS]
				  ,a.[BUSINESS_SEGMENT]
				  ,a.[FINANCE_CHANNEL]
				  ,a.[ACCT_NUM]
				  ,a.[ACCT_NAME]
				  ,a.[SHIP_TO_ADDRESS1]
				  ,a.[SHIP_TO_ADDRESS2]
				  ,a.[SHIP_TO_ADDRESS3]
				  ,a.[SHIP_TO_ADDRESS4]
				  ,a.[SHIP_TO_CITY]
				  ,a.[SHIP_TO_STATE]
				  ,a.[SHIP_TO_POSTAL_CODE]
				  ,a.[SHIP_TO_COUNTRY]
				  ,a.[SHIP_TO_PROVINCE]
				  ,a.[CUST_PO_NUM]
				  ,a.[ORDER_NUM]
				  ,a.[SO_LINE_NUM]
				  ,a.[AR_TYPE]
				  ,a.[CONSOL_INV]
				  ,a.[TRX_NUMBER]
				  ,a.[SKU]
				  ,a.[INV_DESCRIPTION]
				  ,a.[ITEM_TYPE]
				  ,a.[SIOP_FAMILY]
				  ,a.[CATEGORY]
				  ,a.[SUBCATEGORY]
				  ,a.[INVENTORY_ITEM_STATUS_CODE]
				  ,a.[WH_CODE]
				  ,a.[ITEM_FROZEN_COST]
				  ,a.[GL_PERIOD]
				  ,a.[PERIOD_NUM]
				  ,a.[PERIOD_YEAR]
				  ,a.[GL_DATE]
				  ,a.[QTY_INVOICED]
				  ,a.[UOM]
				  ,a.[GL_REVENUE_DISTRIBUTION]
				  ,a.[ENTERED_AMOUNT]
				  ,a.[CURRENCY]
				  ,a.[ACCTD_USD]
				  ,a.[GL_COGS_DISTRIBUTION]
				  ,a.[COGS_AMOUNT]
				  ,a.[MARGIN_USD]
				  ,a.[MARGIN_PCT]
				  ,a.[SO_LINE_ID]
				  ,a.[FRZ_COST]
				  ,a.[FRZ_MAT_COST]
				  ,a.[FRZ_MAT_OH]
				  ,a.[FRZ_RESOUCE]
				  ,a.[FRZ_OUT_PROC]
				  ,a.[FRZ_OH]	
				  ,a.[REPORTING_REVENUE_TYPE]
				  ,a.[FINGERPRINT]
				  ,$Action AS Action
		) a
		WHERE Action = 'Update'
		;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #Invoice

END
GO
