USE [Forecast]
GO
/****** Object:  View [dbo].[DimForecastVersion]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE VIEW [dbo].[DimForecastVersion] AS 
	SELECT BudgetID
		, ForecastVersion
	FROM dbo.ForecastVersion
	WHERE ForecastVersion NOT LIKE '%V%'
GO
