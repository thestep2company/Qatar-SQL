USE [Forecast]
GO
/****** Object:  View [Fact].[SalesForecastY]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[SalesForecastY] AS

WITH ForecastMonths AS (
	SELECT	 
	      ascp.ForecastSource
		, pm.ProductKey
		, dc.DemandClassKey
		, cf.DateKey
		, pm.ProductID
		, dc.DemandClassID
		, cf.DateID		
		, ASCP.Quantity
	FROM dbo.FactSalesForecastQuantites ASCP 	
		--dimension lookups
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.[DateID] = ascp.DateID
		LEFT JOIN dbo.DimProductMaster pm ON pm.[ProductID] = ascp.ProductID
		LEFT JOIN dbo.DimDemandClass dc ON dc.[DemandClassID] = ascp.DemandClassID
	WHERE (cf.[Month Sort] >= (SELECT [ForecastMonth] FROM dbo.ForecastPeriod) AND 'F' = (SELECT [Mode] FROM dbo.ForecastPeriod) --use forecast months
		OR cf.[Month Sort] >= (SELECT [BudgetMonth] FROM dbo.ForecastPeriod) AND 'B' = (SELECT [Mode] FROM dbo.ForecastPeriod)) --use budget months
		AND dc.DemandClassKey NOT IN ('XX','XZ') --do not include safety stock or amazon updside
		AND NOT (dc.DemandClassKey = 'B2B' AND pm.ProductKey NOT LIKE 'DSKU%') --do not run B2B except for dummy SKUs, added back at the end
)
,Costing AS (
	SELECT    
	      ForecastSource
		, pm.ProductKey
		, dc.DemandClassKey
		, cf.DateKey
		, pm.ProductID
		, dc.DemandClassID
		, cf.DateID
		, QUANTITY AS Units
		, QUANTITY*ISNULL(fs.ItemCost,fsp.ItemCost) AS COGS
		, QUANTITY*ISNULL(fs.MaterialCost,fsp.MaterialCost) AS [Material Cost]
		, QUANTITY*ISNULL(fs.MaterialOverheadCost,fsp.MaterialOverheadCost) AS [Material Overhead Cost]
		, QUANTITY*ISNULL(fs.ResourceCost,fsp.ResourceCost) AS [Resource Cost]
		, QUANTITY*ISNULL(fs.OutsideProcessingCost,fsp.OutsideProcessingCost) AS [Outside Processing Cost]
		, QUANTITY*ISNULL(fs.OverheadCost,fsp.OverheadCost) AS [Overhead Cost]
		, ISNULL(fs.ItemCost,fsp.ItemCost) AS [Unit COGS]
		, ISNULL(fs.MaterialCost,fsp.MaterialCost) AS [Unit Material Cost]
		, ISNULL(fs.MaterialOverheadCost,fsp.MaterialOverheadCost) AS [Unit Material Overhead Cost]
		, ISNULL(fs.ResourceCost,fsp.ResourceCost) AS [Unit Resource Cost]
		, ISNULL(fs.OutsideProcessingCost,fsp.OutsideProcessingCost) AS [Unit Outside Processing Cost]
		, ISNULL(fs.OverheadCost,fsp.OverheadCost) AS [Unit Overhead Cost]
	FROM ForecastMonths f 	
		--dimension lookups
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.[DateID] = f.DateID
		LEFT JOIN dbo.DimProductMaster pm ON pm.[ProductID] = f.ProductID
		LEFT JOIN dbo.DimDemandClass dc ON dc.[DemandClassID] = f.DemandClassID
		LEFT JOIN dbo.FactStandard fs ON fs.ProductID = pm.ProductID AND fs.LocationID = 3 AND fs.ItemCost <> 0
		LEFT JOIN dbo.FactStandardPending fsp ON fsp.ProductID = pm.ProductID AND fsp.LocationID = 3 AND fsp.ItemCost <> 0
)
, CustomerSplit AS (
	SELECT 
		  c.ForecastSource
		, ISNULL(ISNULL(cdbs.CustomerDist,cd.CustomerDist),1) AS CustomerDist
		, CASE WHEN cdbs.CustomerDist IS NOT NULL THEN 'Demand Class and SKU Split' WHEN cd.CustomerDist IS NOT NULL THEN 'Demand Class Split' ELSE 'No Split' END AS CustomerDistType
		, cm.CustomerID
		, cm.CustomerKey
		, c.ProductKey
		, c.DemandClassKey
		, c.DateKey
		, c.ProductID
		, c.DemandClassID
		, c.DateID		
		, c.Units*ISNULL(ISNULL(cdbs.CustomerDist,cd.CustomerDist),1) AS Units
		, CASE WHEN c.DemandClassKey IN ('XX','XZ') THEN 0 ELSE c.COGS*ISNULL(ISNULL(cdbs.CustomerDist,cd.CustomerDist),1) END AS COGS
		, CASE WHEN c.DemandClassKey IN ('XX','XZ') THEN 0 ELSE c.[Material Cost]*ISNULL(ISNULL(cdbs.CustomerDist,cd.CustomerDist),1) END AS [Material Cost]
		, CASE WHEN c.DemandClassKey IN ('XX','XZ') THEN 0 ELSE c.[Material Overhead Cost]*ISNULL(ISNULL(cdbs.CustomerDist,cd.CustomerDist),1) END AS [Material Overhead Cost]
		, CASE WHEN c.DemandClassKey IN ('XX','XZ') THEN 0 ELSE c.[Resource Cost]*ISNULL(ISNULL(cdbs.CustomerDist,cd.CustomerDist),1) END AS [Resource Cost]
		, CASE WHEN c.DemandClassKey IN ('XX','XZ') THEN 0 ELSE c.[Outside Processing Cost]*ISNULL(ISNULL(cdbs.CustomerDist,cd.CustomerDist),1) END AS [Outside Processing Cost]
		, CASE WHEN c.DemandClassKey IN ('XX','XZ') THEN 0 ELSE c.[Overhead Cost]*ISNULL(ISNULL(cdbs.CustomerDist,cd.CustomerDist),1) END AS [Overhead Cost]
		, c.[Unit COGS]
		, c.[Unit Material Cost]
		, c.[Unit Material Overhead Cost]
		, c.[Unit Resource Cost]
		, c.[Unit Outside Processing Cost]
		, c.[Unit Overhead Cost]
	FROM Costing c
		LEFT JOIN dbo.DimDemandClass dc on c.DemandClassID = dc.DemandClassID
		LEFT JOIN dbo.FactCustomerDistBySKU cdbs ON cdbs.[DEM_CLASS] = c.[DemandClassKey] AND c.[ProductKey] = cdbs.[SKU] --customer SKU history
		LEFT JOIN dbo.FactCustomerDist cd ON c.[DemandClassKey] = cd.DEM_CLASS AND cdbs.SKU IS NULL --only SKU history if never sold to THAT customer
		LEFT JOIN dbo.DimCustomerMaster cm ON cm.CustomerKey = ISNULL(ISNULL(cdbs.ACCT_NUM,cd.ACCT_NUM),dc.DemandClassKey)
)
, OrderCurve AS ( --even across week days
		SELECT cf1.Year
			, cf1.[Month Sort]
			, cf2.DateID
			--, fs.DemandClassID 
			, 1 AS SalesPercentByDay
			, 0 AS SalesPercentByHour
			, 1.0/CAST(COUNT(cf2.DateID) OVER (PARTITION BY cf1.[Month Sort]) AS FLOAT) AS SalesPercent --, fs.DemandClassID
		FROM  CustomerSplit  fs
			LEFT JOIN dbo.DimCalendarFiscal cf1 ON fs.DateID = cf1.DateID
			LEFT JOIN dbo.DimCalendarFiscal cf2 ON cf1.Month = cf2.Month
		WHERE cf2.[Day of Week Sort] BETWEEN 2 AND 6 --only weekdays
		GROUP BY cf1.Year, cf2.DateID, cf1.[Month Sort]--, fs.DemandClassID
)
, OrderCurveFinancial AS ( --same even dist as order curve above
	SELECT
		  f.ForecastSource
		, f.CustomerDist
		, f.CustomerDistType
		, f.CustomerID
		, f.CustomerKey
		, f.ProductKey
		, f.DemandClassKey
		, ISNULL(oc.DateID,f.DateID) AS DateID
		, f.ProductID
		, f.DemandClassID	
		, f.Units*ISNULL(oc.SalesPercent,1) AS Units
		, f.COGS*ISNULL(oc.SalesPercent,1) AS COGS
		, f.[Material Cost]*ISNULL(oc.SalesPercent,1) AS [Material Cost]
		, f.[Material Overhead Cost]*ISNULL(oc.SalesPercent,1) AS [Material Overhead Cost]
		, f.[Resource Cost]*ISNULL(oc.SalesPercent,1) AS [Resource Cost]
		, f.[Outside Processing Cost]*ISNULL(oc.SalesPercent,1) AS [Outside Processing Cost]
		, f.[Overhead Cost]*ISNULL(oc.SalesPercent,1) AS [Overhead Cost]
		, f.[Unit COGS]
		, f.[Unit Material Cost]
		, f.[Unit Material Overhead Cost]
		, f.[Unit Resource Cost]
		, f.[Unit Outside Processing Cost]
		, f.[Unit Overhead Cost]
	FROM CustomerSplit f
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = f.DateID
		LEFT JOIN OrderCurve oc ON cf.[Month Sort] = oc.[Month Sort] AND cf.[Year] = oc.[Year] --f.DemandClassID = oc.DemandClassID 
		LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassID = f.DemandClassID
		LEFT JOIN dbo.DimCustomerMaster cm ON f.CustomerID = cm.CustomerID
)
--use history to determine ecom spread
, EcomCurve AS ( --get all dates for the year
	SELECT Year, [Week Seasonality], [Month Sort], DateID, DateKey, COUNT(*) OVER (PARTITION BY [Year], [Week Seasonality])  AS DayCount 
	FROM dbo.DimCalendarFiscal cf 
	WHERE ShipDay = 1
		AND cf.[Day of Week Sort] BETWEEN 2 AND 6
		AND (('F' = (SELECT [Mode] FROM dbo.ForecastPeriod) AND cf.[Month Sort] >= (SELECT [ForecastMonth] FROM dbo.ForecastPeriod)) --AND cf.Year = (SELECT LEFT([ForecastMonth],4) FROM dbo.ForecastPeriod)
		OR  ('B' = (SELECT [Mode] FROM dbo.ForecastPeriod) AND cf.[Month Sort] >= (SELECT [BudgetMonth] FROM dbo.ForecastPeriod))) --AND cf.Year = (SELECT LEFT([BudgetMonth],4) FROM dbo.ForecastPeriod)
	GROUP BY Year, [Week Seasonality], [Month Sort], DateID, DateKey 
)
, OrderCurveOperations AS (
	SELECT 
		  1 AS SourceID
		, cf.[Month Sort]
		, d.[DateID] AS TargetDateID
		, cf.DateID AS DateIDJoin
		, sf.ForecastSource
		, sf.CustomerDist
		, sf.CustomerDistType
		, sf.CustomerID
		, sf.CustomerKey
		, sf.ProductKey
		, sf.DemandClassKey
		, d.DateID		
		, sf.ProductID
		, sf.DemandClassID
		, SUM(ISNULL(oc.Value,1) *sf.Units)/DayCount AS Units
		, SUM(ISNULL(oc.Value,1) *sf.COGS)/DayCount AS COGS
		, SUM(ISNULL(oc.Value,1) *sf.[Material Cost])/DayCount AS [Material Cost]
		, SUM(ISNULL(oc.Value,1) *sf.[Material Overhead Cost])/DayCount AS [Material Overhead Cost]
		, SUM(ISNULL(oc.Value,1) *sf.[Resource Cost])/DayCount AS [Resource Cost]
		, SUM(ISNULL(oc.Value,1) *sf.[Outside Processing Cost])/DayCount AS [Outside Processing Cost]
		, SUM(ISNULL(oc.Value,1) *sf.[Overhead Cost])/DayCount AS [Overhead Cost]
		, sf.[Unit COGS]
		, sf.[Unit Material Cost]
		, sf.[Unit Material Overhead Cost]
		, sf.[Unit Resource Cost]
		, sf.[Unit Outside Processing Cost]
		, sf.[Unit Overhead Cost]	
	FROM CustomerSplit sf
		LEFT JOIN dbo.DimCalendarFiscal cf ON sf.[DateID] = cf.DateID
		LEFT JOIN dbo.DimProductMaster pm ON sf.ProductID = pm.ProductID
		LEFT JOIN dbo.DimDemandClass dc ON sf.DemandClassID = dc.DemandClassID
		INNER JOIN dbo.DimOrderCurveProductGroup oc ON oc.Category = pm.Category AND oc.[Product Group] = pm.ProductGroup AND oc.Year = cf.Year
		INNER JOIN EcomCurve d ON d.[Week Seasonality] = oc.[Week Seasonality] AND d.[Year] = cf.Year
	WHERE dc.[Finance Reporting Channel] = 'E-COMMERCE' AND dc.[Ecommerce Type] = 'DROPSHIP'
	GROUP BY cf.[Month Sort]
		, sf.[DateID]
		, cf.DateID 
		, sf.ForecastSource
		, sf.CustomerDist
		, d.DayCount
		, sf.CustomerDistType
		, sf.CustomerID
		, sf.CustomerKey
		, sf.ProductKey
		, sf.DemandClassKey
		, sf.ProductID
		, sf.DemandClassID
		, sf.[Unit COGS]
		, sf.[Unit Material Cost]
		, sf.[Unit Material Overhead Cost]
		, sf.[Unit Resource Cost]
		, sf.[Unit Outside Processing Cost]
		, sf.[Unit Overhead Cost]	
		, d.DateID		
	UNION ALL
	SELECT 2 AS SourceID
		, cf.[Month Sort]
		, sf.DateID AS TargetDateID
		, cf.DateID AS DateIDJoin
		, sf.* 
	FROM OrderCurveFinancial sf 
		LEFT JOIN dbo.DimCalendarFiscal cf ON sf.[DateID] = cf.DateID
		LEFT JOIN dbo.DimProductMaster pm ON sf.ProductID = pm.ProductID
		LEFT JOIN (SELECT DISTINCT Category, [Product Group], [Year] FROM dbo.DimOrderCurveProductGroup) ocpg ON ocpg.Category = pm.Category AND ocpg.[Product Group] = pm.ProductGroup AND ocpg.Year = cf.Year
		LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassID = sf.DemandClassID 
	WHERE dc.[Finance Reporting Channel] = 'E-COMMERCE' AND dc.[Ecommerce Type] = 'DROPSHIP' AND ocpg.[Product Group] IS NULL
	UNION ALL
	SELECT 3 AS SourceID
		, cf.[Month Sort]
		, sf.DateID AS TargetDateID
		, cf.DateID AS DateIDJoin
		, sf.* 
	FROM OrderCurveFinancial sf
		LEFT JOIN dbo.DimProductMaster pm ON sf.ProductID = pm.ProductID
		LEFT JOIN dbo.DimDemandClass dc ON dc.DemandClassID = sf.DemandClassID 
		LEFT JOIN dbo.DimCalendarFiscal cf ON sf.[DateID] = cf.DateID
	WHERE  (dc.[Finance Reporting Channel] <> 'E-COMMERCE' OR dc.[Ecommerce Type] <> 'DROPSHIP')
)
, ForecastCurve AS (
SELECT
	   ForecastSource
	  ,CustomerDist
	  ,CustomerDistType
	  ,CustomerID
	  ,CustomerKey
	  ,ProductKey
	  ,DemandClassKey
	  ,ProductID
	  ,DemandClassID
	  ,DateID		
      ,[Cogs]
      ,[Units]
      ,[Material Cost]
      ,[Material Overhead Cost]
      ,[Resource Cost]
      ,[Outside Processing Cost]
      ,[Overhead Cost]
	  ,[Unit COGS]
	  ,[Unit Material Cost]
	  ,[Unit Material Overhead Cost]
	  ,[Unit Resource Cost]
	  ,[Unit Outside Processing Cost]
	  ,[Unit Overhead Cost]
	  ,0 AS [Cogs Operations]
	  ,0 AS [Units Operations]
	FROM OrderCurveFinancial
	UNION ALL
	SELECT
	   ForecastSource
	  ,CustomerDist
	  ,CustomerDistType
	  ,CustomerID
	  ,CustomerKey
	  ,ProductKey
	  ,DemandClassKey
	  ,ProductID
	  ,DemandClassID
	  ,DateID		
      ,0 AS [Cogs]
      ,0 AS [Units]
      ,0 AS [Material Cost]
      ,0 AS [Material Overhead Cost]
      ,0 AS [Resource Cost]
      ,0 AS [Outside Processing Cost]
      ,0 AS [Overhead Cost]
	  ,[Unit COGS]
	  ,[Unit Material Cost]
	  ,[Unit Material Overhead Cost]
	  ,[Unit Resource Cost]
	  ,[Unit Outside Processing Cost]
	  ,[Unit Overhead Cost]
	  ,[Cogs] AS [Cogs Operations]
	  ,[Units] AS [Units Operations]
	FROM OrderCurveOperations
)
, Pricing AS (
	SELECT 
		fs.*
		, CASE		WHEN DemandClassKey = 'XX' OR DemandClassKey = 'XZ' THEN 0 
					WHEN ISNULL(pl.Price,0) <> 0 THEN pl.Price
					WHEN fpsd.ProductID IS NOT NULL THEN fpsd.InvoicePrice					
					WHEN fps.ProductID IS NOT NULL THEN fps.InvoicePrice
					WHEN DemandClassKey = 'D2U' AND ISNULL(fs.[Unit COGS],0) <> 0 THEN fs.[Unit COGS]*(1.0/(1-.65))
					WHEN ISNULL(gpl.Price,0) <> 0 THEN gpl.Price
					WHEN ISNULL(fs.[Unit COGS],0) <> 0 THEN fs.[Unit COGS]*100.0  --fs.[Unit COGS]*(1+1.0/3) 
					WHEN fp.ForecastPrice IS NOT NULL THEN fp.ForecastPrice  
					ELSE 0
		  END * [Units Operations] AS [Sales Operations]
		, 1 AS SaleTypeID
		, CASE		WHEN DemandClassKey = 'XX' OR DemandClassKey = 'XZ' THEN 0 
					WHEN ISNULL(pl.Price,0) <> 0 THEN pl.Price  
					WHEN fpsd.ProductID IS NOT NULL THEN fpsd.InvoicePrice
					WHEN fps.ProductID IS NOT NULL THEN fps.InvoicePrice
					WHEN DemandClassKey = 'D2U' AND ISNULL(fs.[Unit COGS],0) <> 0 THEN fs.[Unit COGS]*(1.0/(1-.65))
					WHEN ISNULL(gpl.Price,0) <> 0 THEN gpl.Price
					WHEN ISNULL(fs.[Unit COGS],0) <> 0 THEN fs.[Unit COGS]*100.0
					WHEN fp.ForecastPrice IS NOT NULL THEN fp.ForecastPrice
					ELSE 0
		  END * Units*1.0 AS Sales		
		, CASE		WHEN DemandClassKey = 'XX' OR DemandClassKey = 'XZ' THEN 0 
					WHEN ISNULL(pl.Price,0) <> 0 THEN pl.Price*100.0
					WHEN fpsd.ProductID IS NOT NULL THEN fpsd.InvoicePrice*100.0 
					WHEN fps.ProductID IS NOT NULL THEN fps.InvoicePrice*100.0
					WHEN DemandClassKey = 'D2U' AND ISNULL(fs.[Unit COGS],0) <> 0 THEN fs.[Unit COGS]*(1.0/(1-.65))*100.0
					WHEN ISNULL(gpl.Price,0) <> 0 THEN gpl.Price*100.0
					WHEN ISNULL(fs.[Unit COGS],0) <> 0 THEN fs.[Unit COGS]*100*100.0
					WHEN fp.ForecastPrice IS NOT NULL THEN fp.ForecastPrice*100.0
					ELSE 0  
		  END AS UnitPriceID	
		, CAST(pl.Price*100 AS INT) AS InvoicePriceID
		, CAST(fp.ForecastPrice*100 AS INT) AS CurrentForecastPriceID
		, fpsd.InvoicePrice*100 AS AvgDemandClassProductPrice
		, fps.InvoicePrice*100 AS AvgProductPrice
		, ISNULL(fs.[Unit COGS],0)*100.0*100 AS HousePrice
		, CAST(0 AS INT) AS LastForecastPriceID
		, CAST(0 AS INT) AS BudgetPriceID
		, CAST(0 AS INT) AS LastBudgetPriceID 
		, fs.Units*pl.Price AS [Sales Invoice Price]
		, fs.Units*fp.ForecastPrice AS [Sales Forecast Price]
		, CAST(0 AS MONEY) AS [Sales Budget Price]
		, CAST(0 AS MONEY) AS [Sales Budget LY Price] 
		, CAST(NULL AS DATE) AS [Last Invoice Date]
		, fs.Units*fpsd.InvoicePrice AS [Sales Demand Class SKU Price]
		, fs.Units*fps.InvoicePrice AS [Sales Demand Average SKU Price]
		, COGS*100 AS [Sales House Price] --force 99% margin --COGS*(1+1.0/3) 
		, ISNULL(pl.Currency,gpl.Currency) AS [Base Currency]
		, CASE WHEN ISNULL(pl.Price,0) <> 0 THEN 'Oracle Price' 
				WHEN fpsd.ProductID IS NOT NULL THEN 'Average Demand Class Invoice Price' 
				WHEN fps.ProductID IS NOT NULL THEN 'Average Invoice Price'
				WHEN DemandClassKey = 'D2U' AND ISNULL(fs.[Unit COGS],0) <> 0 THEN 'House Price'
				WHEN ISNULL(gpl.Price,0) <> 0 THEN 'General Price'
				WHEN ISNULL(fs.[Unit COGS],0) <> 0 THEN 'House Price' 
				WHEN fp.ProductID IS NOT NULL THEN 'Forecast Price'
				ELSE 'No Price or Cost Provided'
		END AS [Price Type]
	FROM ForecastCurve fs
		--pricing
		LEFT JOIN dbo.DimCalendarFiscal cf ON fs.DateID = cf.DateID
		LEFT JOIN dbo.FactPriceList pl ON pl.CustomerID = fs.CustomerID AND fs.ProductID = pl.ProductID AND cf.DateKey BETWEEN pl.StartDate AND pl.EndDate--pass #1 oracle price list
		LEFT JOIN (SELECT DemandClassID, ProductID, AVG(InvoicePrice) AS InvoicePrice FROM dbo.FactPricing WHERE ISNULL(InvoicePrice,0) <> 0 GROUP BY DemandClassID, ProductID) fpsd ON fs.ProductID = fpsd.ProductID AND fs.DemandClassID = fpsd.DemandClassID --pass #2 demand class invoice price history
		LEFT JOIN (SELECT ProductID, AVG(InvoicePrice) AS InvoicePrice FROM dbo.FactPricing fp LEFT JOIN dbo.DimDemandClass dc ON fp.DemandClassID = dc.DemandClassID WHERE dc.DemandClassKey <> 'D2U' AND ISNULL(InvoicePrice,0) <> 0 GROUP BY ProductID) fps ON fs.ProductID = fps.ProductID --pass #3 product invoice price history
		LEFT JOIN (SELECT ROW_NUMBER() OVER (PARTITION BY ProductID, StartDate ORDER BY Price DESC) AS RowNumber, ProductID, StartDate, EndDate, Price, Currency FROM dbo.FactPriceList WHERE PriceList ='S2C 2021 WHSE PRICE LIST USD') gpl ON gpl.RowNumber = 1 AND fs.ProductID = gpl.ProductID AND cf.DateKey BETWEEN gpl.StartDate AND gpl.EndDate --pass #4 general price list
		--pass #5 house margin
		LEFT JOIN dbo.FactPricing fp ON fs.ProductID = fp.ProductID AND fs.DemandClassID = fp.DemandClassID --pass #6 forecast plug price
		--LEFT JOIN dbo.FactConversionRate cc ON CAST(GETDATE() AS DATE) = cc.CONVERSION_DATE AND pl.Currency = cc.FROM_CURRENCY --convert to USD
)
, SalesGrid AS (
	SELECT c.* --top select is for grid customers only
		, c.Sales-c.COGS AS GP
		, -ISNULL(sgc1.[CoOp],ISNULL(sgc2.[CoOp],ISNULL(sg1.Coop,sg2.Coop)))*c.Sales AS Coop
		, -ISNULL(sgc1.[DIF Returns],ISNULL(sgc2.[DIF Returns],ISNULL(sg1.[DIF Returns],sg2.[DIF Returns])))*c.Sales AS [DIF Returns]
		, ISNULL(sg1.[Invoiced Freight],sg2.[Invoiced Freight])*c.Sales AS [Invoiced Freight]
		, -ISNULL(sgc1.[Freight Allowance],ISNULL(sgc2.[Freight Allowance],ISNULL(sg1.[Freight Allowance],sg2.[Freight Allowance])))*c.Sales AS [Freight Allowance]
		, -ISNULL(sgc1.[Markdown],ISNULL(sgc2.[Markdown],ISNULL(sg1.[Markdown],sg2.[Markdown])))*c.Sales AS [Markdown]
		, -ISNULL(sgc1.[Cash Discounts],ISNULL(sgc2.[Cash Discounts],ISNULL(sg1.[Cash Discounts],sg2.[Cash Discounts])))*c.Sales AS [Cash Discounts]
		, -ISNULL(sgc1.[Other],ISNULL(sgc2.[Other],ISNULL(sg1.[Other],sg2.[Other])))*c.Sales AS [Other]
		, -0*c.Sales AS [Surcharge]
		, -ISNULL(sg1.[Commission],sg2.[Commission])*c.Sales AS [Commission]
		, -0*c.Sales AS [Royalty]
		, -0*c.Sales AS [Freight Out]
		--, c.[Sales Operations]*ISNULL([Coop],0)+ISNULL([Other],0)+ISNULL([DIF Returns],0)+ISNULL([Markdown],0)+ISNULL([Cash Discounts],0)+ISNULL([Freight Allowance],0))+ISNULL([Invoiced Freight],0)
		, -ISNULL(sgc1.[CoOp],ISNULL(sgc2.[CoOp],ISNULL(sg1.Coop,sg2.Coop)))*c.[Sales Operations] AS [Coop Operations]
		, -ISNULL(sgc1.[Other],ISNULL(sgc2.[Other],ISNULL(sg1.[Other],sg2.[Other])))*c.[Sales Operations] AS [Other Operations]
		, -ISNULL(sgc1.[DIF Returns],ISNULL(sgc2.[DIF Returns],ISNULL(sg1.[DIF Returns],sg2.[DIF Returns])))*c.[Sales Operations] AS [DIF Returns Operations]
		, -ISNULL(sgc1.[Markdown],ISNULL(sgc2.[Markdown],ISNULL(sg1.[Markdown],sg2.[Markdown])))*c.[Sales Operations] AS [Markdown Operations]
		, -ISNULL(sgc1.[Cash Discounts],ISNULL(sgc2.[Cash Discounts],ISNULL(sg1.[Cash Discounts],sg2.[Cash Discounts])))*c.[Sales Operations] AS [Cash Discounts Operations]
		, -ISNULL(sgc1.[Freight Allowance],ISNULL(sgc2.[Freight Allowance],ISNULL(sg1.[Freight Allowance],sg2.[Freight Allowance])))*c.[Sales Operations] AS [Freight Allowance Operations]
		, +ISNULL(sg1.[Invoiced Freight],sg2.[Invoiced Freight])*c.[Sales Operations] AS [Invoiced Freight Operations]
	FROM Pricing c
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = c.DateID 
		--add customer grids to download setups
		LEFT JOIN xref.CustomerGridBySKU sgc1 ON c.CustomerKey = CAST(sgc1.[Account Number] AS VARCHAR(50)) AND c.ProductKey = sgc1.SKU AND cf.Year = sgc1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sgc1.Month --match to year + month for Costco customer grid by SKU
		LEFT JOIN xref.CustomerGridBySKU sgc2 ON c.CustomerKey = CAST(sgc2.[Account Number] AS VARCHAR(50)) AND c.ProductKey = sgc2.SKU AND cf.Year = sgc2.Year AND sgc2.Month IS NULL --everything else use month is NULL for Costco customer grid by SKU
		LEFT JOIN xref.[Customer Grid by Account] sg1 ON c.CustomerKey = CAST(sg1.[Account Number] AS VARCHAR(50)) AND cf.Year = sg1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sg1.Month --match on a year + month for the customer grid  --AND c.DemandClassKey = sg1.[Demand Class Code]
		LEFT JOIN xref.[Customer Grid by Account] sg2 ON c.CustomerKey = CAST(sg2.[Account Number] AS VARCHAR(50)) AND cf.Year = sg2.Year AND sg1.[Account Number] IS NULL AND sg2.Month IS NULL  --else use the NULL month for the customer grid  --AND c.DemandClassKey = sg2.[Demand Class Code]
	WHERE (sg1.[Account Number] IS NOT NULL OR sg2.[Account Number] IS NOT NULL)
	UNION ALL	
	--demand classes that do not exist in the customer grid, we check the misc grid to assign customer programs
	SELECT c.*
		, c.Sales-c.COGS AS GP
		, -ISNULL(sgf.Coop,0)*c.Sales AS Coop
		, -ISNULL(sgf.[DIF Returns],0)*c.Sales AS [DIF Returns]
		, ISNULL(sgf.[Invoiced Freight],0) * c.Sales AS [Invoiced Freight]
		, -ISNULL(sgf.[Freight Allowance],0)*c.Sales AS [Freight Allowance]
		, -ISNULL(sgf.[Markdown],0)*c.Sales AS [Markdown]
		, -ISNULL(sgf.[Cash Discounts],0)*c.Sales AS [Cash Discounts]
		, -ISNULL(sgf.[Other],0)*c.Sales AS [Other]
		, -0*c.Sales AS [Surcharge]
		, -ISNULL(sgf.[Commission],0)*c.Sales AS [Commission]
		, -0*c.Sales AS [Royalty]
		, -0*c.Sales AS [Freight Out]
		, -ISNULL(sgf.Coop,0)*c.[Sales Operations] AS [Coop Operations]
		, -ISNULL(sgf.[Other],0)*c.[Sales Operations] AS [Other Operations]
		, -ISNULL(sgf.[DIF Returns],0)*c.[Sales Operations] AS [DIF Returns Operations]
		, -ISNULL(sgf.[Markdown],0)*c.[Sales Operations] AS [Markdown Operations]
		, -ISNULL(sgf.[Cash Discounts],0)*c.[Sales Operations] AS [Cash Discounts Operations]
		, -ISNULL(sgf.[Freight Allowance],0)*c.[Sales Operations] AS [Freight Allowance Operations]
		, +ISNULL(sgf.[Invoiced Freight],0)*c.[Sales Operations] AS [Invoiced Freight Operations]		
	FROM Pricing c
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = c.DateID
		LEFT JOIN xref.[Customer Grid by Account] sg ON c.CustomerKey = CAST(sg.[Account Number] AS VARCHAR(50))  AND cf.Year = sg.Year --AND MONTH(cf.Month) = ISNULL(sg.Month,MONTH(cf.Month))  -- AND c.DemandClassKey = sg.[Demand Class Code]
		INNER JOIN xref.[Customer Grid Misc] sgf ON c.[DemandClassKey] = sgf.[Demand Class Code] --but you are in the misc grid
	WHERE sg.[Account Number] IS NULL  --not in the customer grid  --sg.[Demand Class Code] IS NULL
	UNION ALL 	
	-- does not exist in either grid lookup, keep actual values
	SELECT c.*
		, c.Sales-c.COGS AS GP
		, 0 AS Coop
		, 0 AS [DIF Returns]
		, 0 AS [InvoicedFreight]
		, 0 AS [Freight Allowance]
		, 0 AS [Markdown]
		, 0 AS [Cash Discounts]
		, 0 AS [Other]
		, 0 AS [Surcharge]
		, 0 AS [Commission]
		, 0 AS [Royalty]
		, 0 AS [Freight Out]
		, 0 AS [Coop Operations]
		, 0 AS [Other Operations]
		, 0 AS [DIF Returns Operations]
		, 0 AS [Markdown Operations]
		, 0 AS [Cash Discounts Operations]
		, 0 AS [Freight Allowance Operations]
		, 0 AS [Invoiced Freight Operations]	
	FROM Pricing c
		LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateID = c.DateID
		LEFT JOIN xref.[Customer Grid by Account] sg ON c.CustomerKey = CAST(sg.[Account Number] AS VARCHAR(50)) AND cf.Year = sg.Year  -- AND c.DemandClassKey = sg.[Demand Class Code] 
		LEFT JOIN xref.[Customer Grid Misc] sgf ON c.[DemandClassKey] = sgf.[Demand Class Code]
	WHERE sg.[Account Number] IS NULL AND sgf.[Demand Class Code] IS NULL --must exist in either grid lookup  --sg.[Demand Class Code] IS NULL 
)
SELECT CASE WHEN (SELECT [Mode] FROM dbo.ForecastPeriod) = 'B' THEN 0 ELSE 13 END AS BudgetID
	  ,[ForecastSource]
      ,[DateID]
      ,[DemandClassID]
      ,[ProductID]
      ,[CustomerID]
      ,[SaleTypeID]
      ,[UnitPriceID]
      ,SUM([Sales]) AS [Sales]
      ,SUM([Cogs]) AS [Cogs]
      ,SUM([Material Cost]) AS [Material Cost]
      ,SUM([Material Overhead Cost]) AS [Material Overhead Cost]
      ,SUM([Resource Cost]) AS [Resource Cost]
      ,SUM([Outside Processing Cost]) AS [Outside Processing Cost]
      ,SUM([Overhead Cost]) AS [Overhead Cost]
      ,SUM([GP]) AS [GP]
      ,SUM([Units]) AS [Units]
      ,SUM([Coop]) AS [Coop]
      ,SUM([DIF Returns]) AS [DIF Returns]
      ,SUM([Invoiced Freight]) AS [Invoiced Freight]
      ,SUM([Freight Allowance]) AS [Freight Allowance]
      ,SUM([Markdown]) AS [Markdown]
      ,SUM([Cash Discounts]) AS [Cash Discounts]
      ,SUM([Other]) AS [Other]
      ,SUM([Surcharge]) AS [Surcharge]
      ,SUM([Commission]) AS [Commission]
      ,SUM([Royalty]) AS [Royalty]
      ,SUM([Freight Out]) AS [Freight Out]
      ,SUM([Sales Operations]) AS [Sales Operations]
	  ,SUM([COGS Operations]) AS [COGS Operations]
      ,SUM([Units Operations]) AS [Units Operations]
	  ,SUM([Coop Operations]) AS [Coop Operations]
      ,SUM([DIF Returns Operations]) AS [DIF Returns Operations]
      ,SUM([Invoiced Freight Operations]) AS [Invoiced Freight Operations]
      ,SUM([Freight Allowance Operations]) AS [Freight Allowance Operations]
      ,SUM([Markdown Operations]) AS [Markdown Operations]
      ,SUM([Cash Discounts Operations]) AS [Cash Discounts Operations]
      ,SUM([Other Operations]) AS [Other Operations]
      ,[InvoicePriceID]
      ,[LastForecastPriceID]
      ,[BudgetPriceID]
      ,[LastBudgetPriceID]
      ,SUM([Sales Invoice Price]) AS [Sales Invoice Price]
      ,SUM([Sales Forecast Price]) AS [Sales Forecast Price]
      ,SUM([Sales Budget Price]) AS [Sales Budget Price]
      ,SUM([Sales Budget LY Price]) AS [Sales Budget LY Price]
      ,[Base Currency]
      ,[Price Type]
FROM SalesGrid
GROUP BY 
	   [ForecastSource]
	  ,[DateID]
      ,[DemandClassID]
      ,[ProductID]
      ,[CustomerID]
      ,[SaleTypeID]
      ,[UnitPriceID]
      ,[InvoicePriceID]
      ,[LastForecastPriceID]
      ,[BudgetPriceID]
      ,[LastBudgetPriceID]
      ,[Base Currency]
      ,[Price Type]
GO
