USE [Operations]
GO
/****** Object:  View [OUTPUT].[WIPTransactions]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[WIPTransactions] AS
SELECT [Month Sort] AS Period, wip.* 
FROM Oracle.WIPTransactions wip
		LEFT JOIN Dim.CalendarFiscal cf ON CAST(wip.Transaction_Date AS DATE) = cf.DateKey
WHERE [Month Sort] = '201904'
GO
