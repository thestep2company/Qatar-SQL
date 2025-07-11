USE [Operations]
GO
/****** Object:  View [OUTPUT].[SalesAndForecastChangesWeekly]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[SalesAndForecastChangesWeekly] AS

WITH Data AS (
	SELECT ROW_NUMBER() OVER (PARTITION BY Demand_Class, Item_Num, CAST([Start Date] AS DATE) ORDER BY StartDate) AS RowID, f.*, cf1.*, cf2.*
	FROM Step2.Forecast f
		INNER JOIN (SELECT MIN(DateKey) AS WeekMinDateKey, MAX(DateKey) AS WeekMaxDateKey FROM dbo.DimCalendarFiscal GROUP BY [WeekID]) cf1 ON CAST(StartDate AS DATE) = cf1.WeekMinDateKey
		INNER JOIN (SELECT MIN(DateKey) AS MonthMinDateKey, MAX(DateKey) AS MonthMaxDateKey FROM dbo.DimCalendarFiscal GROUP BY [Month Sort]) cf2 ON CAST([Start Date] AS DATE) = cf2.MonthMinDateKey
)
SELECT a.[Demand_Class], a.[Item_Num] AS SKU, pm.ProductName AS SKU_Name
	, [Month Sort] AS Period
	, a.Quantity
	, a.WeekMinDateKey ,a.WeekMaxDateKey
	, a.MonthMinDateKey, a.MonthMaxDateKey
FROM Data a 
	LEFT JOIN dbo.DimProductMaster pm ON pm.ProductKey = a.[Item_Num]
	LEFT JOIN dbo.DimCalendarFiscal cf ON a.WeekMaxDateKey = cf.[DateKey]
UNION 
SELECT dc.DemandClassKey AS Demand_Class, pm.ProductKey AS SKU, pm.ProductName AS SKU_NAME, cf.[Month Sort] AS Period, SUM(QTY) AS Quantity
	, d.WeekMinDateKey, d.WeekMaxDateKey, d.MonthMinDateKey, d.MonthMaxDateKey
FROM dbo.FactPBISales pbi 
	INNER JOIN (SELECT DISTINCT WeekMinDateKey, WeekMaxDateKey, MonthMinDateKey, MonthMaxDateKey FROM Data) d ON pbi.DateKey < WeekMinDateKey AND pbi.DateKey >= MonthMinDateKey 
	LEFT JOIN dbo.DimProductMaster pm ON pm.ProductID = pbi.ProductID
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.[DateKey] = pbi.DateKey
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassID = pbi.DemandClassID
GROUP BY dc.DemandClassKey, pm.ProductKey, pm.ProductName, cf.[Month Sort], d.WeekMinDateKey, d.WeekMaxDateKey, d.MonthMinDateKey, d.MonthMaxDateKey




GO
