USE [Operations]
GO
/****** Object:  View [Error].[ForcastMissingDays]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[ForcastMissingDays] AS 

--INSERT INTO xref.ProductionForecast 
SELECT shift.Org, shift.Shift, cf.DateKey, 0 AS [Percent] 
FROM dbo.[DimCalendarFiscal] cf
	LEFT JOIN [xref].[ProductionForecast] pf ON cf.DateKey = pf.Date 
	CROSS JOIN (SELECT DISTINCT Org, Shift FROM [xref].[ProductionForecast] WHERE Year(Date) = 2022) shift 
WHERE cf.Year = 2022 AND pf.Date IS NULL


GO
