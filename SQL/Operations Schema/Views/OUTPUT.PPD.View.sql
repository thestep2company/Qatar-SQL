USE [Operations]
GO
/****** Object:  View [OUTPUT].[PPD]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[PPD] AS
SELECT [Month Sort], INV_DESCRIPTION, SUM(ACCTD_USD) AS Sales
FROM Oracle.Invoice i
	LEFT JOIN dbo.DimCalendarFiscal cf ON i.GL_Date = cf.DateKey 
WHERE INV_DESCRIPTION LIKE '%S2C PPD%' 
GROUP BY [Month Sort], INV_DESCRIPTION
--ORDER BY [Month Sort], INV_DESCRIPTION
GO
