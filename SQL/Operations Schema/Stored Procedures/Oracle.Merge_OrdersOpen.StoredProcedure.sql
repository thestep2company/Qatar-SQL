USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_OrdersOpen]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_OrdersOpen]
AS BEGIN

	BEGIN TRY 

		BEGIN TRAN

		TRUNCATE TABLE Oracle.OrdersOpen
	
		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

		INSERT INTO Oracle.OrdersOpen
		SELECT *	
		FROM OPENQUERY(PROD,	
		'
		select	
					ool.line_id  AS ORD_LINE_ID 
					, ool.header_id AS ORD_HEADER_ID 
					, hca.account_name AS CUSTOMER_NAME 
					, hca.account_number AS CUSTOMER_NUM 
					, nvl(hca.sales_channel_code,''missing'') AS SALES_CHANNEL_CODE 
					, nvl(billto.demand_class_code,nvl(ool.demand_class_code,''missing'')) AS DEMAND_CLASS 
					, TO_CHAR(ooh.ordered_date, ''MM/DD/YYYY HH24:MI:SS'') AS ORDER_DATE 
					, ool.line_number AS ORDER_LINE_NUM
					, ooh.order_number AS ORDER_NUM 
					, msib.segment1  AS PART 
					, ool.ordered_item  AS ORDERED_ITEM 
					, msib.description  AS PART_DESC 
					, ool.flow_status_code  AS FLOW_STATUS_CODE 
					, nvl(ool.ordered_quantity,0) AS QTY 
					, ROUND(nvl(ool.ordered_quantity,0) * nvl(ool.unit_selling_price,0),2) AS SELL_DOLLARS 
					, ROUND(nvl(ool.ordered_quantity,0) * nvl(ool.unit_list_price,0),2) AS LIST_DOLLARS 
					, TO_CHAR(ool.request_date, ''MM/DD/YYYY'') AS DATE_REQUESTED 
					, TO_CHAR(ool.schedule_ship_date, ''MM/DD/YYYY'') AS SCH_SHIP_DATE 
					, TO_CHAR(ool.latest_acceptable_date, ''MM/DD/YYYY'') AS CANCEL_DATE 
					, nvl(wh.organization_code,''n/a'')  AS PLANT 
					, TO_CHAR(ooh.creation_date, ''MM/DD/YYYY'') AS create_date 
					, TO_CHAR(ool.creation_date, ''MM/DD/YYYY'')    AS ORD_LINE_CREATE_DATE 
					, TO_CHAR(ool.LAST_UPDATE_DATE, ''MM/DD/YYYY'') AS ORD_LINE_LST_UPDATE_DATE 
					, shipto_l.Address1      as ship_to_Address1 
					, shipto_l.Address2      as ship_to_Address2  
					, shipto_l.Address3      as ship_to_Address3  
					, shipto_l.Address4      as ship_to_Address4  
					, shipto_l.city          as ship_to_City 
					, shipto_l.state         as ship_to_State 
					, shipto_l.postal_code   as ship_to_Postal_Code 
					, shipto_l.country       as ship_to_Country 
					, shipto_l.province      as ship_to_Province 
					, ool.SHIPPING_METHOD_CODE
					, ooh.CUST_PO_NUMBER
					, ooh.transactional_curr_code AS currency
					, TO_CHAR(ool.actual_shipment_date, ''MM/DD/YYYY'') AS ACTUAL_SHIPMENT_DATE
		from 
					ont.oe_order_lines_all ool 
					inner join ont.oe_order_headers_all ooh on ool.org_id = 83 and ooh.org_id = 83 and ooh.header_id = ool.header_id 
					inner join ar.hz_cust_accounts hca on ooh.sold_to_org_id = hca.cust_account_id 
					inner join inv.mtl_system_items_b msib on ool.inventory_item_id = msib.inventory_item_id and nvl(ool.ship_from_org_id,85) = msib.organization_id 
					left join ar.hz_cust_site_uses_all billto on nvl(ooh.invoice_to_org_id,0) = billto.site_use_id 
					left join inv.mtl_parameters wh on nvl(ool.ship_from_org_id,0) = wh.organization_id 
					left join ar.hz_cust_site_uses_all shipto on nvl(ool.ship_to_org_id,0) = shipto.site_use_id 
					left join ar.hz_cust_acct_sites_all shipto_a on shipto.cust_acct_site_id = shipto_a.cust_acct_site_id 
					left join ar.hz_party_sites shipto_p on shipto_p.party_site_id = shipto_a.party_site_id 
					left join ar.hz_locations shipto_l on shipto_p.location_id = shipto_l.location_id 
		where ool.link_to_line_id is NULL 
					and nvl(ool.inventory_item_id,0) not in (select distinct msib.inventory_item_id from inv.mtl_system_items_b msib where msib.segment1 in (''ZFFF'',''ZFRT'',''ZHND'',''D2UINS'',''ZTAX'')) 
					--Oracle Logic
					AND ooh.ordered_date >= TO_DATE(''20190101'',''YYYYMMDD'')
					AND ool.flow_status_code <> ''CLOSED''
					AND ool.FLOW_STATUS_CODE <> ''CANCELLED''
		'
		)
		
		UPDATE i SET FLOW_STATUS_CODE = 'DELETED', EndDate = GETDATE(), CurrentRecord = 0
		FROM Oracle.Orders i 
			LEFT JOIN Oracle.OrdersOpen o ON i.Ord_Line_ID = o.Ord_Line_ID AND i.Ord_Header_ID = o.Ord_Header_ID 
			LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(i.ORDER_DATE AS DATE) = cf.DateKey 
		WHERE i.CurrentRecord = 1 
			AND CAST(i.ORDER_DATE AS DATE) < CAST(GETDATE() AS DATE)
			AND i.StartDate < CAST(GETDATE() AS DATE)
			AND o.ORD_LINE_ID IS NULL
			AND i.FLOW_STATUS_CODE NOT IN ('CLOSED','CANCELLED','DELETED')
			AND EndDate IS NULL

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		COMMIT TRAN
	END TRY

	BEGIN CATCH
	    DECLARE @ErrorMessage NVARCHAR(4000)
		DECLARE @ErrorSeverity INT
		DECLARE @ErrorState INT

		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()

		--RAISEERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
		SELECT @ErrorMessage, @ErrorSeverity, @ErrorState
		
	END CATCH
END


GO
