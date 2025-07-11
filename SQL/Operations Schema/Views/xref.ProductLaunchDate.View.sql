USE [Operations]
GO
/****** Object:  View [xref].[ProductLaunchDate]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [xref].[ProductLaunchDate] AS 
SELECT DISTINCT sb.Part FROM xref.SalesBudget sb
	LEFT JOIN (SELECT DISTINCT Part FROM Oracle.Orders WHERE SELL_DOLLARS > 0 AND FLOW_STATUS_CODE <> 'CANCELLED') o ON sb.Part = o.Part
WHERE o.Part IS NULL AND LEFT(sb.Part,1) <> '6' AND sb.Period = '2023 B'
UNION
SELECT DISTINCT sb.Part FROM xref.SalesBudget sb
	LEFT JOIN Oracle.Invoice i ON sb.Part = i.SKU
WHERE i.SKU IS NULL  AND LEFT(sb.Part,1) <> '6' AND sb.Period = '2023 B'
--ORDER BY Part
GO
