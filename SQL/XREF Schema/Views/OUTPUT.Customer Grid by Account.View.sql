USE [XREF]
GO
/****** Object:  View [OUTPUT].[Customer Grid by Account]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[Customer Grid by Account] AS
SELECT 
	   [Account Number]
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
  FROM [XREF].[dbo].[Customer Grid by Account]
GO
