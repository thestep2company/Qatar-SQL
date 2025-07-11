USE [Operations]
GO
/****** Object:  StoredProcedure [Diff].[InvoiceChangeRecords]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Diff].[InvoiceChangeRecords] AS BEGIN

	DECLARE @job VARCHAR(50) = 'Sales'
	DECLARE @step VARCHAR(50) = 'Invoice'

	--insert new batch
	;
	WITH CTE AS (
		SELECT @job AS Job, @step AS Step, MAX(StartDate) AS TimeStamp
		FROM Oracle.Invoice o
	)
	INSERT INTO dbo.SSASProcessingLog
	SELECT cte.Job, cte.Step, cte.TimeStamp,  COUNT(*) AS RecordCount, 0 AS Processed  
	FROM Oracle.Invoice o
		INNER JOIN CTE ON o.StartDate = cte.TimeStamp
		LEFT JOIN dbo.SSASProcessingLog l ON cte.TimeStamp = l.TimeStamp AND cte.Job = l.Job AND cte.Step = l.Step
	WHERE l.Step IS NULL
	GROUP BY cte.Job, cte.Step, cte.TimeStamp

	DECLARE @lastBatchProcessed DATETIME, @currentBatch DATETIME
	SELECT @currentBatch = MAX(TimeStamp) FROM dbo.SSASProcessingLog WHERE Processed = 0  AND Job = @job AND Step = @step
	SELECT @lastBatchProcessed = MAX(TimeStamp) FROM dbo.SSASProcessingLog WHERE Processed > 0  AND Job = @job AND Step = @step
	
	TRUNCATE TABLE Oracle.InvoiceChangeRecords

	SET IDENTITY_INSERT Oracle.InvoiceChangeRecords ON

	INSERT INTO Oracle.InvoiceChangeRecords (
	   [ID]
      ,[REVENUE_TYPE]
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
	SELECT i.ID
      ,i.[REVENUE_TYPE]
      ,i.[CUSTOMER_TRX_ID]
      ,i.[CUSTOMER_TRX_LINE_ID]
      ,i.[SALES_CHANNEL_CODE]
      ,i.[CUST_GROUP]
      ,i.[DEM_CLASS]
      ,i.[BUSINESS_SEGMENT]
      ,i.[FINANCE_CHANNEL]
      ,i.[ACCT_NUM]
      ,i.[ACCT_NAME]
      ,i.[SHIP_TO_ADDRESS1]
      ,i.[SHIP_TO_ADDRESS2]
      ,i.[SHIP_TO_ADDRESS3]
      ,i.[SHIP_TO_ADDRESS4]
      ,i.[SHIP_TO_CITY]
      ,i.[SHIP_TO_STATE]
      ,i.[SHIP_TO_POSTAL_CODE]
      ,i.[SHIP_TO_COUNTRY]
      ,i.[SHIP_TO_PROVINCE]
      ,i.[CUST_PO_NUM]
      ,i.[ORDER_NUM]
      ,i.[SO_LINE_NUM]
      ,i.[AR_TYPE]
      ,i.[CONSOL_INV]
      ,i.[TRX_NUMBER]
      ,i.[SKU]
      ,i.[INV_DESCRIPTION]
      ,i.[ITEM_TYPE]
      ,i.[SIOP_FAMILY]
      ,i.[CATEGORY]
      ,i.[SUBCATEGORY]
      ,i.[INVENTORY_ITEM_STATUS_CODE]
      ,i.[WH_CODE]
      ,i.[ITEM_FROZEN_COST]
      ,i.[GL_PERIOD]
      ,i.[PERIOD_NUM]
      ,i.[PERIOD_YEAR]
      ,DATEADD(HOUR,DATEPART(HOUR,StartDate),i.[GL_DATE]) AS GL_DATE
      ,i.[QTY_INVOICED]
      ,i.[UOM]
      ,i.[GL_REVENUE_DISTRIBUTION]
      ,i.[ENTERED_AMOUNT]
      ,i.[CURRENCY]
      ,i.[ACCTD_USD]
      ,i.[GL_COGS_DISTRIBUTION]
      ,i.[COGS_AMOUNT]
      ,i.[MARGIN_USD]
      ,i.[MARGIN_PCT]
      ,i.[SO_LINE_ID]
      ,i.[FRZ_COST]
      ,i.[FRZ_MAT_COST]
      ,i.[FRZ_MAT_OH]
      ,i.[FRZ_RESOUCE]
      ,i.[FRZ_OUT_PROC]
      ,i.[FRZ_OH]
	FROM (
			SELECT CUSTOMER_TRX_LINE_ID, CAST(GL_DATE AS DATE) AS GL_DATE
				,SUM([ACCTD_USD]) AS ACCTD_USD
				,SUM([ENTERED_AMOUNT]) AS ENTERED_AMOUNT
				,SUM([ITEM_FROZEN_COST]) AS ITEM_FROZEN_COST
				,SUM([QTY_INVOICED]) AS QTY
			FROM Oracle.Invoice 
			WHERE StartDate BETWEEN DATEADD(MINUTE,-1,@currentBatch ) AND DATEADD(MINUTE,1,@currentBatch) AND EndDate IS NULL
			GROUP BY CUSTOMER_TRX_LINE_ID, CAST(GL_DATE AS DATE)
		) i1
		LEFT JOIN (
			SELECT CUSTOMER_TRX_LINE_ID, CAST(GL_DATE AS DATE) AS GL_DATE
				,SUM([ACCTD_USD]) AS ACCTD_USD
				,SUM([ENTERED_AMOUNT]) AS ENTERED_AMOUNT
				,SUM([ITEM_FROZEN_COST]) AS ITEM_FROZEN_COST
				,SUM([QTY_INVOICED]) AS QTY
			FROM Oracle.Invoice o1
				INNER JOIN (  --need to pick the first occurence of the record in case job has been failing and more than one version is available	
					SELECT DISTINCT MIN(ID) OVER (PARTITION BY CUSTOMER_TRX_LINE_ID, CAST(GL_DATE AS DATE)) AS ID
					FROM Oracle.Invoice
					WHERE EndDate BETWEEN DATEADD(MINUTE,-1,@lastBatchProcessed) AND DATEADD(MINUTE,1,@currentBatch)
				) o2 ON o1.ID = o2.ID
			GROUP BY CUSTOMER_TRX_LINE_ID, CAST(GL_DATE AS DATE) 	
		) i2 ON i1.CUSTOMER_TRX_LINE_ID = i2.CUSTOMER_TRX_LINE_ID AND CAST(i1.GL_DATE AS DATE) = i2.GL_DATE
		LEFT JOIN Oracle.Invoice i ON i.CUSTOMER_TRX_LINE_ID = i1.CUSTOMER_TRX_LINE_ID AND CAST(i.GL_DATE AS DATE) = i1.GL_DATE
	WHERE (i1.QTY <> ISNULL(i2.QTY,0) OR i1.ACCTD_USD <> ISNULL(i2.ACCTD_USD,0) OR i1.ENTERED_AMOUNT <> ISNULL(i2.ENTERED_AMOUNT,0) OR i1.ITEM_FROZEN_COST <> ISNULL(i2.ITEM_FROZEN_COST,0)) AND i.CurrentRecord = 1 --has a difference

END
GO
