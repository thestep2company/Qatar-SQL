USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimForecastPeriod]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Reload_DimForecastPeriod] 
AS BEGIN
	TRUNCATE TABLE dbo.DimForecastPeriod	
	INSERT INTO dbo.DimForecastPeriod SELECT * FROM Dim.ForecastPeriod lp	
END
GO
