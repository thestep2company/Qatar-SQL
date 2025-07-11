USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactSupplyChainPlanKit]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Upsert_FactSupplyChainPlanKit] 
AS BEGIN

	BEGIN TRY 
		BEGIN TRAN FactSupplyChainPlanKit
			
			TRUNCATE TABLE dbo.FactSupplyChainPlanKit
			INSERT INTO dbo.FactSupplyChainPlanKit SELECT * FROM Fact.SupplyChainPlanKit 
		
		COMMIT TRAN FactSupplyChainPlanKit
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN FactSupplyChainPlanKit

		DECLARE @ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
		
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
			
	END CATCH

	IF @@TRANCOUNT > 0
		COMMIT TRAN FactSupplyChainPlanKit
END
GO
