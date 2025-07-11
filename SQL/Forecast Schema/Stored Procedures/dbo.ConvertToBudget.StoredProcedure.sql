USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[ConvertToBudget]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ConvertToBudget] AS BEGIN
	
	UPDATE [Forecast].[dbo].[ForecastPeriod] SET Mode = 'B'

	UPDATE pbi
	SET BudgetID = 0
	FROM Forecast.dbo.FactSalesBudget pbi
		LEFT JOIN Operations.dbo.DimCalendarFiscal cf ON pbi.DateID = cf.DateID 
	WHERE (BudgetID = 13 AND cf.[Month Sort] >= (SELECT BudgetMonth FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod))

	IF (
		SELECT COUNT(*) FROM dbo.ForecastVersion 
		WHERE Year = (SELECT LEFT(BudgetMonth,4) FROM dbo.ForecastPeriod) 
			AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod)
			AND BudgetID = 0
		) > 1 
	BEGIN

		INSERT INTO dbo.ForecastVersion (BudgetID, ForecastVersion, ForecastDate, ForecastName, Year)
		SELECT 0
			, '0+12 B' 
			, GETDATE()
			, (SELECT LEFT(BudgetMonth,4) FROM dbo.ForecastPeriod) + ' Budget V1'
			, (SELECT LEFT(BudgetMonth,4) FROM dbo.ForecastPeriod)

	END
END
GO
