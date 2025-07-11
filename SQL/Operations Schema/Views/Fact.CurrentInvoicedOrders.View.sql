USE [Operations]
GO
/****** Object:  View [Fact].[CurrentInvoicedOrders]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[CurrentInvoicedOrders] AS
SELECT cf.[MonthID] AS DateID, fs.LocationID, fs.ProductID, fs.DemandClassID, -SUM(fs.QTY) AS QUANTITY
FROM dbo.FactPBISales fs
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = fs.DateKey
WHERE cf.[MonthID] = (SELECT DateID + 1 FROM dbo.DimForecastPeriod)
GROUP BY cf.[MonthID], fs.LocationID, fs.ProductID, fs.DemandClassID
GO
