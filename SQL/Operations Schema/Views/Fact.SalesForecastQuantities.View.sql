USE [Operations]
GO
/****** Object:  View [Fact].[SalesForecastQuantities]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[SalesForecastQuantities] AS
WITH Data AS (
	SELECT 'Input' AS ForecastSource, DateID, ProductID, DemandClassID, Quantity FROM Fact.SalesForecastInputCurrent
	UNION SELECT 'Input', DateID, ProductID, DemandClassID, -Quantity FROM Fact.SalesForecastOpenPrior
	UNION SELECT 'Prior Open Orders', DateID, ProductID, DemandClassID, Quantity FROM Fact.SalesForecastOpenPrior
	UNION SELECT 'Input', DateID, ProductID, DemandClassID, Quantity FROM Fact.SalesForecastInputFuture
	UNION SELECT 'Shipped Late', DateID, ProductID, DemandClassID, Quantity FROM Fact.SalesForecastShippedLate
	UNION SELECT 'Shipped Early', DateID, ProductID, DemandClassID, -Quantity FROM Fact.SalesForecastShippedEarly
)
SELECT ForecastSource, cf.DateID, ProductID, DemandClassID, SUM(Quantity) AS Quantity 
FROM Data d
	LEFT JOIN (SELECT MonthID, MIN(DateID) AS DateID FROM dbo.DimCalendarFiscal GROUP BY MonthID) cf ON cf.MonthID = d.DateID
GROUP BY  ForecastSource, cf.DateID, ProductID, DemandClassID
GO
