USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_ShippingDetails]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_ShippingDetails] AS BEGIN

		CREATE TABLE #ShippingDetails (
			[CUSTOMER_NAME] [nvarchar](360) NULL,
			[CUSTOMER_NUM] [nvarchar](30) NULL,
			[CUST_PO_NUMBER] [nvarchar](50) NULL,
			[ORDER_DATE] [nvarchar](10) NULL,
			[QUANTITY_ORDERED] [float] NULL,
			[PART] [nvarchar](40) NULL,
			[PART_DESC] [nvarchar](240) NULL,
			[SHIPPED_QTY] [float] NULL,
			[DATEREQUESTED] [nvarchar](10) NULL,
			[SCHSHIPDATE] [nvarchar](10) NULL,
			[ACTUAL_SHIP_DATE] [nvarchar](10) NULL,
			[Fingerprint] [varchar](32) NOT NULL
		)

		INSERT INTO #ShippingDetails (
			   [CUSTOMER_NAME]
			  ,[CUSTOMER_NUM]
			  ,[CUST_PO_NUMBER]
			  ,[ORDER_DATE]
			  ,[QUANTITY_ORDERED]
			  ,[PART]
			  ,[PART_DESC]
			  ,[SHIPPED_QTY]
			  ,[DATEREQUESTED]
			  ,[SCHSHIPDATE]
			  ,[ACTUAL_SHIP_DATE]
			  ,[Fingerprint]
		)
		SELECT Customer_Name
			,Customer_Num
			,Cust_PO_Number
			,Order_Date
			,MAX(Quantity_Ordered)
			,Part
			,Part_Desc
			,SUM(Shipped_Qty)
			,DateRequested
			,Schshipdate
			,actual_ship_Date
			, 'XXXXXXXX' AS Fingerprint
		FROM OPENQUERY(PROD,
		'
		SELECT                                                                                                                                                                                                                                                                                               
				nvl (hca.account_name, hp.party_name)                        customer_name, 
				hca.account_number											 customer_num,
				ooh.cust_po_number                                           cust_po_number, 
				TO_CHAR(ooh.ordered_date, ''YYYY/MM/DD'')                    order_date,
				sum(ordered_quantity)                                        quantity_ordered,
				msi.segment1                                                 part, 
				msi.description                                              part_desc, 
				SUM(wdd.shipped_quantity)                                    shipped_qty,  
				TO_CHAR(wdd.date_requested, ''YYYY/MM/DD'')                  daterequested, 
				TO_CHAR(wdd.date_scheduled, ''YYYY/MM/DD'')                  schshipdate, 
				TO_CHAR(ool.actual_shipment_date, ''YYYY/MM/DD'')            actual_ship_date
		FROM    oe_order_headers_all				ooh 
				LEFT JOIN oe_order_lines_all		ool		ON ooh.header_id = ool.header_id AND ool.org_id = 83
				LEFT JOIN hz_cust_accounts			hca		ON hca.cust_account_id = ooh.sold_to_org_id 
				LEFT JOIN hz_parties				hp		ON hp.party_id = hca.party_id 
				LEFT JOIN wsh_delivery_details		wdd		ON wdd.source_header_id = ooh.header_id AND wdd.source_line_id = ool.line_id 
				LEFT JOIN wsh_delivery_assignments  wda		ON wdd.delivery_Detail_id = wda.delivery_Detail_id 
				LEFT JOIN wsh_new_deliveries        wnd		ON wnd.delivery_id = wda.delivery_id 
				LEFT JOIN mtl_system_items          msi		ON NVL(ool.ship_from_org_id, 85) = msi.organization_id AND msi.inventory_item_id = ool.inventory_item_id 
				LEFT JOIN mtl_parameters            mp		ON mp.organization_id = NVL(ool.ship_from_org_id, 85)
				LEFT JOIN hz_cust_site_uses_all     hsua	ON hsua.site_use_id = ooh.invoice_to_org_id 
				LEFT JOIN ra_territories            rt		ON rt.territory_id  = hsua.territory_id 
				LEFT JOIN ra_salesreps              rsa		ON rsa.salesrep_id = hsua.primary_salesrep_id 
				LEFT JOIN hz_locations              loc		ON wdd.ship_to_location_id  = loc.location_id 
				LEFT JOIN wsh_carrier_services      wcs     ON wnd.ship_method_code = wcs.ship_method_code    
		WHERE   
				ooh.org_id = 83
				AND wdd.source_code = ''OE'' AND wdd.released_status = ''C'' AND hsua.org_id = 83 AND hsua.site_use_code = ''BILL_TO''
				AND ool.request_date BETWEEN TO_DATE(''2021/12/31 00:00:00'', ''YYYY/MM/DD HH24:MI:SS'')                                                                                                                          
				AND TO_DATE(TO_CHAR(TO_DATE(''2023/12/31 00:00:00'', ''YYYY/MM/DD HH24:MI:SS''), ''YYYY/MM/DD'') || '' 23:59:59'', ''YYYY/MM/DD HH24:MI:SS'') 
		GROUP BY msi.segment1, 
				mp.organization_code, 
				msi.description, 
				hca.account_number, 
				hca.account_name,
				hca.attribute4,
				hca.attribute5, 
				rt.name,
				rsa.name,
				--ppf.email_address,            
				hca.attribute15,                                                
				hp.party_name, 
				ooh.order_number, 
				TO_CHAR(ooh.ordered_date, ''YYYY/MM/DD''), 
				TO_CHAR(wdd.date_requested, ''YYYY/MM/DD''), 
				TO_CHAR(wdd.date_scheduled, ''YYYY/MM/DD''), 
				TO_CHAR(ool.latest_acceptable_date, ''YYYY/MM/DD''), 
				TO_CHAR(ool.actual_shipment_date, ''YYYY/MM/DD''),
				wnd.name, 
				loc.address1, 
				loc.address2, 
				loc.city, 
				loc.state, 
				loc.postal_code, 
				loc.country, 
				ooh.cust_po_number, 
				wnd.attribute1 , 
				wnd.attribute2 , 
				wnd.attribute12 , 
				wcs.ship_method_meaning , 
				wdd.tracking_number, 
				wnd.waybill,
				ooh.tp_attribute7
		'
		 )
		 GROUP BY 
			 Customer_Name
			,Customer_Num
			,Cust_PO_Number
			,Order_Date
			,Part
			,Part_Desc
			,DateRequested
			,Schshipdate
			,actual_ship_Date


		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('ShippingDetails','Oracle') SELECT @columnList
		*/
		UPDATE #shippingDetails
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
					   CAST(ISNULL(CUSTOMER_NAME,'') AS VARCHAR(360)) +  CAST(ISNULL(CUSTOMER_NUM,'') AS VARCHAR(30)) +  CAST(ISNULL(CUST_PO_NUMBER,'') AS VARCHAR(50)) +  CAST(ISNULL(ORDER_DATE,'') AS VARCHAR(10)) +  CAST(ISNULL(QUANTITY_ORDERED,'0') AS VARCHAR(100)) +  CAST(ISNULL(PART,'') AS VARCHAR(40)) +  CAST(ISNULL(PART_DESC,'') AS VARCHAR(240)) +  CAST(ISNULL(SHIPPED_QTY,'0') AS VARCHAR(100)) +  CAST(ISNULL(DATEREQUESTED,'') AS VARCHAR(10)) +  CAST(ISNULL(SCHSHIPDATE,'') AS VARCHAR(10)) +  CAST(ISNULL(ACTUAL_SHIP_DATE,'') AS VARCHAR(10)) 
			),1)),3,32);

		--expire records outside the merge


		INSERT INTO Oracle.ShippingDetails (
			   [CUSTOMER_NAME]
			  ,[CUSTOMER_NUM]
			  ,[CUST_PO_NUMBER]
			  ,[ORDER_DATE]
			  ,[QUANTITY_ORDERED]
			  ,[PART]
			  ,[PART_DESC]
			  ,[SHIPPED_QTY]
			  ,[DATEREQUESTED]
			  ,[SCHSHIPDATE]
			  ,[ACTUAL_SHIP_DATE]
			  ,[FINGERPRINT]
		)
			SELECT 
				   a.[CUSTOMER_NAME]
				  ,a.[CUSTOMER_NUM]
				  ,a.[CUST_PO_NUMBER]
				  ,a.[ORDER_DATE]
				  ,a.[QUANTITY_ORDERED]
				  ,a.[PART]
				  ,a.[PART_DESC]
				  ,a.[SHIPPED_QTY]
				  ,a.[DATEREQUESTED]
				  ,a.[SCHSHIPDATE]
				  ,a.[ACTUAL_SHIP_DATE]
				  ,a.[FINGERPRINT]
			FROM (
				MERGE Oracle.ShippingDetails b
				USING (SELECT * FROM #ShippingDetails) a
				ON a.[CUST_PO_NUMBER] = b.[CUST_PO_NUMBER]
					AND a.[ORDER_DATE] = b.[ORDER_DATE]
					AND a.[DATEREQUESTED] = b.[DATEREQUESTED]
					AND a.[QUANTITY_ORDERED] = b.[QUANTITY_ORDERED]
					AND a.[PART] = b.[PART]
					AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [CUSTOMER_NAME]
					  ,[CUSTOMER_NUM]
					  ,[CUST_PO_NUMBER]
					  ,[ORDER_DATE]
					  ,[QUANTITY_ORDERED]
					  ,[PART]
					  ,[PART_DESC]
					  ,[SHIPPED_QTY]
					  ,[DATEREQUESTED]
					  ,[SCHSHIPDATE]
					  ,[ACTUAL_SHIP_DATE]
					  ,[FINGERPRINT]
				)
				VALUES (
					   a.[CUSTOMER_NAME]
					  ,a.[CUSTOMER_NUM]
					  ,a.[CUST_PO_NUMBER]
					  ,a.[ORDER_DATE]
					  ,a.[QUANTITY_ORDERED]
					  ,a.[PART]
					  ,a.[PART_DESC]
					  ,a.[SHIPPED_QTY]
					  ,a.[DATEREQUESTED]
					  ,a.[SCHSHIPDATE]
					  ,a.[ACTUAL_SHIP_DATE]
					  ,a.[FINGERPRINT]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[CUSTOMER_NAME]
					  ,a.[CUSTOMER_NUM]
					  ,a.[CUST_PO_NUMBER]
					  ,a.[ORDER_DATE]
					  ,a.[QUANTITY_ORDERED]
					  ,a.[PART]
					  ,a.[PART_DESC]
					  ,a.[SHIPPED_QTY]
					  ,a.[DATEREQUESTED]
					  ,a.[SCHSHIPDATE]
					  ,a.[ACTUAL_SHIP_DATE]
					  ,a.[FINGERPRINT]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		DROP TABLE #ShippingDetails

END
GO
