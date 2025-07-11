USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactPBISalesBudgetCurrentDay]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Upsert_FactPBISalesBudgetCurrentDay] AS BEGIN     

TRUNCATE TABLE dbo.FactPBISalesBudgetCurrentDay      
INSERT INTO dbo.FactPBISalesBudgetCurrentDay   
SELECT
	   sb.[BudgetID]
      ,sb.[DateID]
      ,sb.[DateKey]
      ,sb.[DemandClassID]
      ,sb.[ProductID]
      ,sb.[CustomerID]
      ,sb.[SaleTypeID]
      ,sb.[UnitPriceID]
      ,sb.[Sales]
      ,sb.[Cogs]
      ,sb.[Material Cost]
      ,sb.[Material Overhead Cost]
      ,sb.[Resource Cost]
      ,sb.[Outside Processing Cost]
      ,sb.[Overhead Cost]
      ,sb.[GP]
      ,sb.[Units]
      ,sb.[Coop]
      ,sb.[DIF Returns]
      ,sb.[Invoiced Freight]
      ,sb.[Freight Allowance]
      ,sb.[Markdown]
      ,sb.[Cash Discounts]
      ,sb.[Other]
      ,sb.[Surcharge]
      ,sb.[Commission]
      ,sb.[Royalty]
      ,sb.[Freight Out]
      ,sb.[Sales Operations]
      ,sb.[Units Operations]
FROM dbo.FactPBISalesBudget sb    
	LEFT JOIN dbo.DimCalendarFiscal cf ON sb.DateID = cf.DateID  
WHERE     (cf.[DateKey] >= DATEADD(DAY,-2,GETDATE()) AND cf.DateKey < GETDATE()     
	OR (cf.[DateKey] >= DATEADD(DAY,-364,DATEADD(DAY,-2,GETDATE())) AND cf.DateKey < DATEADD(DAY,-364,GETDATE()))    
	OR (cf.[DateKey] >= DATEADD(DAY,-364*2,DATEADD(DAY,-2,GETDATE())) AND cf.DateKey < DATEADD(DAY,-364*2,GETDATE())))    
	AND (sb.BudgetID = 0 OR sb.BudgetID = 13)    
END



GO
