USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactStandardPending]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_FactStandardPending] 
AS BEGIN
	BEGIN TRY 
		BEGIN TRAN

			DECLARE @startDate DATE = DATEADD(DAY,-7,GETDATE())

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()
	
			DELETE FROM p
			FROM dbo.FactStandardPending p
				LEFT JOIN dbo.DimCalendarFiscal cf 
			ON p.DateID = cf.DateID 
			WHERE cf.DateKey >= @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

			INSERT INTO dbo.FactStandardPending
			SELECT p.* FROM Fact.StandardPending p
				LEFT JOIN dbo.DimCalendarFiscal cf 
			ON p.DateID = cf.DateID 
			WHERE cf.DateKey >= @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		THROW
	END CATCH

 END
GO
