USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactPlan]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Upsert_FactPlan] 
AS BEGIN
	BEGIN TRY 
		BEGIN TRAN

			--run once per day
			IF DATEPART(HOUR,GETDATE()) < 12 BEGIN
			
				DECLARE @startDate DATE = DATEADD(DAY,-15,GETDATE())

				INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()

				DELETE FROM p
				FROM dbo.FactPlan p
					LEFT JOIN dbo.DimCalendarFiscal cf 
				ON p.DateID = cf.DateID 
				WHERE cf.DateKey >= @startDate

				INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

				INSERT INTO dbo.FactPlan 
				SELECT p.* FROM Fact.[Plan] p
					LEFT JOIN dbo.DimCalendarFiscal cf 
				ON p.DateID = cf.DateID 
				WHERE cf.DateKey >= @startDate

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
