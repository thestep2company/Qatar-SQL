USE [Operations]
GO
/****** Object:  View [Dim].[ForecastPeriod]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[ForecastPeriod] AS 
SELECT MIN([MonthID]) AS MonthID 
FROM dbo.DimCalendarFiscal cf
WHERE cf.DateKey = CAST(GETDATE() AS DATE) --any year forecast
GO
