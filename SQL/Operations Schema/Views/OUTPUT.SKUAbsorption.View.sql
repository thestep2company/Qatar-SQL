USE [Operations]
GO
/****** Object:  View [OUTPUT].[SKUAbsorption]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [OUTPUT].[SKUAbsorption] AS 
SELECT 
	   [Month Sort] AS [Period]
	  ,[Year]
	  ,[Month Seasonality] AS [Month]
      ,[SEGMENT2] AS [Location]
      ,[SEGMENT4] AS Account
      ,CAST([ACCOUNTING_DATE] AS DATE) AS ACCCOUNTING_DATE
      ,[SKU]
	  ,[SIOP Family]
	  ,pm.[Category]
      ,SUM([DEBIT]-[CREDIT]) AS Activity
	  ,'WIP' AS Source
	  --,JE_HEADER_ID
	  --,JE_LINE_NUM
	  ,SUM(TRANSACTION_QUANTITY) AS Qty
	  ,pm.ProductName
  FROM [Oracle].[XLA_WIP] wip
	LEFT JOIN dbo.DimProductMaster pm ON pm.ProductKey = wip.SKU
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = wip.ACCOUNTING_DATE
  WHERE  SEGMENT4 IN ('4110','4111','4112','4113','4125','4130','4135','4140','4810','4811','4812')
	  AND ACCOUNTING_DATE >= DATEADD(yy, DATEDIFF(yy, 0, DATEADD(YEAR,-1,GETDATE())), 0)
	  --AND JE_HEADER_ID = 9577178 AND JE_LINE_NUM BETWEEN 18 AND 21 AND SEGMENT4 IN ('4112','4113')
  GROUP BY [Month Sort]
	  ,[Year]
	  ,[Month Seasonality]
	  ,[SEGMENT2]
      ,[SEGMENT4]
      ,[ACCOUNTING_DATE]
	  ,[SIOP Family]
	  ,pm.[Category]
	  ,[SKU]
	  --,JE_HEADER_ID
	  --,JE_LINE_NUM
	  ,pm.ProductName
UNION ALL
SELECT [Month Sort] AS [Period]
	  ,[Year]
	  ,[Month Seasonality] AS [Month]
      ,[SEGMENT2] AS [Location]
      ,[SEGMENT4] AS Account
      ,CAST([ACCOUNTING_DATE] AS DATE) AS ACCCOUNTING_DATE
      ,[SKU]
	  ,[SIOP Family]
	  ,pm.[Category]
      ,SUM([DEBIT]-[CREDIT]) AS Activity
	  ,'MTL' AS Source
	  --,JE_HEADER_ID
	  --,JE_LINE_NUM
	  ,SUM(TRANSACTION_QUANTITY) AS Qty
	  ,pm.ProductName
  FROM [Oracle].[XLA_MTL] wip
	LEFT JOIN dbo.DimProductMaster pm ON pm.ProductKey = wip.SKU
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = wip.ACCOUNTING_DATE
  WHERE  SEGMENT4 IN ('4110','4111','4112','4113','4125','4130','4135','4140','4810','4811','4812')
	  AND ACCOUNTING_DATE >= DATEADD(yy, DATEDIFF(yy, 0, DATEADD(YEAR,-1,GETDATE())), 0)
	  --AND JE_HEADER_ID = 9577178 AND JE_LINE_NUM BETWEEN 18 AND 21 AND SEGMENT4 IN ('4112','4113')
  GROUP BY [Month Sort]
	  ,[Year]
	  ,[Month Seasonality]
	  ,[SEGMENT2]
      ,[SEGMENT4]
      ,[ACCOUNTING_DATE]
	  ,[SIOP Family]
	  ,pm.[Category]
	  ,[SKU]
	  --,JE_HEADER_ID
	  --,JE_LINE_NUM
	  ,pm.ProductName
--GO


GO
