USE [Operations]
GO
/****** Object:  View [xref].[PlannedSales]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [xref].[PlannedSales] AS 
WITH Dates AS (
	SELECT DateKey 
	FROM Dim.CalendarFiscal 
	WHERE [Day of Week Sort] = 1
)
--current records
SELECT RIGHT([ORGANIZATION_CODE],3) AS ORG_CODE
	,[ITEM_SEGMENTS]
	,[DEMAND_CLASS]
	,CAST(START_OF_WEEK AS DATE) AS START_OF_WEEK
	,[FIRM_PLANNED_TYPE]
	,'Planned ' + [ORDER_TYPE_TEXT] AS [ORDER_TYPE_TEXT]
	,SUM([QUANTITY]) AS Quantity  
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey
WHERE (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (18, 29, 30)) 
	AND d.DateKey > GETDATE() AND mov.CurrentRecord = 1
GROUP BY RIGHT([ORGANIZATION_CODE],3)
		,[ITEM_SEGMENTS]
		,[DEMAND_CLASS]
		,CAST(START_OF_WEEK AS DATE)
		,[FIRM_PLANNED_TYPE]
		,[ORDER_TYPE_TEXT]
UNION
--previous weeks use Saturday snapshots
SELECT RIGHT([ORGANIZATION_CODE],3) AS ORG_CODE
	,[ITEM_SEGMENTS]
	,[DEMAND_CLASS]
	,CAST(START_OF_WEEK AS DATE) AS START_OF_WEEK
	,[FIRM_PLANNED_TYPE]
	,'Planned ' + [ORDER_TYPE_TEXT]
	,SUM([QUANTITY]) AS Quantity  
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN Dates d ON CAST(START_OF_WEEK AS DATE)  = d.DateKey AND DATEADD(DAY,-1,DATEADD(HOUR,10,CAST(DateKey AS DATETIME))) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) 
WHERE (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (18, 29, 30)) 
GROUP BY RIGHT([ORGANIZATION_CODE],3)
		,[ITEM_SEGMENTS]
		,[DEMAND_CLASS]
		,CAST(START_OF_WEEK AS DATE)
		,[FIRM_PLANNED_TYPE]
		,[ORDER_TYPE_TEXT]
GO
