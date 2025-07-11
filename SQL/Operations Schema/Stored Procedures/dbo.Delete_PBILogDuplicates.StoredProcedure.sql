USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Delete_PBILogDuplicates]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Delete_PBILogDuplicates] AS BEGIN
	WITH CTE AS (
		SELECT GUID, Activity, MAX(Import_TimeStamp) AS Import_TimeStamp, COUNT(*) AS RecordCount FROM dbo.PowerBIActivityLog GROUP BY GUID, Activity HAVING COUNT(*) > 1
	)
	DELETE FROM pbi
	FROM  dbo.PowerBIActivityLog pbi
		INNER JOIN CTE ON pbi.GUID = cte.GUID AND pbi.Import_TimeStamp = cte.Import_TimeStamp

;	WITH CTE AS (
		SELECT GUID, Activity, MAX(Import_TimeStamp) AS Import_TimeStamp, COUNT(*) AS RecordCount FROM dbo.PowerBIActivityLog GROUP BY GUID, Activity HAVING COUNT(*) > 1
	)
	DELETE FROM pbi
	FROM  dbo.PowerBIActivityLog pbi
		INNER JOIN CTE ON pbi.GUID = cte.GUID AND pbi.Import_TimeStamp = cte.Import_TimeStamp
END
GO
