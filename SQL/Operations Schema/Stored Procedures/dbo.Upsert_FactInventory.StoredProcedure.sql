USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactInventory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_FactInventory] 
AS BEGIN
	BEGIN TRY 
		BEGIN TRAN

			DECLARE @startDate DATE = DATEADD(DAY,-7,GETDATE())
			DECLARE @endDate DATE = (SELECT DATEADD(dd, 7-(DATEPART(dw, @startDate)), @startDate))

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()

			DELETE FROM p
			FROM dbo.FactInventory p
			WHERE p.DateKey >= @startDate

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

			INSERT INTO dbo.FactInventory
			SELECT p.* FROM Fact.[Inventory] p
			WHERE p.DateKey >= @startDate

			;--insert week ending records for products with out of stock records
			WITH FirstInventoryDate AS (
				SELECT i.PlantID, i.ProductID, 0 AS InventoryCodeID, MIN(i.DateID) AS DateID, i.InventoryTypeID, 0 AS InventoryStatusID, 0 AS AgeID, 0 AS [Inventory List], 0 AS [Inventory Cost], 0 AS Quantity, 0 AS Volume, 0 AS [Average Age], MIN(i.DateKey) AS InventoryDateKey
				FROM dbo.FactInventory i 
					LEFT JOIN (SELECT ProductID, PlantID, MIN(DateID) AS DateID FROM dbo.FactProduction WHERE ShiftOffsetID = 1 GROUP BY ProductID, PlantID) p ON i.ProductID = p.ProductID AND i.PlantID = p.PlantID AND i.DateID >= p.DateID
				WHERE i.DateKey >= DATEADD(DAY,-360,@startDate) AND i.InventoryTypeID = 1
				GROUP BY i.PlantID, i.ProductID, i.InventoryTypeID
			)
			, ZeroRecords AS (
				SELECT i.PlantID, i.ProductID, i.InventoryCodeID, cf.DateID, i.InventoryTypeID, i.InventoryStatusID, i.AgeID, i.[Inventory List], i.[Inventory Cost], i.[Quantity], i.[Volume], i.[Average Age], i.[InventoryDateKey], cf.DateKey
				FROM dbo.DimCalendarFiscal cf 
					INNER JOIN FirstInventoryDate i ON cf.DateID >= i.DateID
				WHERE (cf.DateKey BETWEEN DATEADD(DAY,-360,@startDate) AND @endDate AND cf.[Day of Week] = 'Sat')
					OR (cf.DateKey BETWEEN DATEADD(DAY,-180,@startDate) AND @endDate)
			)
			INSERT INTO dbo.FactInventory
			SELECT z.PlantID, z.ProductID, z.InventoryCodeID, z.DateID, z.InventoryTypeID, z.InventoryStatusID, z.AgeID, z.[Inventory List], z.[Inventory Cost], z.[Quantity], z.[Volume], z.[Average Age], z.[DateKey] 
			FROM ZeroRecords z
				LEFT JOIN dbo.FactInventory i ON i.ProductID = z.ProductID AND i.PlantID = z.PlantID AND i.DateKey = z.DateKey
			WHERE i.ProductID IS NULL AND z.DateKey >= @startDate
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
