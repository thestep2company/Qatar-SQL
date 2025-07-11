USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactPlannedSalesFWOS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Upsert_FactPlannedSalesFWOS] 
AS BEGIN
	BEGIN TRY 
		BEGIN TRAN
			--run once per day
			IF DATEPART(HOUR,GETDATE()) < 12 BEGIN

				TRUNCATE TABLE dbo.FactPlannedSalesFWOS

				INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

				INSERT INTO dbo.FactPlannedSalesFWOS
				SELECT p.* FROM Fact.[PlannedSalesFWOS] p

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
