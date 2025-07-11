USE [Operations]
GO
/****** Object:  View [OUTPUT].[ForecastSnapshots]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [OUTPUT].[ForecastSnapshots] AS 
WITH Dates AS ( --pick sunday snapshots
	SELECT DATEADD(HOUR,1,CAST(DateKey AS DATETIME)) AS DateKey, [Month Sort], [MonthID], ROW_NUMBER() OVER (PARTITION BY [Month Sort] ORDER BY [DateKey]) AS RowNum
	FROM dbo.DimCalendarFiscal 
	WHERE [Day of Week] = 'Sun' AND DateKey >= DATEADD(MONTH,-13,GETDATE()) --CAST(YEAR(GETDATE())-1 AS VARCHAR(4)) + '-10-01' 
		AND DateKey <= GETDATE()
)
, Calendar AS ( --fiscal month
	SELECT [Month Sort], [MonthID], MIN(DateKey) AS FirstDay, MAX(DateKey) AS LastDay FROM dbo.DimCalendarFiscal GROUP BY [Month Sort], [MonthID]
)
, Data AS (
	--step2 forecast file
	SELECT DISTINCT 
		   sf.ID
		  , DENSE_RANK() OVER (PARTITION BY [Demand_Class], [Item_Num], c.[Month Sort] ORDER BY [DateKey] ASC) AS RowNum
		  , d.DateKey
		  ,sf.[Demand_Class]
		  ,dc.DemandClassName
		  ,sf.[Item_Num]
		  ,pm.ProductName
		  ,c.[Month Sort] AS [Period]
		  ,c.FirstDay
		  ,c.LastDay
		  ,DATEDIFF(WEEK,d.DateKey,c.FirstDay) AS WeekOffset
		  ,c.[MonthID] - d.[MonthID] AS MonthOffset
		  ,sf.[Quantity]
		  ,'Forecast' AS SaleType
	FROM [Step2].[Forecast] sf
		INNER JOIN Dates d ON d.DateKey >= sf.StartDate AND d.DateKey < ISNULL(sf.EndDate,'9999-12-31')
		LEFT JOIN Calendar c ON CAST([Start Date] AS DATE) = c.FirstDay
		LEFT JOIN dbo.DimProductMaster pm ON sf.[Item_Num] = pm.ProductKey
		LEFT JOIN dbo.DimDemandClass dc ON sf.[Demand_Class] = dc.DemandClassKey
	WHERE pm.[Part Type] = 'FINISHED GOODS' AND d.RowNum = 1 
		AND c.[MonthID] - d.[MonthID] >= 0 -- OR DATEDIFF(WEEK,d.DateKey,c.FirstDay) BETWEEN -4 AND 0)
	UNION ALL
	SELECT 0 AS ID
		,0 AS RowNum 
		,d.DateKey
		,i.DEMAND_CLASS
		,dc.DemandClassName
		,i.PART AS [Item_Num]
		,pm.ProductName
		,c.[Month Sort] AS [Period]
		,c.FirstDay
		,c.LastDay
		,0 AS WeekOffset
		,0 AS MonthOffset
		,SUM(QTY) AS Quantity
		,'Sales' AS SaleType
	FROM Oracle.Orders i 
		LEFT JOIN Calendar c ON CAST(i.SCH_SHIP_DATE AS DATE) >= c.FirstDay AND CAST(i.SCH_SHIP_DATE AS DATE) <= c.LastDay
		INNER JOIN Dates d ON c.[Month Sort] = d.[Month Sort]
		LEFT JOIN dbo.DimProductMaster pm ON i.PART = pm.ProductKey
		LEFT JOIN dbo.DimDemandClass dc ON i.[Demand_Class] = dc.DemandClassKey
	WHERE pm.[Part Type] = 'FINISHED GOODS' AND d.RowNum = 1 AND i.CurrentRecord = 1 AND i.FLOW_STATUS_CODE NOT IN ('CANCELLED','DELETED') -- 'CLOSED'
		AND i.CUSTOMER_NUM <> '1055833'
	GROUP BY d.DateKey
		,i.DEMAND_CLASS
		,dc.DemandClassName
		,i.FLOW_STATUS_CODE
		,i.PART
		,pm.ProductName
		,c.[Month Sort]
		,d.DateKey 
		,c.FirstDay
		,c.LastDay
)
SELECT d1.*, d1.Quantity - ISNULL(d2.Quantity,0) AS Delta--, d2.*
FROM Data d1
	LEFT JOIN Data d2 ON d1.Item_Num = d2.[Item_Num] AND d1.[Demand_Class] = d2.[Demand_Class] AND d1.[Period] = d2.[Period] AND d1.[SaleType] = d2.[SaleType] AND d1.RowNum = d2.RowNum + 1
WHERE d1.SaleType = 'Forecast' --AND d1.Item_Num = '874699' AND d1.[Demand_Class] = 'A04727' AND d1.[Period] ='202405'
UNION
SELECT d1.*, d1.Quantity - ISNULL(d2.Quantity,0) AS Delta
FROM Data d1 
	LEFT JOIN Data d2 ON d1.Item_Num = d2.[Item_Num] AND d1.[Demand_Class] = d2.[Demand_Class] AND d1.[Period] = d2.[Period] AND 'Forecast' = d2.[SaleType] AND d1.DateKey = d2.DateKey
WHERE d1.SaleType = 'Sales' --AND d1.Item_Num = '874699' AND d1.[Demand_Class] = 'A04727' AND d1.[Period] ='202405'
--ORDER BY d1.[Demand_Class], d1.[Item_Num], d1.[Period], d1.[DateKey] 
GO
