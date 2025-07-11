USE [Operations]
GO
/****** Object:  View [OUTPUT].[REC_PPDFRT]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[REC_PPDFRT] AS
--sales model
SELECT cf.[Month Sort]
	, i.[REPORTING_REVENUE_TYPE]
	, SUM(ACCTD_USD) AS Sales
FROM Oracle.Invoice i
	LEFT JOIN dbo.DimRevenueType r ON i.REVENUE_TYPE = r.RevenueKey
	LEFT JOIN dbo.DimCalendarFiscal cf ON i.GL_DATE = cf.DateKey
WHERE i.CurrentRecord = 1 AND cf.DateID >= (43100 + 366) 
	AND cf.[Month Sort] = '202304' 
	AND INV_DESCRIPTION LIKE 'S2C PPD%' 
GROUP BY cf.[Month Sort]
	, i.[REPORTING_REVENUE_TYPE]
GO
