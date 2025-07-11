USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Update_FactCurrentDayEstimate]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Update_FactCurrentDayEstimate] AS BEGIN
TRUNCATE TABLE [dbo].[FactCurrentDayEstimate]
 INSERT INTO [dbo].[FactCurrentDayEstimate] ([SalesEstimate], [NetSalesEstimate])
 SELECT [SalesEstimate], [NetSalesEstimate] FROM Fact.CurrentDayEstimate

 UPDATE [dbo].[FactCurrentDayEstimate] SET [AmazonSalesEstimate] = ae.[AmazonSalesEstimate]
      ,[AmazonNetSalesEstimate] = ae.[AmazonNetSalesEstimate]
	  FROM Fact.CurrentDayEstimateAmazon ae

 INSERT INTO dbo.CurrentDayEstimateLog
(SalesEstimate, NetSalesEstimate)
SELECT [SalesEstimate], [NetSalesEstimate] FROM Fact.CurrentDayEstimate

 END
GO
