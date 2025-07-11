USE [Operations]
GO
/****** Object:  View [Fact].[SalesForecastInputCurrent]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Fact].[SalesForecastInputCurrent] AS
WITH Data AS (
	SELECT sf.*
	FROM [Step2].[Forecast] sf
		LEFT JOIN dbo.DimCalendarFiscal cf ON [Start Date] = cf.[DateKey]
	WHERE CurrentRecord = 1 AND cf.[MonthID] = (SELECT DISTINCT CurrentMonthID FROM dbo.DimCalendarFiscal WHERE CurrentMonthID IS NOT NULL) 
)
SELECT 
	cf.MonthID AS DateID 
	,ProductID 
	,DemandClassID
	,SUM(CAST(Quantity AS INT)) AS Quantity
FROM Data d 
	LEFT JOIN dbo.DimCalendarFiscal cf ON d.[Start Date] = cf.[DateKey]
	LEFT JOIN dbo.DimProductMaster pm ON d.Item_Num = pm.ProductKey 
	LEFT JOIN dbo.DimDemandClass dc ON d.[Demand_Class] = dc.DemandClassKey
GROUP BY cf.MonthID
	,ProductID 
	,DemandClassID
GO
