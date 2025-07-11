USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Update_PBISales]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Update_PBISales] 
	@p_startDate DATE = NULL
AS BEGIN

	BEGIN TRY 
		BEGIN TRAN	

			DECLARE @monthStart DATE, @monthEnd DATE, @rolling7Day DATE, @startDate DATE, @today DATE 

			SET @today = GETDATE()
			SET @rolling7Day = DATEADD(DAY,-7,@today)

			;WITH MonthStart AS (SELECT [Month Sort] FROM dbo.DimCalendarFiscal cf WHERE DateKey = ISNULL(@p_startDate,@today))
			SELECT @monthStart = MIN(DateKey) FROM dbo.DimCalendarFiscal cf
				INNER JOIN MonthStart ms ON cf.[Month Sort] = ms.[Month Sort] 

			;WITH MonthEnd AS (SELECT [Month Sort] FROM dbo.DimCalendarFiscal cf WHERE DateKey = @rolling7Day)
			SELECT @monthEnd = MIN(DateKey) FROM dbo.DimCalendarFiscal cf
				INNER JOIN MonthEnd me ON cf.[Month Sort] = me.[Month Sort]

			SELECT @monthStart, @monthEnd

			--run 7 day lookback except for first couple days of close.  Back dating of records needs to comb the full month to post to PBI.
			IF @monthStart <> @monthEnd	
				SET @startDate = ISNULL(@p_startDate,@monthEnd)
			ELSE 
				SET @startDate = ISNULL(@p_startDate,@monthStart)

			SELECT @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete Unit Price', GETDATE()
			DELETE FROM dbo.FactUnitPrice WHERE LastGLDate >= @startDate
			
			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert Unit Price', GETDATE()
			INSERT INTO dbo.FactUnitPrice SELECT *  FROM [Fact].[UnitPrice] WHERE LastGLDate >= @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete Sales', GETDATE()
			DELETE FROM dbo.FactPBISales  WHERE DateKey >= @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert Sales', GETDATE()
			INSERT INTO dbo.FactPBISales SELECT *  FROM Fact.PBISales WHERE DateKey >= @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Update Geography', GETDATE()
			UPDATE s SET s.GeographyID = g2.ID
			FROM dbo.FactPBISales s
				LEFT JOIN Oracle.Geography g ON s.GeographyID = g.ID 
				LEFT JOIN ORacle.Geography g2 ON g.PostalCode = g2.PostalCode AND g.Country = g2.Country AND g2.CurrentRecord = 1
			WHERE g.CurrentRecord = 0 AND DateKey >= @startDate

			--GRID
			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Update Grid', GETDATE()
			EXEC [FPA].[Merge_StandardMarginPBI] @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		THROW
	END CATCH

END
GO
