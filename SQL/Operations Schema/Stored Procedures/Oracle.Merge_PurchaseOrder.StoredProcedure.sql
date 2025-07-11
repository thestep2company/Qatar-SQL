USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_PurchaseOrder]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_PurchaseOrder] AS BEGIN		
		
		CREATE TABLE #PurchaseOrder (
			[PO_HEADER_ID] [float] NOT NULL,
			[PO_LINE_ID] [float] NOT NULL,
			[LINE_NUMBER] [float] NOT NULL,
			[SHIPMENT_LINE_NUMBER] [float] NULL,
			[LINE_LOCATION_ID] [float] NULL,
			[SUPPLIER_NAME] [nvarchar](240) NULL,
			[VENDOR_SITE] [nvarchar](45) NULL,
			[VENDOR_ID] [float] NULL,
			[PO_NUMBER] [nvarchar](20) NOT NULL,
			[PO_TYPE] [nvarchar](25) NOT NULL,
			[PO_CREATE_DATE] [datetime2](7) NULL,
			[PO_LINE_CREATE_DATE] [datetime2](7) NULL,
			[PO_STATUS] [nvarchar](25) NULL,
			[BUYER_NAME] [nvarchar](240) NULL,
			[SHIP_TO] [nvarchar](60) NULL,
			[BILL_TO] [nvarchar](60) NULL,
			[ITEM] [nvarchar](40) NULL,
			[ITEM_DESCRIPTION] [nvarchar](240) NULL,
			[ITEM_TYPE] [nvarchar](30) NULL,
			[UNIT_PRICE] [float] NULL,
			[ORDER_QUANTITY] [float] NULL,
			[QUANTITY_RECEIVED] [float] NULL,
			[QUANTITY_CANCELLED] [float] NULL,
			[REMAINING_QUANTITY] [float] NULL,
			[NEED_BY_DATE] [datetime2](7) NULL,
			[PROMISED_DATE] [datetime2](7) NULL,
			[HEADER_CLOSED_CODE] [nvarchar](25) NULL,
			[LINE_CLOSED_CODE] [nvarchar](25) NULL,
			[NOTE_TO_VENDOR] [nvarchar](480) NULL,
			[ORDER_TOTAL] [float] NULL,
			[CLOSED_CODE] [nvarchar](30) NULL,
			[PO_LINE_CANCEL_FLAG] [nvarchar](1) NULL,
			[PO_LINE_CANCEL_DATE] [datetime2](7) NULL,
			[Fingerprint] [varchar](32) NOT NULL
		) ON [PRIMARY]

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

		INSERT INTO #PurchaseOrder
		SELECT *, 'XXXXXXXX' 
		FROM OPENQUERY(PROD,
			'
			SELECT distinct
				 poh.po_header_id
				,pol.PO_LINE_ID
				,pol.line_num LINE_NUMBER
				,poll.shipment_num SHIPMENT_LINE_NUMBER
				,poll.LINE_LOCATION_ID
				,pov.vendor_name SUPPLIER_NAME
				,povs.vendor_site_code VENDOR_SITE 
				,povs.vendor_id VENDOR_ID
				,poh.segment1 PO_NUMBER
				,poh.type_lookup_code PO_TYPE

				,trunc(poh.creation_date) PO_Create_date
				,trunc(pol.creation_date) PO_Line_Create_date
	
				,poh.authorization_status PO_STATUS
				,ppf.full_name BUYER_NAME
				,hrls.location_code SHIP_TO
				,hrlb.location_code  BILL_TO
				,msib.segment1 ITEM
				,msib.description ITEM_DESCRIPTION
				,msib.Item_Type item_type
	
				,pol.unit_price UNIT_PRICE
				,poll.quantity ORDER_QUANTITY
				,poll.quantity_received QUANTITY_RECEIVED
				,poll.quantity_cancelled  QUANTITY_CANCELLED
				,poll.quantity - poll.quantity_received - poll.quantity_cancelled REMAINING_QUANTITY
				,trunc(poll.need_by_date) NEED_BY_DATE
				,trunc(poll.promised_date) PROMISED_DATE
				,poh.closed_Code Header_CLOSED_CODE
				,pol.closed_Code Line_CLOSED_CODE
				,pol.note_to_vendor
	
				,pol.unit_price *  poll.quantity ORDER_TOTAL
				,poll.closed_code
				,pol.cancel_flag PO_Line_Cancel_Flag
				,pol.cancel_date PO_Line_Cancel_Date   
	
			FROM
				PO_HEADERS_ALL poh
				LEFT JOIN PO_LINES_ALL pol            ON poh.po_header_id = pol.po_header_id
				LEFT JOIN mtl_system_items_b msib     ON pol.item_id = msib.inventory_item_id	
				LEFT JOIN PO_DISTRIBUTIONS_ALL pod    ON pol.po_line_id = pod.po_line_id 
				LEFT JOIN PO_LINE_LOCATIONS_ALL poll  ON poll.line_location_id  = pod.line_location_id
				LEFT JOIN po_vendors pov              ON pov.vendor_id = poh.vendor_id
				LEFT JOIN po_vendor_sites_All povs    ON povs.vendor_site_id = poh.vendor_site_id
				LEFT JOIN hr_locations_all hrls       ON poh.ship_to_location_id = hrls.location_id
				LEFT JOIN hr_locations_all hrlb		  ON poh.Bill_to_Location_ID = hrlb.location_id -- for bill to name
				LEFT JOIN per_all_people_f ppf        ON poh.agent_id = ppf.person_id
				LEFT JOIN po_line_types polt          ON polt.line_type_id = pol.line_type_id
			WHERE
				msib.organization_id  = 85
				--AND pol.cancel_flag <> ''Y''
				AND hrls.location_code != ''US - Fontana, CA''
				AND pol.creation_date >= TO_DATE(''2016-01-01'', ''YYYY-MM-DD'') --sysdate -365 --TO_DATE(''2022-01-01'', ''YYYY-MM-DD'')  -- AND 
			'
			)


		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('PurchaseOrder','Oracle') SELECT @columnList
		*/

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

		UPDATE #PurchaseOrder
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
					   CAST(ISNULL([PO_HEADER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PO_LINE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([LINE_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([SHIPMENT_LINE_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([LINE_LOCATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([SUPPLIER_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([VENDOR_SITE],'') AS VARCHAR(45)) +  CAST(ISNULL([VENDOR_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PO_NUMBER],'') AS VARCHAR(20)) +  CAST(ISNULL([PO_TYPE],'') AS VARCHAR(25)) +  CAST(ISNULL([PO_CREATE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([PO_LINE_CREATE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([PO_STATUS],'') AS VARCHAR(25)) +  CAST(ISNULL([BUYER_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIP_TO],'') AS VARCHAR(60)) +  CAST(ISNULL([BILL_TO],'') AS VARCHAR(60)) +  CAST(ISNULL([ITEM],'') AS VARCHAR(40)) +  CAST(ISNULL([ITEM_DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([ITEM_TYPE],'') AS VARCHAR(30)) +  CAST(ISNULL([UNIT_PRICE],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORDER_QUANTITY],'0') AS VARCHAR(100)) +  CAST(ISNULL([QUANTITY_RECEIVED],'0') AS VARCHAR(100)) +  CAST(ISNULL([QUANTITY_CANCELLED],'0') AS VARCHAR(100)) +  CAST(ISNULL([REMAINING_QUANTITY],'0') AS VARCHAR(100)) +  CAST(ISNULL([NEED_BY_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([PROMISED_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([HEADER_CLOSED_CODE],'') AS VARCHAR(25)) +  CAST(ISNULL([LINE_CLOSED_CODE],'') AS VARCHAR(25)) +  CAST(ISNULL([NOTE_TO_VENDOR],'') AS VARCHAR(480)) +  CAST(ISNULL([ORDER_TOTAL],'0') AS VARCHAR(100)) +  CAST(ISNULL([CLOSED_CODE],'') AS VARCHAR(30)) +  CAST(ISNULL([PO_LINE_CANCEL_FLAG],'') AS VARCHAR(1)) +  CAST(ISNULL([PO_LINE_CANCEL_DATE],'') AS VARCHAR(100)) 
			),1)),3,32);


		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO Oracle.[PurchaseOrder] (
			[PO_HEADER_ID]
			,[PO_LINE_ID]
		    ,[LINE_NUMBER]
		    ,[SHIPMENT_LINE_NUMBER]
		    ,[LINE_LOCATION_ID]
		    ,[SUPPLIER_NAME]
		    ,[VENDOR_SITE]
		    ,[VENDOR_ID]
		    ,[PO_NUMBER]
		    ,[PO_TYPE]
		    ,[PO_CREATE_DATE]
		    ,[PO_LINE_CREATE_DATE]
		    ,[PO_STATUS]
		    ,[BUYER_NAME]
		    ,[SHIP_TO]
		    ,[BILL_TO]
		    ,[ITEM]
		    ,[ITEM_DESCRIPTION]
		    ,[ITEM_TYPE]
		    ,[UNIT_PRICE]
		    ,[ORDER_QUANTITY]
		    ,[QUANTITY_RECEIVED]
		    ,[QUANTITY_CANCELLED]
		    ,[REMAINING_QUANTITY]
		    ,[NEED_BY_DATE]
		    ,[PROMISED_DATE]
		    ,[HEADER_CLOSED_CODE]
		    ,[LINE_CLOSED_CODE]
		    ,[NOTE_TO_VENDOR]
		    ,[ORDER_TOTAL]
		    ,[CLOSED_CODE]
		    ,[PO_LINE_CANCEL_FLAG]
		    ,[PO_LINE_CANCEL_DATE]
		    ,[Fingerprint]
		)
			SELECT 
				a.[PO_HEADER_ID]
				,a.[PO_LINE_ID]
				,a.[LINE_NUMBER]
				,a.[SHIPMENT_LINE_NUMBER]
				,a.[LINE_LOCATION_ID]
				,a.[SUPPLIER_NAME]
				,a.[VENDOR_SITE]
				,a.[VENDOR_ID]
				,a.[PO_NUMBER]
				,a.[PO_TYPE]
				,a.[PO_CREATE_DATE]
				,a.[PO_LINE_CREATE_DATE]
				,a.[PO_STATUS]
				,a.[BUYER_NAME]
				,a.[SHIP_TO]
				,a.[BILL_TO]
				,a.[ITEM]
				,a.[ITEM_DESCRIPTION]
				,a.[ITEM_TYPE]
				,a.[UNIT_PRICE]
				,a.[ORDER_QUANTITY]
				,a.[QUANTITY_RECEIVED]
				,a.[QUANTITY_CANCELLED]
				,a.[REMAINING_QUANTITY]
				,a.[NEED_BY_DATE]
				,a.[PROMISED_DATE]
				,a.[HEADER_CLOSED_CODE]
				,a.[LINE_CLOSED_CODE]
				,a.[NOTE_TO_VENDOR]
				,a.[ORDER_TOTAL]
				,a.[CLOSED_CODE]
				,a.[PO_LINE_CANCEL_FLAG]
				,a.[PO_LINE_CANCEL_DATE]
				,a.[Fingerprint]
			FROM (
				MERGE Oracle.[PurchaseOrder] b
				USING (SELECT * FROM #PurchaseOrder) a
				ON a.[PO_HEADER_ID] = b.[PO_HEADER_ID] 
					AND a.[PO_LINE_ID] = b.[PO_LINE_ID] 
					AND ISNULL(a.[LINE_LOCATION_ID],0) = ISNULL(b.[LINE_LOCATION_ID],0)
					AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					[PO_HEADER_ID]
					,[PO_LINE_ID]
				    ,[LINE_NUMBER]
				    ,[SHIPMENT_LINE_NUMBER]
				    ,[LINE_LOCATION_ID]
				    ,[SUPPLIER_NAME]
				    ,[VENDOR_SITE]
				    ,[VENDOR_ID]
				    ,[PO_NUMBER]
				    ,[PO_TYPE]
				    ,[PO_CREATE_DATE]
				    ,[PO_LINE_CREATE_DATE]
				    ,[PO_STATUS]
				    ,[BUYER_NAME]
				    ,[SHIP_TO]
				    ,[BILL_TO]
				    ,[ITEM]
				    ,[ITEM_DESCRIPTION]
				    ,[ITEM_TYPE]
				    ,[UNIT_PRICE]
				    ,[ORDER_QUANTITY]
				    ,[QUANTITY_RECEIVED]
				    ,[QUANTITY_CANCELLED]
				    ,[REMAINING_QUANTITY]
				    ,[NEED_BY_DATE]
				    ,[PROMISED_DATE]
				    ,[HEADER_CLOSED_CODE]
				    ,[LINE_CLOSED_CODE]
				    ,[NOTE_TO_VENDOR]
				    ,[ORDER_TOTAL]
				    ,[CLOSED_CODE]
				    ,[PO_LINE_CANCEL_FLAG]
				    ,[PO_LINE_CANCEL_DATE]
				    ,[Fingerprint]
				)
				VALUES (
					a.[PO_HEADER_ID]
					,a.[PO_LINE_ID]
				    ,a.[LINE_NUMBER]
				    ,a.[SHIPMENT_LINE_NUMBER]
				    ,a.[LINE_LOCATION_ID]
				    ,a.[SUPPLIER_NAME]
				    ,a.[VENDOR_SITE]
				    ,a.[VENDOR_ID]
				    ,a.[PO_NUMBER]
				    ,a.[PO_TYPE]
				    ,a.[PO_CREATE_DATE]
				    ,a.[PO_LINE_CREATE_DATE]
				    ,a.[PO_STATUS]
				    ,a.[BUYER_NAME]
				    ,a.[SHIP_TO]
				    ,a.[BILL_TO]
				    ,a.[ITEM]
				    ,a.[ITEM_DESCRIPTION]
				    ,a.[ITEM_TYPE]
				    ,a.[UNIT_PRICE]
				    ,a.[ORDER_QUANTITY]
				    ,a.[QUANTITY_RECEIVED]
				    ,a.[QUANTITY_CANCELLED]
				    ,a.[REMAINING_QUANTITY]
				    ,a.[NEED_BY_DATE]
				    ,a.[PROMISED_DATE]
				    ,a.[HEADER_CLOSED_CODE]
				    ,a.[LINE_CLOSED_CODE]
				    ,a.[NOTE_TO_VENDOR]
				    ,a.[ORDER_TOTAL]
				    ,a.[CLOSED_CODE]
				    ,a.[PO_LINE_CANCEL_FLAG]
				    ,a.[PO_LINE_CANCEL_DATE]
				    ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						a.[PO_HEADER_ID]
					   ,a.[PO_LINE_ID]
					   ,a.[LINE_NUMBER]
					   ,a.[SHIPMENT_LINE_NUMBER]
					   ,a.[LINE_LOCATION_ID]
					   ,a.[SUPPLIER_NAME]
					   ,a.[VENDOR_SITE]
					   ,a.[VENDOR_ID]
					   ,a.[PO_NUMBER]
					   ,a.[PO_TYPE]
					   ,a.[PO_CREATE_DATE]
					   ,a.[PO_LINE_CREATE_DATE]
					   ,a.[PO_STATUS]
					   ,a.[BUYER_NAME]
					   ,a.[SHIP_TO]
					   ,a.[BILL_TO]
					   ,a.[ITEM]
					   ,a.[ITEM_DESCRIPTION]
					   ,a.[ITEM_TYPE]
					   ,a.[UNIT_PRICE]
					   ,a.[ORDER_QUANTITY]
					   ,a.[QUANTITY_RECEIVED]
					   ,a.[QUANTITY_CANCELLED]
					   ,a.[REMAINING_QUANTITY]
					   ,a.[NEED_BY_DATE]
					   ,a.[PROMISED_DATE]
					   ,a.[HEADER_CLOSED_CODE]
					   ,a.[LINE_CLOSED_CODE]
					   ,a.[NOTE_TO_VENDOR]
					   ,a.[ORDER_TOTAL]
					   ,a.[CLOSED_CODE]
					   ,a.[PO_LINE_CANCEL_FLAG]
					   ,a.[PO_LINE_CANCEL_DATE]
					   ,a.[Fingerprint]
					   ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;
	
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #PurchaseOrder

END
GO
