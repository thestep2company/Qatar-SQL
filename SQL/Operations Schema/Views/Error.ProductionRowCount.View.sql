USE [Operations]
GO
/****** Object:  View [Error].[ProductionRowCount]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[ProductionRowCount] AS 
SELECT SUM([Total Dollars]) AS NSP, COUNT(*) AS Records FROM Fact.Production WHERE DateID >= 44562 AND ShiftOffsetID = 1
UNION
SELECT SUM([Total Dollars]) AS NSP, COUNT(*) AS Records FROM Fact.Production20220321 WHERE DateID >= 44562 AND ShiftOffsetID = 1
GO
