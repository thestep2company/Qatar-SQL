USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_FactFWOS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Reload_FactFWOS] AS BEGIN

	DECLARE @startDate DATE = CAST(dateadd(week, datediff(week, -1, GETDATE()), -1) AS DATE) 
	DECLARE @endDate DATE = DATEADD(WEEK,26,@startDate)

	DROP TABLE IF EXISTS #FWOS

	CREATE TABLE #FWOS (
		StartDate DATE,
		OutOfStockWeek DATE,
		SKU VARCHAR(25),
		FWOS INT,
		PAB INT
	)

	WHILE @startDate <= @endDate BEGIN

		;
		WITH CTE AS (
			--FG OBI Demand
			SELECT CAST(dateadd(week, datediff(week, -1, START_OF_WEEK), -1) AS DATE) AS START_OF_WEEK
				,ITEM_SEGMENTS AS SKU
				,REPLACE(CASE WHEN (mov.quantity <> 0 and mov.plan_id = 4  AND mov.order_type in (1,3,24) AND mov.source_table = 'MSC_DEMANDS') THEN ORDER_TYPE_TEXT
							WHEN (mov.quantity <> 0 and mov.plan_id = 4  AND mov.order_type = 30 AND mov.source_table = 'MSC_DEMANDS') THEN ORDER_TYPE_TEXT + ' Demand'
							WHEN (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5) AND FIRM_PLANNED_TYPE = 1 THEN 'Production'
							WHEN (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 5) AND FIRM_PLANNED_TYPE = 2 THEN 'Production Non Firm' 
							WHEN (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (18, 29, 30))  THEN ORDER_TYPE_TEXT
							WHEN (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 18 and FIRM_PLANNED_TYPE = 2)  THEN 'On Hand'
							WHEN (mov.quantity <> 0 and mov.plan_id IN (4,22) and mov.order_type = 3 and mov.source_table = 'MSC_SUPPLIES') THEN ORDER_TYPE_TEXT
							WHEN (mov.quantity <> 0 and mov.plan_id IN (4,22) and mov.order_type = 1 and mov.source_table = 'MSC_SUPPLIES') THEN ORDER_TYPE_TEXT
					END,'On Hand', 'Total On Hand') AS InventoryType
				, QUANTITY
			FROM Oracle.MSC_ORDERS_V_STAGING mov
			WHERE ITEM_SEGMENTS >= '400000'
			UNION ALL
			--All Forward Deamnd (to fill in weeks with no activity)
			SELECT DISTINCT DateKey, mov.ITEM_SEGMENTS AS SKU, 'Total On Hand', 0 
			FROM 
			(	
				SELECT DISTINCT ITEM_SEGMENTS FROM Oracle.MSC_ORDERS_V_STAGING mov
				WHERE ITEM_SEGMENTS >= '400000'
			) mov
			CROSS JOIN (
				SELECT DateKey FROM dbo.DimCalendarFiscal cf 
				WHERE cf.[Day of Week] = 'Sun' AND DateKey >= @startDate AND DateKey <= @endDate
			) cf 
		)
		, Condense AS (
			--compress needed types
			SELECT START_OF_WEEK, SKU, InventoryType, SUM(QUANTITY) AS QUANTITY
			FROM CTE 
			WHERE InventoryType NOT LIKE '%Demand%' AND InventoryType <> 'Production Non Firm'--exclude intracompany demand and non firm
			GROUP BY START_OF_WEEK, SKU, InventoryType
			--ORDER BY START_OF_WEEK
		)
		, Horizontal AS (
			--create PAB
			SELECT cte.START_OF_WEEK, SKU, 'Projected Available Balance' AS InventoryType, '88888' AS InventoryTypeSort, SUM(Quantity) OVER (PARTITION BY SKU ORDER BY START_OF_WEEK) AS [Quantity] --PAB Firm
			FROM Condense cte
			WHERE CAST(dateadd(week, datediff(week, -1, @startDate), -1) AS DATE) >= START_OF_WEEK
			UNION 
			SELECT cte.START_OF_WEEK, SKU, InventoryType, InventoryTypeSort, Quantity
			FROM Condense cte
				LEFT JOIN dbo.DimInventoryType it ON cte.InventoryType = it.InventoryTypeName
			WHERE cte.InventoryType IN ('Sales Orders', 'Forecast')
		)
		, Data AS (
			--roll from current point forward PAB with future sales to determine when we run out if no production happens (WOS)
			SELECT START_OF_WEEK, h.SKU, h.InventoryType
				, Quantity
				,  SUM(h.Quantity) OVER (PARTITION BY h.SKU ORDER BY START_OF_WEEK DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS RollingQuantity
			FROM (SELECT START_OF_WEEK, SKU, CASE WHEN h.InventoryType IN ('Sales Orders', 'Forecast') THEN 'Future Sales' ELSE h.InventoryType END AS InventoryType, SUM(Quantity) AS Quantity
				  FROM Horizontal h
				  WHERE (h.InventoryType IN ('Sales Orders', 'Forecast') AND START_OF_WEEK > @startDate) OR (h.InventoryType = 'Projected Available Balance' AND START_OF_WEEK = @startDate)
				  GROUP BY START_OF_WEEK, SKU, CASE WHEN h.InventoryType IN ('Sales Orders', 'Forecast') THEN 'Future Sales' ELSE h.InventoryType END
			) h  
		)
		, NextNegative AS (
			--find first date PAB (firm) goes negative
			SELECT @startDate AS StartDate, ROW_NUMBER() OVER (PARTITION BY SKU ORDER BY START_OF_WEEK) AS RowNum, * FROM Data
			WHERE RollingQuantity < 0
		)
		, NeverNegative AS (
			--find SKUs that never run out of inventory
			SELECT @startDate AS StartDate, DATEADD(YEAR,1,CAST(dateadd(week, datediff(week, -1, GETDATE()), -1) AS DATE)) AS START_OF_WEEK, SKU, 'Projected Available Balance' AS InventoryType, 0 AS Quantity, MIN(RollingQuantity) AS RollingQuantity
			FROM Data
				LEFT JOIN (
					SELECT MAX(CAST(dateadd(week, datediff(week, -1, START_OF_WEEK), -1) AS DATE)) AS START_OF_WEEK, ITEM_SEGMENTS 
					FROM Oracle.MSC_ORDERS_V_STAGING mov
					WHERE ITEM_SEGMENTS >= '40000'
					GROUP BY  ITEM_SEGMENTS
				) mov ON mov.ITEM_SEGMENTS = data.SKU
			GROUP BY SKU
			HAVING MIN(RollingQuantity) > 0
		) 		--save
		INSERT INTO #FWOS
		SELECT StartDate, START_OF_WEEK AS OutOfStockWeek, SKU
			, DATEDIFF(WEEK,StartDate,START_OF_WEEK) - CASE WHEN DATEDIFF(WEEK,StartDate,START_OF_WEEK) <> 0 THEN 1 ELSE 0 END AS FWOS
			, RollingQuantity AS PAB 
		FROM NextNegative 
		WHERE RowNum = 1
		UNION
		SELECT StartDate, START_OF_WEEK AS OutOfStockWeek, SKU
			, 99 AS FWOS
			, RollingQuantity AS PAB 
		FROM NeverNegative 

		SET @startDate = DATEADD(WEEK,1,@startDate)

	END

	--trunc and load results
	TRUNCATE TABLE dbo.FactFWOS

	INSERT INTO dbo.FactFWOS
	SELECT cf.DateID, pm.ProductID, CASE WHEN fwos.FWOS < 0 THEN 0 ELSE fwos.FWOS END AS FWOS
	FROM #FWOS fwos
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = fwos.StartDate
		LEFT JOIN dbo.DimProductMaster pm ON fwos.SKU = pm.ProductKey

END
GO
