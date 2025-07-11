USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Freight]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_Freight] AS BEGIN

			CREATE TABLE #freight (
				[SHIP_DATE] [nvarchar](10) NULL,
				[SOLD_TO_ACCOUNT_NUMBER] [nvarchar](255) NULL,
				[ORGANIZATION_CODE] [nvarchar](10) NULL,
				[CARRIER] [nvarchar](255) NULL,
				[SHIP_METHOD_CODE] [nvarchar](255) NULL,
				[SERVICE_LEVEL] [nvarchar](50) NULL,
				[PARCEL_GROUP] [nvarchar](255) NULL,
				[FREIGHT_COST] [float] NULL,
				[FREIGHT_COSTS_REQUIRED] [nvarchar](1) NULL,
				[ITEM_NUMBER] [nvarchar](255) NULL,
				[ITEM_DESC] [nvarchar](255) NULL,
				[WEIGHT] [float] NULL,
				[VOLUME] [float] NULL,
				[UNIT_WIDTH] [float] NULL,
				[UNIT_LENGTH] [float] NULL,
				[UNIT_HEIGHT] [float] NULL,
				[LONGEST] [float] NULL,
				[DIM_WT] [float] NULL,
				[CONVEYABLE] [nvarchar](14) NULL,
				[FROM_ZIP] [nvarchar](20) NULL,
				[SHIP_TO_ADDRESS2] [nvarchar](255) NULL,
				[SHIP_TO_ADDRESS3] [nvarchar](255) NULL,
				[SHIP_TO_CITY] [nvarchar](255) NULL,
				[SHIP_TO_STATE] [nvarchar](50) NULL,
				[TO_ZIP] [nvarchar](20) NULL,
				[SHIP_TO_COUNTRY] [nvarchar](155) NULL,
				[DELIVERY_ID] [float] NULL,
				[DELIVERY_DETAIL_ID] [float] NULL,
				[ORDER_NUMBER] [nvarchar](255) NULL,
				[ORDER_LINE_NUMBER] [nvarchar](30) NULL,
				[ORDER_HEADER_ID] [float] NULL,
				[ORDER_LINE_ID] [float] NULL,
				[KIT_ITEM_NUMBER] [nvarchar](255) NULL,
				[KIT_ITEM_DESC] [nvarchar](255) NULL,
				[LPN_ID] [float] NULL,
				[SSCC] [nvarchar](20) NULL,
				[ORDER_ITEM_NUMBER] [nvarchar](255) NULL,
				[Fingerprint] [VARCHAR](32) NOT NULL
			) 

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

			INSERT INTO #freight 
			SELECT *, 'XXXXXXX'
			FROM OPENQUERY(PROD,'
			select 
				to_char(xtt.asn_date, ''MM/DD/YYYY'') Ship_Date
				, xtt.sold_to_account_number
				, xtt.organization_code
				, xtt.carrier
				, xtt.SHIP_METHOD_CODE
				, xtt.SERVICE_LEVEL
				, xtt.PARCEL_GROUP
				, xtt.FREIGHT_COST
				, xtt.FREIGHT_COSTS_REQUIRED
				, xtt.item_number
				, xtt.item_desc
				, xtt.weight
				, xtt.VOLUME
				, xtt.UNIT_WIDTH
				, xtt.UNIT_LENGTH
				, xtt.UNIT_HEIGHT
				, greatest (xtt.UNIT_WIDTH, xtt.UNIT_LENGTH, xtt.UNIT_HEIGHT) as longest
				, ((xtt.UNIT_WIDTH + xtt.UNIT_LENGTH + xtt.UNIT_HEIGHT)*2) - greatest (xtt.UNIT_WIDTH, xtt.UNIT_LENGTH, xtt.UNIT_HEIGHT) as dim_wt
				, case when ( greatest (xtt.UNIT_WIDTH, xtt.UNIT_LENGTH, xtt.UNIT_HEIGHT) > 48 
						or ((xtt.UNIT_WIDTH + xtt.UNIT_LENGTH + xtt.UNIT_HEIGHT)*2) - greatest (xtt.UNIT_WIDTH, xtt.UNIT_LENGTH, xtt.UNIT_HEIGHT) >= 105  )
					then ''NON-Conveyable'' else ''Conveyable''
				end  as Conveyable
				, xtt.SHIP_FM_POSTAL_CODE  From_Zip
				, xtt.ship_to_address2
				, xtt.SHIP_TO_ADDRESS3
				, xtt.ship_to_city
				, xtt.SHIP_TO_STATE
				, xtt.SHIP_TO_POSTAL_CODE  To_Zip
				, xtt.SHIP_TO_COUNTRY
				, xtt.DELIVERY_ID
				, xtt.DELIVERY_DETAIL_ID            
				, xtt.ORDER_NUMBER   
				, xtt.ORDER_LINE_NUMBER       
				, xtt.ORDER_HEADER_ID               
				, xtt.ORDER_LINE_ID      
				, xtt.KIT_ITEM_NUMBER              
				, xtt.KIT_ITEM_DESC      
				, xtt.LPN_ID
				, xtt.SSCC
				, case
						when xtt.KIT_ITEM_NUMBER is not null then xtt.KIT_ITEM_NUMBER            
						else xtt.item_number
				end as ORDER_ITEM_NUMBER
			from xxdc.xxont_tracking_temp   xtt 
			where xtt.asn_date >= sysdate - 1
				and substr(status_code,1,4) in ( ''ASN_'', ''NO-A'', ''SHIP'')  
				and mode_of_transport = ''PARCEL''
				and xtt.organization_code not in ( 230, 410)
				and xtt.FREIGHT_COST <> 0
			 '
			 )

 			/*
				DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Oracle','Freight') SELECT @columnList
			*/

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

			UPDATE #freight
			SET Fingerprint = 
				SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
					--replace @columnList result here
					  CAST(ISNULL(SHIP_DATE,'') AS VARCHAR(10)) +  CAST(ISNULL(SOLD_TO_ACCOUNT_NUMBER,'') AS VARCHAR(255)) +  CAST(ISNULL(ORGANIZATION_CODE,'') AS VARCHAR(10)) +  CAST(ISNULL(CARRIER,'') AS VARCHAR(255)) +  CAST(ISNULL(SHIP_METHOD_CODE,'') AS VARCHAR(255)) +  CAST(ISNULL(SERVICE_LEVEL,'') AS VARCHAR(50)) +  CAST(ISNULL(PARCEL_GROUP,'') AS VARCHAR(255)) +  CAST(ISNULL(FREIGHT_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(FREIGHT_COSTS_REQUIRED,'') AS VARCHAR(1)) +  CAST(ISNULL(ITEM_NUMBER,'') AS VARCHAR(255)) +  CAST(ISNULL(ITEM_DESC,'') AS VARCHAR(255)) +  CAST(ISNULL(WEIGHT,'0') AS VARCHAR(100)) +  CAST(ISNULL(VOLUME,'0') AS VARCHAR(100)) +  CAST(ISNULL(UNIT_WIDTH,'0') AS VARCHAR(100)) +  CAST(ISNULL(UNIT_LENGTH,'0') AS VARCHAR(100)) +  CAST(ISNULL(UNIT_HEIGHT,'0') AS VARCHAR(100)) +  CAST(ISNULL(LONGEST,'0') AS VARCHAR(100)) +  CAST(ISNULL(DIM_WT,'0') AS VARCHAR(100)) +  CAST(ISNULL(CONVEYABLE,'') AS VARCHAR(14)) +  CAST(ISNULL(FROM_ZIP,'') AS VARCHAR(20)) +  CAST(ISNULL(SHIP_TO_ADDRESS2,'') AS VARCHAR(255)) +  CAST(ISNULL(SHIP_TO_ADDRESS3,'') AS VARCHAR(255)) +  CAST(ISNULL(SHIP_TO_CITY,'') AS VARCHAR(255)) +  CAST(ISNULL(SHIP_TO_STATE,'') AS VARCHAR(50)) +  CAST(ISNULL(TO_ZIP,'') AS VARCHAR(20)) +  CAST(ISNULL(SHIP_TO_COUNTRY,'') AS VARCHAR(155)) +  CAST(ISNULL(DELIVERY_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(DELIVERY_DETAIL_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(ORDER_NUMBER,'') AS VARCHAR(255)) +  CAST(ISNULL(ORDER_LINE_NUMBER,'') AS VARCHAR(30)) +  CAST(ISNULL(ORDER_HEADER_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(ORDER_LINE_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(KIT_ITEM_NUMBER,'') AS VARCHAR(255)) +  CAST(ISNULL(KIT_ITEM_DESC,'') AS VARCHAR(255)) +  CAST(ISNULL(LPN_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(SSCC,'') AS VARCHAR(20)) +  CAST(ISNULL(ORDER_ITEM_NUMBER,'') AS VARCHAR(255)) 
				),1)),3,32);


			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

			INSERT INTO Oracle.Freight (
					 [SHIP_DATE]
					  ,[SOLD_TO_ACCOUNT_NUMBER]
					  ,[ORGANIZATION_CODE]
					  ,[CARRIER]
					  ,[SHIP_METHOD_CODE]
					  ,[SERVICE_LEVEL]
					  ,[PARCEL_GROUP]
					  ,[FREIGHT_COST]
					  ,[FREIGHT_COSTS_REQUIRED]
					  ,[ITEM_NUMBER]
					  ,[ITEM_DESC]
					  ,[WEIGHT]
					  ,[VOLUME]
					  ,[UNIT_WIDTH]
					  ,[UNIT_LENGTH]
					  ,[UNIT_HEIGHT]
					  ,[LONGEST]
					  ,[DIM_WT]
					  ,[CONVEYABLE]
					  ,[FROM_ZIP]
					  ,[SHIP_TO_ADDRESS2]
					  ,[SHIP_TO_ADDRESS3]
					  ,[SHIP_TO_CITY]
					  ,[SHIP_TO_STATE]
					  ,[TO_ZIP]
					  ,[SHIP_TO_COUNTRY]
					  ,[DELIVERY_ID]
					  ,[DELIVERY_DETAIL_ID]
					  ,[ORDER_NUMBER]
					  ,[ORDER_LINE_NUMBER]
					  ,[ORDER_HEADER_ID]
					  ,[ORDER_LINE_ID]
					  ,[KIT_ITEM_NUMBER]
					  ,[KIT_ITEM_DESC]
					  ,[LPN_ID]
					  ,[SSCC]
					  ,[ORDER_ITEM_NUMBER]
					,[Fingerprint]
			)
			SELECT 
						 a.[SHIP_DATE]
					    ,a.[SOLD_TO_ACCOUNT_NUMBER]
					    ,a.[ORGANIZATION_CODE]
					    ,a.[CARRIER]
					    ,a.[SHIP_METHOD_CODE]
					    ,a.[SERVICE_LEVEL]
					    ,a.[PARCEL_GROUP]
					    ,a.[FREIGHT_COST]
					    ,a.[FREIGHT_COSTS_REQUIRED]
					    ,a.[ITEM_NUMBER]
					    ,a.[ITEM_DESC]
					    ,a.[WEIGHT]
					    ,a.[VOLUME]
					    ,a.[UNIT_WIDTH]
					    ,a.[UNIT_LENGTH]
					    ,a.[UNIT_HEIGHT]
					    ,a.[LONGEST]
					    ,a.[DIM_WT]
					    ,a.[CONVEYABLE]
					    ,a.[FROM_ZIP]
					    ,a.[SHIP_TO_ADDRESS2]
					    ,a.[SHIP_TO_ADDRESS3]
					    ,a.[SHIP_TO_CITY]
					    ,a.[SHIP_TO_STATE]
					    ,a.[TO_ZIP]
					    ,a.[SHIP_TO_COUNTRY]
					    ,a.[DELIVERY_ID]
					    ,a.[DELIVERY_DETAIL_ID]
					    ,a.[ORDER_NUMBER]
					    ,a.[ORDER_LINE_NUMBER]
					    ,a.[ORDER_HEADER_ID]
					    ,a.[ORDER_LINE_ID]
					    ,a.[KIT_ITEM_NUMBER]
					    ,a.[KIT_ITEM_DESC]
					    ,a.[LPN_ID]
					    ,a.[SSCC]
					    ,a.[ORDER_ITEM_NUMBER]
						,a.[Fingerprint]
			FROM (
				MERGE Oracle.Freight b
				USING (SELECT * FROM #Freight) a
				ON a.LPN_ID = b.LPN_ID AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
						 [SHIP_DATE]
						  ,[SOLD_TO_ACCOUNT_NUMBER]
						  ,[ORGANIZATION_CODE]
						  ,[CARRIER]
						  ,[SHIP_METHOD_CODE]
						  ,[SERVICE_LEVEL]
						  ,[PARCEL_GROUP]
						  ,[FREIGHT_COST]
						  ,[FREIGHT_COSTS_REQUIRED]
						  ,[ITEM_NUMBER]
						  ,[ITEM_DESC]
						  ,[WEIGHT]
						  ,[VOLUME]
						  ,[UNIT_WIDTH]
						  ,[UNIT_LENGTH]
						  ,[UNIT_HEIGHT]
						  ,[LONGEST]
						  ,[DIM_WT]
						  ,[CONVEYABLE]
						  ,[FROM_ZIP]
						  ,[SHIP_TO_ADDRESS2]
						  ,[SHIP_TO_ADDRESS3]
						  ,[SHIP_TO_CITY]
						  ,[SHIP_TO_STATE]
						  ,[TO_ZIP]
						  ,[SHIP_TO_COUNTRY]
						  ,[DELIVERY_ID]
						  ,[DELIVERY_DETAIL_ID]
						  ,[ORDER_NUMBER]
						  ,[ORDER_LINE_NUMBER]
						  ,[ORDER_HEADER_ID]
						  ,[ORDER_LINE_ID]
						  ,[KIT_ITEM_NUMBER]
						  ,[KIT_ITEM_DESC]
						  ,[LPN_ID]
						  ,[SSCC]
						  ,[ORDER_ITEM_NUMBER]
						,[Fingerprint]
				)
				VALUES (
						 a.[SHIP_DATE]
					    ,a.[SOLD_TO_ACCOUNT_NUMBER]
					    ,a.[ORGANIZATION_CODE]
					    ,a.[CARRIER]
					    ,a.[SHIP_METHOD_CODE]
					    ,a.[SERVICE_LEVEL]
					    ,a.[PARCEL_GROUP]
					    ,a.[FREIGHT_COST]
					    ,a.[FREIGHT_COSTS_REQUIRED]
					    ,a.[ITEM_NUMBER]
					    ,a.[ITEM_DESC]
					    ,a.[WEIGHT]
					    ,a.[VOLUME]
					    ,a.[UNIT_WIDTH]
					    ,a.[UNIT_LENGTH]
					    ,a.[UNIT_HEIGHT]
					    ,a.[LONGEST]
					    ,a.[DIM_WT]
					    ,a.[CONVEYABLE]
					    ,a.[FROM_ZIP]
					    ,a.[SHIP_TO_ADDRESS2]
					    ,a.[SHIP_TO_ADDRESS3]
					    ,a.[SHIP_TO_CITY]
					    ,a.[SHIP_TO_STATE]
					    ,a.[TO_ZIP]
					    ,a.[SHIP_TO_COUNTRY]
					    ,a.[DELIVERY_ID]
					    ,a.[DELIVERY_DETAIL_ID]
					    ,a.[ORDER_NUMBER]
					    ,a.[ORDER_LINE_NUMBER]
					    ,a.[ORDER_HEADER_ID]
					    ,a.[ORDER_LINE_ID]
					    ,a.[KIT_ITEM_NUMBER]
					    ,a.[KIT_ITEM_DESC]
					    ,a.[LPN_ID]
					    ,a.[SSCC]
					    ,a.[ORDER_ITEM_NUMBER]
						,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						 a.[SHIP_DATE]
					    ,a.[SOLD_TO_ACCOUNT_NUMBER]
					    ,a.[ORGANIZATION_CODE]
					    ,a.[CARRIER]
					    ,a.[SHIP_METHOD_CODE]
					    ,a.[SERVICE_LEVEL]
					    ,a.[PARCEL_GROUP]
					    ,a.[FREIGHT_COST]
					    ,a.[FREIGHT_COSTS_REQUIRED]
					    ,a.[ITEM_NUMBER]
					    ,a.[ITEM_DESC]
					    ,a.[WEIGHT]
					    ,a.[VOLUME]
					    ,a.[UNIT_WIDTH]
					    ,a.[UNIT_LENGTH]
					    ,a.[UNIT_HEIGHT]
					    ,a.[LONGEST]
					    ,a.[DIM_WT]
					    ,a.[CONVEYABLE]
					    ,a.[FROM_ZIP]
					    ,a.[SHIP_TO_ADDRESS2]
					    ,a.[SHIP_TO_ADDRESS3]
					    ,a.[SHIP_TO_CITY]
					    ,a.[SHIP_TO_STATE]
					    ,a.[TO_ZIP]
					    ,a.[SHIP_TO_COUNTRY]
					    ,a.[DELIVERY_ID]
					    ,a.[DELIVERY_DETAIL_ID]
					    ,a.[ORDER_NUMBER]
					    ,a.[ORDER_LINE_NUMBER]
					    ,a.[ORDER_HEADER_ID]
					    ,a.[ORDER_LINE_ID]
					    ,a.[KIT_ITEM_NUMBER]
					    ,a.[KIT_ITEM_DESC]
					    ,a.[LPN_ID]
					    ,a.[SSCC]
					    ,a.[ORDER_ITEM_NUMBER]
						,a.[Fingerprint]
						,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		DROP TABLE #Freight

END
GO
