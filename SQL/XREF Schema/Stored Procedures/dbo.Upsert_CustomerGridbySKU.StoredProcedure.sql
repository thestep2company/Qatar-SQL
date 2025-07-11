USE [XREF]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_CustomerGridbySKU]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_CustomerGridbySKU]
AS BEGIN
WITH Grid AS (
  SELECT 
	   [Account Number]
      ,[Account Name]
      ,[SKU]
      ,[Description]
      ,[Year]
      ,[Month]
      ,[Other]
      ,[Freight Allowance]
      ,[DIF Returns]
      ,[Cash Discounts]
      ,[Markdown]
      ,[CoOp]
      ,[Total Program %]
	  ,ROW_NUMBER() OVER (PARTITION BY [SKU] ,[Account Number] ORDER BY [Year] DESC,[Month] DESC) AS RowNum
  FROM [dbo].[CustomerGridbySKU]
  WHERE Year >= 2025
)
, Dates AS (	
	SELECT DISTINCT Year, CAST([Month Seasonality Sort] AS INT) AS Month
	FROM Operations.dbo.DimCalendarFiscal
)
INSERT INTO dbo.[CustomerGridbySKU]
(	   [Account Number]
      ,[Account Name]
      ,[SKU]
      ,[Description]
      ,[Year]
      ,[Month]
      ,[Other]
      ,[Freight Allowance]
      ,[DIF Returns]
      ,[Cash Discounts]
      ,[Markdown]
      ,[CoOp]
      ,[Total Program %])
SELECT g.[Account Number]
      ,g.[Account Name]
      ,g.[SKU]
      ,g.[Description]
      ,d.[Year]
      ,d.[Month]
      ,g.[Other]
      ,g.[Freight Allowance]
      ,g.[DIF Returns]
      ,g.[Cash Discounts]
      ,g.[Markdown]
      ,g.[CoOp]
      ,g.[Total Program %]
FROM Grid g
	INNER JOIN Dates d ON d.Year*100+d.Month > g.Year*100+g.Month  --Anything greater than the last date in the grid
WHERE RowNum = 1
ORDER BY g.[SKU], g.[Account Number], d.Year, d.Month
END
GO
