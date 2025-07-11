USE [Operations]
GO
/****** Object:  View [Fact].[Standards]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Fact].[Standards] AS 


		SELECT ROW_NUMBER() OVER (PARTITION BY LEFT(im.[4 Digit],4) ORDER BY MachineHours ASC) AS Rank
			  --,im.ProductKey
			  ,im.ProductID
			  ,LEFT(im.[4 Digit],4) AS [4 Digit]
			  ,l.LocationID
			  --,l.LocationKey
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
		FROM Oracle.Standards std 
			LEFT JOIN dbo.DimProductMaster im ON std.ProductKey = im.ProductKey
			LEFT JOIN dbo.DimLocation l ON std.Organization_Code  = l.LocationKey
		WHERE CurrentRecord = 1 
GO
