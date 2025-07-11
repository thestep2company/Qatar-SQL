USE [XREF]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_CustomerGridbyAccount]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_CustomerGridbyAccount]
AS BEGIN
WITH Grid AS (
  SELECT 
	   [Demand Class Code]
      ,[Account Number]
      ,[Account Name]
      ,[Other]
      ,[Freight Allowance]
      ,[DIF Returns]
      ,[Cash Discounts]
      ,[Markdown]
      ,[CoOp]
      ,[Total]
      ,[Commission]
      ,[Invoiced Freight]
      ,[Year]
      ,[Month]
	  ,ROW_NUMBER() OVER (PARTITION BY [Demand Class Code] ,[Account Number] ORDER BY [Year] DESC,[Month] DESC) AS RowNum
  FROM [dbo].[Customer Grid by Account]
  WHERE Year >= 2025
)
, Dates AS (	
	SELECT DISTINCT Year, CAST([Month Seasonality Sort] AS INT) AS Month
	FROM Operations.dbo.DimCalendarFiscal
)
INSERT INTO dbo.[Customer Grid by Account]
([Demand Class Code]
      ,[Account Number]
      ,[Account Name]
      ,[Other]
      ,[Freight Allowance]
      ,[DIF Returns]
      ,[Cash Discounts]
      ,[Markdown]
      ,[CoOp]
      ,[Total]
      ,[Commission]
      ,[Invoiced Freight]
      ,[Year]
      ,[Month])
SELECT g.[Demand Class Code]
      ,g.[Account Number]
      ,g.[Account Name]
      ,g.[Other]
      ,g.[Freight Allowance]
      ,g.[DIF Returns]
      ,g.[Cash Discounts]
      ,g.[Markdown]
      ,g.[CoOp]
      ,g.[Total]
      ,g.[Commission]
      ,g.[Invoiced Freight]
      ,d.[Year]
      ,d.[Month] 
FROM Grid g
	INNER JOIN Dates d ON d.Year*100+d.Month > g.Year*100+g.Month  --Anything greater than the last date in the grid
WHERE RowNum = 1
ORDER BY g.[Demand Class Code], g.[Account Number], d.Year, d.Month
END
GO
