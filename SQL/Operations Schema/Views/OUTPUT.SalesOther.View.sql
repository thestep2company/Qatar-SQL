USE [Operations]
GO
/****** Object:  View [OUTPUT].[SalesOther]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [OUTPUT].[SalesOther] AS
SELECT [GL_PERIOD]
      ,[PERIOD_NUM]
      ,[PERIOD_YEAR]
      --,[GL_DATE]
      ,SUM([QTY_INVOICED]) AS QTY
      ,[GL_REVENUE_DISTRIBUTION]
      ,SUM([ACCTD_USD]) AS Sales
      ,[GL_COGS_DISTRIBUTION]
	  , SUBSTRING([GL_REVENUE_DISTRIBUTION],11,4) AS Account
  FROM [Oracle].[Invoice]
  WHERE REVENUE_TYPE = 'OTHER' AND GL_DATE >= '2023-01-01'
  GROUP BY  [GL_PERIOD]
      ,[PERIOD_NUM]
      ,[PERIOD_YEAR]  
	  ,[GL_REVENUE_DISTRIBUTION]
	  ,[GL_COGS_DISTRIBUTION]
  --ORDER BY PERIOD_NUM, SUBSTRING([GL_REVENUE_DISTRIBUTION],11,4)
GO
