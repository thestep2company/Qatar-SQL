USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[ForecastPrep05LabelForecast]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ForecastPrep05LabelForecast] AS BEGIN

	IF (SELECT Mode FROM dbo.ForecastPeriod) = 'F' AND (SELECT ShiftPriorForecast FROM dbo.ForecastPeriod) = 1 BEGIN

		--only retain 12 prior versions
		DELETE FROM dbo.ForecastVersion WHERE BudgetID = -12

		--advance the forecast
		UPDATE dbo.ForecastVersion SET BudgetID = BudgetID - 1 WHERE BudgetID < 0
		UPDATE dbo.ForecastVersion SET BudgetID = -1 WHERE BudgetID = 13

		--insert current forecast
		INSERT INTO dbo.ForecastVersion (BudgetID, ForecastVersion, ForecastDate, ForecastName, Year)
		SELECT 13
			, CAST(CAST([Month Seasonality Sort] AS INT) AS VARCHAR(2)) + '+' + CAST(12 - [Month Seasonality Sort] AS VARCHAR(2))
			, GETDATE() AS ForecastDate 
			, (SELECT LEFT(ForecastMonth,4) FROM dbo.ForecastPeriod) + ' Forecast ' + CAST(CAST([Month Seasonality Sort] AS INT) AS VARCHAR(2)) + '+' + CAST(12 - [Month Seasonality Sort] AS VARCHAR(2))
			, YEAR(DateKey)
		FROM dbo.DimCalendarFiscal WHERE DateKey IN (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal WHERE UseActual = 1 AND CurrentYear = 'Current Year')

		----Added step to LabelForecast INSERT 0+12 if no UseActual flags are available for the current year
		--IF (SELECT MAX(BudgetID) FROM dbo.ForecastVersion) <> 13
		--	INSERT INTO dbo.ForecastVersion SELECT 13, '0+12', GETDATE(), CAST(YEAR(GETDATE()) AS VARCHAR(4)) + ' Forecast 0+12', YEAR(GETDATE())		

		----if we are in the same accounting period still (UseActual has not advanced still) call the moving forecat "Current" and the prior will be the frozen
		--IF (SELECT ForecastVersion FROM dbo.ForecastVersion WHERE BudgetID = -1) = (SELECT ForecastVersion FROM dbo.ForecastVersion WHERE BudgetID = 13)
		UPDATE dbo.ForecastVersion SET ForecastVersion = 'Demand', ForecastName = 'Demand Forecast' WHERE BudgetID = 13
			
	END


	IF (SELECT Mode FROM dbo.ForecastPeriod) = 'B' AND (SELECT ShiftPriorBudget FROM dbo.ForecastPeriod) = 1 BEGIN
		
		--only retain 12 prior versions
		DELETE FROM dbo.ForecastVersion WHERE BudgetID = 12

		--the UPDATE is advancing the budget version like this... 
		--SELECT BudgetID, ForecastVersion, BudgetID + 1 AS RenameBudgetID, ForecastVersion + CASE WHEN ForecastVersion NOT LIKE '%V%' THEN ' V' + (SELECT CAST(CAST(MAX(RIGHT(ForecastVersion,1)) AS INT)+1 AS VARCHAR(1)) FROM dbo.ForecastVersion WHERE BudgetID >= 0 AND ForecastVersion LIKE '%V%') ELSE '' END AS RenameForecastVersion FROM dbo.ForecastVersion WHERE BudgetID >= 0 AND BudgetID < 12 ORDER BY BudgetID DESC

		UPDATE dbo.ForecastVersion 
		SET BudgetID = BudgetID + 1, ForecastVersion = ForecastVersion + CASE WHEN ForecastVersion NOT LIKE '%V%' THEN ' V' + (SELECT CAST(CAST(MAX(RIGHT(ForecastVersion,1)) AS INT)+1 AS VARCHAR(1)) FROM dbo.ForecastVersion WHERE BudgetID >= 0 AND ForecastVersion LIKE '%V%') ELSE '' END
		WHERE BudgetID >= 0 AND BudgetID < 12
	
	END

END	

GO
