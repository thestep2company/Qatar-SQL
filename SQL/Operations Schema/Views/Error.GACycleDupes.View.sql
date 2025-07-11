USE [Operations]
GO
/****** Object:  View [Error].[GACycleDupes]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Error].[GACycleDupes] AS 
/*


WITH CTE AS (
  SELECT Fingerprint
	, MIN(ID) AS MinID
	, MAX(ID) AS MaxID 
  FROM [Operations].[Manufacturing].[L03260133] 
  GROUP BY FIngerprint HAVING COUNT(*) > 1
)
DELETE FROM a
FROM [Operations].[Manufacturing].[L03260133] a
	INNER JOIN CTE b ON a.ID = b.MaxID

UPDATE [Operations].[Manufacturing].[L03260133]
SET EndDate = NULL, CurrentRecord = 1

*/

SELECT * FROM [Operations].[Manufacturing].[L01260133] WHERE CurrentRecord = 0 UNION 
SELECT * FROM [Operations].[Manufacturing].[L02260133] WHERE CurrentRecord = 0 UNION 
SELECT * FROM [Operations].[Manufacturing].[L03260133] WHERE CurrentRecord = 0 UNION 
SELECT * FROM [Operations].[Manufacturing].[L04260133] WHERE CurrentRecord = 0 UNION 
SELECT * FROM [Operations].[Manufacturing].[L05260133] WHERE CurrentRecord = 0
GO
