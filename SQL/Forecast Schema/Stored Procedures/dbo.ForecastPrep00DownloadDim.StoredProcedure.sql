USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[ForecastPrep00DownloadDim]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ForecastPrep00DownloadDim] AS BEGIN

	DROP TABLE IF EXISTS dbo.DimCalendarFiscal 
	SELECT * INTO dbo.DimCalendarFiscal FROM Operations.dbo.DimCalendarFiscal

	DROP TABLE IF EXISTS  dbo.DimM2MTimeSeries
	SELECT * INTO dbo.DimM2MTimeSeries	FROM Operations.dbo.DimM2MTimeSeries

	DROP TABLE IF EXISTS  dbo.DimTimeSeries
	SELECT * INTO dbo.DimTimeSeries		FROM Operations.dbo.DimTimeSeries
	
	DROP TABLE IF EXISTS  dbo.DimProductMaster  
	SELECT * INTO dbo.DimProductMaster  FROM Operations.dbo.DimProductMaster

	DROP TABLE IF EXISTS  dbo.DimCustomerMaster 
	SELECT * INTO dbo.DimCustomerMaster FROM Operations.dbo.DimCustomerMaster
	
	DROP TABLE IF EXISTS  dbo.DimDemandClass
	SELECT * INTO dbo.DimDemandClass	FROM Operations.dbo.DimDemandClass
	
	DROP TABLE IF EXISTS  dbo.DimPricingDistribution
	SELECT * INTO dbo.DimPricingDistribution FROM Operations.dbo.DimPricingDistribution

	DROP TABLE IF EXISTS  dbo.DimRevenueType
	SELECT * INTO dbo.DimRevenueType	FROM Operations.dbo.DimRevenueType

	DROP TABLE IF EXISTS dbo.ForecastVersion 
	SELECT * INTO dbo.ForecastVersion FROM Operations.Forecast.ForecastVersion
	
	DROP TABLE IF EXISTS dbo.DimOrderCurveProductGroup
	SELECT * INTO dbo.DimOrderCurveProductGroup FROM Dim.OrderCurveProductGroup

	DROP TABLE IF EXISTS xref.[Customer Grid by Account]
	SELECT * INTO xref.[Customer Grid by Account] FROM XREF.dbo.[Customer Grid by Account]

	DROP TABLE IF EXISTS xref.[Customer Grid Misc]
	SELECT * INTO xref.[Customer Grid Misc] FROM XREF.dbo.[Customer Grid Misc]

	DROP TABLE IF EXISTS xref.[CustomerGridBySKU]
	SELECT * INTO xref.[CustomerGridBySKU] FROM XREF.dbo.[CustomerGridBySKU]

END
GO
