USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_QualityReceiving]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--TRUNCATE TABLE Oracle.QualityReceiving


CREATE PROCEDURE [Oracle].[Merge_QualityReceiving] AS BEGIN

		CREATE TABLE #QualityReceiving (
			[PO_HEADER_ID] [float] NOT NULL,
			[PO_LINE_ID] [float] NOT NULL,
			[LINE_LOCATION_ID] [float] NULL,
			[ORG_CODE] [nvarchar](3) NULL,
			[ORG_NAME] [nvarchar](240) NOT NULL,
			[ORGANIZATION_ID] [float] NULL,
			[PACKING_SLIP] [nvarchar](25) NULL,
			[ITEM] [nvarchar](40) NULL,
			[PART_CLASS] [nvarchar](240) NULL,
			[QUANTITY] [float] NULL,
			[DOCUMENT_NUMBER] [nvarchar](143) NULL,
			[PRICE] [float] NULL,
			[SUPPLIER] [nvarchar](240) NULL,
			[TRANSACTION_DATE] [nvarchar](19) NULL,
			[UOM] [nvarchar](25) NULL,
			[RECEIPT_NUMBER] [nvarchar](30) NULL,
			[RECEIVER] [nvarchar](240) NULL,
			[BUYER] [nvarchar](240) NULL,
			[DELIVER_TO] [nvarchar](240) NULL,
			[DESTINATION_TYPE] [nvarchar](80) NOT NULL,
			[DESCRIPTION] [nvarchar](240) NULL,
			[TRANSACTION_TYPE] [nvarchar](80) NOT NULL,
			[Fingerprint] [varchar](32) NOT NULL
		) ON [PRIMARY]


		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

		INSERT INTO #QualityReceiving
		SELECT 
			   [PO_HEADER_ID]
			  ,[PO_LINE_ID]
			  ,[LINE_LOCATION_ID]
			  ,[ORG_CODE]
			  ,[ORG_NAME]
			  ,[ORGANIZATION_ID]
			  ,[PACKING_SLIP]
			  ,[ITEM]
			  ,[PART_CLASS]
			  ,[QUANTITY]
			  ,[DOCUMENT_NUMBER]
			  ,[PRICE]
			  ,[SUPPLIER]
			  ,[TRANSACTION_DATE]
			  ,[UOM]
			  ,[RECEIPT_NUMBER]
			  ,[RECEIVER]
			  ,[BUYER]
			  ,[DELIVER_TO]
			  ,[DESTINATION_TYPE]
			  ,[DESCRIPTION]
			  ,[TRANSACTION_TYPE]
			  ,'XXXXXXX' AS [Fingerprint]
		FROM OPENQUERY(PROD,'
				SELECT  
						poh.po_header_id, 
						pol.PO_LINE_ID,
						pll.LINE_LOCATION_ID,
						OOD.ORGANIZATION_CODE AS org_code,
						OOD.ORGANIZATION_NAME AS org_name,
						RCT.ORGANIZATION_ID, 
						NVL(RSL.PACKING_SLIP,RSH.PACKING_SLIP) AS packing_slip, 
						MSI.SEGMENT1 as item, 
						MSI.ATTRIBUTE4 as part_class,
						SUM(ROUND(RCT.QUANTITY,2)) as quantity, 
						POH.SEGMENT1 || DECODE(POR.RELEASE_NUM, NULL,NULL,''-'' || POR.RELEASE_NUM) || DECODE(POL.LINE_NUM,NULL,NULL,''-'' || POL.LINE_NUM) || DECODE(PLL.SHIPMENT_NUM,NULL,NULL,''-''||     PLL.SHIPMENT_NUM) as document_number, 
						PLL.PRICE_OVERRIDE as price, 
						POV.VENDOR_NAME as supplier, 
						TO_CHAR(RCT.TRANSACTION_DATE,  ''YYYY/MM/DD HH24:MI:SS'') as transaction_date,
						--RCT.TRANSACTION_DATE as transaction_date, 
						RCT.UNIT_OF_MEASURE as uom, 
						RSH.RECEIPT_NUM  as receipt_number,
						P1.FULL_NAME as receiver,
						P2.FULL_NAME as buyer,
						P3.FULL_NAME AS deliver_to,
						PLC.DISPLAYED_FIELD as destination_type, 
						RSL.ITEM_DESCRIPTION as description, 
						PLC2.DISPLAYED_FIELD as transaction_type 
				FROM 
						PO_LOOKUP_CODES					PLC 
						, PO_LOOKUP_CODES				PLC1
						, PO_LOOKUP_CODES				PLC2
						, PO_LOOKUP_CODES				PLC3
						, PO_RELEASES_ALL				POR 
						, PO_DISTRIBUTIONS_ALL			POD	
						, APPS.PER_PEOPLE_F				P2 	
						, APPS.PER_PEOPLE_F				P3 	
						, HR_LOCATIONS					HRL	
						, MTL_TRANSACTION_REASONS		MTR	
						, PO_VENDORS					POV	
						, APPS.HR_ORGANIZATION_UNITS	HRU	
						, MTL_SYSTEM_ITEMS				MSI 
						, MTL_CATEGORIES				MCA	
						, MTL_ITEM_LOCATIONS			MSL	
						, PO_HEADERS_ALL				POH  
						, PO_LINES_ALL					POL	 
						, PO_LINE_LOCATIONS_ALL			PLL	
						, RCV_TRANSACTIONS				PAR	
						, RCV_SHIPMENT_LINES			RSL	 
						, RCV_SHIPMENT_HEADERS			RSH	 
						, APPS.PER_PEOPLE_F				P1	
						, RCV_TRANSACTIONS				RCT          
						, ORG_ORGANIZATION_DEFINITIONS	OOD	 
				WHERE   
						MCA.CATEGORY_ID = RSL.CATEGORY_ID 
						AND		MSI.INVENTORY_ITEM_ID (+) = RSL.ITEM_ID 
						AND		RCT.SHIPMENT_LINE_ID = RSL.SHIPMENT_LINE_ID 
						AND		RCT.SHIPMENT_HEADER_ID  = RSH.SHIPMENT_HEADER_ID 
						AND		MSL.INVENTORY_LOCATION_ID (+) = RCT.LOCATOR_ID
						AND		nvl(MSL.ORGANIZATION_ID,RCT.ORGANIZATION_ID) = RCT.ORGANIZATION_ID
						AND		RCT.ORGANIZATION_ID = ood.organization_id
						AND		RCT.PO_RELEASE_ID = POR.PO_RELEASE_ID (+)
						AND		RCT.PO_DISTRIBUTION_ID = POD.PO_DISTRIBUTION_ID (+)
						AND		RCT.PO_LINE_LOCATION_ID = PLL.LINE_LOCATION_ID
						AND		RCT.PO_HEADER_ID = POH.PO_HEADER_ID
						AND		RCT.PO_LINE_ID = POL.PO_LINE_ID
						AND		NVL(MSI.ORGANIZATION_ID, 87) =  87 
						AND     RCT.SOURCE_DOCUMENT_CODE     = ''PO'' 
						AND     RSH.RECEIPT_SOURCE_CODE || ''''    = ''VENDOR'' 
						AND     (POH.TYPE_LOOKUP_CODE    = ''STANDARD'' ) 
						AND     (RCT.EMPLOYEE_ID = P1.PERSON_ID (+) AND TRUNC(RCT.CREATION_DATE) BETWEEN NVL(P1.EFFECTIVE_START_DATE,TRUNC(RCT.CREATION_DATE)) AND NVL(P1.EFFECTIVE_END_DATE,TRUNC(RCT.CREATION_DATE))) 
						AND     (POH.AGENT_ID = P2.PERSON_ID  (+)  AND TRUNC(POH.APPROVED_DATE) BETWEEN NVL(P2.EFFECTIVE_START_DATE,TRUNC(POH.APPROVED_DATE)) AND NVL(P2.EFFECTIVE_END_DATE,TRUNC(POH.APPROVED_DATE)))
						AND     PLC1.LOOKUP_CODE = RSH.RECEIPT_SOURCE_CODE  ||  '''' 
						AND     PLC1.LOOKUP_TYPE = ''SHIPMENT SOURCE TYPE'' 
						AND     RSH.VENDOR_ID = POV.VENDOR_ID 
						AND     PAR.TRANSACTION_ID (+) = RCT.PARENT_TRANSACTION_ID 
						AND     HRL.LOCATION_ID(+) = RCT.DELIVER_TO_LOCATION_ID 
						AND     P3.PERSON_ID(+) = RCT.DELIVER_TO_PERSON_ID 
						AND     TRUNC(RCT.CREATION_DATE) BETWEEN NVL(P3.EFFECTIVE_START_DATE,TRUNC(RCT.CREATION_DATE)) AND NVL(P3.EFFECTIVE_END_DATE,TRUNC(RCT.CREATION_DATE)) 
						AND     PLC.LOOKUP_CODE = RCT.DESTINATION_TYPE_CODE 
						AND     PLC.LOOKUP_TYPE = ''RCV DESTINATION TYPE'' 
						AND     PLC2.LOOKUP_TYPE =''RCV TRANSACTION TYPE'' 
						AND     PLC2.LOOKUP_CODE = RCT.TRANSACTION_TYPE 
						AND     PLC3.LOOKUP_TYPE (+) = ''RCV TRANSACTION TYPE'' 
						AND     PLC3.LOOKUP_CODE (+) = PAR.TRANSACTION_TYPE 
						AND     HRU.ORGANIZATION_ID = RCT.ORGANIZATION_ID 
						AND     MTR.REASON_ID(+) = RCT.REASON_ID 
						AND		RCT.TRANSACTION_DATE >= sysdate - 35 -- BETWEEN TO_DATE(:P_START_DATE_TIME, ''YYYY/MM/DD HH24:MI:SS'') AND TO_DATE(:P_END_DATE_TIME, ''YYYY/MM/DD HH24:MI:SS'') 
				GROUP BY 
						poh.po_header_id, 
						pol.PO_LINE_ID,
						pll.LINE_LOCATION_ID,
						OOD.ORGANIZATION_CODE,
						OOD.ORGANIZATION_NAME,
						RCT.ORGANIZATION_ID, 
						NVL(RSL.PACKING_SLIP,RSH.PACKING_SLIP), 
						MSI.SEGMENT1, 
						MSI.ATTRIBUTE4, 
						POH.SEGMENT1 || DECODE(POR.RELEASE_NUM, NULL,NULL,''-'' || POR.RELEASE_NUM) || DECODE(POL.LINE_NUM,NULL,NULL,''-'' || POL.LINE_NUM) || DECODE(PLL.SHIPMENT_NUM,NULL,NULL,''-''||     PLL.SHIPMENT_NUM), 
						PLL.PRICE_OVERRIDE, 
						POV.VENDOR_NAME, 
						TO_CHAR(RCT.TRANSACTION_DATE,  ''YYYY/MM/DD HH24:MI:SS''),
						RCT.UNIT_OF_MEASURE, 
						RSH.RECEIPT_NUM,
						P1.FULL_NAME,
						P2.FULL_NAME,
						P3.FULL_NAME,
						PLC.DISPLAYED_FIELD, 
						RSL.ITEM_DESCRIPTION, 
						PLC2.DISPLAYED_FIELD
				'
		)

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('QualityReceiving','Oracle') SELECT @columnList
		*/
		UPDATE #QualityReceiving
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				   CAST(ISNULL([PO_HEADER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PO_LINE_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([LINE_LOCATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORG_CODE],'') AS VARCHAR(3)) +  CAST(ISNULL([ORG_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([ORGANIZATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PACKING_SLIP],'') AS VARCHAR(25)) +  CAST(ISNULL([ITEM],'') AS VARCHAR(40)) +  CAST(ISNULL([PART_CLASS],'') AS VARCHAR(240)) +  CAST(ISNULL([QUANTITY],'0') AS VARCHAR(100)) +  CAST(ISNULL([DOCUMENT_NUMBER],'') AS VARCHAR(143)) +  CAST(ISNULL([PRICE],'0') AS VARCHAR(100)) +  CAST(ISNULL([SUPPLIER],'') AS VARCHAR(240)) +  CAST(ISNULL([TRANSACTION_DATE],'') AS VARCHAR(19)) +  CAST(ISNULL([UOM],'') AS VARCHAR(25)) +  CAST(ISNULL([RECEIPT_NUMBER],'') AS VARCHAR(30)) +  CAST(ISNULL([RECEIVER],'') AS VARCHAR(240)) +  CAST(ISNULL([BUYER],'') AS VARCHAR(240)) +  CAST(ISNULL([DELIVER_TO],'') AS VARCHAR(240)) +  CAST(ISNULL([DESTINATION_TYPE],'') AS VARCHAR(80)) +  CAST(ISNULL([DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([TRANSACTION_TYPE],'') AS VARCHAR(80)) 
			),1)),3,32);

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO Oracle.[QualityReceiving] (
			   [PO_HEADER_ID]
			  ,[PO_LINE_ID]
			  ,[LINE_LOCATION_ID]
			  ,[ORG_CODE]
			  ,[ORG_NAME]
			  ,[ORGANIZATION_ID]
			  ,[PACKING_SLIP]
			  ,[ITEM]
			  ,[PART_CLASS]
			  ,[QUANTITY]
			  ,[DOCUMENT_NUMBER]
			  ,[PRICE]
			  ,[SUPPLIER]
			  ,[TRANSACTION_DATE]
			  ,[UOM]
			  ,[RECEIPT_NUMBER]
			  ,[RECEIVER]
			  ,[BUYER]
			  ,[DELIVER_TO]
			  ,[DESTINATION_TYPE]
			  ,[DESCRIPTION]
			  ,[TRANSACTION_TYPE]
			  ,[Fingerprint]
		)
			SELECT 
			   a.[PO_HEADER_ID]
			  ,a.[PO_LINE_ID]
			  ,a.[LINE_LOCATION_ID]
			  ,a.[ORG_CODE]
			  ,a.[ORG_NAME]
			  ,a.[ORGANIZATION_ID]
			  ,a.[PACKING_SLIP]
			  ,a.[ITEM]
			  ,a.[PART_CLASS]
			  ,a.[QUANTITY]
			  ,a.[DOCUMENT_NUMBER]
			  ,a.[PRICE]
			  ,a.[SUPPLIER]
			  ,a.[TRANSACTION_DATE]
			  ,a.[UOM]
			  ,a.[RECEIPT_NUMBER]
			  ,a.[RECEIVER]
			  ,a.[BUYER]
			  ,a.[DELIVER_TO]
			  ,a.[DESTINATION_TYPE]
			  ,a.[DESCRIPTION]
			  ,a.[TRANSACTION_TYPE]
			  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.[QualityReceiving] b
				USING (SELECT * FROM #QualityReceiving) a
				ON  a.[TRANSACTION_DATE] = b.[TRANSACTION_DATE]
					AND a.[RECEIPT_NUMBER] = b.[RECEIPT_NUMBER]
					AND a.[TRANSACTION_TYPE] = b.[TRANSACTION_TYPE]
					AND a.PO_HEADER_ID = b.PO_HEADER_ID
					AND a.PO_LINE_ID = b.PO_LINE_ID
					AND a.LINE_LOCATION_ID = b.LINE_LOCATION_ID
					AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
				    [PO_HEADER_ID]
			      ,[PO_LINE_ID]
				  ,[LINE_LOCATION_ID]
				  ,[ORG_CODE]
				  ,[ORG_NAME]
				  ,[ORGANIZATION_ID]
				  ,[PACKING_SLIP]
				  ,[ITEM]
				  ,[PART_CLASS]
				  ,[QUANTITY]
				  ,[DOCUMENT_NUMBER]
				  ,[PRICE]
				  ,[SUPPLIER]
				  ,[TRANSACTION_DATE]
				  ,[UOM]
				  ,[RECEIPT_NUMBER]
				  ,[RECEIVER]
				  ,[BUYER]
				  ,[DELIVER_TO]
				  ,[DESTINATION_TYPE]
				  ,[DESCRIPTION]
				  ,[TRANSACTION_TYPE]
				  ,[Fingerprint]
				)
				VALUES (
				   a.[PO_HEADER_ID]
				  ,a.[PO_LINE_ID]
				  ,a.[LINE_LOCATION_ID]
				  ,a.[ORG_CODE]
				  ,a.[ORG_NAME]
				  ,a.[ORGANIZATION_ID]
				  ,a.[PACKING_SLIP]
				  ,a.[ITEM]
				  ,a.[PART_CLASS]
				  ,a.[QUANTITY]
				  ,a.[DOCUMENT_NUMBER]
				  ,a.[PRICE]
				  ,a.[SUPPLIER]
				  ,a.[TRANSACTION_DATE]
				  ,a.[UOM]
				  ,a.[RECEIPT_NUMBER]
				  ,a.[RECEIVER]
				  ,a.[BUYER]
				  ,a.[DELIVER_TO]
				  ,a.[DESTINATION_TYPE]
				  ,a.[DESCRIPTION]
				  ,a.[TRANSACTION_TYPE]
				  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
				       a.[PO_HEADER_ID]
				      ,a.[PO_LINE_ID]
					  ,a.[LINE_LOCATION_ID]
					  ,a.[ORG_CODE]
					  ,a.[ORG_NAME]
					  ,a.[ORGANIZATION_ID]
					  ,a.[PACKING_SLIP]
					  ,a.[ITEM]
					  ,a.[PART_CLASS]
					  ,a.[QUANTITY]
					  ,a.[DOCUMENT_NUMBER]
					  ,a.[PRICE]
					  ,a.[SUPPLIER]
					  ,a.[TRANSACTION_DATE]
					  ,a.[UOM]
					  ,a.[RECEIPT_NUMBER]
					  ,a.[RECEIVER]
					  ,a.[BUYER]
					  ,a.[DELIVER_TO]
					  ,a.[DESTINATION_TYPE]
					  ,a.[DESCRIPTION]
					  ,a.[TRANSACTION_TYPE]
					  ,a.[Fingerprint]
					   ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
	
	DROP TABLE #QualityReceiving

END
GO
