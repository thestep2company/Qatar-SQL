USE [Operations]
GO
/****** Object:  View [Fact].[SalesGrid]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Fact].[SalesGrid] AS
SELECT dc.DemandClassID
	  ,MIN(DateID) AS DateID
      ,a.[COOP]
      ,a.[DIF Returns]
	  ,a.[Invoiced Freight]
	  ,a.[Freight Allowance]
	  ,a.[Markdown]
	  ,a.[Cash Discounts]
	  ,a.[Other]
	  ,a.[Commission]
	  ,cf.[Month Sort]
FROM [xref].[SalesGrid] a
	INNER JOIN dbo.DimDemandClass dc ON a.[Demand  Class] =  dc.DemandClassKey
	LEFT JOIN dbo.DimCalendarFiscal cf ON a.Year = cf.Year AND a.Month = CAST(cf.[Month Seasonality Sort] AS INT)
GROUP BY dc.DemandClassID
      ,a.[COOP]
      ,a.[DIF Returns]
	  ,a.[Invoiced Freight]
	  ,a.[Freight Allowance]
	  ,a.[Markdown]
	  ,a.[Cash Discounts]
	  ,a.[Other]
	  ,a.[Commission]
	  ,cf.[Month Sort]
GO
