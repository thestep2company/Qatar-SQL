USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactPBISalesOrders]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_FactPBISalesOrders] AS BEGIN

	BEGIN TRY
		BEGIN TRAN

			DECLARE @rolling3months DATE

			SET @rolling3months = DATEADD(MONTH,-3,GETDATE())

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()

			DELETE FROM dbo.FactPBISalesOrders WHERE DateKey >= @rolling3months

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

			INSERT INTO dbo.FactPBISalesOrders SELECT * FROM Fact.PBISalesOrders WHERE DateKey >= @rolling3months

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Update', GETDATE()

		    UPDATE s SET s.GeographyID = g2.ID
		    FROM dbo.FactPBISalesOrders s
			   LEFT JOIN Oracle.Geography g ON s.GeographyID = g.ID 
			   LEFT JOIN ORacle.Geography g2 ON g.PostalCode = g2.PostalCode AND g.Country = g2.Country AND g2.CurrentRecord = 1
		    WHERE g.CurrentRecord = 0

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Update Grid', GETDATE()
			EXEC [FPA].[Merge_StandardMarginPBISalesOrders] @rolling3months

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
			
		COMMIT TRAN

	END TRY

	BEGIN CATCH

		THROW
		SELECT ERROR_NUMBER(), ERROR_MESSAGE()
		ROLLBACK TRAN

	END CATCH
END
GO
