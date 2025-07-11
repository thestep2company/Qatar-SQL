USE [Operations]
GO
/****** Object:  StoredProcedure [FPA].[Merge_StandardMarginPBI]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [FPA].[Merge_StandardMarginPBI] 
	@p_startDate DATE = NULL
AS BEGIN

		DECLARE @startDate DATE, @lastRun DATETIME = (SELECT MAX(GL_DATE) FROM Oracle.Invoice)
		--look back through entire open period
		SET @startDate = ISNULL(@p_startDate, DATEADD(DAY,-45,GETDATE()))		
		
		DECLARE @endDate DATE = GETDATE()

		SELECT @startDate, @endDate
		EXEC xref.Merge_SalesGridBySKU
		EXEC FPA.Merge_SalesGrid

		--D&A = Markdown, D&A Misc = Other, Commission stays the same
		UPDATE i 
		SET COOP = [Sales]*-ISNULL(sgc1.[CoOp],ISNULL(sgc2.[CoOp],ISNULL(sg1.[COOP],sg2.[COOP])))
			, [DIF RETURNS] = [Sales]*-ISNULL(sgc1.[DIF Returns],ISNULL(sgc2.[DIF Returns],ISNULL(sg1.[DIF Returns],sg2.[DIF Returns])))
			, [Frieght Allowance] = [Sales]*-ISNULL(sgc1.[Freight Allowance],ISNULL(sgc2.[Freight Allowance],ISNULL(sg1.[Freight Allowance],sg2.[Freight Allowance])))
			, [Markdown] = [Sales]*-ISNULL(sgc1.[Markdown],ISNULL(sgc2.[Markdown],ISNULL(sg1.[Markdown],sg2.[Markdown])))
			, [Cash Discounts] = [Sales]*-ISNULL(sgc1.[Cash Discounts],ISNULL(sgc2.[Cash Discounts],ISNULL(sg1.[Cash Discounts],sg2.[Cash Discounts])))
			--, [Other] = [Sales]*-ISNULL(sgc1.[Other],ISNULL(sgc2.[Other],ISNULL(sg1.[Other],sg2.[Other])))
			, Commission = [Sales]*-ISNULL(sg1.[Commission],sg2.[Commission])
			, [Invoiced Freight] = [Sales]*ISNULL(sg1.[Invoiced Freight],sg2.[Invoiced Freight])
		FROM dbo.FactPBISales i
			LEFT JOIN dbo.DimRevenueType r ON i.RevenueID = r.RevenueID
			LEFT JOIN dbo.DimCalendarFiscal cf ON i.DateKey = cf.DateKey
			LEFT JOIN dbo.DimCustomerMaster c ON i.CustomerID = c.CustomerID
		--	LEFT JOIN dbo.DimDemandClass dc ON i.DemandClassID = dc.DemandClassID
			LEFT JOIN dbo.DimProductMaster p ON i.ProductID = p.ProductID
			--LEFT JOIN xref.SalesGridByCustomer sg ON sg.[Demand Class Code] = dc.DemandClassKey AND ISNULL(sg.[Account Number],'') = ISNULL(c.[CustomerKey],'') AND MONTH(cf.Month) = ISNULL(sg.Month,MONTH(cf.Month))
			LEFT JOIN xref.SalesGridBySKU sgc1 ON c.CustomerKey = CAST(sgc1.[Account Number] AS VARCHAR(50)) AND p.ProductKey = sgc1.SKU AND cf.Year = sgc1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sgc1.Month --match to year + month for Costco customer grid by SKU
			LEFT JOIN xref.SalesGridBySKU sgc2 ON c.CustomerKey = CAST(sgc2.[Account Number] AS VARCHAR(50)) AND p.ProductKey = sgc2.SKU AND cf.Year = sgc2.Year AND sgc2.Month IS NULL --everything else use month is NULL for Costco customer grid by SKU
			LEFT JOIN xref.SalesGridByCustomer sg1 ON c.CustomerKey = CAST(sg1.[Account Number] AS VARCHAR(50)) AND cf.Year = sg1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sg1.Month --match on a year + month for the customer grid  --AND dc.DemandClassKey = sg1.[Demand Class Code]
			LEFT JOIN xref.SalesGridByCustomer sg2 ON c.CustomerKey = CAST(sg2.[Account Number] AS VARCHAR(50)) AND cf.Year = sg2.Year AND sg1.[Account Number] IS NULL AND sg2.Month IS NULL  --else use the NULL month for the customer grid  -- AND dc.DemandClassKey = sg2.[Demand Class Code]
		WHERE cf.DateKey >= @startDate AND cf.DateKey < @endDate AND i.RevenueID <> 5  --ignore invoiced freight
		OPTION (RECOMPILE)


		--D&A = Markdown, D&A Misc = Other, Commission stays the same
		UPDATE i 
		SET [Other] = [Sales]*-ISNULL(sgc1.[Other],ISNULL(sgc2.[Other],ISNULL(sg1.[Other],sg2.[Other])))
		FROM dbo.FactPBISales i
			LEFT JOIN dbo.DimRevenueType r ON i.RevenueID = r.RevenueID
			LEFT JOIN dbo.DimCalendarFiscal cf ON i.DateKey = cf.DateKey
			LEFT JOIN dbo.DimCustomerMaster c ON i.CustomerID = c.CustomerID
		--	LEFT JOIN dbo.DimDemandClass dc ON i.DemandClassID = dc.DemandClassID
			LEFT JOIN dbo.DimProductMaster p ON i.ProductID = p.ProductID
			--LEFT JOIN xref.SalesGridByCustomer sg ON sg.[Demand Class Code] = dc.DemandClassKey AND ISNULL(sg.[Account Number],'') = ISNULL(c.[CustomerKey],'') AND MONTH(cf.Month) = ISNULL(sg.Month,MONTH(cf.Month))
			LEFT JOIN xref.SalesGridBySKU sgc1 ON c.CustomerKey = CAST(sgc1.[Account Number] AS VARCHAR(50)) AND p.ProductKey = sgc1.SKU AND cf.Year = sgc1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sgc1.Month --match to year + month for Costco customer grid by SKU
			LEFT JOIN xref.SalesGridBySKU sgc2 ON c.CustomerKey = CAST(sgc2.[Account Number] AS VARCHAR(50)) AND p.ProductKey = sgc2.SKU AND cf.Year = sgc2.Year AND sgc2.Month IS NULL --everything else use month is NULL for Costco customer grid by SKU
			LEFT JOIN xref.SalesGridByCustomer sg1 ON c.CustomerKey = CAST(sg1.[Account Number] AS VARCHAR(50)) AND cf.Year = sg1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sg1.Month --match on a year + month for the customer grid  --AND dc.DemandClassKey = sg1.[Demand Class Code]
			LEFT JOIN xref.SalesGridByCustomer sg2 ON c.CustomerKey = CAST(sg2.[Account Number] AS VARCHAR(50)) AND cf.Year = sg2.Year AND sg1.[Account Number] IS NULL AND sg2.Month IS NULL  --else use the NULL month for the customer grid  -- AND dc.DemandClassKey = sg2.[Demand Class Code]
		WHERE cf.DateKey >= @startDate AND cf.DateKey < @endDate AND i.RevenueID <> 5  --ignore invoiced freight
			AND c.CustomerKey NOT IN (
			'1000375'
			,'1000596'
			,'1000769'
			,'1039832'
			,'1000690'
			,'1001026'
			,'1000830'
			,'1001199'
		)
		OPTION (RECOMPILE)

		--royalty
		UPDATE i 
		SET Royalty = [Sales]*-cm.[Royalty License %]
		--SELECT cf.[Month Sort], SUM(i.[Royalty]), SUM([Sales]*-cm.[Royalty License %]), SUM(i.[Royalty]) - SUM(i.[Sales]*-cm.[Royalty License %])
		FROM dbo.FactPBISales i
			LEFT JOIN dbo.DimCalendarFiscal cf ON i.DateKey = cf.DateKey
			LEFT JOIN dbo.DimProductMaster pm ON i.ProductID = pm.ProductID
			INNER JOIN Fact.Royalty cm ON LEFT(pm.ProductKey,4) = cm.[4 Digit] AND cm.[Month Sort] = cf.[Month Sort]
		WHERE cf.DateKey >= @startDate AND cf.DateKey < @endDate AND i.RevenueID <> 5 
   
		--surcharge (probably do not need, swap to actual like invoiced freight)
		UPDATE i
		SET Surcharge = Sales
		FROM dbo.FactPBISales i
			LEFT JOIN dbo.DimRevenueType r ON i.RevenueID = r.RevenueID
			LEFT JOIN dbo.DimCalendarFiscal cf ON i.DateKey = cf.DateKey
		WHERE r.RevenueID = 6 --surchage sale type
			AND cf.DateKey >= @startDate AND cf.DateKey < @endDate 

		--6 digit attempts
		UPDATE i
		SET i.[Freight Out] = -QTY*Freight
		FROM dbo.FactPBISales i
			LEFT JOIN dbo.DimProductMaster p ON i.ProductID = p.ProductID
			LEFT JOIN dbo.DimCalendarFiscal cf ON i.DateKey = cf.DateKey
			LEFT JOIN dbo.DimRevenueType r ON i.RevenueID = r.RevenueID
			INNER JOIN Fact.Freight f ON p.ProductID = f.ProductID AND f.[Month Sort] = cf.[Month Sort]
			LEFT JOIN dbo.DimCustomerMaster c ON i.CustomerID = c.CustomerID
			LEFT JOIN dbo.DimDemandClass dc ON i.DemandClassID = dc.DemandClassID
		WHERE cf.DateKey >= @startDate AND cf.DateKey < @endDate 
			AND dc.DemandClassKey IN ('D2U','AMZMP') --Step2 direct or Amazon
			AND QTY <> 0


		UPDATE i
		SET i.[Freight Out] = -QTY*Freight
		FROM dbo.FactPBISales i
			LEFT JOIN dbo.DimProductMaster p ON i.ProductID = p.ProductID
			LEFT JOIN dbo.DimCalendarFiscal cf ON i.DateKey = cf.DateKey
			LEFT JOIN dbo.DimRevenueType r ON i.RevenueID = r.RevenueID
			INNER JOIN Fact.Freight f ON p.ProductID = f.ProductID AND f.[Month Sort] = cf.[Month Sort]
			LEFT JOIN dbo.DimCustomerMaster c ON i.CustomerID = c.CustomerID
			LEFT JOIN dbo.DimDemandClass dc ON i.DemandClassID = dc.DemandClassID
		WHERE cf.DateKey >= @startDate AND cf.DateKey < @endDate 	
			AND dc.DemandClassKey = 'K04531E' --KOHLS.com
			AND LEFT(p.ProductKey,4) IN ('8416','4905') --neat & tidy II
			AND QTY <> 0
		
		--category attempt
		UPDATE i 
		SET i.[Freight Out] = -Sales*fc.PercentOfRev
		FROM dbo.FactPBISales i
			LEFT JOIN dbo.DimProductMaster p ON i.ProductID = p.ProductID
			LEFT JOIN dbo.DimCalendarFiscal cf ON i.DateKey = cf.DateKey
			LEFT JOIN dbo.DimRevenueType r ON i.RevenueID = r.RevenueID
			LEFT JOIN Fact.Freight f ON p.ProductID = f.ProductID AND f.[Month Sort] = cf.[Month Sort]
			LEFT JOIN xref.FreightCategory fc ON ISNULL(p.Category,'') = ISNULL(fc.[Category],'')
			LEFT JOIN dbo.DimCustomerMaster c ON i.CustomerID = c.CustomerID
			LEFT JOIN dbo.DimDemandClass dc ON i.DemandClassID = dc.DemandClassID
		WHERE cf.DateKey >= @startDate AND cf.DateKey < @endDate 
			AND dc.DemandClassKey IN ('D2U','AMZMP') --Step2 direct or Amazon 
			AND f.ProductID IS NULL --take category average if 4 digit does not return anything
			AND QTY <> 0
			AND i.ProductID <> 0
			AND i.RevenueID <> 5
			AND p.[Category] <> 'OTHER' --for SKUs with categories
			
END
		
GO
