USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactPlannedProductionFWOS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_FactPlannedProductionFWOS] 
AS BEGIN
	BEGIN TRY 
		BEGIN TRAN
		--run once per day
			IF DATEPART(HOUR,GETDATE()) < 12 BEGIN

				TRUNCATE TABLE dbo.FactPlannedProductionFWOS

				INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

				INSERT INTO dbo.FactPlannedProductionFWOS
				SELECT p.* FROM Fact.[PlannedProductionFWOS] p

				INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
			END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		THROW
	END CATCH

 END

GO
