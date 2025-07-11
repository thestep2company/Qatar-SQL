USE [Operations]
GO
/****** Object:  StoredProcedure [Diff].[OrdersChangeLogging]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Diff].[OrdersChangeLogging] AS BEGIN
	--if ssas sales orders processing succeeds
	DECLARE @job VARCHAR(50) = 'Sales'
	DECLARE @step VARCHAR(50) = 'Orders'

	DECLARE @lastBatchProcessed DATETIME, @currentBatch DATETIME, @recordCount INT
	SELECT @currentBatch = MAX(TimeStamp) FROM dbo.SSASProcessingLog WHERE Processed = 0 AND Job = @job AND Step = @step
	SELECT @lastBatchProcessed = MAX(TimeStamp) FROM dbo.SSASProcessingLog WHERE Processed > 0  AND Job = @job AND Step = @step

	SELECT @currentBatch, @lastBatchProcessed

	SELECT @recordCount = COUNT(*) FROM [Fact].[SalesChangeRecords] WHERE SaleTypeID = 1

	UPDATE dbo.SSASProcessingLog SET Processed = @recordCount WHERE TimeStamp BETWEEN DATEADD(MINUTE,1,@lastBatchProcessed) AND DATEADD(MINUTE,1,@currentBatch) AND Job = @job AND Step = @step
	
END
GO
