USE [Operations]
GO
/****** Object:  View [OUTPUT].[SCPKitOnHand]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [OUTPUT].[SCPKitOnHand] AS 
	WITH Forecast AS (
		SELECT DISTINCT DPP.ITEM_SEGMENTS --DPP.* --
		FROM Oracle.MSC_ORDERS_V_FORECAST DPP
			LEFT JOIN Oracle.MSC_ORDERS_V_STAGING ASCP 
		ON DPP.ITEM_SEGMENTS = ASCP.ITEM_SEGMENTS 
			AND DPP.SOURCE_TABLE = ASCP.SOURCE_TABLE
			AND DPP.ORDER_TYPE = ASCP.ORDER_TYPE
		WHERE CurrentRecord = 1
			AND ASCP.ITEM_SEGMENTS IS NULL
	)
	, SKUs AS (
		SELECT l.LocationKey, BOM.* FROM dbo.DimBillOfMaterial BOM
			LEFT JOIN dbo.DimProductMaster pm1 ON bom.PARENT_SKU = pm1.ProductKey
			LEFT JOIN dbo.DimProductMaster pm2 ON bom.CHILD_SKU = pm2.ProductKey
			CROSS JOIN dbo.DimLocation l
		WHERE PARENT_SKU IN (SELECT ITEM_SEGMENTS FROM Forecast)
			AND Level = 1
			AND pm2.[Part Type] = 'FINISHED GOODS'
	)
	, ChildInventory AS (
		SELECT 'PRD:'+SKUs.LocationKey AS ORGANIZATION_CODE, DEMAND_CLASS, PARENT_SKU, CHILD_SKU, msc.plan_id, SUM(ISNULL(msc.QUANTITY,0)) AS QUANTITY
			, msc.ORDER_TYPE, msc.ORDER_TYPE_TEXT, CAST(START_OF_WEEK AS DATE) AS START_OF_WEEK, msc.FIRM_PLANNED_TYPE
		FROM SKUs
			LEFT JOIN Oracle.MSC_ORDERS_V_STAGING msc 
		ON SKUs.CHILD_SKU = msc.ITEM_SEGMENTS 
			AND RIGHT(msc.ORGANIZATION_CODE,3) = SKUs.LocationKey
			AND msc.quantity <> 0 and msc.plan_id = 22  and msc.order_type = 18 and FIRM_PLANNED_TYPE = 1 --on Hand QTY
		GROUP BY SKUs.LocationKey, DEMAND_CLASS, PARENT_SKU, CHILD_SKU, msc.plan_id
			, msc.ORDER_TYPE, msc.ORDER_TYPE_TEXT, CAST(START_OF_WEEK AS DATE), msc.FIRM_PLANNED_TYPE
	)
	, ParentInventory AS (
		SELECT ORGANIZATION_CODE, PARENT_SKU, CHILD_SKU--, INVENTORY_ATP_CODE, AVAILABILITY_TYPE, RESERVABLE_TYPE
			, QUANTITY
			, MIN(Quantity) OVER (PARTITION BY PARENT_SKU, ORGANIZATION_CODE) AS TOTALQUANTITY
		FROM ChildInventory
		--ORDER BY ORGANIZATION_CODE, PARENT_SKU, CHILD_SKU, QUANTITY
	)
	, QtyOnHand AS (
		SELECT DISTINCT 
			  ITEM_SEGMENTS
			, k.PARENT_SKU AS KIT_SKU
			, ORGANIZATION_CODE AS ORGANIZATION_CODE
			, TOTALQUANTITY AS KIT_QTY 
		FROM SKUs 
			INNER JOIN Forecast f ON SKUs.PARENT_SKU = f.ITEM_SEGMENTS --only for kits that have finished good components
			LEFT JOIN ParentInventory k ON f.ITEM_SEGMENTS = k.PARENT_SKU AND TOTALQUANTITY <> 0 --only return values where kit is available
		--ORDER BY ITEM_SEGMENTS, k.PARENT_SKU, ORGANIZATION_CODE
	)
	SELECT 
	      'MSC_SUPPLIES' AS SOURCE_TABLE
		, KIT_SKU AS ITEM_SEGMENTS
		, ProductName AS DESCRIPTION
		, CAST(NULL AS NVARCHAR(34)) AS DEMAND_CLASS
		, CAST(NULL AS DATETIME2) AS NEW_ORDER_DATE
		, 1 AS FIRM_PLANNED_TYPE
		, CAST(NULL AS DATETIME2) AS FIRM_DATE
		, KIT_QTY AS QUANTITY
		, 'On Hand' AS ORDER_TYPE_TEXT
		, 18 AS ORDER_TYPE
		, CAST(NULL AS DATETIME2) AS NEW_DUE_DATE
		, CAST(NULL AS NVARCHAR(10)) AS PLANNER_CODE
		, ORGANIZATION_CODE AS ORGANIZATION_CODE
		, 22 AS PLAN_ID
		, dateadd(week, datediff(week, 0, CAST(GETDATE() AS DATE)), -1) AS START_OF_WEEK
		, CAST(NULL AS CHAR(18)) AS RowID
		, GETDATE() AS StartDate
		, CAST(NULL AS DATETIME) EndDate
		, 1 AS CurrentRecord
		, NULL AS SOURCE_ORGANIZATION_CODE
	FROM QtyOnHand qoh
		LEFT JOIN dbo.DimProductMaster pm ON qoh.KIT_SKU = pm.ProductKey

	
GO
