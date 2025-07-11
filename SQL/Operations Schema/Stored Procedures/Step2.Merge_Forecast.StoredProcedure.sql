USE [Operations]
GO
/****** Object:  StoredProcedure [Step2].[Merge_Forecast]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Step2].[Merge_Forecast] 
AS BEGIN
	BEGIN TRY 
		BEGIN TRAN Forecast

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Expire', GETDATE()

			UPDATE Step2.Forecast SET EndDate = GETDATE(), CurrentRecord = 0 WHERE CurrentRecord = 1

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()
			
			INSERT INTO Step2.Forecast (Demand_Class, Item_Num, [Start Date], [Quantity], [Bucket Type])
			SELECT [Demand_Class]
				  ,[Item_Num]
				  ,[start date]
				  ,[Quantity]
				  ,[Bucket Type]
			FROM xref.Step2_Forecast

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		COMMIT TRAN Forecast
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN Forecast

		DECLARE @ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
		
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
			
	END CATCH

	IF @@TRANCOUNT > 0
		COMMIT TRAN Forecast

 END
GO
