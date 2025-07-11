USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactLabor]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Upsert_FactLabor] 
AS BEGIN
	BEGIN TRY
		BEGIN TRAN
			DELETE FROM dbo.FactLabor 
			WHERE DateID >=
					(
				SELECT MIN(cf.DateID) AS DateID
					FROM dbo.DimM2MTimeSeries m2m
					LEFT JOIN dbo.DimTimeSeries ts ON m2m.TimeSeriesID = ts.TimeSeriesID
					LEFT JOIN dbo.DimCalendarFiscal cf ON m2m.DateID = cf.DateID
				WHERE ts.TimeSeriesKey = 'T14'
				)

			INSERT INTO dbo.FactLabor 
			SELECT l.* FROM Fact.Labor l
			WHERE l.DateID >=
					(
				SELECT MIN(cf.DateID) AS DateID
					FROM dbo.DimM2MTimeSeries m2m
					LEFT JOIN dbo.DimTimeSeries ts ON m2m.TimeSeriesID = ts.TimeSeriesID
					LEFT JOIN dbo.DimCalendarFiscal cf ON m2m.DateID = cf.DateID
				WHERE ts.TimeSeriesKey = 'T14'
			)	
		COMMIT TRAN
	END TRY

	BEGIN CATCH
		THROW
		ROLLBACK TRAN
	END CATCH

END
GO
