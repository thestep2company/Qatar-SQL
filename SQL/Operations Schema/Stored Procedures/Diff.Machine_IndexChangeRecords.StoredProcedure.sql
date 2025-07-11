USE [Operations]
GO
/****** Object:  StoredProcedure [Diff].[Machine_IndexChangeRecords]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Diff].[Machine_IndexChangeRecords] AS BEGIN

	DECLARE @job VARCHAR(50) = 'Production'
	DECLARE @step VARCHAR(50) = 'Machine_Index'

	--insert new batch
	;
	WITH CTE AS (
		SELECT @job AS Job, @step AS Step, MAX(StartDate) AS TimeStamp
		FROM Manufacturing.MACHINE_INDEX o
	)
	INSERT INTO dbo.SSASProcessingLog
	SELECT cte.Job, cte.Step, cte.TimeStamp,  COUNT(*) AS RecordCount, 0 AS Processed  
	FROM Manufacturing.MACHINE_INDEX o
		INNER JOIN CTE ON o.StartDate = cte.TimeStamp
		LEFT JOIN dbo.SSASProcessingLog l ON cte.TimeStamp = l.TimeStamp AND cte.Job = l.Job AND cte.Step = l.Step
	WHERE l.Step IS NULL
	GROUP BY cte.Job, cte.Step, cte.TimeStamp

	DECLARE @lastBatchProcessed DATETIME, @currentBatch DATETIME
	SELECT @currentBatch = MAX(TimeStamp) FROM dbo.SSASProcessingLog WHERE Processed = 0  AND Job = @job AND Step = @step
	SELECT @lastBatchProcessed = MAX(TimeStamp) FROM dbo.SSASProcessingLog WHERE Processed > 0  AND Job = @job AND Step = @step
	

	TRUNCATE TABLE [Manufacturing].[Machine_IndexChangeRecords]

	INSERT INTO [Manufacturing].[Machine_IndexChangeRecords]
	SELECT [ID]
      ,[INDEX_ID]
      ,[MACHINE_ID]
      ,[DATE_TIME]
      ,[REC_TYPE]
      ,[PLANT]
      ,[SHIFT]
      ,[MACHINE_NUM]
      ,[ARM_NUMBER]
      ,[MACHINE_SIZE]
      ,[SPIDER_SIDE_1]
      ,[SPIDER_SIDE_2]
      ,[CYCLE_COUNT]
      ,[DEAD_ARM]
      ,[MISSED_CYCLE]
      ,[REASON_CODE]
      ,[MISSED_TIME]
      ,[OVEN_TEMP]
      ,[CYCLE_TIME]
      ,[COOLER_1_FAN_DELAY]
      ,[COOLER_1_FAN_TIME]
      ,[COOLER_2_WATER_DELAY]
      ,[WATER_TIME]
      ,[COOLER_2_FAN_TIME]
      ,[OUTSIDE_AIR_TEMP]
      ,[CREATE_DATE]
      ,[REASON_DESCRIPTION]
      ,[OPERATOR]
      ,[COMPUTER_NAME]
      ,[SHIFT_DATE]
      ,[INDEX_TIME]
      ,[OPERATOR_NAME]
      ,[TransDate]
      ,[TransDateOffset]
      ,[SHIFT_ID]
    FROM [Manufacturing].[MACHINE_INDEX]
	WHERE StartDate BETWEEN DATEADD(MINUTE,-1,@currentBatch ) AND DATEADD(MINUTE,1,@currentBatch) AND EndDate IS NULL

END
GO
