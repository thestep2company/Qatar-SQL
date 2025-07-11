USE [Operations]
GO
/****** Object:  View [Fact].[ProductionBudget]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[ProductionBudget] AS

SELECT WeekID 
	  ,l.LocationID
	  ,pb.[Production $ Budget (Cost) - TOYS]
      ,pb.[Production $ Budget (Cost) - Custom]
      ,pb.[Machine Hrs (Budget) - TOYS]
      ,pb.[Machine Hrs (Budget) -Custom]
      ,pb.[Labor Earned OH]
      ,pb.[Mfg. Earned OH]
      ,pb.[Purchased OH Earned]
      ,pb.[Total Overhead Earned]
FROM xref.ProductionBudget pb
	LEFT JOIN (SELECT DISTINCT Week, WeekID FROM dbo.DimCalendarFiscal) cf ON pb.Week = cf.Week
	LEFT JOIN dbo.DimLocation l ON pb.[Location] = l.LocationKey
GO
