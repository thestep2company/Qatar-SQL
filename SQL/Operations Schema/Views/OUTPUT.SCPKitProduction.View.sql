USE [Operations]
GO
/****** Object:  View [OUTPUT].[SCPKitProduction]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[SCPKitProduction] AS 
	WITH Forecast AS (
		SELECT DISTINCT DPP.ITEM_SEGMENTS --DPP.* --
		FROM Oracle.MSC_ORDERS_V_FORECAST DPP
			LEFT JOIN Oracle.MSC_ORDERS_V_STAGING ASCP 
		ON DPP.ITEM_SEGMENTS = ASCP.ITEM_SEGMENTS 
			AND DPP.SOURCE_TABLE = ASCP.SOURCE_TABLE
			AND DPP.ORDER_TYPE = ASCP.ORDER_TYPE
		WHERE CurrentRecord = 1
			AND ASCP.ITEM_SEGMENTS IS NULL
			--AND DPP.ITEM_SEGMENTS IN ('4130KR','4133KR')
	)
	, Dates AS (
		SELECT 'PRD:111' AS ORGANIZATION_CODE, DateKey FROM dbo.DimCalendarFiscal WHERE [Day of Week] = 'Sun' AND DateKey >= DATEADD(WEEK,-1,GETDATE())
		UNION
		SELECT 'PRD:122' AS ORGANIZATION_CODE, DateKey FROM dbo.DimCalendarFiscal WHERE [Day of Week] = 'Sun' AND DateKey >= DATEADD(WEEK,-1,GETDATE())
	)
	, SKUs AS (
		SELECT BOM.* FROM dbo.DimBillOfMaterial BOM
			LEFT JOIN dbo.DimProductMaster pm1 ON bom.PARENT_SKU = pm1.ProductKey
			LEFT JOIN dbo.DimProductMaster pm2 ON bom.CHILD_SKU = pm2.ProductKey
		WHERE PARENT_SKU IN (SELECT ITEM_SEGMENTS FROM Forecast)
			AND Level = 1
			AND pm2.[Part Type] = 'FINISHED GOODS'
	)
	, ChildProduction AS (
		SELECT d.ORGANIZATION_CODE, PARENT_SKU, CHILD_SKU, msc.QUANTITY, msc.ORDER_TYPE, msc.ORDER_TYPE_TEXT, d.DateKey AS START_OF_WEEK, msc.FIRM_PLANNED_TYPE
		FROM SKUs
			CROSS JOIN Dates d --in order to look for missing child production
			LEFT JOIN Oracle.MSC_ORDERS_V_STAGING msc 
			ON SKUs.CHILD_SKU = msc.ITEM_SEGMENTS AND msc.START_OF_WEEK = d.DateKey AND msc.ORGANIZATION_CODE = d.ORGANIZATION_CODE
				AND (msc.quantity <> 0 and msc.plan_id = 4 and msc.order_type = 5)
	)
	, ParentProduction AS (
		SELECT ORGANIZATION_CODE, PARENT_SKU, CHILD_SKU, ORDER_TYPE, ORDER_TYPE_TEXT, START_OF_WEEK, FIRM_PLANNED_TYPE
			, QUANTITY
			, MIN(ISNULL(Quantity,0)) OVER (PARTITION BY PARENT_SKU, ORGANIZATION_CODE, START_OF_WEEK) AS TOTALQUANTITY
		FROM ChildProduction
		--ORDER BY ORGANIZATION_CODE, PARENT_SKU, START_OF_WEEK, CHILD_SKU
	)
	, Production AS (
		SELECT DISTINCT   
			--  CHILD_SKU AS ITEM_SEGMENTS
			  PARENT_SKU AS KIT_SKU
			, ORGANIZATION_CODE AS ORGANIZATION_CODE
			, ORDER_TYPE
			, ORDER_TYPE_TEXT
			, FIRM_PLANNED_TYPE
			, START_OF_WEEK
			, TOTALQUANTITY AS KIT_QTY  
		FROM ParentProduction pp
		WHERE TotalQuantity <> 0
	)
	SELECT 
	      'MSC_SUPPLIES' AS SOURCE_TABLE
		, KIT_SKU AS ITEM_SEGMENTS
		, ProductName AS DESCRIPTION
		, CAST(NULL AS NVARCHAR(34)) AS DEMAND_CLASS
		, CAST(NULL AS DATETIME2) AS NEW_ORDER_DATE
		, FIRM_PLANNED_TYPE
		, CAST(NULL AS DATETIME2) AS FIRM_DATE
		, KIT_QTY AS QUANTITY
		, ORDER_TYPE_TEXT
		, ORDER_TYPE
		, CAST(NULL AS DATETIME2) AS NEW_DUE_DATE
		, CAST(NULL AS NVARCHAR(10)) AS PLANNER_CODE
		, ORGANIZATION_CODE
		, 4 AS PLAN_ID
		, START_OF_WEEK
		, CAST(NULL AS CHAR(18)) AS RowID
		, GETDATE() AS StartDate
		, CAST(NULL AS DATETIME) EndDate
		, 1 AS CurrentRecord
		, NULL AS SOURCE_ORGANIZATION_CODE
	FROM Production p
		LEFT JOIN dbo.DimProductMaster pm ON p.KIT_SKU = pm.ProductKey
GO
