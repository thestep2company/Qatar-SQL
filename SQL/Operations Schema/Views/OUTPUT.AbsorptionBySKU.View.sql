USE [Operations]
GO
/****** Object:  View [OUTPUT].[AbsorptionBySKU]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[AbsorptionBySKU] AS 
SELECT [Month Sort], [Organization_Code], ACCOUNT_CODE, SUM(ISNULL(accounted_dr,0)-ISNULL(accounted_cr,0)) AS Absorption 
FROM Oracle.InventoryTransactions i
		LEFT JOIN Dim.CalendarFiscal cf ON CAST(Accounting_Date AS DATE) = cf.DateKey
		LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS l ON l.ORGANIZATION_ID = i.ORGANIZATION_ID
WHERE (Account_CODE LIKE '%4110%' OR Account_code LIKE '%4125%')  
	AND cf.DateKey >= '2021-01-01' AND i.EndDate IS NULL
	AND [Organization_Code] IN ('111','122')
GROUP BY [Month Sort], [Organization_Code], ACCOUNT_CODE
UNION
SELECT [Month Sort], [Org], [4_digit_acct] , SUM(Base_trans_value) AS Absorption
FROM Oracle.WIPTransactions wip
	LEFT JOIN Dim.CalendarFiscal cf ON CAST(wip.Transaction_Date AS DATE) = cf.DateKey
WHERE [4_digit_acct]  IN ('4110','4112','4113', '4125', '4810', '4811', '4812') 
	AND EndDate IS NULL 
	AND cf.DateKey >= '2021-01-01'
	AND Org IN ('111','122')
GROUP BY [Month Sort], [Org], [4_digit_acct] 
GO
