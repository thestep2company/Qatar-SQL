USE [Operations]
GO
/****** Object:  View [Error].[MAPP]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[MAPP] AS 
SELECT a.* --b.* 
--UPDATE a SET a.EndDate = DATEADD(SECOND,-1,b.StartDate)
FROM dbo.MAPP a
	INNER JOIN dbo.MAPP b ON a.SKU = b.SKU AND ISNULL(a.DemandClass,'') = ISNULL(b.DemandClass,'') AND a.StartDate < b.StartDate AND a.EndDate > b.StartDate
GO
