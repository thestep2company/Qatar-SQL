USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactProductionPlan]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_FactProductionPlan] 
AS BEGIN
	BEGIN TRY 
		BEGIN TRAN FactProductionPlan

			DECLARE @startDate DATE = DATEADD(DAY,-15,GETDATE())

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()
			
			DELETE FROM p
			FROM dbo.FactProductionPlan p
				LEFT JOIN dbo.DimCalendarFiscal cf 
			ON p.DateID = cf.DateID 
			WHERE cf.DateKey >= @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()
			
			INSERT INTO dbo.FactProductionPlan
			SELECT p.* FROM Fact.[ProductionPlan] p
				LEFT JOIN dbo.DimCalendarFiscal cf 
			ON p.DateID = cf.DateID 
			WHERE cf.DateKey >= @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
			
		COMMIT TRAN FactProductionPlan
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN FactProductionPlan

		DECLARE @ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
		
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
			
	END CATCH

	IF @@TRANCOUNT > 0
		COMMIT TRAN FactProductionPlan

 END
GO
