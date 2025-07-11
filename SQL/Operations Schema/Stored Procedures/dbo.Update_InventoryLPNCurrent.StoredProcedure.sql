USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Update_InventoryLPNCurrent]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Update_InventoryLPNCurrent] AS BEGIN

	BEGIN TRY
		BEGIN TRAN
			TRUNCATE TABLE dbo.[FactInventoryLPNCurrent]

			INSERT INTO dbo.[FactInventoryLPNCurrent] 
			SELECT [PlantID]
				  ,[ProductID]
				  ,[InventoryCodeID]
				  ,[InventoryTypeID]
				  ,[InventoryStatusID]
				  ,[LocatorID]
				  ,[LOT_NUMBER]
				  ,[LPN_ID]
				  ,[AgeID]
				  ,[Inventory Cost]
				  ,[Quantity]
				  ,[Volume]
				  ,[Average Age]
			  FROM [Fact].[InventoryLPNCurrent]

		COMMIT TRAN
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		THROW
	END CATCH
 END
GO
