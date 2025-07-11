USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[ForecastUpload]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ForecastUpload]
	--@reloadPriorForecast BIT = 1
AS BEGIN

	BEGIN TRY 
		BEGIN TRAN Upload

		--update the calendar for new forecast
		UPDATE cf1
		SET	cf1.UseActual = cf2.UseActual
			,cf1.UseActualPrior = cf2.UseActualPrior
			,cf1.UseForecast = cf2.UseForecast
			,cf1.UseForecastPrior = cf2.UseForecastPrior
		--SELECT *
		FROM Operations.dbo.DimCalendarFiscal cf1
			LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf1.DateKey = cf2.DateKey
		WHERE ISNULL(cf1.UseActual,0) <> ISNULL(cf2.UseActual,0)
			OR ISNULL(cf1.UseActualPrior,0) <> ISNULL(cf2.UseActualPrior,0)
			OR ISNULL(cf1.UseForecast,0) <> ISNULL(cf2.UseForecast,0)
			OR ISNULL(cf1.UseForecastPrior,0) <> ISNULL(cf2.UseForecastPrior,0)
		
		--add current actuals to adjustments file, they can be corrected after Vena is updated.
		INSERT INTO xref.dbo.FinanceAdjustmentActuals (Year, Month, [Programs & Allowances])
		SELECT DISTINCT 
			cf.Year
			, cf.[Month Seasonality]
			,ROUND((SUM(s.[Cash Discounts]) + SUM(s.[Frieght Allowance]) + SUM(s.[Markdown]) + SUM(s.[Other]) + SUM(s.[COOP]) + SUM(s.[DIF RETURNS])),2) 
		FROM dbo.FactPBISales s
			LEFT JOIN dbo.DimCalendarFiscal cf ON s.DateKey = cf.DateKey
			LEFT JOIN [xref].[dbo].[FinanceAdjustmentActuals] a ON cf.Year = a.Year AND cf.[Month Seasonality] = a.Month
		WHERE cf.Year > 2022 AND cf.UseActual = 1 AND a.Month IS NULL AND a.Year IS NULL
		GROUP BY cf.Year, cf.[Month Seasonality]

		--overwrite current
		IF (SELECT ShiftPriorForecast FROM dbo.ForecastPeriod WHERE Mode = 'F') = 0 
			OR (SELECT ShiftPriorBudget FROM dbo.ForecastPeriod WHERE Mode = 'B') = 0 
		BEGIN

			--PBI Forecasts
			DELETE FROM pbi
			--SELECT BudgetID, [Month Sort], SUM(Sales)
			FROM Operations.dbo.FactPBISalesBudget pbi
				LEFT JOIN Operations.dbo.DimCalendarFiscal cf ON pbi.DateID = cf.DateID 
			WHERE (BudgetID = 13 AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod))
				OR (BudgetID = 0 AND cf.[Month Sort] >= (SELECT BudgetMonth FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod))
			--GROUP BY BudgetID, [Month Sort]

			INSERT INTO Operations.dbo.FactPBISalesBudget (
				[BudgetID]
				,[DateID]
				,[DateKey]
				,[DemandClassID]
				,[ProductID]
				,[CustomerID]
				,[SaleTypeID]
				,[UnitPriceID]
				,[Sales]
				,[Cogs]
				,[Material Cost]
				,[Material Overhead Cost]
				,[Resource Cost]
				,[Outside Processing Cost]
				,[Overhead Cost]
				,[GP]
				,[Units]
				,[Coop]
				,[DIF Returns]
				,[Invoiced Freight]
				,[Freight Allowance]
				,[Markdown]
				,[Cash Discounts]
				,[Other]
				,[Surcharge]
				,[Commission]
				,[Royalty]
				,[Freight Out]
				,[Sales Operations]
				,[Units Operations]
				,[ForecastSource]
				,[CostTypeID]
				,[COGS Operations]
			    ,[Coop Operations]
			    ,[Other Operations]
			    ,[DIF Returns Operations]
			    ,[Markdown Operations]
			    ,[Cash Discounts Operations]
			    ,[Freight Allowance Operations]
			    ,[Invoiced Freight Operations]
				,[InvoicePriceID]
			    ,[LastForecastPriceID]
                ,[BudgetPriceID]
			    ,[LastBudgetPriceID]
			    ,[Sales Invoice Price]
			    ,[Sales Forecast Price]
			    ,[Sales Budget Price]
			    ,[Sales Budget LY Price]
			    ,[Base Currency]
			    ,[Price Type]
			) 
			SELECT 
			   s.[BudgetID]
			  ,s.[DateID]
			  ,s.[DateKey]
			  ,s.[DemandClassID]
			  ,s.[ProductID]
			  ,s.[CustomerID]
			  ,s.[SaleTypeID]
			  ,s.[UnitPriceID]
			  ,s.[Sales]
			  ,s.[Cogs]
			  ,s.[Material Cost]
			  ,s.[Material Overhead Cost]
			  ,s.[Resource Cost]
			  ,s.[Outside Processing Cost]
			  ,s.[Overhead Cost]
			  ,s.[GP]
			  ,s.[Units]
			  ,s.[Coop]
			  ,s.[DIF Returns]
			  ,s.[Invoiced Freight]
			  ,s.[Freight Allowance]
			  ,s.[Markdown]
			  ,s.[Cash Discounts]
			  ,s.[Other]
			  ,s.[Surcharge]
			  ,s.[Commission]
			  ,s.[Royalty]
			  ,s.[Freight Out]
			  ,s.[Sales Operations]
			  ,s.[Units Operations]
			  ,s.[ForecastSource]
			  ,s.[CostTypeID]
			  ,s.[COGS Operations]
			  ,s.[Coop Operations]
			  ,s.[Other Operations]
			  ,s.[DIF Returns Operations]
			  ,s.[Markdown Operations]
			  ,s.[Cash Discounts Operations]
			  ,s.[Freight Allowance Operations]
			  ,s.[Invoiced Freight Operations]
			  ,s.[InvoicePriceID]
			  ,s.[LastForecastPriceID]
              ,s.[BudgetPriceID]
			  ,s.[LastBudgetPriceID]
			  ,s.[Sales Invoice Price]
			  ,s.[Sales Forecast Price]
			  ,s.[Sales Budget Price]
			  ,s.[Sales Budget LY Price]
			  ,s.[Base Currency]
			  ,s.[Price Type]
			FROM dbo.FactSalesBudget s
				LEFT JOIN Operations.dbo.DimCalendarFiscal cf ON s.DateID = cf.DateID 
			WHERE (BudgetID = 13 AND cf.[Month Sort] >= (SELECT ForecastMonth FROM dbo.ForecastPeriod) AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod))
				OR (BudgetID = 0 AND cf.[Month Sort] >= (SELECT BudgetMonth FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod))
		END

		IF (SELECT ShiftPriorForecast FROM dbo.ForecastPeriod WHERE Mode = 'F') = 1 
			OR (SELECT ShiftPriorBudget FROM dbo.ForecastPeriod WHERE Mode = 'B') = 1  BEGIN
		
			UPDATE Operations.dbo.FactPBISalesBudget SET BudgetID = BudgetID - 1 WHERE BudgetID < 0 --shift all prior forecasts one period
			DELETE FROM Operations.dbo.FactPBISalesBudget WHERE BudgetID < -12 --retain 12 prior forecasts
			UPDATE Operations.dbo.FactPBISalesBudget SET BudgetID = - 1 WHERE BudgetID = 13  --make current forecast prior
		
			INSERT INTO Operations.dbo.FactPBISalesBudget (
				[BudgetID]
				,[DateID]
				,[DateKey]
				,[DemandClassID]
				,[ProductID]
				,[CustomerID]
				,[SaleTypeID]
				,[UnitPriceID]
				,[Sales]
				,[Cogs]
				,[Material Cost]
				,[Material Overhead Cost]
				,[Resource Cost]
				,[Outside Processing Cost]
				,[Overhead Cost]
				,[GP]
				,[Units]
				,[Coop]
				,[DIF Returns]
				,[Invoiced Freight]
				,[Freight Allowance]
				,[Markdown]
				,[Cash Discounts]
				,[Other]
				,[Surcharge]
				,[Commission]
				,[Royalty]
				,[Freight Out]
				,[Sales Operations]
				,[Units Operations]
				,[ForecastSource]
				,[CostTypeID]
				,[COGS Operations]
			    ,[Coop Operations]
			    ,[Other Operations]
			    ,[DIF Returns Operations]
			    ,[Markdown Operations]
			    ,[Cash Discounts Operations]
			    ,[Freight Allowance Operations]
			    ,[Invoiced Freight Operations]
				,[InvoicePriceID]
			    ,[LastForecastPriceID]
                ,[BudgetPriceID]
			    ,[LastBudgetPriceID]
			    ,[Sales Invoice Price]
			    ,[Sales Forecast Price]
			    ,[Sales Budget Price]
			    ,[Sales Budget LY Price]
			    ,[Base Currency]
			    ,[Price Type]
			)
			SELECT 
			   s.[BudgetID]
			  ,s.[DateID]
			  ,s.[DateKey]
			  ,s.[DemandClassID]
			  ,s.[ProductID]
			  ,s.[CustomerID]
			  ,s.[SaleTypeID]
			  ,s.[UnitPriceID]
			  ,s.[Sales]
			  ,s.[Cogs]
			  ,s.[Material Cost]
			  ,s.[Material Overhead Cost]
			  ,s.[Resource Cost]
			  ,s.[Outside Processing Cost]
			  ,s.[Overhead Cost]
			  ,s.[GP]
			  ,s.[Units]
			  ,s.[Coop]
			  ,s.[DIF Returns]
			  ,s.[Invoiced Freight]
			  ,s.[Freight Allowance]
			  ,s.[Markdown]
			  ,s.[Cash Discounts]
			  ,s.[Other]
			  ,s.[Surcharge]
			  ,s.[Commission]
			  ,s.[Royalty]
			  ,s.[Freight Out]
			  ,s.[Sales Operations]
			  ,s.[Units Operations]
			  ,s.[ForecastSource]
			  ,s.[CostTypeID]
			  ,s.[COGS Operations]
			  ,s.[Coop Operations]
			  ,s.[Other Operations]
			  ,s.[DIF Returns Operations]
			  ,s.[Markdown Operations]
			  ,s.[Cash Discounts Operations]
			  ,s.[Freight Allowance Operations]
			  ,s.[Invoiced Freight Operations]
			  ,s.[InvoicePriceID]
			  ,s.[LastForecastPriceID]
              ,s.[BudgetPriceID]
			  ,s.[LastBudgetPriceID]
			  ,s.[Sales Invoice Price]
			  ,s.[Sales Forecast Price]
			  ,s.[Sales Budget Price]
			  ,s.[Sales Budget LY Price]
			  ,s.[Base Currency]
			  ,s.[Price Type]
			FROM dbo.FactSalesBudget s
					LEFT JOIN Operations.dbo.DimCalendarFiscal cf ON s.DateID = cf.DateID 
			WHERE (
				(BudgetID = 13 AND cf.[Month Sort] >= (SELECT ForecastMonth FROM dbo.ForecastPeriod) AND 'F' = (SELECT MODE FROM dbo.ForecastPeriod))
				OR (BudgetID = 0 AND cf.[Month Sort] >= (SELECT BudgetMonth FROM dbo.ForecastPeriod) AND 'B' = (SELECT MODE FROM dbo.ForecastPeriod))
				)
		
			TRUNCATE TABLE Operations.Forecast.ForecastVersion  
			INSERT INTO Operations.Forecast.ForecastVersion (BudgetID, ForecastVersion, ForecastDate, ForecastName, Year) 
			SELECT BudgetID, ForecastVersion, ForecastDate, ForecastName, Year FROM dbo.ForecastVersion WHERE BudgetID <> 13

			----Added step to LabelForecast INSERT 0+12 if no UseActual flags are available for the current year
			IF (SELECT MAX(DateKey) FROM Operations.dbo.DimCalendarFiscal WHERE UseActual = 1 AND CurrentYear = 'Current Year') IS NULL BEGIN
				INSERT INTO dbo.ForecastVersion (BudgetID, ForecastVersion, ForecastDate, ForecastName, Year) 
				SELECT 13, '0+12', GETDATE(), CAST(YEAR(GETDATE()) AS VARCHAR(4)) + ' Forecast 0+12', YEAR(GETDATE())	
			END

			ELSE BEGIN			
				INSERT INTO Operations.Forecast.ForecastVersion (BudgetID, ForecastVersion, ForecastDate, ForecastName, Year)
				SELECT 13
					, CAST(CAST([Month Seasonality Sort] AS INT) AS VARCHAR(2)) + '+' + CAST(12 - [Month Seasonality Sort] AS VARCHAR(2))
					, GETDATE() AS ForecastDate 
					, (SELECT LEFT(ForecastMonth,4) FROM dbo.ForecastPeriod) + ' Forecast ' + CAST(CAST([Month Seasonality Sort] AS INT) AS VARCHAR(2)) + '+' + CAST(12 - [Month Seasonality Sort] AS VARCHAR(2))
					, YEAR(DateKey)
				FROM Operations.dbo.DimCalendarFiscal 
				WHERE DateKey IN (SELECT MAX(DateKey) FROM Operations.dbo.DimCalendarFiscal WHERE UseActual = 1 AND CurrentYear = 'Current Year')
			END

			----stop shifting forecast after successful upload
			--UPDATE dbo.ForecastPeriod SET ShiftPriorForecast = 0 WHERE Mode = 'F' AND ShiftPriorForecast = 1
			--UPDATE dbo.ForecastPeriod SET ShiftPriorBudget = 0 WHERE Mode = 'B' AND ShiftPriorBudget = 1

		END

		COMMIT TRAN Upload
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN Upload

		DECLARE @ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
		
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
			
	END CATCH

	IF @@TRANCOUNT > 0
		COMMIT TRAN Upload

END


GO
