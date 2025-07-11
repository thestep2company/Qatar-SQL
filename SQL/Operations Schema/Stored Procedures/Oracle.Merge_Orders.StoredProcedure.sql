USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Orders]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Orders] AS BEGIN

	CREATE TABLE #Orders(
		[ORD_LINE_ID] [float] NOT NULL,
		[ORD_HEADER_ID] [float] NOT NULL,
		[CUSTOMER_NAME] [nvarchar](240) NULL,
		[CUSTOMER_NUM] [nvarchar](30) NOT NULL,
		[SALES_CHANNEL_CODE] [nvarchar](30) NULL,
		[DEMAND_CLASS] [nvarchar](30) NULL,
		[ORDER_DATE] [nvarchar](19) NULL,
		[ORDER_LINE_NUM] [float] NULL,
		[ORDER_NUM] [float] NOT NULL,
		[PART] [nvarchar](40) NULL,
		[ORDERED_ITEM] [nvarchar](2000) NULL,
		[PART_DESC] [nvarchar](240) NULL,
		[FLOW_STATUS_CODE] [nvarchar](30) NULL,
		[QTY] [float] NULL,
		[SELL_DOLLARS] [float] NULL,
		[LIST_DOLLARS] [float] NULL,
		[DATE_REQUESTED] [nvarchar](10) NULL,
		[SCH_SHIP_DATE] [nvarchar](10) NULL,
		[CANCEL_DATE] [nvarchar](10) NULL,
		[ACTUAL_SHIPMENT_DATE] [nvarchar](10) NULL,
		[PLANT] [nvarchar](3) NULL,
		[CREATE_DATE] [nvarchar](10) NULL,
		[ORD_LINE_CREATE_DATE] [nvarchar](10) NULL,
		[ORD_LINE_LST_UPDATE_DATE] [nvarchar](10) NULL,
		[SHIP_TO_ADDRESS1] [nvarchar](240) NULL,
		[SHIP_TO_ADDRESS2] [nvarchar](240) NULL,
		[SHIP_TO_ADDRESS3] [nvarchar](240) NULL,
		[SHIP_TO_ADDRESS4] [nvarchar](240) NULL,
		[SHIP_TO_CITY] [nvarchar](60) NULL,
		[SHIP_TO_STATE] [nvarchar](60) NULL,
		[SHIP_TO_POSTAL_CODE] [nvarchar](60) NULL,
		[SHIP_TO_COUNTRY] [nvarchar](60) NULL,
		[SHIP_TO_PROVINCE] [nvarchar](60) NULL,
		[SHIPPING_METHOD_CODE] [nvarchar](30) NULL,
		[CURRENCY] [nvarchar](15) NULL,
		[CUST_PO_NUMBER] [nvarchar](50) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) 

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #Orders (
		   [ORD_LINE_ID]
		  ,[ORD_HEADER_ID]
		  ,[CUSTOMER_NAME]
		  ,[CUSTOMER_NUM]
		  ,[SALES_CHANNEL_CODE]
		  ,[DEMAND_CLASS]
		  ,[ORDER_DATE]
		  ,[ORDER_LINE_NUM]
		  ,[ORDER_NUM]
		  ,[PART]
		  ,[ORDERED_ITEM]
		  ,[PART_DESC]
		  ,[FLOW_STATUS_CODE]
		  ,[QTY]
		  ,[SELL_DOLLARS]
		  ,[LIST_DOLLARS]
		  ,[DATE_REQUESTED]
		  ,[SCH_SHIP_DATE]
		  ,[CANCEL_DATE]
		  ,[ACTUAL_SHIPMENT_DATE]
		  ,[PLANT]
		  ,[CREATE_DATE]
		  ,[ORD_LINE_CREATE_DATE]
		  ,[ORD_LINE_LST_UPDATE_DATE]
		  ,[SHIP_TO_ADDRESS1]
		  ,[SHIP_TO_ADDRESS2]
		  ,[SHIP_TO_ADDRESS3]
		  ,[SHIP_TO_ADDRESS4]
		  ,[SHIP_TO_CITY]
		  ,[SHIP_TO_STATE]
		  ,[SHIP_TO_POSTAL_CODE]
		  ,[SHIP_TO_COUNTRY]
		  ,[SHIP_TO_PROVINCE]
		  ,[SHIPPING_METHOD_CODE]
		  ,[Currency]
		  ,[CUST_PO_NUMBER]
		  ,[Fingerprint]
	)
	SELECT
		   [ORD_LINE_ID]
		  ,[ORD_HEADER_ID]
		  ,[CUSTOMER_NAME]
		  ,[CUSTOMER_NUM]
		  ,[SALES_CHANNEL_CODE]
		  ,[DEMAND_CLASS]
		  ,[ORDER_DATE]
		  ,[ORDER_LINE_NUM]
		  ,[ORDER_NUM]
		  ,[PART]
		  ,[ORDERED_ITEM]
		  ,[PART_DESC]
		  ,[FLOW_STATUS_CODE]
		  ,[QTY]
		  ,[SELL_DOLLARS]
		  ,[LIST_DOLLARS]
		  ,[DATE_REQUESTED]
		  ,[SCH_SHIP_DATE]
		  ,[CANCEL_DATE]
		  ,[ACTUAL_SHIPMENT_DATE]
		  ,[PLANT]
		  ,[CREATE_DATE]
		  ,[ORD_LINE_CREATE_DATE]
		  ,[ORD_LINE_LST_UPDATE_DATE]
		  ,[SHIP_TO_ADDRESS1]
		  ,[SHIP_TO_ADDRESS2]
		  ,[SHIP_TO_ADDRESS3]
		  ,[SHIP_TO_ADDRESS4]
		  ,[SHIP_TO_CITY]
		  ,[SHIP_TO_STATE]
		  ,[SHIP_TO_POSTAL_CODE]
		  ,[SHIP_TO_COUNTRY]
		  ,[SHIP_TO_PROVINCE]
		  ,[SHIPPING_METHOD_CODE]
		  ,[CURRENCY]
		  ,[CUST_PO_NUMBER]
		  ,'XXX' AS [Fingerprint]
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
					, TO_CHAR(ool.actual_shipment_date, ''MM/DD/YYYY'') AS ACTUAL_SHIPMENT_DATE
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
					, ooh.transactional_curr_code AS currency
					, ooh.CUST_PO_NUMBER
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
					and (ool.LAST_UPDATE_DATE >= sysdate - 7)
					--OR ool.creation_date >= sysdate - 7)
					--and ooh.creation_date >= TO_DATE(''20170101'',''YYYYMMDD'') and ooh.creation_date < TO_DATE(''20171001'',''YYYYMMDD'')
		'
	)

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Orders','Oracle') SELECT @columnList
	*/
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()
	
	UPDATE #orders
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
					   CAST(ISNULL([ORD_LINE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORD_HEADER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([CUSTOMER_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([CUSTOMER_NUM],'') AS VARCHAR(30)) +  CAST(ISNULL([SALES_CHANNEL_CODE],'') AS VARCHAR(30)) +  CAST(ISNULL([DEMAND_CLASS],'') AS VARCHAR(30)) +  CAST(ISNULL([ORDER_DATE],'') AS VARCHAR(19)) +  CAST(ISNULL([ORDER_NUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([PART],'') AS VARCHAR(40)) +  CAST(ISNULL([ORDERED_ITEM],'') AS VARCHAR(2000)) +  CAST(ISNULL([PART_DESC],'') AS VARCHAR(240)) +  CAST(ISNULL([FLOW_STATUS_CODE],'') AS VARCHAR(30)) +  CAST(ISNULL([QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([SELL_DOLLARS],'0') AS VARCHAR(100)) +  CAST(ISNULL([LIST_DOLLARS],'0') AS VARCHAR(100)) +  CAST(ISNULL([DATE_REQUESTED],'') AS VARCHAR(10)) +  CAST(ISNULL([SCH_SHIP_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([CANCEL_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([PLANT],'') AS VARCHAR(3)) +  CAST(ISNULL([CREATE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([ORD_LINE_CREATE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([ORD_LINE_LST_UPDATE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([SHIP_TO_ADDRESS1],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_ADDRESS2],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_ADDRESS3],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_ADDRESS4],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_CITY],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_STATE],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_POSTAL_CODE],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_COUNTRY],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_PROVINCE],'') AS VARCHAR(60)) +  CAST(ISNULL([ACTUAL_SHIPMENT_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([ORDER_LINE_NUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([SHIPPING_METHOD_CODE],'') AS VARCHAR(30)) +  CAST(ISNULL([Currency],'') AS VARCHAR(15)) +  CAST(ISNULL([CUST_PO_NUMBER],'') AS VARCHAR(50)) 
					   --CAST(ISNULL([ORD_LINE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORD_HEADER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([CUSTOMER_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([CUSTOMER_NUM],'') AS VARCHAR(30)) +  CAST(ISNULL([SALES_CHANNEL_CODE],'') AS VARCHAR(30)) +  CAST(ISNULL([DEMAND_CLASS],'') AS VARCHAR(30)) +  CAST(ISNULL([ORDER_DATE],'') AS VARCHAR(19)) +  CAST(ISNULL([ORDER_NUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([PART],'') AS VARCHAR(40)) +  CAST(ISNULL([ORDERED_ITEM],'') AS VARCHAR(2000)) +  CAST(ISNULL([PART_DESC],'') AS VARCHAR(240)) +  CAST(ISNULL([FLOW_STATUS_CODE],'') AS VARCHAR(30)) +  CAST(ISNULL([QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([SELL_DOLLARS],'0') AS VARCHAR(100)) +  CAST(ISNULL([LIST_DOLLARS],'0') AS VARCHAR(100)) +  CAST(ISNULL([DATE_REQUESTED],'') AS VARCHAR(10)) +  CAST(ISNULL([SCH_SHIP_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([CANCEL_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([PLANT],'') AS VARCHAR(3)) +  CAST(ISNULL([CREATE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([ORD_LINE_CREATE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([ORD_LINE_LST_UPDATE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([SHIP_TO_ADDRESS1],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_ADDRESS2],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_ADDRESS3],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_ADDRESS4],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_CITY],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_STATE],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_POSTAL_CODE],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_COUNTRY],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_PROVINCE],'') AS VARCHAR(60)) +  CAST(ISNULL([ACTUAL_SHIPMENT_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([ORDER_LINE_NUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([SHIPPING_METHOD_CODE],'') AS VARCHAR(30)) +  CAST(ISNULL([Currency],'') AS VARCHAR(15)) 
					  --CAST(ISNULL([ORD_LINE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORD_HEADER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([CUSTOMER_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([CUSTOMER_NUM],'') AS VARCHAR(30)) +  CAST(ISNULL([SALES_CHANNEL_CODE],'') AS VARCHAR(30)) +  CAST(ISNULL([DEMAND_CLASS],'') AS VARCHAR(30)) +  CAST(ISNULL([ORDER_DATE],'') AS VARCHAR(19)) +  CAST(ISNULL([ORDER_NUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([PART],'') AS VARCHAR(40)) +  CAST(ISNULL([ORDERED_ITEM],'') AS VARCHAR(2000)) +  CAST(ISNULL([PART_DESC],'') AS VARCHAR(240)) +  CAST(ISNULL([FLOW_STATUS_CODE],'') AS VARCHAR(30)) +  CAST(ISNULL([QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([SELL_DOLLARS],'0') AS VARCHAR(100)) +  CAST(ISNULL([LIST_DOLLARS],'0') AS VARCHAR(100)) +  CAST(ISNULL([DATE_REQUESTED],'') AS VARCHAR(10)) +  CAST(ISNULL([SCH_SHIP_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([CANCEL_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([PLANT],'') AS VARCHAR(3)) +  CAST(ISNULL([CREATE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([ORD_LINE_CREATE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([ORD_LINE_LST_UPDATE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([SHIP_TO_ADDRESS1],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_ADDRESS2],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_ADDRESS3],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_ADDRESS4],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_CITY],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_STATE],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_POSTAL_CODE],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_COUNTRY],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_PROVINCE],'') AS VARCHAR(60)) +  CAST(ISNULL([ACTUAL_SHIPMENT_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([SHIPPING_METHOD_CODE],'') AS VARCHAR(30)) 
					  --CAST(ISNULL([ORD_LINE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORD_HEADER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([CUSTOMER_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([CUSTOMER_NUM],'') AS VARCHAR(30)) +  CAST(ISNULL([SALES_CHANNEL_CODE],'') AS VARCHAR(30)) +  CAST(ISNULL([DEMAND_CLASS],'') AS VARCHAR(30)) +  CAST(ISNULL([ORDER_DATE],'') AS VARCHAR(19)) +  CAST(ISNULL([ORDER_NUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([PART],'') AS VARCHAR(40)) +  CAST(ISNULL([ORDERED_ITEM],'') AS VARCHAR(2000)) +  CAST(ISNULL([PART_DESC],'') AS VARCHAR(240)) +  CAST(ISNULL([FLOW_STATUS_CODE],'') AS VARCHAR(30)) +  CAST(ISNULL([QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([SELL_DOLLARS],'0') AS VARCHAR(100)) +  CAST(ISNULL([LIST_DOLLARS],'0') AS VARCHAR(100)) +  CAST(ISNULL([DATE_REQUESTED],'') AS VARCHAR(10)) +  CAST(ISNULL([SCH_SHIP_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([CANCEL_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([PLANT],'') AS VARCHAR(3)) +  CAST(ISNULL([CREATE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([ORD_LINE_CREATE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([ORD_LINE_LST_UPDATE_DATE],'') AS VARCHAR(10)) +  CAST(ISNULL([SHIP_TO_ADDRESS1],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_ADDRESS2],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_ADDRESS3],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_ADDRESS4],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO_CITY],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_STATE],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_POSTAL_CODE],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_COUNTRY],'') AS VARCHAR(60)) +  CAST(ISNULL([SHIP_TO_PROVINCE],'') AS VARCHAR(60)) +  CAST(ISNULL([ACTUAL_SHIPMENT_DATE],'') AS VARCHAR(10)) 
		),1)),3,32);


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.Orders (
	   [ORD_LINE_ID]
      ,[ORD_HEADER_ID]
      ,[CUSTOMER_NAME]
      ,[CUSTOMER_NUM]
      ,[SALES_CHANNEL_CODE]
      ,[DEMAND_CLASS]
      ,[ORDER_DATE]
	  ,[ORDER_LINE_NUM]
      ,[ORDER_NUM]
      ,[PART]
      ,[ORDERED_ITEM]
      ,[PART_DESC]
      ,[FLOW_STATUS_CODE]
      ,[QTY]
      ,[SELL_DOLLARS]
      ,[LIST_DOLLARS]
      ,[DATE_REQUESTED]
      ,[SCH_SHIP_DATE]
      ,[CANCEL_DATE]
	  ,[ACTUAL_SHIPMENT_DATE]
      ,[PLANT]
      ,[CREATE_DATE]
      ,[ORD_LINE_CREATE_DATE]
      ,[ORD_LINE_LST_UPDATE_DATE]
      ,[SHIP_TO_ADDRESS1]
      ,[SHIP_TO_ADDRESS2]
      ,[SHIP_TO_ADDRESS3]
      ,[SHIP_TO_ADDRESS4]
      ,[SHIP_TO_CITY]
      ,[SHIP_TO_STATE]
      ,[SHIP_TO_POSTAL_CODE]
      ,[SHIP_TO_COUNTRY]
      ,[SHIP_TO_PROVINCE]
	  ,[SHIPPING_METHOD_CODE]
	  ,[CURRENCY]
	  ,[CUST_PO_NUMBER]
      ,[Fingerprint]
	)
		SELECT 
				   a.[ORD_LINE_ID]
				  ,a.[ORD_HEADER_ID]
				  ,a.[CUSTOMER_NAME]
				  ,a.[CUSTOMER_NUM]
				  ,a.[SALES_CHANNEL_CODE]
				  ,a.[DEMAND_CLASS]
				  ,a.[ORDER_DATE]
				  ,a.[ORDER_LINE_NUM]
				  ,a.[ORDER_NUM]
				  ,a.[PART]
				  ,a.[ORDERED_ITEM]
				  ,a.[PART_DESC]
				  ,a.[FLOW_STATUS_CODE]
				  ,a.[QTY]
				  ,a.[SELL_DOLLARS]
				  ,a.[LIST_DOLLARS]
				  ,a.[DATE_REQUESTED]
				  ,a.[SCH_SHIP_DATE]
				  ,a.[CANCEL_DATE]
				  ,a.[ACTUAL_SHIPMENT_DATE]
				  ,a.[PLANT]
				  ,a.[CREATE_DATE]
				  ,a.[ORD_LINE_CREATE_DATE]
				  ,a.[ORD_LINE_LST_UPDATE_DATE]
				  ,a.[SHIP_TO_ADDRESS1]
				  ,a.[SHIP_TO_ADDRESS2]
				  ,a.[SHIP_TO_ADDRESS3]
				  ,a.[SHIP_TO_ADDRESS4]
				  ,a.[SHIP_TO_CITY]
				  ,a.[SHIP_TO_STATE]
				  ,a.[SHIP_TO_POSTAL_CODE]
				  ,a.[SHIP_TO_COUNTRY]
				  ,a.[SHIP_TO_PROVINCE]
				  ,a.[SHIPPING_METHOD_CODE]
				  ,a.[CURRENCY]
				  ,a.[CUST_PO_NUMBER]
				  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.Orders b
				USING (SELECT * FROM #orders) a
				ON a.[ORD_LINE_ID] = b.[ORD_LINE_ID] AND a.[ORD_HEADER_ID] = b.[ORD_HEADER_ID] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [ORD_LINE_ID]
					  ,[ORD_HEADER_ID]
					  ,[CUSTOMER_NAME]
					  ,[CUSTOMER_NUM]
					  ,[SALES_CHANNEL_CODE]
					  ,[DEMAND_CLASS]
					  ,[ORDER_DATE]
					  ,[ORDER_LINE_NUM]
					  ,[ORDER_NUM]
					  ,[PART]
					  ,[ORDERED_ITEM]
					  ,[PART_DESC]
					  ,[FLOW_STATUS_CODE]
					  ,[QTY]
					  ,[SELL_DOLLARS]
					  ,[LIST_DOLLARS]
					  ,[DATE_REQUESTED]
					  ,[SCH_SHIP_DATE]
					  ,[CANCEL_DATE]
					  ,[ACTUAL_SHIPMENT_DATE]
					  ,[PLANT]
					  ,[CREATE_DATE]
					  ,[ORD_LINE_CREATE_DATE]
					  ,[ORD_LINE_LST_UPDATE_DATE]
					  ,[SHIP_TO_ADDRESS1]
					  ,[SHIP_TO_ADDRESS2]
					  ,[SHIP_TO_ADDRESS3]
					  ,[SHIP_TO_ADDRESS4]
					  ,[SHIP_TO_CITY]
					  ,[SHIP_TO_STATE]
					  ,[SHIP_TO_POSTAL_CODE]
					  ,[SHIP_TO_COUNTRY]
					  ,[SHIP_TO_PROVINCE]
					  ,[SHIPPING_METHOD_CODE]
					  ,[CURRENCY]
					  ,[CUST_PO_NUMBER]
					  ,[Fingerprint]
			)
			VALUES (
				   a.[ORD_LINE_ID]
				  ,a.[ORD_HEADER_ID]
				  ,a.[CUSTOMER_NAME]
				  ,a.[CUSTOMER_NUM]
				  ,a.[SALES_CHANNEL_CODE]
				  ,a.[DEMAND_CLASS]
				  ,a.[ORDER_DATE]
				  ,a.[ORDER_LINE_NUM]
				  ,a.[ORDER_NUM]
				  ,a.[PART]
				  ,a.[ORDERED_ITEM]
				  ,a.[PART_DESC]
				  ,a.[FLOW_STATUS_CODE]
				  ,a.[QTY]
				  ,a.[SELL_DOLLARS]
				  ,a.[LIST_DOLLARS]
				  ,a.[DATE_REQUESTED]
				  ,a.[SCH_SHIP_DATE]
				  ,a.[CANCEL_DATE]
				  ,a.[ACTUAL_SHIPMENT_DATE]
				  ,a.[PLANT]
				  ,a.[CREATE_DATE]
				  ,a.[ORD_LINE_CREATE_DATE]
				  ,a.[ORD_LINE_LST_UPDATE_DATE]
				  ,a.[SHIP_TO_ADDRESS1]
				  ,a.[SHIP_TO_ADDRESS2]
				  ,a.[SHIP_TO_ADDRESS3]
				  ,a.[SHIP_TO_ADDRESS4]
				  ,a.[SHIP_TO_CITY]
				  ,a.[SHIP_TO_STATE]
				  ,a.[SHIP_TO_POSTAL_CODE]
				  ,a.[SHIP_TO_COUNTRY]
				  ,a.[SHIP_TO_PROVINCE]
				  ,a.[SHIPPING_METHOD_CODE]
				  ,a.[CURRENCY]
				  ,a.[CUST_PO_NUMBER]
				  ,a.[Fingerprint]
			)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
			THEN UPDATE SET b.EndDate=GETDATE()
				,b.CurrentRecord=0
			OUTPUT 
				   a.[ORD_LINE_ID]
				  ,a.[ORD_HEADER_ID]
				  ,a.[CUSTOMER_NAME]
				  ,a.[CUSTOMER_NUM]
				  ,a.[SALES_CHANNEL_CODE]
				  ,a.[DEMAND_CLASS]
				  ,a.[ORDER_DATE]
				  ,a.[ORDER_LINE_NUM]
				  ,a.[ORDER_NUM]
				  ,a.[PART]
				  ,a.[ORDERED_ITEM]
				  ,a.[PART_DESC]
				  ,a.[FLOW_STATUS_CODE]
				  ,a.[QTY]
				  ,a.[SELL_DOLLARS]
				  ,a.[LIST_DOLLARS]
				  ,a.[DATE_REQUESTED]
				  ,a.[SCH_SHIP_DATE]
				  ,a.[CANCEL_DATE]
				  ,a.[ACTUAL_SHIPMENT_DATE]
				  ,a.[PLANT]
				  ,a.[CREATE_DATE]
				  ,a.[ORD_LINE_CREATE_DATE]
				  ,a.[ORD_LINE_LST_UPDATE_DATE]
				  ,a.[SHIP_TO_ADDRESS1]
				  ,a.[SHIP_TO_ADDRESS2]
				  ,a.[SHIP_TO_ADDRESS3]
				  ,a.[SHIP_TO_ADDRESS4]
				  ,a.[SHIP_TO_CITY]
				  ,a.[SHIP_TO_STATE]
				  ,a.[SHIP_TO_POSTAL_CODE]
				  ,a.[SHIP_TO_COUNTRY]
				  ,a.[SHIP_TO_PROVINCE]
				  ,a.[SHIPPING_METHOD_CODE]
				  ,a.[CURRENCY]
				  ,a.[CUST_PO_NUMBER]
				  ,a.[Fingerprint]
				  ,$Action AS Action
		) a
		WHERE Action = 'Update'
		;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #orders

END
GO
