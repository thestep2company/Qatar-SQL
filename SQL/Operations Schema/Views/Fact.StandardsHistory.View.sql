USE [Operations]
GO
/****** Object:  View [Fact].[StandardsHistory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [Fact].[StandardsHistory] AS 

		SELECT im.ProductID
			  ,l.LocationID
			  ,[Machine]
			  ,[RoundsPerShift]*CASE WHEN l.LocationKey IN ('122','133') THEN .6666666 ELSE 1.0 END AS RoundsPerShift
			  ,[UnitsPerSpider]
			  ,[SpidersPerUnit]
			  ,[MachineHours]
			  ,[MachineRate]
			  ,[MachineCost]
			  ,[LaborRate]
			  ,[RotoOperHours]
			  ,[RotoFloatHours]
			  ,[TotalRotoHours]
			  ,[TotalRotoCost]
			  ,[AssyLaborHours]
			  ,[AssyLeadHours]
			  ,[TotalAssyHours]
			  ,[TotalAssyCost]
			  ,[TotalProcessingCost]
			  ,[TotalStandardHours]
			  ,StartDate
			  ,ISNULL(EndDate,'9999-12-31') AS EndDate
		FROM Oracle.Standards std 
			LEFT JOIN dbo.DimProductMaster im ON std.ProductKey = im.ProductKey
			LEFT JOIN dbo.DimLocation l ON std.Organization_Code  = l.LocationKey

GO
