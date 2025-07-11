USE [Operations]
GO
/****** Object:  View [Error].[FactStandardMonitor]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[FactStandardMonitor] AS 

SELECT a.* FROM dbo.FactStandardsHistory a
	LEFT JOIN dbo.FactStandard b ON a.ProductID = b.ProductID AND a.LocationID = b.LocationID  AND a.StartDate > b.StartDate AND a.StartDate < b.EndDate
WHERE a.MachineHours <> b.MachineHours 
	OR a.RoundsPerShift <> b.RoundsPerShift
	OR a.UnitsPerSpider <> b.UnitsPerSpider
	OR a.LaborRate <> b.LaborRate
	OR a.RotoFloatHours <> b.RotoFloatHours
GO
