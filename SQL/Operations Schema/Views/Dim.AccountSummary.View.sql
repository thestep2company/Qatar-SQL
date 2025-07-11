USE [Operations]
GO
/****** Object:  View [Dim].[AccountSummary]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [Dim].[AccountSummary] AS 
SELECT 'Assets' AS Header, '00000' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Liabilities' AS Header, '00050' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Equity & Retained Earnings' AS Header, '00090' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Gross Sales' AS Header, '00100' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Sales Deductions' AS Header, '00150' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Net Sales' AS Header, '00199' AS HeaderSort, 0 AS Detail, 1 AS Summary UNION
SELECT 'Cost of Goods Sold' AS Header, '00200' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Gross Profit @ Standard' AS Header, '00300' AS HeaderSort, 0 AS Detail, 1 AS Summary UNION
SELECT 'Overheads' AS Header, '00310' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Distribution' AS Header, '00320' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
--SELECT 'Amortization of Variances' AS Header, '00330' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Other Cost of Sales' AS Header, '00340' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Additional Variance' AS Header, '00350' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Freight Out' AS Header, '00380' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Gross Margin' AS Header, '00400' AS HeaderSort, 0 AS Detail, 1 AS Summary UNION
SELECT 'Operating Expenses' AS Header, '00500' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Operating Profit' AS Header, '00590' AS HeaderSort, 0 AS Detail, 1 AS Summary UNION
SELECT 'Non-Operating Expenses' AS Header, '00600' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Discontinued Operations' AS Header, '00650' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'Net Income' AS Header, '00700' AS HeaderSort, 0 AS Detail, 1 AS Summary UNION
SELECT 'EBITA Reconciliation' AS Header, '00800' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'EBITA' AS Header, '00850' AS HeaderSort, 0 AS Detail, 1 AS Summary UNION
SELECT 'Addbacks' AS Header, '00900' AS HeaderSort, 1 AS Detail, 0 AS Summary UNION
SELECT 'EBITA with Convenant Addbacks' AS Header, '00950' AS HeaderSort, 0 AS Detail, 1 AS Summary UNION
SELECT 'Orphan' AS Header, '00999' AS HeaderSort, 1 AS Detail, 0 AS Summary
GO
