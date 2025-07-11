USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactPlannedSales]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_FactPlannedSales] 
AS BEGIN
	BEGIN TRY 
		BEGIN TRAN

			TRUNCATE TABLE dbo.FactPlannedSales

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert 1', GETDATE()

			INSERT INTO dbo.FactPlannedSales
			SELECT p.* FROM Fact.[PlannedSales13Week] p

			--INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert 2', GETDATE()

			--INSERT INTO dbo.FactPlannedSales
			--SELECT p.* FROM Fact.[PlannedSales14week] p

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

			--DELETE FROM c    
			--FROM  (SELECT DISTINCT PostDateID, ProductionDateID FROM dbo.FactPlannedSales WHERE ForecastID = 14) a     
			--	LEFT JOIN      (SELECT DISTINCT PostDateID, ProductionDateID FROM dbo.FactPlannedSales WHERE ForecastID = 13) b ON a.PostDateID = b.PostDateID AND a.ProductionDateID = b.ProductionDateID      
			--	INNER JOIN dbo.FactPlannedSales c ON a.PostDateID = c.PostDateID AND a.ProductionDateID = c.ProductionDateID AND c.ForecastID = 14
			--WHERE b.ProductionDateID IS NULL

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		THROW
	END CATCH

 END
GO
