USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_CustomerMaster]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_CustomerMaster] 
AS BEGIN

		CREATE TABLE #customer (
			[ID] [int] IDENTITY(1,1) NOT NULL,
			[ACCOUNT_NUMBER] [nvarchar](30) NOT NULL,
			[ACCOUNT_NAME] [nvarchar](240) NULL,
			[SALES_CHANNEL_CODE] [nvarchar](30) NULL,
			[INSIDE_REP] [nvarchar](150) NULL,
			[TRAFFIC_PERSON] [nvarchar](150) NULL,
			[LABEL_FORMAT] [nvarchar](150) NULL,
			[BUSINESS_SEGMENT] [nvarchar](150) NULL,
			[CUSTOMER_GROUP] [nvarchar](150) NULL,
			[FINANCE_CHANNEL] [nvarchar](150) NULL,
			[TERRITORY] [nvarchar](40) NULL,
			[SALESPERSON] [nvarchar](240) NULL,
			[ORDER_TYPE] [nvarchar](30) NULL,
			[DEMAND_CLASS_CODE] [nvarchar](30) NULL,
			[Fingerprint] [varchar](32) NOT NULL,
		)

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

		INSERT INTO #customer (
			   [ACCOUNT_NUMBER]
			  ,[ACCOUNT_NAME]
			  ,[SALES_CHANNEL_CODE]
			  ,[INSIDE_REP]
			  ,[TRAFFIC_PERSON]
			  ,[LABEL_FORMAT]
			  ,[BUSINESS_SEGMENT]
			  ,[CUSTOMER_GROUP]
			  ,[FINANCE_CHANNEL]
			  ,[TERRITORY]
			  ,[SALESPERSON]
			  ,[ORDER_TYPE]
			  ,[DEMAND_CLASS_CODE] 
			  ,[FINGERPRINT]
		)
		SELECT [ACCOUNT_NUMBER]
			  ,[ACCOUNT_NAME]
			  ,[SALES_CHANNEL_CODE]
			  ,[INSIDE_REP]
			  ,[TRAFFIC_PERSON]
			  ,[LABEL_FORMAT]
			  ,[BUSINESS_SEGMENT]
			  ,[CUSTOMER_GROUP]
			  ,[FINANCE_CHANNEL]
			  ,[TERRITORY]
			  ,[SALESPERSON]
			  ,[ORDER_TYPE]
			  ,[DEMAND_CLASS_CODE] 
			  ,'XXX' AS Fingerprint
		FROM OPENQUERY(PROD,'
			SELECT		DISTINCT 
						hca.account_number 
						, hca.account_name 
						, hca.sales_channel_code 
						, hca.attribute4 as Inside_Rep 
						, hca.attribute3 as Traffic_Person 
						, hca.attribute12 as Label_Format 
						, hca.attribute1 as Business_Segment 
						, hca.attribute5 as Customer_Group 
						, hca.attribute8 as Finance_Channel 
						, terr.name as Territory 
						, saleper.name as Salesperson 
						, typ.name as Order_Type 
						, BillUse.demand_class_code 
			FROM		AR.hz_cust_accounts hca 
						LEFT JOIN AR.hz_cust_acct_sites_all hcas on hca.cust_account_id = hcas.cust_account_id and hcas.org_id = 83 and hcas.status = ''A'' and hcas.bill_to_flag = ''P'' 
						LEFT JOIN AR.hz_cust_site_uses_all BillUse on nvl(hcas.cust_acct_site_id,0) = BillUse.cust_acct_site_id and BillUse.site_use_code = ''BILL_TO'' and BillUse.org_id = 83 and BillUse.status = ''A'' and BillUse.primary_flag = ''Y'' and BillUse.org_id = 83 
						LEFT JOIN AR.ra_territories terr on nvl(BillUse.territory_id,0) = terr.territory_id 
						LEFT JOIN APPS.ra_salesreps_all saleper on nvl(BillUse.primary_salesrep_id,0) = saleper.salesrep_id 
						LEFT JOIN ONT.oe_transaction_types_tl typ on nvl(BillUse.order_type_id,0) = typ.transaction_type_id and typ.language = ''US'' 
			WHERE		hca.status = ''A'' 
						AND substr(hca.account_name,1,4) <> ''INF:'' 
						AND length(trim(hca.account_number)) >= 7 
		')

		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('CustomerMaster','Oracle') SELECT @columnList
		*/
	
		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

		UPDATE #customer
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
					  CAST(ISNULL(ACCOUNT_NUMBER,'') AS VARCHAR(30)) +  CAST(ISNULL(ACCOUNT_NAME,'') AS VARCHAR(240)) +  CAST(ISNULL(SALES_CHANNEL_CODE,'') AS VARCHAR(30)) +  CAST(ISNULL(INSIDE_REP,'') AS VARCHAR(150)) +  CAST(ISNULL(TRAFFIC_PERSON,'') AS VARCHAR(150)) +  CAST(ISNULL(LABEL_FORMAT,'') AS VARCHAR(150)) +  CAST(ISNULL(BUSINESS_SEGMENT,'') AS VARCHAR(150)) +  CAST(ISNULL(CUSTOMER_GROUP,'') AS VARCHAR(150)) +  CAST(ISNULL(FINANCE_CHANNEL,'') AS VARCHAR(150)) +  CAST(ISNULL(TERRITORY,'') AS VARCHAR(40)) +  CAST(ISNULL(SALESPERSON,'') AS VARCHAR(240)) +  CAST(ISNULL(ORDER_TYPE,'') AS VARCHAR(30)) +  CAST(ISNULL(DEMAND_CLASS_CODE,'') AS VARCHAR(30)) 
			),1)),3,32);

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO Oracle.CustomerMaster (
			   [ACCOUNT_NUMBER]
			  ,[ACCOUNT_NAME]
			  ,[SALES_CHANNEL_CODE]
			  ,[INSIDE_REP]
			  ,[TRAFFIC_PERSON]
			  ,[LABEL_FORMAT]
			  ,[BUSINESS_SEGMENT]
			  ,[CUSTOMER_GROUP]
			  ,[FINANCE_CHANNEL]
			  ,[TERRITORY]
			  ,[SALESPERSON]
			  ,[ORDER_TYPE]
			  ,[DEMAND_CLASS_CODE] 
			  ,[FINGERPRINT]
		)
			SELECT 
				    a.[ACCOUNT_NUMBER]
					,a.[ACCOUNT_NAME]
					,a.[SALES_CHANNEL_CODE]
					,a.[INSIDE_REP]
					,a.[TRAFFIC_PERSON]
					,a.[LABEL_FORMAT]
					,a.[BUSINESS_SEGMENT]
					,a.[CUSTOMER_GROUP]
					,a.[FINANCE_CHANNEL]
					,a.[TERRITORY]
					,a.[SALESPERSON]
					,a.[ORDER_TYPE]
					,a.[DEMAND_CLASS_CODE] 
					,a.[FINGERPRINT]
			FROM (
				MERGE Oracle.CustomerMaster b
				USING (SELECT * FROM #Customer) a
				ON a.ACCOUNT_NUMBER = b.ACCOUNT_NUMBER AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [ACCOUNT_NUMBER]
					  ,[ACCOUNT_NAME]
					  ,[SALES_CHANNEL_CODE]
					  ,[INSIDE_REP]
					  ,[TRAFFIC_PERSON]
					  ,[LABEL_FORMAT]
					  ,[BUSINESS_SEGMENT]
					  ,[CUSTOMER_GROUP]
					  ,[FINANCE_CHANNEL]
					  ,[TERRITORY]
					  ,[SALESPERSON]
					  ,[ORDER_TYPE]
					  ,[DEMAND_CLASS_CODE] 
					  ,[FINGERPRINT]
				)
				VALUES (
					   a.[ACCOUNT_NUMBER]
					  ,a.[ACCOUNT_NAME]
					  ,a.[SALES_CHANNEL_CODE]
					  ,a.[INSIDE_REP]
					  ,a.[TRAFFIC_PERSON]
					  ,a.[LABEL_FORMAT]
					  ,a.[BUSINESS_SEGMENT]
					  ,a.[CUSTOMER_GROUP]
					  ,a.[FINANCE_CHANNEL]
					  ,a.[TERRITORY]
					  ,a.[SALESPERSON]
					  ,a.[ORDER_TYPE]
					  ,a.[DEMAND_CLASS_CODE] 
					  ,a.[FINGERPRINT]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[ACCOUNT_NUMBER]
					  ,a.[ACCOUNT_NAME]
					  ,a.[SALES_CHANNEL_CODE]
					  ,a.[INSIDE_REP]
					  ,a.[TRAFFIC_PERSON]
					  ,a.[LABEL_FORMAT]
					  ,a.[BUSINESS_SEGMENT]
					  ,a.[CUSTOMER_GROUP]
					  ,a.[FINANCE_CHANNEL]
					  ,a.[TERRITORY]
					  ,a.[SALESPERSON]
					  ,a.[ORDER_TYPE]
					  ,a.[DEMAND_CLASS_CODE] 
					  ,a.[FINGERPRINT]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		DROP TABLE #Customer

END
GO
