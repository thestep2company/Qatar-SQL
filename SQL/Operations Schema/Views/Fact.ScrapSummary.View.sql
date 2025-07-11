USE [Operations]
GO
/****** Object:  View [Fact].[ScrapSummary]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[ScrapSummary] AS
SELECT DateID, PlantID, ProductID, RepairID
	,SUM([Qty]) AS Qty
	,SUM([Lbs]) AS Lbs
FROM Fact.Scrap
WHERE ShiftOffsetID = 0
GROUP BY DateID, PlantID, ProductID, RepairID
GO
