USE [Operations]
GO
/****** Object:  View [Fact].[InventoryLPN]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [Fact].[InventoryLPN] AS 

WITH Inventory AS (
	SELECT	moqd.ID
			,ISNULL(ms.Reservable_Type,si.Reservable_Type) AS Reservable_Type
			,moqd.organization_ID					
			,moqd.INVENTORY_ITEM_ID
			,moqd.subinventory_code	
			,moqd.LOCATOR_ID
			,moqd.LOT_NUMBER
			--,moqd.LPN_ID
			,DATEADD(DAY,-1,c.DateKey) AS DateKey --post Sunday AM run to Saturday of proir week for ending inventory value
			,sum(moqd.primary_transaction_quantity)		OH_QTY
			--,sum(moqd.transaction_quantity) AS List
			,sum(moqd.primary_transaction_quantity*cictv.item_cost) AS COST --changed from transaction_quantity due to variances 121100
			,sum(moqd.primary_transaction_quantity*UNIT_VOLUME) AS Volume
			,DATEDIFF(DAY,ORIG_DATE_RECEIVED,c.DateKey) AS Age
	FROM	Oracle.Inv_mtl_onhand_quantities_detail			moqd
			INNER JOIN dbo.DimCalendarFiscal					c	ON DATEADD(HOUR,1,CAST(c.DateKey AS DATETIME)) BETWEEN moqd.StartDate AND ISNULL(moqd.EndDate,'9999-12-31') AND c.DateKey < GETDATE() AND (DATEPART(WeekDay,c.DateKey) = 1  OR (DATEPART(DAY,c.DateKey) = 1 AND DATEPART(Month,c.DateKey) = 1) OR c.DateKey = CAST(GETDATE() AS DATE)) --account for time stamps  -OR c.DateKey >= DATEADD(DAY,-180,CAST(GETDATE() AS DATE))
			LEFT JOIN Oracle.[INV_MTL_SECONDARY_INVENTORIES] si   ON moqd.SUBINVENTORY_CODE= si.SECONDARY_INVENTORY_NAME AND moqd.ORGANIZATION_ID = si.Organization_ID AND si.CurrentRecord = 1
			LEFT JOIN Oracle.INV_MTL_MATERIAL_STATUSES_VL	ms		ON ms.STATUS_ID = moqd.STATUS_ID AND ms.CurrentRecord = 1
			LEFT JOIN Oracle.Inv_mtl_system_items_b			msi		ON moqd.inventory_item_id = msi.inventory_item_id and moqd.organization_id = msi.organization_id AND c.DateKey BETWEEN msi.StartDate AND ISNULL(msi.EndDate,'9999-12-31') --AND msi.CurrentRecord = 1
			LEFT JOIN Oracle.CST_ITEM_COST_TYPE_V			cictv	ON moqd.inventory_item_id = cictv.inventory_item_id and moqd.organization_id = cictv.organization_id and cictv.cost_type='Frozen' AND c.DateKey BETWEEN cictv.StartDate AND ISNULL(cictv.EndDate,'9999-12-31') --AND cictv.CurrentRecord = 1			
	WHERE	moqd.organization_id not in (88, 144, 145) -- including org 166 (555) from below query 
		AND moqd.organization_id = moqd.owning_organization_id 
		and ISNULL(moqd.locator_id,0) not in (4589, 4590)
	GROUP BY moqd.ID
			,ISNULL(ms.Reservable_Type,si.Reservable_Type)
			,moqd.organization_id
			,moqd.INVENTORY_ITEM_ID
			--,msi.segment1
			,moqd.subinventory_code
			,moqd.LOCATOR_ID
			,moqd.LOT_NUMBER
			--,moqd.LPN_ID
			,c.DateKey
			,DATEDIFF(DAY,ORIG_DATE_RECEIVED,c.DateKey)
)
SELECT
	  l.LocationID AS PlantID
	, pm.ProductID
	, ic.InventoryCodeID
	, c.DateID
	, it.InventoryTypeID
	, i.Reservable_Type AS InventoryStatusID
	, dl.LocatorID
	, i.LOT_NUMBER
	, SUM(i.COST) AS [Inventory Cost]
	, SUM(ISNULL(i.OH_QTY,0)) AS Quantity
	, SUM(i.Volume) AS Volume
	, i.Age AS [Receipt Age]
	, DATEDIFF(DAY,ln.ORIGINATION_DATE,c.DateKey) AS [Original Age]
	, c.DateKey
	, ISNULL(a2.AgeID,a.AgeID) AS AgeID
FROM Inventory i
	LEFT JOIN dbo.DimCalendarFiscal c ON i.DateKey = c.DateKey
	LEFT JOIN Oracle.Inv_mtl_system_items_b	msi		ON i.inventory_item_id = msi.inventory_item_id and i.organization_id = msi.organization_id AND msi.CurrentRecord = 1
	LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS o ON i.ORGANIZATION_ID = o.ORGANIZATION_ID AND o.CurrentRecord = 1
	LEFT JOIN dbo.DimLocation l ON o.ORGANIZATION_CODE = l.LocationKey
	LEFT JOIN dbo.DimProductMaster pm ON msi.Segment1 = pm.ProductKey
	LEFT JOIN Dim.InventoryCode ic ON ic.InventoryCodeKey = i.SubInventory_Code
	LEFT JOIN Dim.InventoryType it ON 'Total On Hand'  = it.InventoryTypeName
	LEFT JOIN Dim.Aging a ON i.[Age] BETWEEN a.Floor AND a.Ceiling
	LEFT JOIN dbo.DimLocator dl ON dl.LocationKey = o.ORGANIZATION_ID AND dl.LocatorKey = i.Locator_ID --msi.INVENTORY_ITEM_ID
	LEFT JOIN Dim.LotNumber ln ON i.INVENTORY_ITEM_ID = ln.INVENTORY_ITEM_ID AND i.LOT_NUMBER = ln.LOT_NUMBER
	LEFT JOIN Dim.Aging a2 ON DATEDIFF(DAY,ln.ORIGINATION_DATE,c.DateKey) BETWEEN a2.Floor AND a2.Ceiling
GROUP BY 
	  l.LocationID
	, pm.ProductID
	, ic.InventoryCodeID
	, c.DateID
	, it.InventoryTypeID
	, i.Reservable_Type
	, dl.LocatorID
	, i.LOT_NUMBER
	, i.Age
	, DATEDIFF(DAY,ln.ORIGINATION_DATE,c.DateKey)
	, c.DateKey
	, ISNULL(a2.AgeID,a.AgeID)

GO
