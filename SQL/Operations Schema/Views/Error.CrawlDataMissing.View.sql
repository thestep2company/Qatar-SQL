USE [Operations]
GO
/****** Object:  View [Error].[CrawlDataMissing]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[CrawlDataMissing] AS 
SELECT * FROM dbo.FactMAPP WHERE EndDate IS NULL AND StartDate <= '2021-01-01'
GO
