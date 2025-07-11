USE [Operations]
GO
/****** Object:  View [Fact].[CurrentDayEstimate]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[CurrentDayEstimate] AS
WITH Rolling4 AS(  --Rolling 4 days of orders for Dropship E-Commerce Finished Goods only
SELECT 	DATEPART(HOUR,ORDER_DATE) AS HourID
,SUM([LIST_DOLLARS]) AS SALES
,SUM([QTY]) AS QTY
,SUM([Invoiced Freight]) AS [Invoiced Freight]
,SUM([Customer Programs]) AS [Customer Programs]
,SUM([Net Sales]) AS [Net Sales]
FROM [OUTPUT].[CurrentDayEstimateT4] o
LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(o.ORDER_DATE AS DATE) = cf.DateKey
LEFT JOIN dbo.DimDemandClass dc ON o.DEMAND_CLASS = dc.DemandClassKey
LEFT JOIN dbo.DimProductMaster pm ON o.PART = pm.ProductKey
WHERE o.CurrentRecord = 1 AND dc.[Finance Reporting Channel] = 'E-COMMERCE' AND dc.[Ecommerce Type] = 'DROPSHIP' 
AND pm.[Part Type] = 'FINISHED GOODS'
AND cf.DateKey >= DATEADD(DAY,-4,CAST(GETDATE() AS DATE)) AND cf.DateKey < CAST(GETDATE() AS DATE)
GROUP BY DATEPART(HOUR,ORDER_DATE)
)
,Percentages AS(  --Percentage of total sales for each hour
SELECT HourID
,SALES / (SELECT SUM(SALES) FROM Rolling4) AS SalesPercent
,[Net Sales] / (SELECT SUM([Net Sales]) FROM Rolling4) AS NetSalesPercent
FROM Rolling4
GROUP BY HourID, SALES, [Net Sales]
)
,Today AS( --Current Day Orders
SELECT DATEPART(HOUR,ORDER_DATE) AS HourID
,SUM([LIST_DOLLARS]) AS SALES
,SUM([QTY]) AS QTY
,SUM([Invoiced Freight]) AS [Invoiced Freight]
,SUM([Customer Programs]) AS [Customer Programs]
,SUM([Net Sales]) AS [Net Sales]
FROM [OUTPUT].[CurrentDayEstimateT4]  o
LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(o.ORDER_DATE AS DATE) = cf.DateKey
LEFT JOIN dbo.DimDemandClass dc ON o.DEMAND_CLASS = dc.DemandClassKey
LEFT JOIN dbo.DimProductMaster pm ON o.PART = pm.ProductKey
WHERE cf.DateKey = CAST(GETDATE() AS DATE)
GROUP BY DATEPART(HOUR,ORDER_DATE)
)
,Estimate AS( --Current day orders and current hour
SELECT MAX(HourID) AS CurrentHourID
,SUM(SALES) AS SALES
,SUM([Net Sales]) AS [Net Sales]
FROM Today
)
,TotalPercent AS( --Total percentage through the current hour
SELECT SUM(SalesPercent) AS TotalCurrentPercent
,SUM(NetSalesPercent) AS NetTotalCurrentPercent
FROM Percentages
WHERE HourID <= (SELECT CurrentHourID FROM Estimate)
)
SELECT --Sales estimate calculated by taking current day orders divided by the total T4 average percentage through the current hour
SALES / (SELECT TotalCurrentPercent FROM TotalPercent) AS SalesEstimate
, [Net Sales] / (SELECT NetTotalCurrentPercent FROM TotalPercent) AS NetSalesEstimate
FROM Estimate
GO
