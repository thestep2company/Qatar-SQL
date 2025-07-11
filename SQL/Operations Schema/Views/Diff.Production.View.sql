USE [Operations]
GO
/****** Object:  View [Diff].[Production]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Diff].[Production] AS
WITH LastBatch AS (
	SELECT MAX(StartDate) AS LastBatch FROM Manufacturing.Production
)
, CurrentProduction AS (
	SELECT i.* FROM Manufacturing.Production i
		INNER JOIN LastBatch l ON i.STartDate = l.LastBatch
	WHERE i.CurrentRecord = 1
)
, PriorProduction AS (
	SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY TRANS_DATE_TIME, PART_NUMBER ORDER BY StartDate DESC) AS RowNumber
		, TRANS_DATE_TIME, PART_NUMBER, PRODUCTION_QTY
	FROM Manufacturing.Production i
		INNER JOIN LastBatch l ON i.StartDate < l.LastBatch
	WHERE i.Trans_Date_Time >= DATEADD(DAY,-35,GETDATE())
)
--new production
SELECT co.*, 0 AS NetChange--, po.*
FROM CurrentProduction co
	LEFT JOIN PriorProduction po ON co.TRANS_DATE_TIME = po.TRANS_DATE_TIME AND co.PART_NUMBER = po.PART_NUMBER AND po.RowNumber = 1
WHERE po.PART_NUMBER IS NULL 
GO
