USE [Operations]
GO
/****** Object:  StoredProcedure [Diff].[ProductionChangeRecords]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Diff].[ProductionChangeRecords] AS BEGIN

	DECLARE @job VARCHAR(50) = 'Production'
	DECLARE @step VARCHAR(50) = 'Production'

	--insert new batch
	--;
	--WITH CTE AS (
	--	SELECT @job AS Job, @step AS Step, MAX(StartDate) AS TimeStamp
	--	FROM Manufacturing.Production o
	--)
	--INSERT INTO dbo.SSASProcessingLog
	--SELECT cte.Job, cte.Step, cte.TimeStamp,  COUNT(*) AS RecordCount, 0 AS Processed  
	--FROM Manufacturing.Production o
	--	INNER JOIN CTE ON o.StartDate = cte.TimeStamp
	--	LEFT JOIN dbo.SSASProcessingLog l ON cte.TimeStamp = l.TimeStamp AND cte.Job = l.Job AND cte.Step = l.Step
	--WHERE l.Step IS NULL
	--GROUP BY cte.Job, cte.Step, cte.TimeStamp

	DECLARE @lastBatchProcessed DATETIME, @currentBatch DATETIME
	SELECT @currentBatch = MAX(TimeStamp) FROM dbo.SSASProcessingLog WHERE Processed = 0  AND Job = @job AND Step = @step
	SELECT @lastBatchProcessed = MAX(TimeStamp) FROM dbo.SSASProcessingLog WHERE Processed > 0  AND Job = @job AND Step = @step
	
	SELECT @lastBatchProcessed, @currentBatch

	;WITH CurrentProduction AS (
		SELECT i.* FROM Manufacturing.Production i
		WHERE StartDate BETWEEN DATEADD(MINUTE,-1,@currentBatch ) AND DATEADD(MINUTE,1,@currentBatch) AND EndDate IS NULL
	)
	, PriorProduction AS (
			SELECT PRODUCTION_ID
			FROM Manufacturing.Production o1
				INNER JOIN (  --need to pick the first occurence of the record in case job has been failing and more than one version is available	
					SELECT DISTINCT MIN(ID) OVER (PARTITION BY PRODUCTION_ID) AS RowNumber, ID
					FROM Manufacturing.Production i
					WHERE EndDate BETWEEN DATEADD(MINUTE,-1,@lastBatchProcessed) AND DATEADD(MINUTE,1,@currentBatch)
				) o2 ON o1.ID = o2.ID
			GROUP BY PRODUCTION_ID
	)
	--new production
	SELECT co.*
	FROM CurrentProduction co
		LEFT JOIN PriorProduction po ON co.PRODUCTION_ID = po.PRODUCTION_ID 
	WHERE po.PRODUCTION_ID IS NULL 
END



GO
