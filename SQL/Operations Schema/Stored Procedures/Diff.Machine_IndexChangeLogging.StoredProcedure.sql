USE [Operations]
GO
/****** Object:  StoredProcedure [Diff].[Machine_IndexChangeLogging]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Diff].[Machine_IndexChangeLogging] AS BEGIN
	--if ssas sales orders processing succeeds
	DECLARE @job VARCHAR(50) = 'Production'
	DECLARE @step VARCHAR(50) = 'Machine_Index'

	DECLARE @lastBatchProcessed DATETIME, @currentBatch DATETIME, @recordCount INT
	SELECT @currentBatch = MAX(TimeStamp) FROM dbo.SSASProcessingLog WHERE Processed = 0 AND Job = @job AND Step = @step
	SELECT @lastBatchProcessed = MAX(TimeStamp) FROM dbo.SSASProcessingLog WHERE Processed > 0  AND Job = @job AND Step = @step

	SELECT @currentBatch, @lastBatchProcessed

	SELECT @recordCount = COUNT(*) FROM [Fact].[CycleTimeChangeRecords]

	UPDATE dbo.SSASProcessingLog SET Processed = @recordCount WHERE TimeStamp BETWEEN DATEADD(MINUTE,1,@lastBatchProcessed) AND DATEADD(MINUTE,1,@currentBatch) AND Job = @job AND Step = @step
	
END
GO
