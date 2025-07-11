USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[InvoiceSep24]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InvoiceSep24] AS BEGIN

SELECT * 
INTO Oracle.InvoiceSep24
FROM OPENQUERY(PROD,
'with trx AS (
select gl.period_name period
	,trunc(gldist.gl_date) gl_date
	,case when substr(nvl(trxl.description,''xxxxxxxxxxxxxx''),1,14)=''MANUALOVERIDE.'' then 0 when substr(trxl.description,1,4)=''S2C '' then 0 when gldist.acctd_amount<0 and nvl(trxl.quantity_invoiced,0)>0 then trxl.quantity_invoiced*-1 when gldist.acctd_amount<0 and nvl(trxl.quantity_credited,0)>0 then trxl.quantity_credited*-1 when trxl.quantity_invoiced is not null then trxl.quantity_invoiced when trxl.quantity_credited is not null then trxl.quantity_credited else 0 end qty
	,gldist.amount AMT
	,gldist.acctd_amount USD
	,substr(ca.segment4,1,2) gl_filter
	,ca.segment1||''.''||ca.segment2||''.''||ca.segment3||''.''||ca.segment4||''.''||ca.segment5||''.''||ca.segment6||''.''||ca.segment7 salesHash
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
where gl.period_name = ''Sep-24''
	and nvl(trxl.interface_line_context,''xx'')<>''AR Conversion''
)
,override AS (
select period
	,gl_date
	,sum(qty) QTY
	,sum(AMT) AMT
	,sum(USD) USD
	,gl_filter
	,salesHash
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
	,salesHash
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
	,g.AMT
	,g.USD
	,case when msib.segment1 in (''ZFFF'',''ZFRT'',''ZHND'',''D2UINS'') then ''SHIPHANDLING'' when msib.segment1=''ZTAX'' then ''ZTAX'' when g.invDesc LIKE ''%FRT%MBS%'' THEN ''FRTMBS'' when substr(g.invDesc,1,7) in (''S2C DSF'',''S2C FRT'') OR g.salesHash LIKE ''%3300%'' then ''SHIPHANDLING'' when substr(g.invDesc,1,7) in (''S2C DEF'',''S2C COO'') then ''ALLOWANCE'' when substr(g.invDesc,1,7) = ''S2C TPI'' THEN ''TPI'' when substr(g.invDesc,1,4)=''S2C '' then ''S2C_ADJ_OTHER'' when g.gl_filter not in (''30'',''31'',''32'') then ''OTHER'' else ''AAA-SALES'' end revType
	,g.salesHash
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
	left join bom.cst_item_costs cic on cic.cost_type_id = 1 and nvl(msib.inventory_item_id,0)=cic.inventory_item_id and nvl(g.orgID,185)=cic.organization_id
)
, cogs AS (
select crcml.revenue_om_line_id
	,min(ca.segment1||''.''||ca.segment2||''.''||ca.segment3||''.''||ca.segment4||''.''||ca.segment5||''.''||ca.segment6||''.''||ca.segment7) cogsHash
	,sum(nvl(mta.base_transaction_value,0)) cogs_amount
from rev
	inner join bom.cst_revenue_cogs_match_lines crcml on crcml.pac_cost_type_id is null and crcml.operating_unit_id=83 and crcml.revenue_om_line_id=rev.so_line_id
	inner join bom.cst_cogs_events cce on crcml.cogs_om_line_id=cce.cogs_om_line_id and cce.event_type=3
	inner join inv.mtl_material_transactions mmt on cce.mmt_transaction_id=mmt.transaction_id
	inner join inv.mtl_transaction_accounts mta on mmt.transaction_id=mta.transaction_id
	inner join gl.gl_code_combinations ca on mta.reference_account=ca.code_combination_id
where mta.accounting_line_type=35
	and mta.reference_account in (4212,4213,103126)
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
	,r.salesHash
	,r.AMT
	,trxh.invoice_currency_code
	,r.USD
	,cogs.cogsHash
	,cogs.cogs_amount
	,r.amt-cogs.cogs_amount
	,case when r.amt=0 then null when cogs.cogs_amount=0 then null else round((r.amt-cogs.cogs_amount)/r.amt*100,1) end
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
	left join ont.oe_order_lines_all ool on ool.org_id=83 and nvl(r.so_line_id, 0 )=to_char(ool.line_id)
	left join ont.oe_order_headers_all ooh on nvl(ool.header_id,0)=ooh.header_id
	left join cogs on nvl(to_char(r.so_line_id),''xx'')=to_char(cogs.revenue_om_line_id) and r.qty > 0
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

END
GO
