USE [Forecast]
GO
/****** Object:  View [Fact].[FinanceAdjustmentActuals]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[FinanceAdjustmentActuals] AS
WITH Calendar AS ( --common table expression to group data by year, period and min(dateID)
	SELECT YEAR, [Month Seasonality] AS [Month], MIN(DateKey) AS DateKey, MIN(DateID) AS DateID 
	FROM dbo.DimCalendarFiscal cf GROUP BY YEAR, [Month Seasonality]
)
SELECT pm.ProductID
	, cm.CustomerID
	, dc.DemandClassID
	, DateID
	,[Total Gross Sales - Product]
	,[Invoiced Freight]
	,[Programs & Allowances]
FROM dbo.FinanceAdjustmentActuals a
	LEFT JOIN Calendar c ON a.Year = c.Year AND a.Month = c.Month
	LEFT JOIN dbo.DimCustomerMaster cm ON cm.CustomerKey = 'Adjustment'
	LEFT JOIN dbo.DimProductMaster pm ON pm.ProductKey = 'Adjustment'
	LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassKey = 'Adjustment'
GO
