USE [Operations]
GO
/****** Object:  View [Fact].[ScrapLive]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[ScrapLive] AS
SELECT
	   l.LocationID AS PlantID
	  ,s.ShiftID
	  ,m.MachineID
      ,p1.ProductID AS ComponentID
	  ,p2.ProductID 
	  ,r.RepairID
	  ,rr.RepairReasonID
	  ,c.DateID	  
	  ,DATEPART(HOUR,scr.[CREATION_DATE]) AS HourID
	  ,scr.SHIFT_ID AS CurrentShiftID
	  ,0 AS ShiftOffsetID
	  ,[CREATED_BY] AS [UserName]
	  ,[ERROR_CODE] AS [ErrorKey]
	  ,[PIGMEN_RESIN] AS [PigmentKey]
	  ,CAST([QTY] AS FLOAT) AS Qty
	  ,CAST([LBS_REPAIRED_SCRAPPED] AS FLOAT) AS [Lbs]
FROM Oracle.Scrap scr
	LEFT JOIN dbo.DimLocation l ON scr.Org_Code = l.LocationKey
	LEFT JOIN dbo.DimShift s ON scr.[Shift] = s.ShiftKey
	LEFT JOIN dbo.DimMachine m ON scr.[LINES] + CASE WHEN RIGHT(scr.[LINES],1) = '_' THEN 'IG' ELSE '' END = m.MachineKey AND scr.Org_Code = m.LocationKey
	LEFT JOIN dbo.DimProductMaster p1 ON scr.[COMP_ITEM] = p1.ProductKey
	LEFT JOIN dbo.DimProductMaster p2 ON scr.[SEGMENT1] = p2.ProductKey
	LEFT JOIN dbo.DimRepair r ON scr.[REPAIR_SCRAP_TYPE] = r.RepairKey
	LEFT JOIN dbo.DimRepairReason rr ON LEFT(scr.[REPAIR_SCRAP_REASON],2) = rr.RepairReasonKey AND scr.ORG_CODE = rr.OrgCode
	LEFT JOIN dbo.DimCalendarFiscal c ON CAST(scr.[CREATION_DATE] AS DATE) = c.DateKey --no offset shift data
	INNER JOIN Dim.ShiftControl sc ON sc.CurrentShiftID = scr.Shift_ID
WHERE scr.CurrentRecord = 1 --AND p1.ProductKey = '400599' AND [Month Sort] = '202111'
UNION
SELECT
	   l.LocationID AS PlantID
	  ,s.ShiftID
	  ,m.MachineID
      ,p1.ProductID AS ComponentID
	  ,p2.ProductID 
	  ,r.RepairID
	  ,rr.RepairReasonID
	  ,c.DateID	  
	  ,DATEPART(HOUR,scr.[CREATION_DATE]) AS HourID
	  ,scr.SHIFT_ID AS CurrentShiftID
	  ,1 AS ShiftOffsetID
	  ,[CREATED_BY] AS [UserName]
	  ,[ERROR_CODE] AS [ErrorKey]
	  ,[PIGMEN_RESIN] AS [PigmentKey]
	  ,CAST([QTY] AS FLOAT) AS Qty
	  ,CAST([LBS_REPAIRED_SCRAPPED] AS FLOAT) AS [Lbs]
FROM Oracle.Scrap scr
	LEFT JOIN dbo.DimLocation l ON scr.Org_Code = l.LocationKey
	LEFT JOIN dbo.DimShift s ON scr.[Shift] = s.ShiftKey
	LEFT JOIN dbo.DimMachine m ON scr.[LINES] + CASE WHEN RIGHT(scr.[LINES],1) = '_' THEN 'IG' ELSE '' END = m.MachineKey AND scr.Org_Code = m.LocationKey
	LEFT JOIN dbo.DimProductMaster p1 ON scr.[COMP_ITEM] = p1.ProductKey
	LEFT JOIN dbo.DimProductMaster p2 ON scr.[SEGMENT1] = p2.ProductKey
	LEFT JOIN dbo.DimRepair r ON scr.[REPAIR_SCRAP_TYPE] = r.RepairKey
	LEFT JOIN dbo.DimRepairReason rr ON LEFT(scr.[REPAIR_SCRAP_REASON],2) = rr.RepairReasonKey AND scr.ORG_CODE = rr.OrgCode
	LEFT JOIN dbo.DimCalendarFiscal c ON CAST(DATEADD(HOUR,-6,scr.[CREATION_DATE]) AS DATE) = c.DateKey --no offset shift data
	INNER JOIN Dim.ShiftControl sc ON sc.CurrentShiftID = scr.Shift_ID
WHERE scr.CurrentRecord = 1

GO
