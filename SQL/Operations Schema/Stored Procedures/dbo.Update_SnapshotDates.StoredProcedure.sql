USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Update_SnapshotDates]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Update_SnapshotDates] AS BEGIN

 --ALTER TABLE dbo.DimCalendarFiscal ADD SBSnapshot BIT
 --ALTER TABLE dbo.DimCalendarFiscal ADD PVSnapshot BIT

 UPDATE dbo.DimCalendarFiscal SET SBSnapshot = 0, PVSnapshot = 0

 UPDATE cf SET SBSnapshot = 1 FROM dbo.DimCalendarFiscal cf WHERE [Day of Week Sort] = 7
 UPDATE cf SET PVSnapshot = 1 FROM dbo.DimCalendarFiscal cf WHERE [Day of Week Sort] = 6

 SELECT * FROM dbo.DimCalendarFiscal WHERE SBHoliday = 1 AND SBSnapshot = 1
 SELECT * FROM dbo.DimCalendarFiscal WHERE PVHoliday = 1 AND PVSnapshot = 1

DECLARE @i INT = 0
 
WHILE @i < 7 BEGIN

 ;WITH CTE AS (SELECT DateID FROM dbo.DimCalendarFiscal WHERE SBHoliday = 1 AND SBSnapshot = 1)
 UPDATE cf SET SBSnapshot = 1 FROM dbo.DimCalendarFiscal cf INNER JOIN cte ON cf.DateID + 1 = cte.DateID 

 UPDATE cf1 
 SET SBSnapshot = 0 
 FROM dbo.DimCalendarFiscal cf1 
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf1.DateID = cf2.DateID + 1
 WHERE cf1.SBHoliday = 1 AND cf1.SBSnapshot = 1 AND cf2.SBSnapshot = 1


 ;WITH CTE AS (SELECT DateID FROM dbo.DimCalendarFiscal WHERE PVHoliday = 1 AND PVSnapshot = 1)
 UPDATE cf SET PVSnapshot = 1 FROM dbo.DimCalendarFiscal cf INNER JOIN cte ON cf.DateID + 1 = cte.DateID 

 UPDATE cf1 
 SET PVSnapshot = 0 
 FROM dbo.DimCalendarFiscal cf1 
	LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf1.DateID = cf2.DateID + 1
 WHERE cf1.PVHoliday = 1 AND cf1.PVSnapshot = 1 AND cf2.PVSnapshot = 1

 SET @i = @i + 1
 
END

SELECT * FROM dbo.DimCalendarFiscal WHERE SBHoliday = 1 AND SBSnapshot = 1
 SELECT * FROM dbo.DimCalendarFiscal WHERE PVHoliday = 1 AND PVSnapshot = 1

 END
GO
