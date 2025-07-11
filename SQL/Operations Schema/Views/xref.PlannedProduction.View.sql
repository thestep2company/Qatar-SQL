USE [Operations]
GO
/****** Object:  View [xref].[PlannedProduction]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [xref].[PlannedProduction] AS 

/****** Object:  View [xref].[PlannedProduction]    Script Date: 10/5/2022 10:55:07 AM ******/
WITH StartDates AS (
	SELECT DateKey 
	FROM dbo.DimCalendarFiscal 
	WHERE [Day of Week Sort] = 1
)
, SnapshotDates AS (
	SELECT '111' AS ORG_CODE, DateKey FROM dbo.DimCalendarFiscal WHERE SBSnapshot = 1 UNION
	SELECT '122' AS ORG_CODE, DateKey FROM dbo.DimCalendarFiscal WHERE PVSnapshot = 1
)
--hold on to saturday of prior week snapshots as "frozen" production
SELECT RIGHT([ORGANIZATION_CODE],3) AS ORG_CODE
			,[ITEM_SEGMENTS]
			,[DEMAND_CLASS]
			,CASE WHEN START_OF_WEEK = '2023-12-31' THEN '2024-01-01' ELSE CAST(START_OF_WEEK AS DATE) END AS START_OF_WEEK
			,[FIRM_PLANNED_TYPE]
			,'Planned Production' AS [ORDER_TYPE_TEXT]
			,DATEADD(HOUR,11,CAST(s.DateKey AS DATETIME)) AS SnapshotDate
			,SUM([QUANTITY]) AS Quantity 
FROM Oracle.MSC_ORDERS_V mov
	INNER JOIN StartDates d ON CAST(START_OF_WEEK AS DATE) = d.DateKey 
	INNER JOIN SnapshotDates s ON s.ORG_CODE = RIGHT([ORGANIZATION_CODE],3) AND DATEADD(HOUR,11,CAST(s.DateKey AS DATETIME)) BETWEEN StartDate AND ISNULL(EndDate,GETDATE()) AND d.DateKey > s.DateKey AND d.DateKey < DATEADD(DAY,7,s.DateKey) 
WHERE (mov.quantity <> 0	and mov.plan_id = 4  and mov.order_type = 5)
	AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1
GROUP BY RIGHT([ORGANIZATION_CODE],3)
		,[ITEM_SEGMENTS]
		,[DEMAND_CLASS]
		,CASE WHEN START_OF_WEEK = '2023-12-31' THEN '2024-01-01' ELSE CAST(START_OF_WEEK AS DATE) END
		,[FIRM_PLANNED_TYPE]
		,[ORDER_TYPE_TEXT]
		,DATEADD(HOUR,11,CAST(s.DateKey AS DATETIME))
GO
