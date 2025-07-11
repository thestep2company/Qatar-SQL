USE [Operations]
GO
/****** Object:  View [Error].[ResourceHours]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Error].[ResourceHours] AS 

SELECT CAST([TRANS_DATE_TIME] AS DATE) AS TransDate, COUNT(*) AS RecordCount
FROM [Manufacturing].[Production]
WHERE RESOURCE_HOURS = 0
GROUP BY CAST([TRANS_DATE_TIME] AS DATE)
GO
