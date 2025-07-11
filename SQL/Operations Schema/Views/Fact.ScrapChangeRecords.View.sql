USE [Operations]
GO
/****** Object:  View [Fact].[ScrapChangeRecords]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Fact].[ScrapChangeRecords] AS
SELECT
	  scr.ID
	  ,l.LocationID AS PlantID
	  ,s.ShiftID
	  ,m.MachineID
      ,p1.ProductID AS ComponentID
	  ,p2.ProductID 
	  ,r.RepairID
	  ,rr.RepairReasonID
	  ,c.DateID	  
	  ,DATEPART(HOUR,scr.[CREATION_DATE]) AS HourID
	  ,0 AS ShiftOffsetID
	  ,[CREATED_BY] AS [UserName]
	  ,[ERROR_CODE] AS [ErrorKey]
	  ,[PIGMEN_RESIN] AS [PigmentKey]
	  ,CAST([QTY] AS FLOAT) AS Qty
	  ,CAST([LBS_REPAIRED_SCRAPPED] AS FLOAT) AS [Lbs]
FROM Diff.Scrap scr
	LEFT JOIN dbo.DimLocation l ON scr.Org_Code = l.LocationKey
	LEFT JOIN Dim.Shift s ON scr.[Shift] = s.ShiftKey
	LEFT JOIN Dim.Machine m ON scr.[LINES] + CASE WHEN RIGHT(scr.[LINES],1) = '_' THEN 'IG' ELSE '' END = m.MachineKey
	LEFT JOIN dbo.DimProductMaster p1 ON scr.[COMP_ITEM] = p1.ProductKey
	LEFT JOIN dbo.DimProductMaster p2 ON scr.[SEGMENT1] = p2.ProductKey
	LEFT JOIN Dim.Repair r ON scr.[REPAIR_SCRAP_TYPE] = r.RepairKey
	LEFT JOIN Dim.RepairReason rr ON LEFT(scr.[REPAIR_SCRAP_REASON],2) = rr.RepairReasonKey
	LEFT JOIN dbo.DimCalendarFiscal c ON CAST(scr.[CREATION_DATE] AS DATE) = c.DateKey --no offset shift data
WHERE scr.CurrentRecord = 1
UNION ALL
SELECT
	  scr.ID
	  ,l.LocationID AS PlantID
	  ,s.ShiftID
	  ,m.MachineID
      ,p1.ProductID AS ComponentID
	  ,p2.ProductID 
	  ,r.RepairID
	  ,rr.RepairReasonID
	  ,c.DateID
	  ,DATEPART(HOUR,scr.[CREATION_DATE]) AS HourID
	  ,1 AS ShiftOffsetID
	  ,[CREATED_BY] AS [UserName]
	  ,[ERROR_CODE] AS [ErrorKey]
	  ,[PIGMEN_RESIN] AS [PigmentKey]
	  ,CAST([QTY] AS FLOAT) AS Qty
	  ,CAST([LBS_REPAIRED_SCRAPPED] AS FLOAT) AS [Lbs]
FROM Diff.Scrap scr
	LEFT JOIN dbo.DimLocation l ON scr.Org_Code = l.LocationKey
	LEFT JOIN Dim.Shift s ON scr.[Shift] = s.ShiftKey
	LEFT JOIN Dim.Machine m ON scr.[LINES] + CASE WHEN RIGHT(scr.[LINES],1) = '_' THEN 'IG' ELSE '' END = m.MachineKey
	LEFT JOIN dbo.DimProductMaster p1 ON scr.[COMP_ITEM] = p1.ProductKey
	LEFT JOIN dbo.DimProductMaster p2 ON scr.[SEGMENT1] = p2.ProductKey
	LEFT JOIN Dim.Repair r ON scr.[REPAIR_SCRAP_TYPE] = r.RepairKey
	LEFT JOIN Dim.RepairReason rr ON LEFT(scr.[REPAIR_SCRAP_REASON],2) = rr.RepairReasonKey
	LEFT JOIN dbo.DimCalendarFiscal c ON CAST(DATEADD(HOUR,-6,scr.[CREATION_DATE]) AS DATE) = c.DateKey --offset shift data
WHERE scr.CurrentRecord = 1
GO
