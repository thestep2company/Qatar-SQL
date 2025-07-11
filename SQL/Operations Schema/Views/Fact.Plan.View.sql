USE [Operations]
GO
/****** Object:  View [Fact].[Plan]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Fact].[Plan] AS

--WITH Standards AS (
--	SELECT ProductID, LocationID, SUM(MachineHours) AS MachineHours, SUM(TotalStandardHours) AS StandardHours, MAX(UnitsPerSpider) AS UP, MAX(RoundsPerShift) AS RoundsPerShift, MAX(TotalProcessingCost) AS StandardCost
--	FROM dbo.FactStandard
--	GROUP BY ProductID, LocationID
--)
--, StandardsOverride AS (
--	SELECT [4 Digit], MAX(MachineHours) AS MachineHours, MAX(TotalStandardHours) AS StandardHours, MAX(UnitsPerSpider) AS UP, MAX(RoundsPerShift) AS RoundsPerShift, MAX(TotalProcessingCost) AS StandardCost
--	FROM dbo.FactStandards
--	WHERE Rank = 1
--	GROUP BY [4 Digit]
--)
--, Inventory AS (
--	SELECT	si.Reservable_Type
--			,mp.organization_code					Org_Code
--			,msi.segment1							Item
--			,moqd.subinventory_code					SubInv_Code
--			,DATEADD(DAY,-1,c.DateKey) AS DateKey
--			,sum (moqd.transaction_quantity)		OH_QTY
--			,sum(moqd.transaction_quantity*cictv.item_cost) AS COST
--	FROM	Oracle.Inv_mtl_onhand_quantities_detail			moqd
--			INNER JOIN dbo.DimCalendarFiscal					c		ON c.DateKey BETWEEN moqd.StartDate AND ISNULL(moqd.EndDate,'9999-12-31') AND (DATEPART(WeekDay,c.DateKey) = 1 OR c.DateKey >= DATEADD(DAY,-30,CAST(GETDATE() AS DATE))) AND c.DateKey < DATEADD(DAY,1,GETDATE()) --account for time stamps
--			LEFT JOIN [Oracle].[INV_MTL_SECONDARY_INVENTORIES] si	ON moqd.SUBINVENTORY_CODE= si.SECONDARY_INVENTORY_NAME AND moqd.ORGANIZATION_ID = si.Organization_ID AND si.CurrentRecord = 1
--			LEFT JOIN Oracle.Inv_mtl_system_items_b			msi		ON moqd.inventory_item_id = msi.inventory_item_id and moqd.organization_id = msi.organization_id AND c.DateKey BETWEEN msi.StartDate AND ISNULL(msi.EndDate,'9999-12-31') --AND msi.CurrentRecord = 1
--			LEFT JOIN Oracle.Inv_mtl_parameters				mp		ON mp.organization_id = moqd.organization_id AND c.DateKey BETWEEN mp.StartDate AND ISNULL(mp.EndDate,'9999-12-31') --AND mp.CurrentRecord = 1
--			LEFT JOIN Oracle.CST_ITEM_COST_TYPE_V			cictv	ON moqd.inventory_item_id = cictv.inventory_item_id and moqd.organization_id = cictv.organization_id and cictv.cost_type='Frozen' AND c.DateKey BETWEEN cictv.StartDate AND ISNULL(cictv.EndDate,'9999-12-31') --AND cictv.CurrentRecord = 1			
--	WHERE	moqd.organization_id not in (88, 144, 145) 
--	GROUP BY si.Reservable_Type
--			,mp.organization_code
--			,msi.segment1
--			,moqd.subinventory_code
--			,c.DateKey
--)
--, InvoiceAvgCost AS (
--	SELECT  SKU AS Item
--		, SUM(COGS_AMOUNT)/SUM(QTY_INVOICED) AS Cost
--	FROM Oracle.Invoice
--	WHERE GL_DATE > DATEADD(YEAR,-1,GETDATE()) AND CurrentRecord = 1
--	GROUP BY SKU
--	HAVING  SUM(QTY_INVOICED) <> 0
--)
--, InventoryByItem AS (
--	SELECT Item
--		, SUM(Cost)/SUM(OH_QTY) AS AvgCost
--	FROM Inventory
--	GROUP BY Item
--	HAVING  SUM(OH_QTY) <> 0
--)
WITH Forecast AS (
	SELECT RIGHT([ORGANIZATION_CODE],3) AS ORG_CODE
		  ,[ITEM_SEGMENTS]
		  ,[DEMAND_CLASS]
		  ,CAST(START_OF_WEEK AS DATE) AS START_OF_WEEK
		  ,[FIRM_PLANNED_TYPE]
		  ,[ORDER_TYPE_TEXT]
		  ,SUM([QUANTITY]) AS Quantity
	FROM Oracle.ProductionPlan
	WHERE START_OF_WEEK <= (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal) --'2026-01-01' --DATEADD(YEAR,5,DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0))
	GROUP BY RIGHT([ORGANIZATION_CODE],3)
		,[ITEM_SEGMENTS]
		,[DEMAND_CLASS]
		,CAST(START_OF_WEEK AS DATE)
		,[FIRM_PLANNED_TYPE]
		,[ORDER_TYPE_TEXT]
	UNION

	SELECT ORG_CODE
		  ,[ITEM_SEGMENTS]
		  ,[DEMAND_CLASS]
		  ,START_OF_WEEK
		  ,[FIRM_PLANNED_TYPE]
		  ,[ORDER_TYPE_TEXT]
		  ,[QUANTITY]
	FROM xref.PlannedProduction
	WHERE START_OF_WEEK <= (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal)
	UNION
	SELECT ORG_CODE
		  ,[ITEM_SEGMENTS]
		  ,[DEMAND_CLASS]
		  ,START_OF_WEEK
		  ,[FIRM_PLANNED_TYPE]
		  ,[ORDER_TYPE_TEXT]
		  ,[QUANTITY]
	FROM xref.PlannedSales
	WHERE START_OF_WEEK <= (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal)
	UNION
	SELECT RIGHT([ORGANIZATION_CODE],3)
		  ,[ITEM_SEGMENTS]
		  ,[DEMAND_CLASS]
		  ,CAST(START_OF_WEEK AS DATE) AS START_OF_WEEK
		  ,[FIRM_PLANNED_TYPE]
		  ,[ORDER_TYPE_TEXT]
		  ,SUM([QUANTITY]) AS Quantity
	FROM Oracle.ForecastOpenOrdersOnHand
	WHERE START_OF_WEEK <= (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal) AND [ORDER_TYPE_TEXT] <> 'On Hand'
	GROUP BY RIGHT([ORGANIZATION_CODE],3)
		,[ITEM_SEGMENTS]
		,[DEMAND_CLASS]
		,CAST(START_OF_WEEK AS DATE)
		,[FIRM_PLANNED_TYPE]
		,[ORDER_TYPE_TEXT]
	UNION
	SELECT RIGHT([ORGANIZATION_CODE],3)
		  ,[ITEM_SEGMENTS]
		  ,[DEMAND_CLASS]
		  ,CAST(START_OF_WEEK AS DATE) AS START_OF_WEEK
		  ,[FIRM_PLANNED_TYPE]
		  ,[ORDER_TYPE_TEXT]
		  ,SUM([QUANTITY]) AS Quantity
	FROM Oracle.PurchaseOrders
	WHERE START_OF_WEEK <= (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal)
	GROUP BY RIGHT([ORGANIZATION_CODE],3)
		,[ITEM_SEGMENTS]
		,[DEMAND_CLASS]
		,CAST(START_OF_WEEK AS DATE)
		,[FIRM_PLANNED_TYPE]
		,[ORDER_TYPE_TEXT]
	UNION
	SELECT 
		o.ORGANIZATION_CODE AS Org_Code
		,cd.item_name AS [ITEM_SEGMENTS]
		,cd.Demand_Class
		,CAST(DATEADD(week, DATEDIFF(week, -1, cd.Using_ASSEMBLY_DEMAND_DATE ), -1) AS DATE) AS START_OF_WEEK
		,demand_type
		,'SKU Demand'
		,-cd.Using_Requirement_Quantity AS Quantity
	FROM Oracle.ComponentDemand cd
		LEFT JOIN dbo.DimProductMaster pm ON cd.Item_Name = pm.ProductKey
		LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS o ON cd.organization_ID = o.ORGANIZATION_ID
	WHERE DATEADD(week, DATEDIFF(week, -1, cd.Using_ASSEMBLY_DEMAND_DATE ), -1) <= (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal) --DATEADD(YEAR,5,DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0))
)
, Data AS (
	SELECT 
		  o.ID AS PlantID
		, im.ProductID
		, dc.DemandClassID
		, 0 AS InventoryCodeID
		, c.DateID
		, CASE WHEN f.ORDER_TYPE_TEXT = 'Planned Order' AND f.FIRM_PLANNED_TYPE = 1 THEN 'Production'
			   WHEN f.ORDER_TYPE_TEXT = 'Planned Order' AND f.FIRM_PLANNED_TYPE <> 1 THEN 'Production Non Firm'
			   ELSE f.ORDER_TYPE_TEXT
		END AS InventoryType
		, SUM(Quantity) AS Quantity
		, CAST(0 AS MONEY) AS [Sale Price]
		, CAST(0 AS MONEY) AS [Average Cost] --average invoice cost or average current inventory cost if not available
		, SUM(s1.ItemCost*Quantity) AS [Inventory Cost] --average invoice cost or average current inventory cost if not available
		, SUM(Quantity*s1.[MachineHours]) AS [Machine Hours]
	FROM Forecast f
		LEFT JOIN dbo.DimProductMaster im ON f.ITEM_SEGMENTS = im.ProductKey
		LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS o ON f.Org_Code = o.ORGANIZATION_CODE AND o.CurrentRecord = 1
		LEFT JOIN dbo.DimCalendarFiscal c ON f.START_OF_WEEK = c.DateKey
		LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = f.Demand_Class
		LEFT JOIN dbo.FactStandard s1 ON o.ID = s1.LocationID AND im.ProductID = s1.ProductID AND GETDATE() BETWEEN s1.StartDate AND s1.EndDate
	GROUP BY 
		   o.ID
		, im.ProductID 
		, dc.DemandClassID
		, c.DateID
		, CASE WHEN f.ORDER_TYPE_TEXT = 'Planned Order' AND f.FIRM_PLANNED_TYPE = 1 THEN 'Production'
			   WHEN f.ORDER_TYPE_TEXT = 'Planned Order' AND f.FIRM_PLANNED_TYPE <> 1 THEN 'Production Non Firm'
			   ELSE f.ORDER_TYPE_TEXT
	END
)
SELECT PlantID
	,ProductID
	,DemandClassID
	,InventoryCodeID
	,1 AS InventoryStatusID
	,DateID  
	,i.InventoryTypeID 
	,SUM([Sale Price]) AS [Sale Price]
	,SUM([Average Cost]) AS [Average Cost]
	,SUM([Inventory Cost]) AS [Inventory Cost]
	,SUM([Quantity]) AS [Quantity]
	,SUM([Machine Hours]) AS [Machine Hours]
FROM Data d
	LEFT JOIN Dim.InventoryType i ON d.InventoryType = i.InventoryTypeName
GROUP BY 
	PlantID
	,ProductID
	,DemandClassID
	,InventoryCodeID
	,DateID
	,i.InventoryTypeID 

GO
