USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactSupplyChainPlan]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_FactSupplyChainPlan] 
AS BEGIN
	BEGIN TRY 
		BEGIN TRAN FactSupplyChainPlan

			DECLARE @startDate DATE = DATEADD(DAY,-15,GETDATE())

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()
			
			DELETE FROM p
			FROM dbo.FactSupplyChainPlan p
				LEFT JOIN dbo.DimCalendarFiscal cf 
			ON p.DateID = cf.DateID 
			WHERE cf.DateKey >= @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert FG', GETDATE()

			INSERT INTO dbo.FactSupplyChainPlan
			SELECT p.* FROM Fact.[SupplyChainPlan] p
				LEFT JOIN dbo.DimCalendarFiscal cf 
			ON p.DateID = cf.DateID 
			WHERE cf.DateKey >= @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert Kit', GETDATE()

			INSERT INTO dbo.FactSupplyChainPlan
			SELECT p.* FROM Fact.[SupplyChainPlanKit] p
				LEFT JOIN dbo.DimCalendarFiscal cf 
			ON p.DateID = cf.DateID 
			WHERE cf.DateKey >= @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Update', GETDATE()
			
			----assign COGS overrides to OBI figures if they are missing cost
			--;WITH COGSOverride AS (
			--	SELECT pm.ProductID, pm.ProductKey, pm.ProductName, SUM(COGS)/SUM(Units) ItemCost, SUM(Sales)/SUM(Units) AS Sales, SUM(Sales-COGS)/SUM(Sales) AS Margin, UnitPriceID
			--	FROM xref.dbo.FactSalesBudget sb
			--		LEFT JOIN xref.dbo.FactStandard fs ON sb.ProductID = fs.ProductID
			--		LEFT JOIN xref.dbo.DimProductMaster pm ON pm.ProductID = sb.ProductID
			--		LEFT JOIN xref.dbo.DimCalendarFiscal cf ON sb.DateID = cf.DateID
			--	WHERE ISNULL(fs.ItemCost,0) = 0 AND cf.Year = 2024 AND BudgetID = 0 AND pm.[Forecast Segment] NOT LIKE '%PLACEHOLDER%'
			--	GROUP BY pm.ProductID, pm.ProductKey, pm.ProductName, ItemCost, UnitPriceID
			--	HAVING SUM(Units) <> 0 AND SUM(Sales) <> 0
			--	--ORDER BY pm.ProductKey
			--)
			--UPDATE sc 
			--SET sc.Cost = sc.Quantity * cogs.ItemCost
			--FROM dbo.FactSupplyChainPlan sc
			--	LEFT JOIN COGSOverride cogs ON sc.ProductID = cogs.ProductID 
			--WHERE sc.Cost = 0

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert 2', GETDATE()

			--assign missing OBI data from Budget (currently cannot run further than 15 months ahead)
			;WITH CTE AS (
				SELECT cf.Year, cf.Week, cf.WeekNum, SUM(Quantity) AS Quantity, MIN(DateKey) AS WeekStart
				FROM dbo.DimCalendarFiscal cf 
					LEFT JOIN dbo.FactSupplyChainPlan scp ON scp.DateID = cf.DateID AND scp.InventoryTypeID IN (4,5)
				WHERE Year = 2024 AND WeekNum <> 1
				GROUP BY cf.Year, cf.Week, cf.WeekNum
				HAVING SUM(Quantity) IS NULL
			)
			, MissingWeeks AS (
				SELECT cf.Week, cf.WeekNum, SUM(scp.Quantity) AS Qty, WeekStart
				FROM dbo.DimCalendarFiscal cf 
					INNER JOIN CTE ON cf.WeekNum = cte.WeekNum AND cte.Year - 1 = cf.Year
					LEFT JOIN dbo.FactSupplyChainPlan scp ON scp.DateID = cf.DateID AND scp.InventoryTypeID IN (4,5)
				GROUP BY cf.Week, cf.WeekNum, WeekStart
				HAVING SUM(scp.Quantity) IS NOT NULL
			)
			INSERT INTO dbo.FactSupplyChainPlan
			SELECT 3 AS LocationID, sb.ProductID, sb.DemandClassID, 1 AS InventoryCodeID, sb.DateID, 4 AS InventoryTypeID, 'Forecast' AS ORDER_TYPE_TEXT
				,-SUM(sb.Units) AS Quantity, -SUM(sb.COGS) AS Cost, 0 AS MachineHours, 0 AS MachineID, 0 AS PlanMachineID
			FROM dbo.FactSalesBudget sb 
				LEFT JOIN dbo.DimCalendarFiscal cf ON sb.DateID = cf.DateID 
				INNER JOIN MissingWeeks ms ON ms.WeekNum = cf.WeekNum
			WHERE cf.Year = (SELECT LEFT(BudgetMonth,4) FROM Forecast.dbo.ForecastPeriod)
			GROUP BY sb.ProductID, sb.DemandClassID, sb.DateID

			--remove duplicate work order records
			DELETE FROM dbo.FactSupplyChainPlan WHERE InventoryTypeID IS NULL

			--flag visible products
  			UPDATE pm 
			SET pm.HasSCP = CASE WHEN v.ProductID IS NOT NULL THEN v.HasSCP ELSE 0 END 
			FROM dbo.DimProductMaster pm
				LEFT JOIN Fact.ProductIsVisible v ON pm.ProductID = v.ProductID

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		COMMIT TRAN FactSupplyChainPlan
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN FactSupplyChainPlan

		DECLARE @ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
		
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
			
	END CATCH

	IF @@TRANCOUNT > 0
		COMMIT TRAN FactSupplyChainPlan

 END
GO
