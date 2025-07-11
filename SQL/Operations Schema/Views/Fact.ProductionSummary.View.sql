USE [Operations]
GO
/****** Object:  View [Fact].[ProductionSummary]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Fact].[ProductionSummary] AS 
SELECT DateID, PlantID, ProductID
	,SUM([Production Qty]) AS [Production Qty] 
	,SUM([Total Dollars]) AS [Total Dollars]
	,SUM([Standard Cost]) AS [Standard Cost]
	,SUM([Machine Hours]) AS [Machine Hours]
	,SUM([FG Total Resin]) AS [FG Total Resin]
FROM Fact.Production 
WHERE ShiftOffsetID = 0
GROUP BY DateID, PlantID, ProductID
GO
