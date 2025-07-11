USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactInventoryLPN]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Upsert_FactInventoryLPN] 
AS BEGIN
	BEGIN TRY 
		BEGIN TRAN

			DECLARE @startDate DATE = DATEADD(DAY,-7,GETDATE())
			DECLARE @endDate DATE = (SELECT DATEADD(dd, 7-(DATEPART(dw, @startDate)), @startDate))
			DECLARE @yesterday DATE = DATEADD(DAY,-1,GETDATE())

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Deletes', GETDATE()

			DELETE FROM i
			FROM dbo.FactInventoryLPN i 
				INNER JOIN dbo.DimCalendarFiscal cf  ON cf.DateID = i.DateID
			WHERE Quantity = 0 AND cf.[Day of Week] <> 'Sat' AND cf.DateKey <> @yesterday

			DELETE FROM p
			FROM dbo.FactInventoryLPN p
			WHERE p.DateKey >= @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

			INSERT INTO dbo.FactInventoryLPN
			SELECT p.* FROM Fact.[InventoryLPN] p
			WHERE p.DateKey >= @startDate

			;--insert week ending records for products with out of stock records
			WITH FirstInventoryDate AS (
				SELECT i.PlantID, i.ProductID, 0 AS InventoryCodeID, MIN(i.DateID) AS DateID, i.InventoryTypeID, 0 AS InventoryStatusID, 0 AS [LocatorID], NULL AS LOT_NUMBER, 0 AS [Inventory Cost], 0 AS Quantity, 0 AS Volume, 0 AS [Receipt Age], 0 AS [Original Age], MIN(i.DateKey) AS InventoryDateKey, 0 AS AgeID
				FROM dbo.FactInventoryLPN i 
					--LEFT JOIN (SELECT ProductID, PlantID, MIN(DateID) AS DateID FROM dbo.FactProduction WHERE ShiftOffsetID = 1 GROUP BY ProductID, PlantID) p ON i.ProductID = p.ProductID AND i.PlantID = p.PlantID AND i.DateID >= p.DateID
				WHERE i.DateKey >= DATEADD(DAY,-30,@startDate) AND i.InventoryTypeID = 1
				GROUP BY i.PlantID, i.ProductID, i.InventoryTypeID--, i.[LocatorID]
			)
			, ZeroRecords AS (
				SELECT i.PlantID, i.ProductID, i.InventoryCodeID, cf.DateID, i.InventoryTypeID, i.InventoryStatusID, i.[LocatorID], i.[LOT_NUMBER], i.[Inventory Cost], i.[Quantity], i.[Volume], i.[Receipt Age], i.[Original Age], i.[InventoryDateKey], cf.DateKey, i.AgeID
				FROM dbo.DimCalendarFiscal cf 
					INNER JOIN FirstInventoryDate i ON cf.DateID >= i.DateID
				WHERE (cf.DateKey BETWEEN DATEADD(DAY,-30,@startDate) AND @yesterday AND (cf.[Day of Week] = 'Sat' OR cf.DateKey = @yesterday))
					--OR (cf.DateKey BETWEEN DATEADD(DAY,-180,@startDate) AND @endDate)
			)
			INSERT INTO dbo.FactInventoryLPN
			SELECT z.PlantID, z.ProductID, z.InventoryCodeID, z.DateID, z.InventoryTypeID, z.InventoryStatusID, z.[LocatorID], z.[LOT_NUMBER], z.[Inventory Cost], z.[Quantity], z.[Volume], z.[Receipt Age], z.[Original Age], z.[DateKey], z.AgeID
			FROM ZeroRecords z
				LEFT JOIN dbo.FactInventoryLPN i ON i.ProductID = z.ProductID AND i.PlantID = z.PlantID AND i.DateKey = z.DateKey --AND ISNULL(i.LocatorID,'') = ISNULL(z.LocatorID,'')
			WHERE i.ProductID IS NULL AND z.DateKey >= DATEADD(DAY,-30,@startDate)
			ORDER BY z.DateKey


			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		THROW
	END CATCH

 END
GO
