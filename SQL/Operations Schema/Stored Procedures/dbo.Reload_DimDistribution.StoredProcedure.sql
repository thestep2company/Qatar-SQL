USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimDistribution]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Reload_DimDistribution] 
AS BEGIN
	TRUNCATE TABLE dbo.DimDistribution	
	SET IDENTITY_INSERT dbo.DimDistribution ON 

	INSERT INTO dbo.DimDistribution (
	   [BucketID]
      ,[BucketKey]
      ,[BucketNickle]
      ,[BucketNickelSort]
      ,[BucketDime]
      ,[BucketDimeSort]
      ,[BucketQuarter]
      ,[BucketQuarterSort]
      ,[BucketHalf]
      ,[BucketHalfSort]
      ,[BucketOne]
      ,[BucketOneSort]
      ,[BucketFive]
      ,[BucketFiveSort]
      ,[BucketTen]
      ,[BucketTenSort]
	)
	SELECT * FROM Dim.Distribution OPTION (maxrecursion 0)
END
GO
