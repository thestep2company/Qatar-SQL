USE [Operations]
GO
/****** Object:  View [Fact].[Inventory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[Inventory] AS 

WITH Inventory AS (
	SELECT	ISNULL(ms.Reservable_Type,si.Reservable_Type) AS Reservable_Type
			,ms.STATUS_CODE
			,mp.organization_code					Org_Code
			,msi.segment1							Item
			,moqd.subinventory_code					SubInv_Code
			,c.DateKey
			,sum(moqd.transaction_quantity)		OH_QTY
			,sum(moqd.transaction_quantity*pp.List_Less_7) AS List
			,sum(moqd.transaction_quantity*cictv.item_cost) AS COST
			,sum(moqd.transaction_quantity*UNIT_VOLUME) AS Volume
			,DATEDIFF(DAY,ORIG_DATE_RECEIVED,c.DateKey) AS Age
	FROM	Oracle.Inv_mtl_onhand_quantities_detail			moqd
			INNER JOIN dbo.DimCalendarFiscal					c	ON DATEADD(HOUR,1,CAST(c.DateKey AS DATETIME)) BETWEEN moqd.StartDate AND ISNULL(moqd.EndDate,'9999-12-31') AND (DATEPART(WeekDay,c.DateKey) = 7 OR (DATEPART(DAY,c.DateKey) = 31 AND DATEPART(Month,c.DateKey) = 12)) AND c.DateKey < DATEADD(DAY,1,CAST(GETDATE() AS DATE)) --c.DateKey >= DATEADD(DAY,-180,CAST(GETDATE() AS DATE)) OR  account for time stamps
			LEFT JOIN [Oracle].[INV_MTL_SECONDARY_INVENTORIES] si   ON moqd.SUBINVENTORY_CODE= si.SECONDARY_INVENTORY_NAME AND moqd.ORGANIZATION_ID = si.Organization_ID AND si.CurrentRecord = 1
			LEFT JOIN Oracle.INV_MTL_MATERIAL_STATUSES_VL	ms		ON ms.STATUS_ID = moqd.STATUS_ID AND ms.CurrentRecord = 1
			LEFT JOIN Oracle.Inv_mtl_system_items_b			msi		ON moqd.inventory_item_id = msi.inventory_item_id and moqd.organization_id = msi.organization_id AND c.DateKey BETWEEN msi.StartDate AND ISNULL(msi.EndDate,'9999-12-31') --AND msi.CurrentRecord = 1
			LEFT JOIN Oracle.Inv_mtl_parameters				mp		ON mp.organization_id = moqd.organization_id AND c.DateKey BETWEEN mp.StartDate AND ISNULL(mp.EndDate,'9999-12-31') --AND mp.CurrentRecord = 1
			LEFT JOIN Oracle.CST_ITEM_COST_TYPE_V			cictv	ON moqd.inventory_item_id = cictv.inventory_item_id and moqd.organization_id = cictv.organization_id and cictv.cost_type='Frozen' AND c.DateKey BETWEEN cictv.StartDate AND ISNULL(cictv.EndDate,'9999-12-31') --AND cictv.CurrentRecord = 1			
			LEFT JOIN Fact.ProductPricing					pp		ON msi.segment1 = pp.ProductKey		
	WHERE	moqd.organization_id not in (88, 144, 145,166) -- first snapshots 
		AND moqd.organization_id = moqd.owning_organization_id and ISNULL(moqd.locator_id,0) not in (4589, 4590)
	GROUP BY ISNULL(ms.Reservable_Type,si.Reservable_Type)
			,ms.STATUS_CODE
			,mp.organization_code
			,msi.segment1
			,moqd.subinventory_code
			,c.DateKey
			,DATEDIFF(DAY,ORIG_DATE_RECEIVED,c.DateKey)
	UNION ALL
	SELECT	ISNULL(ms.Reservable_Type,si.Reservable_Type) AS Reservable_Type
			,ms.STATUS_CODE
			,mp.organization_code					Org_Code
			,msi.segment1							Item
			,moqd.subinventory_code					SubInv_Code
			,c.DateKey
			,sum(moqd.transaction_quantity)		OH_QTY
			,sum(moqd.transaction_quantity*pp.List_Less_7) AS List
			,sum(moqd.transaction_quantity*cictv.item_cost) AS COST
			,sum(moqd.transaction_quantity*UNIT_VOLUME) AS Volume
			,DATEDIFF(DAY,ORIG_DATE_RECEIVED,c.DateKey) AS Age
	FROM	Oracle.Inv_mtl_onhand_quantities_detail			moqd
			INNER JOIN dbo.DimCalendarFiscal					c	ON DATEADD(HOUR,1,CAST(c.DateKey AS DATETIME)) BETWEEN moqd.StartDate AND ISNULL(moqd.EndDate,'9999-12-31') AND (DATEPART(WeekDay,c.DateKey) = 7 OR (DATEPART(DAY,c.DateKey) = 31 AND DATEPART(Month,c.DateKey) = 12)) AND c.DateKey < DATEADD(DAY,1,CAST(GETDATE() AS DATE)) -- OR c.DateKey >= DATEADD(DAY,-180,CAST(GETDATE() AS DATE))account for time stamps
			LEFT JOIN [Oracle].[INV_MTL_SECONDARY_INVENTORIES] si   ON moqd.SUBINVENTORY_CODE= si.SECONDARY_INVENTORY_NAME AND moqd.ORGANIZATION_ID = si.Organization_ID AND si.CurrentRecord = 1
			LEFT JOIN Oracle.INV_MTL_MATERIAL_STATUSES_VL	ms		ON ms.STATUS_ID = moqd.STATUS_ID AND ms.CurrentRecord = 1
			LEFT JOIN Oracle.Inv_mtl_system_items_b			msi		ON moqd.inventory_item_id = msi.inventory_item_id and moqd.organization_id = msi.organization_id AND c.DateKey BETWEEN msi.StartDate AND ISNULL(msi.EndDate,'9999-12-31') --AND msi.CurrentRecord = 1
			LEFT JOIN Oracle.Inv_mtl_parameters				mp		ON mp.organization_id = moqd.organization_id AND c.DateKey BETWEEN mp.StartDate AND ISNULL(mp.EndDate,'9999-12-31') --AND mp.CurrentRecord = 1
			LEFT JOIN Oracle.CST_ITEM_COST_TYPE_V			cictv	ON moqd.inventory_item_id = cictv.inventory_item_id and moqd.organization_id = cictv.organization_id and cictv.cost_type='Frozen' AND c.DateKey BETWEEN cictv.StartDate AND ISNULL(cictv.EndDate,'9999-12-31') --AND cictv.CurrentRecord = 1			
			LEFT JOIN Fact.ProductPricing					pp		ON msi.segment1 = pp.ProductKey		
	WHERE	moqd.organization_id = 166 and moqd.organization_id = moqd.owning_organization_id 
	GROUP BY ISNULL(ms.Reservable_Type,si.Reservable_Type)
			,ms.STATUS_CODE
			,mp.organization_code
			,msi.segment1
			,moqd.subinventory_code
			,c.DateKey
			,DATEDIFF(DAY,ORIG_DATE_RECEIVED,c.DateKey)
	UNION
	SELECT	ISNULL(ms.Reservable_Type,si.Reservable_Type) AS Reservable_Type
			,ms.STATUS_CODE
			,mp.organization_code					Org_Code
			,msi.segment1							Item
			,moqd.subinventory_code					SubInv_Code
			,c.DateKey
			,sum(moqd.transaction_quantity)		OH_QTY
			,sum(moqd.transaction_quantity*pp.List_Less_7) AS List
			,sum(moqd.transaction_quantity*cictv.item_cost) AS COST
			,sum(moqd.transaction_quantity*UNIT_VOLUME) AS Volume
			,DATEDIFF(DAY,ORIG_DATE_RECEIVED,c.DateKey) AS Age
	FROM	Oracle.Inv_mtl_onhand_quantities_detail			moqd
			INNER JOIN dbo.DimCalendarFiscal					c	ON DATEADD(HOUR,1,CAST(c.DateKey AS DATETIME)) BETWEEN moqd.StartDate AND ISNULL(moqd.EndDate,'9999-12-31') AND (DATEPART(WeekDay,c.DateKey) = 7  OR (DATEPART(DAY,c.DateKey) = 31 AND DATEPART(Month,c.DateKey) = 12)) AND c.DateKey < DATEADD(DAY,1,CAST(GETDATE() AS DATE)) --OR c.DateKey >= DATEADD(DAY,-180,CAST(GETDATE() AS DATE))account for time stamps
			LEFT JOIN [Oracle].[INV_MTL_SECONDARY_INVENTORIES] si   ON moqd.SUBINVENTORY_CODE= si.SECONDARY_INVENTORY_NAME AND moqd.ORGANIZATION_ID = si.Organization_ID AND si.CurrentRecord = 1
			LEFT JOIN Oracle.INV_MTL_MATERIAL_STATUSES_VL	ms		ON ms.STATUS_ID = moqd.STATUS_ID AND ms.CurrentRecord = 1
			LEFT JOIN Oracle.Inv_mtl_system_items_b			msi		ON moqd.inventory_item_id = msi.inventory_item_id and moqd.organization_id = msi.organization_id AND c.DateKey BETWEEN msi.StartDate AND ISNULL(msi.EndDate,'9999-12-31') --AND msi.CurrentRecord = 1
			LEFT JOIN Oracle.Inv_mtl_parameters				mp		ON mp.organization_id = moqd.organization_id AND c.DateKey BETWEEN mp.StartDate AND ISNULL(mp.EndDate,'9999-12-31') --AND mp.CurrentRecord = 1
			LEFT JOIN Oracle.CST_ITEM_COST_TYPE_V			cictv	ON moqd.inventory_item_id = cictv.inventory_item_id and moqd.organization_id = cictv.organization_id and cictv.cost_type='Frozen' AND c.DateKey BETWEEN cictv.StartDate AND ISNULL(cictv.EndDate,'9999-12-31') --AND cictv.CurrentRecord = 1			
			LEFT JOIN Fact.ProductPricing					pp		ON msi.segment1 = pp.ProductKey		
	WHERE	((moqd.locator_id = 4589 and moqd.organization_id = 87) or (moqd.locator_id = 4590 and moqd.organization_id = 86)) and moqd.organization_id = moqd.owning_organization_id
	GROUP BY ISNULL(ms.Reservable_Type,si.Reservable_Type)
			,ms.STATUS_CODE
			,mp.organization_code
			,msi.segment1
			,moqd.subinventory_code
			,c.DateKey
			,DATEDIFF(DAY,ORIG_DATE_RECEIVED,c.DateKey)
	--UNION ALL
	--SELECT 
	--   si.RESERVABLE_TYPE
 --     ,ih.[Organization Code]
 --     ,ih.[Part Number]
	--  ,[Subinventory Code]
	--  ,DateKey
 --     ,[Quantity] 
	--  ,[Quantity]*pp.List_Less_7 AS List
	--  ,[Value] AS [Inventory Cost]
	--  ,[Quantity]*p.[Product Volume] AS Volume
	--  ,0 AS [Average Age]
	--FROM [Import].[InventoryHistory] ih
	--	LEFT JOIN dbo.DimCalendarFiscal c ON DATEADD(DAY,1,ih.InventoryDate) = c.DateKey
	--	LEFT JOIN dbo.DimProductMaster p ON ih.[Part Number] = p.ProductKey
	--	LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS o ON ih.[ORGANIZATION CODE] = o.ORGANIZATION_CODE AND o.CurrentRecord = 1
	--	LEFT JOIN Oracle.INV_MTL_SECONDARY_INVENTORIES si ON ih.[SUBINVENTORY CODE]= si.SECONDARY_INVENTORY_NAME AND o.ORGANIZATION_ID = si.Organization_ID AND si.CurrentRecord = 1
	--	LEFT JOIN Dim.InventoryCode ic ON ic.InventoryCodeKey = ih.[Subinventory Code]
	--	LEFT JOIN Fact.ProductPricing pp ON ih.[Part Number] = pp.ProductKey	
)
, InvoiceAvgCost AS (
	SELECT  SKU AS Item
		, SUM(COGS_AMOUNT)/SUM(QTY_INVOICED) AS Cost
	FROM Oracle.Invoice
	WHERE GL_DATE > DATEADD(YEAR,-1,GETDATE()) AND CurrentRecord = 1
	GROUP BY SKU
	HAVING  SUM(QTY_INVOICED) <> 0
)
, InventoryByItem AS (
	SELECT Item
		, SUM(Cost)/SUM(OH_QTY) AS AvgCost
	FROM Inventory
	GROUP BY Item
	HAVING  SUM(OH_QTY) <> 0
)
, Data AS (
	SELECT 
		  o.ID AS PlantID
		, im.ProductID
		, ic.InventoryCodeID
		, c.DateID
		, 'Total On Hand' AS InventoryType
		, i.Reservable_Type
		, ISNULL(i.OH_QTY,0) AS Quantity
		, i.Volume AS Volume
		, i.List AS [Inventory List]
		, i.COST AS [Inventory Cost]
		, i.Age AS [Average Age]
		, c.DateKey
	FROM Inventory i
		LEFT JOIN dbo.DimProductMaster im ON i.Item = im.ProductKey
		LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS o ON i.Org_Code = o.ORGANIZATION_CODE AND o.CurrentRecord = 1
		LEFT JOIN Dim.InventoryCode ic ON ic.InventoryCodeKey = i.SubInv_Code
		LEFT JOIN dbo.DimCalendarFiscal c ON i.DateKey = c.DateKey
	--UNION ALL
	--SELECT 
	--	  o.ID AS PlantID
	--	, im.ProductID
	--	, ic.InventoryCodeID
	--	, c.DateID
	--	, 'Yellow Wrap' AS InventoryType
	--	, i.Reservable_Type
	--	, -ISNULL(i.OH_QTY,0) AS Quantity
	--	, -i.Volume AS Volume
	--	,- i.List AS [Inventory List]
	--	,- i.COST AS [Inventory Cost]
	--	, i.Age AS [Average Age]
	--	, c.DateKey
	--FROM Inventory i
	--	LEFT JOIN dbo.DimProductMaster im ON i.Item = im.ProductKey
	--	LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS o ON i.Org_Code = o.ORGANIZATION_CODE AND o.CurrentRecord = 1
	--	LEFT JOIN Dim.InventoryCode ic ON ic.InventoryCodeKey = i.SubInv_Code
	--	LEFT JOIN dbo.DimCalendarFiscal c ON i.DateKey = c.DateKey
	--WHERE (i.SubInv_Code = 'MRB' OR  i.SubInv_Code = 'Yellow') --140 location added 4/8/21 - ((o.ORGANIZATION_CODE IN ('120','130','134','140')) add 9/2/21
	--	AND im.ProductKey <> '5020YL' AND im.ProductKey <> '5024YL' --black wrap SKUs created 6/8/21
	--UNION ALL
	--SELECT 
	--	  o.ID AS PlantID
	--	, im.ProductID
	--	, ic.InventoryCodeID
	--	, c.DateID
	--	, 'Reboxed' AS InventoryType
	--	, i.Reservable_Type
	--	, -ISNULL(i.OH_QTY,0) AS Quantity
	--	, -i.Volume AS Volume
	--	,- i.List AS [Inventory List]
	--	,- i.COST AS [Inventory Cost]
	--	, i.Age AS [Average Age]
	--	, c.DateKey
	--FROM Inventory i
	--	LEFT JOIN dbo.DimProductMaster im ON i.Item = im.ProductKey
	--	LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS o ON i.Org_Code = o.ORGANIZATION_CODE AND o.CurrentRecord = 1
	--	LEFT JOIN Dim.InventoryCode ic ON ic.InventoryCodeKey = i.SubInv_Code
	--	LEFT JOIN dbo.DimCalendarFiscal c ON i.DateKey = c.DateKey
	--WHERE i.SubInv_Code = 'REBOX'
)
SELECT PlantID
	,ProductID
	,InventoryCodeID
	,DateID  
	,i.InventoryTypeID 
	,d.Reservable_Type AS InventoryStatusID
	,a.AgeID
	,[Inventory List]
	,[Inventory Cost]
	,[Quantity] 
	,[Volume]
	,[Average Age]
	,[DateKey]
FROM Data d
	LEFT JOIN Dim.InventoryType i ON d.InventoryType = i.InventoryTypeName
	LEFT JOIN Dim.Aging a ON d.[Average Age] BETWEEN a.Floor AND a.Ceiling


GO
