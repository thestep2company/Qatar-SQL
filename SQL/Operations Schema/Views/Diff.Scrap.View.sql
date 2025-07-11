USE [Operations]
GO
/****** Object:  View [Diff].[Scrap]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Diff].[Scrap] AS
WITH LastBatch AS (
	SELECT MAX(StartDate) AS LastBatch FROM Oracle.Scrap
)
, CurrentScrap AS (
	SELECT i.* FROM Oracle.Scrap i
		INNER JOIN LastBatch l ON i.STartDate = l.LastBatch
	WHERE i.CurrentRecord = 1
)
, PriorScrap AS (
	SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY COLLECTION_ID, OCCURRENCE ORDER BY StartDate DESC) AS RowNumber
		, COLLECTION_ID, OCCURRENCE, QTY, LBS_REPAIRED_SCRAPPED
	FROM Oracle.Scrap i
		INNER JOIN LastBatch l ON i.StartDate < l.LastBatch
	WHERE i.CREATION_DATE >= DATEADD(DAY,-35,GETDATE())
)
--new production
SELECT co.*
FROM CurrentScrap co
	LEFT JOIN PriorScrap po ON co.COLLECTION_ID = po.COLLECTION_ID  AND co.OCCURRENCE = po.OCCURRENCE AND po.RowNumber = 1
WHERE po.COLLECTION_ID IS NULL 
UNION
--change orders
SELECT co.ID
	, co.Collection_ID
	, co.OCCURRENCE
	, co.CREATION_DATE
	, co.ORG_CODE
	, co.SHIFT
	, co.LINES
	, co.REPAIR_SCRAP_TYPE
	, co.REPAIR_SCRAP_REASON
	, co.COMP_ITEM
	, CAST(co.QTY AS FLOAT) - CAST(po.QTY AS FLOAT) AS Qty
	, CAST(co.LBS_REPAIRED_SCRAPPED AS FLOAT) - CAST(po.LBS_REPAIRED_SCRAPPED AS FLOAT) AS LBS_REPARIED_SCRAPPED
	, co.ROTO_DESCRIPTION
	, co.PIGMEN_RESIN
	, co.ERROR_CODE
	, co.CREATED_BY
	, co.SEGMENT1
	, co.Fingerprint
	, co.StartDate
	, NULL AS EndDate
	, 1 AS CurrentRecord
	, co.Shift_ID
FROM CurrentScrap co
	LEFT JOIN PriorScrap po ON co.COLLECTION_ID = po.COLLECTION_ID  AND co.OCCURRENCE = po.OCCURRENCE AND po.RowNumber = 1
WHERE po.COLLECTION_ID IS NOT NULL 
	AND (CAST(co.QTY AS FLOAT) - CAST(po.QTY AS FLOAT) <> 0 OR CAST(co.LBS_REPAIRED_SCRAPPED AS FLOAT) - CAST(po.LBS_REPAIRED_SCRAPPED AS FLOAT) <> 0)

GO
