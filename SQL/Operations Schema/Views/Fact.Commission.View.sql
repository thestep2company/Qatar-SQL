USE [Operations]
GO
/****** Object:  View [Fact].[Commission]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Fact].[Commission] AS
SELECT a.[Demand_Class]
	  ,dc.DemandClassID
	  ,a.[Commission %]
	  ,cf.[Month Sort]
FROM [xref].[Commission] a
	LEFT JOIN dbo.DimDemandClass dc ON a.[Demand_Class] = dc.[DemandClassKey]
	LEFT JOIN dbo.DimCalendarFiscal cf ON a.Year = cf.Year
GROUP BY a.[Demand_Class]
	  ,dc.DemandClassID
	  ,a.[Commission %]
	  ,cf.[Month Sort]
--ORDER BY [Month Sort]


GO
