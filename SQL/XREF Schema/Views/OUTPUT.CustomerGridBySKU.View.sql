USE [XREF]
GO
/****** Object:  View [OUTPUT].[CustomerGridBySKU]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[CustomerGridBySKU] AS
SELECT [Account Number]
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
FROM [XREF].[dbo].[CustomerGridBySKU]
GO
