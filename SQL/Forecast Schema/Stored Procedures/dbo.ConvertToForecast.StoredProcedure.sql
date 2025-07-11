USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[ConvertToForecast]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ConvertToForecast] AS BEGIN
	
	UPDATE pbi
	SET BudgetID = 13
	FROM dbo.FactSalesBudget pbi
		LEFT JOIN dbo.DimCalendarFiscal cf ON pbi.DateID = cf.DateID 
	WHERE (BudgetID = 0 AND cf.[Month Sort] >= (SELECT BudgetMonth FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod))

	UPDATE [dbo].[ForecastPeriod] SET Mode = 'F'

END
  
GO
