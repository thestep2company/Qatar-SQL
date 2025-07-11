USE [Operations]
GO
/****** Object:  View [OUTPUT].[Absorption]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [OUTPUT].[Absorption] AS
SELECT 'WIP' AS Type, [Month Sort] AS Period, wip.[4_digit_Acct], ORg, SKU, DESCRIPTION, PART_ID, PART_DESCRIPTION, SUM(BASE_TRANS_VALUE) AS Amount , SUM(TRANSACTION_Quantity) AS Quantity
FROM Oracle.WIPTransactions wip
		LEFT JOIN Dim.CalendarFiscal cf ON CAST(wip.Transaction_Date AS DATE) = cf.DateKey
WHERE [4_digit_Acct] IN 
('4110'
,'4112'
,'4113'
,'4125'
--,'4135'
,'4810'
,'4811'
,'4812'
,'4813'
)
GROUP BY [Month Sort], wip.[4_digit_Acct], ORg, SKU, DESCRIPTION, PART_ID, PART_DESCRIPTION
UNION ALL
SELECT 'INV', [Month Sort] AS Period, inv.[Account_CODE], Organization_ID, ITEM_CODE, [DESCRIPTION], '', '', -SUM(ACCOUNTED_CR) AS AMount, SUM(Quantity) AS Quantity
FROM Oracle.InventoryTransactions inv
		LEFT JOIN Dim.CalendarFiscal cf ON CAST(inv.Accounting_Date AS DATE) = cf.DateKey
WHERE LTRIM(RTRIM([Account_Code])) IN 
('4110'
,'4125'
--,'4135'
)
GROUP BY [Month Sort], inv.[Account_CODE], Organization_ID, ITEM_CODE, [DESCRIPTION]



GO
