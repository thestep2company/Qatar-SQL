USE [Operations]
GO
/****** Object:  View [Fact].[PBISalesBudget]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[PBISalesBudget] AS 
SELECT 13 AS BudgetID
      ,b.[DateID]
	  ,cf.DateKey
      ,[DemandClassID]
      ,[ProductID]
      ,[CustomerID]
	  ,[SaleTypeID]
	  ,UnitPriceID
      ,SUM([Sales]) AS [Sales]
      ,SUM([Cogs])  AS [Cogs]
      ,SUM([GP])	AS [GP]
      ,SUM([Units]) AS [Units]
      ,SUM([Coop])	AS [Coop]
      ,SUM([DIF Returns]) AS [DIF Returns]
      ,SUM([Invoiced Freight]) AS [Invoiced Freight]
      ,SUM([Freight Allowance]) AS [Freight Allowance]
      ,SUM([Markdown]) AS [Markdown]
      ,SUM([Cash Discounts]) AS [Cash Discounts]
      ,SUM([Other]) AS [Other]
      ,SUM([Surcharge]) AS [Surcharge]
      ,SUM([Commission]) AS [Commission]
      ,SUM([Royalty]) AS [Royalty]
      ,SUM([Freight Out]) AS [Freight Out]
  FROM [dbo].[FactOrderCurve] b
  	LEFT JOIN dbo.DimCalendarFiscal cf ON b.DateID = cf.DateID 
  WHERE SaleTypeID = 0
  GROUP BY b.[DateID]
	  ,cf.DateKey
      ,[DemandClassID]
      ,[RevenueTypeID]
      ,[ProductID]
      ,[CustomerID]
	  ,[SaleTypeID]
	  ,UnitPriceID
  UNION ALL
  --SELECT * FROM Fact.SalesBudgetByCustomer
  SELECT [ForecastID]
		  ,b.[DateID]
		  ,cf.DateKey
		  ,[DemandClassID]
		  ,[ProductID]
		  ,[CustomerID]
		  ,[SaleTypeID]
		  ,[UnitPriceID]
		  ,[Sales]
		  ,[COGS]
		  ,[GP]
		  ,[Units]
		  ,[Coop]
		  ,[DIF Returns]
		  ,[Invoiced Freight]
		  ,[Freight Allowance]
		  ,[Markdown]
		  ,[Cash Discounts]
		  ,[Other]
		  ,[Surcharge]
		  ,[Commission]
		  ,[Royalty]
		  ,[Freight Out]
	FROM [dbo].[FactSalesBudget] b
		LEFT JOIN dbo.DimCalendarFiscal cf ON b.DateID = cf.DateID 
	WHERE ForecastID = 0 AND SaleTYpeID = 0
GO
