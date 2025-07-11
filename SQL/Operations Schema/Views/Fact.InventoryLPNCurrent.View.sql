USE [Operations]
GO
/****** Object:  View [Fact].[InventoryLPNCurrent]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Fact].[InventoryLPNCurrent] AS 

WITH Inventory AS (
	SELECT	ISNULL(ms.Reservable_Type,si.Reservable_Type) AS Reservable_Type
			,ic.organization_ID					
			,ic.INVENTORY_ITEM_ID
			,ic.subinventory_code	
			,ic.LOCATOR_ID
			,ic.LOT_NUMBER
			,ic.LPN_ID
			,sum(ic.primary_transaction_quantity)	AS	OH_QTY --changed from transaction_quantity due to variances 121100
			,sum(ic.primary_transaction_quantity*cictv.item_cost) AS COST
			,sum(ic.primary_transaction_quantity*UNIT_VOLUME) AS Volume
			,DATEDIFF(DAY,ORIG_DATE_RECEIVED,GETDATE()) AS Age
	FROM	Oracle.InventoryCurrent		ic
			LEFT JOIN Oracle.[INV_MTL_SECONDARY_INVENTORIES] si   ON ic.SUBINVENTORY_CODE= si.SECONDARY_INVENTORY_NAME AND ic.ORGANIZATION_ID = si.Organization_ID AND si.CurrentRecord = 1
			LEFT JOIN Oracle.INV_MTL_MATERIAL_STATUSES_VL	ms		ON ms.STATUS_ID = ic.STATUS_ID AND ms.CurrentRecord = 1
			LEFT JOIN Oracle.Inv_mtl_system_items_b			msi		ON ic.inventory_item_id = msi.inventory_item_id and ic.organization_id = msi.organization_id AND ic.StartDate BETWEEN msi.StartDate AND ISNULL(msi.EndDate,'9999-12-31') --AND msi.CurrentRecord = 1
			LEFT JOIN Oracle.CST_ITEM_COST_TYPE_V			cictv	ON ic.inventory_item_id = cictv.inventory_item_id and ic.organization_id = cictv.organization_id and cictv.cost_type='Frozen'  AND ic.StartDate BETWEEN cictv.StartDate AND ISNULL(cictv.EndDate,'9999-12-31') --AND cictv.CurrentRecord = 1			
	WHERE	ic.organization_id not in (88, 144, 145) -- 300s, 555  -- including org 166 (555) from below query 
		AND ic.organization_id = ic.owning_organization_id 
		and ISNULL(ic.locator_id,0) not in (4589, 4590) --BULK, Component Shortage (not sure why we need to exclude)
	GROUP BY ISNULL(ms.Reservable_Type,si.Reservable_Type)
			,ic.organization_id
			,ic.INVENTORY_ITEM_ID
			,ic.subinventory_code
			,ic.LOCATOR_ID
			,ic.LOT_NUMBER
			,ic.LPN_ID
			,DATEDIFF(DAY,ORIG_DATE_RECEIVED,GETDATE())
)
SELECT
	  l.LocationID AS PlantID
	, pm.ProductID
	, ic.InventoryCodeID
	, it.InventoryTypeID
	, i.Reservable_Type AS InventoryStatusID
	, dl.LocatorID
	, i.LOT_NUMBER
	, i.LPN_ID
	, ISNULL(a2.AgeID,a.AgeID) AS AgeID
	, i.COST AS [Inventory Cost]
	, ISNULL(i.OH_QTY,0) AS Quantity
	, i.Volume AS Volume
	, ISNULL(DATEDIFF(DAY,ln.ORIGINATION_DATE,GETDATE()),i.Age) AS [Average Age] --origination age or receipt age
	, msi.INVENTORY_ITEM_ID
	, i.Locator_ID
FROM Inventory i
	LEFT JOIN Oracle.Inv_mtl_system_items_b	msi		ON i.inventory_item_id = msi.inventory_item_id and i.organization_id = msi.organization_id AND msi.CurrentRecord = 1
	LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS o ON i.ORGANIZATION_ID = o.ORGANIZATION_ID AND o.CurrentRecord = 1
	LEFT JOIN dbo.DimLocation l ON o.ORGANIZATION_CODE = l.LocationKey
	LEFT JOIN dbo.DimProductMaster pm ON msi.Segment1 = pm.ProductKey
	LEFT JOIN Dim.InventoryCode ic ON ic.InventoryCodeKey = i.SubInventory_Code
	LEFT JOIN Dim.InventoryType it ON 'Total On Hand'  = it.InventoryTypeName
	LEFT JOIN Dim.Aging a ON i.[Age] BETWEEN a.Floor AND a.Ceiling
	LEFT JOIN dbo.DimLocator dl ON dl.LocationKey = o.ORGANIZATION_ID AND dl.LocatorKey = i.Locator_ID --msi.INVENTORY_ITEM_ID
	LEFT JOIN Dim.LotNumber ln ON i.INVENTORY_ITEM_ID = ln.INVENTORY_ITEM_ID AND i.LOT_NUMBER = ln.LOT_NUMBER
	LEFT JOIN Dim.Aging a2 ON DATEDIFF(DAY,ln.ORIGINATION_DATE,GETDATE()) BETWEEN a2.Floor AND a2.Ceiling




GO
