USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[ForecastPrep06CustomerDistribution]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ForecastPrep06CustomerDistribution] AS BEGIN

	DROP TABLE IF EXISTS  dbo.FactCustomerDist
	SELECT * INTO dbo.FactCustomerDist FROM Fact.CustomerDist

	DROP TABLE IF EXISTS  dbo.FactCustomerDistBySKU
	SELECT * INTO dbo.FactCustomerDistBySKU FROM Fact.CustomerDistBySKU

END
GO
