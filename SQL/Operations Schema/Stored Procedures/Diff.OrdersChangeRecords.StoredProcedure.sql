USE [Operations]
GO
/****** Object:  StoredProcedure [Diff].[OrdersChangeRecords]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Diff].[OrdersChangeRecords] AS BEGIN

	DECLARE @job VARCHAR(50) = 'Sales'
	DECLARE @step VARCHAR(50) = 'Orders'

	--insert new batch
	;
	WITH CTE AS (
		SELECT @job AS Job, @step AS Step, MAX(StartDate) AS TimeStamp
		FROM Oracle.Orders o
	)
	INSERT INTO dbo.SSASProcessingLog
	SELECT cte.Job, cte.Step, cte.TimeStamp,  COUNT(*) AS RecordCount, 0 AS Processed  
	FROM Oracle.Orders o
		INNER JOIN CTE ON o.StartDate = cte.TimeStamp
		LEFT JOIN dbo.SSASProcessingLog l ON cte.TimeStamp = l.TimeStamp AND cte.Job = l.Job AND cte.Step = l.Step
	WHERE l.Step IS NULL
	GROUP BY cte.Job, cte.Step, cte.TimeStamp

	DECLARE @lastBatchProcessed DATETIME, @currentBatch DATETIME
	SELECT @currentBatch = MAX(TimeStamp) FROM dbo.SSASProcessingLog WHERE Processed = 0  AND Job = @job AND Step = @step
	SELECT @lastBatchProcessed = MAX(TimeStamp) FROM dbo.SSASProcessingLog WHERE Processed > 0  AND Job = @job AND Step = @step
	
	TRUNCATE TABLE Oracle.OrdersChangeRecords

	SET IDENTITY_INSERT Oracle.OrdersChangeRecords ON 

	INSERT INTO Oracle.OrdersChangeRecords (
	   [ID]
	  ,[ORD_LINE_ID]
      ,[ORD_HEADER_ID]
      ,[CUSTOMER_NAME]
      ,[CUSTOMER_NUM]
      ,[SALES_CHANNEL_CODE]
      ,[DEMAND_CLASS]
      ,[ORDER_DATE]
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
	)
	SELECT i.ID
      ,i.[ORD_LINE_ID]
      ,i.[ORD_HEADER_ID]
      ,i.[CUSTOMER_NAME]
      ,i.[CUSTOMER_NUM]
      ,i.[SALES_CHANNEL_CODE]
      ,i.[DEMAND_CLASS]
      ,i.[ORDER_DATE]
      ,i.[ORDER_NUM]
      ,i.[PART]
      ,i.[ORDERED_ITEM]
      ,i.[PART_DESC]
      ,i.[FLOW_STATUS_CODE]
      ,i1.[QTY] - ISNULL(i2.[QTY],0) AS [QTY]
      ,i1.[SELL_DOLLARS] - ISNULL(i2.[SELL_DOLLARS],0) AS [SELL_DOLLARS]
      ,i1.[LIST_DOLLARS] - ISNULL(i2.[LIST_DOLLARS],0) AS [LIST_DOLLARS]
      ,i.[DATE_REQUESTED]
      ,i.[SCH_SHIP_DATE]
      ,i.[CANCEL_DATE]
      ,i.[PLANT]
      ,i.[CREATE_DATE]
      ,i.[ORD_LINE_CREATE_DATE]
      ,i.[ORD_LINE_LST_UPDATE_DATE]
      ,i.[SHIP_TO_ADDRESS1]
      ,i.[SHIP_TO_ADDRESS2]
      ,i.[SHIP_TO_ADDRESS3]
      ,i.[SHIP_TO_ADDRESS4]
      ,i.[SHIP_TO_CITY]
      ,i.[SHIP_TO_STATE]
      ,i.[SHIP_TO_POSTAL_CODE]
      ,i.[SHIP_TO_COUNTRY]
      ,i.[SHIP_TO_PROVINCE]
	FROM (
			SELECT ORD_LINE_ID, CAST(ORDER_DATE AS DATE) AS ORDER_DATE, SUM(LIST_DOLLARS) AS LIST_DOLLARS, SUM(QTY) AS QTY, SUM(SELL_DOLLARS) AS SELL_DOLLARS 
			FROM Oracle.Orders 
			WHERE StartDate BETWEEN DATEADD(MINUTE,-1,@currentBatch ) AND DATEADD(MINUTE,1,@currentBatch) AND EndDate IS NULL
			GROUP BY ORD_LINE_ID, CAST(ORDER_DATE AS DATE)
		) i1
		LEFT JOIN (
			SELECT ORD_LINE_ID, CAST(ORDER_DATE AS DATE) AS ORDER_DATE, SUM(LIST_DOLLARS) AS LIST_DOLLARS, SUM(QTY) AS QTY, SUM(SELL_DOLLARS) AS SELL_DOLLARS 
			FROM Oracle.Orders o1
				INNER JOIN (  --need to pick the first occurence of the record in case job has been failing and more than one version is available	
					SELECT DISTINCT MIN(ID) OVER (PARTITION BY ORD_LINE_ID, CAST(ORDER_DATE AS DATE)) AS ID
					FROM Oracle.Orders 
					WHERE EndDate BETWEEN DATEADD(MINUTE,-1,@lastBatchProcessed) AND DATEADD(MINUTE,1,@currentBatch)
				) o2 ON o1.ID = o2.ID
			GROUP BY ORD_LINE_ID, CAST(ORDER_DATE AS DATE) 	
		) i2 ON i1.ORD_LINE_ID = i2.ORD_LINE_ID AND CAST(i1.ORDER_DATE AS DATE) = i2.ORDER_DATE
		LEFT JOIN Oracle.Orders i ON i.ORD_LINE_ID = i1.ORD_LINE_ID AND CAST(i.ORDER_DATE AS DATE) = i1.ORDER_DATE
	WHERE (i1.QTY <> ISNULL(i2.QTY,0) OR i1.LIST_DOLLARS <> ISNULL(i2.LIST_DOLLARS,0) OR i1.SELL_DOLLARS <> ISNULL(i2.SELL_DOLLARS,0)) AND i.CurrentRecord = 1--has a difference

END
GO
