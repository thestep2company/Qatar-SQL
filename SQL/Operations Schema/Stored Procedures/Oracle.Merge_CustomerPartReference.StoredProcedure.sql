USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_CustomerPartReference]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_CustomerPartReference]
AS BEGIN

		CREATE TABLE #customerPart (
			[ACCT_NUM] [nvarchar](30) NOT NULL,
			[ACCT_NAME] [nvarchar](240) NULL,
			[CUSTOMER_NAME] [nvarchar](360) NOT NULL,
			[STEP2_ITEM_NUM] [nvarchar](40) NULL,
			[CUSTOMER_ITEM] [nvarchar](50) NOT NULL,
			[DESCRIPTION] [nvarchar](240) NULL,
			[ITEM_TYPE] [nvarchar](30) NULL,
			[RANK] [float] NOT NULL,
			[Fingerprint] [varchar](32) NOT NULL
		)


		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

		INSERT INTO #customerPart (
			   [ACCT_NUM]
			  ,[ACCT_NAME]
			  ,[CUSTOMER_NAME]
			  ,[STEP2_ITEM_NUM]
			  ,[CUSTOMER_ITEM]
			  ,[DESCRIPTION]
			  ,[ITEM_TYPE]
			  ,[RANK]
			  ,[FINGERPRINT]
		)
		SELECT [ACCT_NUM]
			  ,[ACCT_NAME]
			  ,[CUSTOMER_NAME]
			  ,[STEP2_ITEM_NUM]
			  ,[CUSTOMER_ITEM]
			  ,[DESCRIPTION]
			  ,[ITEM_TYPE]
			  ,[RANK]
			  ,'XXX' AS Fingerprint
		FROM OPENQUERY(PROD,'
			SELECT		DISTINCT 
						hca.account_number      as ACCT_NUM 
						, hca.account_name      as ACCT_NAME 
						, hp.party_name         as customer_name 
						, mtl.segment1          as step2_item_num 
						, UPPER(mci.customer_item_number) as customer_item --remove case sensitivity
						, mtl.description 
						, mtl.item_type 
						, mcix.preference_number rank 
			FROM        mtl_customer_items   mci 
						, mtl_customer_item_xrefs mcix 
						, mtl_system_items mtl 
						, hz_cust_accounts hca 
						, hz_parties hp 
			WHERE       mci.customer_item_id = mcix.customer_item_id 
						and mcix.inventory_item_id = mtl.inventory_item_id 
						and mcix.master_organization_id = mtl.organization_id 
						and hca.cust_account_id = mci.customer_id 
						and hp.party_id = hca.party_id 
		')

		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('CustomerPartReference','Oracle') SELECT @columnList
		*/

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

		UPDATE #customerPart
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
					   CAST(ISNULL(ACCT_NUM,'') AS VARCHAR(30)) +  CAST(ISNULL(ACCT_NAME,'') AS VARCHAR(240)) +  CAST(ISNULL(CUSTOMER_NAME,'') AS VARCHAR(360)) +  CAST(ISNULL(STEP2_ITEM_NUM,'') AS VARCHAR(40)) +  CAST(ISNULL(CUSTOMER_ITEM,'') AS VARCHAR(50)) +  CAST(ISNULL(DESCRIPTION,'') AS VARCHAR(240)) +  CAST(ISNULL(ITEM_TYPE,'') AS VARCHAR(30)) +  CAST(ISNULL(RANK,'0') AS VARCHAR(100)) 
			),1)),3,32);

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO Oracle.CustomerPartReference (
			   [ACCT_NUM]
			  ,[ACCT_NAME]
			  ,[CUSTOMER_NAME]
			  ,[STEP2_ITEM_NUM]
			  ,[CUSTOMER_ITEM]
			  ,[DESCRIPTION]
			  ,[ITEM_TYPE]
			  ,[RANK]
			  ,[FINGERPRINT]
		)
			SELECT 
				   a.[ACCT_NUM]
				  ,a.[ACCT_NAME]
				  ,a.[CUSTOMER_NAME]
				  ,a.[STEP2_ITEM_NUM]
				  ,a.[CUSTOMER_ITEM]
				  ,a.[DESCRIPTION]
				  ,a.[ITEM_TYPE]
				  ,a.[RANK] 
				  ,a.[FINGERPRINT]
			FROM (
				MERGE Oracle.CustomerPartReference b
				USING (SELECT * FROM #customerPart) a
				ON a.ACCT_NUM = b.ACCT_NUM AND a.Step2_Item_Num = b.Step2_Item_Num AND a.[CUSTOMER_ITEM] = b.[CUSTOMER_ITEM] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [ACCT_NUM]
					  ,[ACCT_NAME]
					  ,[CUSTOMER_NAME]
					  ,[STEP2_ITEM_NUM]
					  ,[CUSTOMER_ITEM]
					  ,[DESCRIPTION]
					  ,[ITEM_TYPE]
					  ,[RANK]
					  ,[FINGERPRINT]
				)
				VALUES (
					   a.[ACCT_NUM]
					  ,a.[ACCT_NAME]
					  ,a.[CUSTOMER_NAME]
					  ,a.[STEP2_ITEM_NUM]
					  ,a.[CUSTOMER_ITEM]
					  ,a.[DESCRIPTION]
					  ,a.[ITEM_TYPE]
					  ,a.[RANK]
					  ,a.[FINGERPRINT]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[ACCT_NUM]
					  ,a.[ACCT_NAME]
					  ,a.[CUSTOMER_NAME]
					  ,a.[STEP2_ITEM_NUM]
					  ,a.[CUSTOMER_ITEM]
					  ,a.[DESCRIPTION]
					  ,a.[ITEM_TYPE]
					  ,a.[RANK]
					  ,a.[FINGERPRINT]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		DROP TABLE #customerPart

END
GO
