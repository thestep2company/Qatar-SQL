USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[ForecastPrep02ForecastPeriod]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ForecastPrep02ForecastPeriod] 
AS BEGIN

	;WITH FirstWeekOfMonth AS (
		SELECT [Month Sort], MIN(WeekID) AS WeekID, MAX(DateKey) AS COGSDate, MIN(DateKey) AS CustomerSplitDate
		FROM dbo.DimCalendarFiscal 
		WHERE WeekID <> 0
		GROUP BY [Month Sort]
	)
	, DateSettings AS (
		SELECT fw.* 
		FROM dbo.DimCalendarFiscal cf
			INNER JOIN FirstWeekOfMonth fw ON cf.WeekID = fw.WeekID 
		WHERE CAST(GETDATE() AS DATE) = cf.DateKey --only check while in first week of month
	)
	UPDATE fp  
	SET fp.ForecastMonth = d.[Month Sort] 
		,fp.COGSDate = d.[COGSDate]
		,fp.CustomerSplitDate = d.CustomerSplitDate
		,fp.ShiftPriorForecast = 1
	FROM dbo.ForecastPeriod fp
		CROSS JOIN DateSettings d --1 row JOIN
	WHERE Mode = 'F'
		AND d.[Month Sort] <> (SELECT MIN([Month Sort]) FROM dbo.DimCalendarFiscal WHERE UseForecast = 1)
	--if proposed month setting does not match downloaded month setting, shift prior forecast
	--if proposed month setting matches downloaded month setting, do not shift prior forecast


	DECLARE @shiftPriorForecast BIT
	SET @shiftPriorForecast = (SELECT ShiftPriorForecast FROM dbo.ForecastPeriod)

	IF @shiftPriorForecast = 1 AND (SELECT Mode FROM dbo.ForecastPeriod) = 'F' BEGIN
		UPDATE dbo.FactSalesBudget SET BudgetID = BudgetID - 1 WHERE BudgetID < 0 --shift all prior forecasts one period
		DELETE FROM dbo.FactSalesBudget WHERE BudgetID < -12 --retain 12 prior forecasts
		UPDATE dbo.FactSalesBudget SET BudgetID = - 1 WHERE BudgetID = 13  --make current forecast prior
	END

	DECLARE @shiftPriorBudget BIT
	SET @shiftPriorBudget = (SELECT ShiftPriorBudget FROM dbo.ForecastPeriod)

	IF @shiftPriorBudget = 1 AND (SELECT Mode FROM dbo.ForecastPeriod) = 'B' BEGIN
		UPDATE sb 
		SET BudgetID = BudgetID + 1
		FROM dbo.FactSalesBudget sb 
			LEFT JOIN dbo.DimCalendarFiscal cf ON sb.DateID = cf.DateID 
		WHERE [Month Sort] >= (SELECT BudgetMonth FROM dbo.ForecastPeriod)
			AND BudgetID >= 0 AND BudgetID < 12--shift all prior forecasts one period

		DELETE FROM dbo.FactSalesBudget WHERE BudgetID > 12 --retain 12 prior budget
	END

END	
GO
