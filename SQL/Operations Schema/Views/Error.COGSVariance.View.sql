USE [Operations]
GO
/****** Object:  View [Error].[COGSVariance]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [Error].[COGSVariance] AS
SELECT  [ID]
      ,[TRX_NUMBER]
      ,[SKU]
      ,[Qty]
      ,[Sales]
      ,[LookupCOGS]
      ,[LookupUnitCOGS]
      ,[GLCOGS]
      ,[GLUnitCOGS]
  FROM [xref].[COGSLookup]
  WHERE GLCogs > LookupCOGS * 3
  AND GLCogs <> 0
  AND NOT (SKU = '879800' AND GLUnitCogs = 19.96)
  AND NOT (SKU = '485100' AND GLUnitCogs = 19.73)
  AND NOT (SKU = '879800' AND GLUnitCogs = 19.25)


/*
 WITH CTE AS ( 
	SELECT DISTINCT TRANSACTION_ID, SKU FROM [Operations].[Oracle].[COGSActual] WHERE CurrentRecord = 0 AND SKU >= '400000' 
)
SELECT * FROM [Operations].[Oracle].[COGSActual] cogs
	INNER JOIN CTE ON cogs.TRANSACTION_ID = cte.TRANSACTION_ID AND cogs.SKU = cte.SKU
ORDER BY cte.TRANSACTION_ID, StartDate
*/
GO
