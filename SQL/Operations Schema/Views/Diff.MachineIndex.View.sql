USE [Operations]
GO
/****** Object:  View [Diff].[MachineIndex]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Diff].[MachineIndex] AS
WITH LastBatch AS (
	SELECT MAX(StartDate) AS LastBatch FROM Manufacturing.MACHINE_INDEX
)
, CurrentCycle AS (
	SELECT i.* FROM Manufacturing.MACHINE_INDEX i
		INNER JOIN LastBatch l ON i.STartDate = l.LastBatch
	WHERE i.CurrentRecord = 1
)
, PriorCycle AS (
	SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY INDEX_ID ORDER BY StartDate DESC) AS RowNumber
		, INDEX_ID
	FROM Manufacturing.MACHINE_INDEX i
		INNER JOIN LastBatch l ON i.StartDate < l.LastBatch
	WHERE i.Date_Time >= DATEADD(DAY,-35,GETDATE())
)
--new machine data
SELECT co.*
FROM CurrentCycle co
	LEFT JOIN PriorCycle po ON co.INDEX_ID = po.INDEX_ID AND po.RowNumber = 1
WHERE po.INDEX_ID  IS NULL 
GO
