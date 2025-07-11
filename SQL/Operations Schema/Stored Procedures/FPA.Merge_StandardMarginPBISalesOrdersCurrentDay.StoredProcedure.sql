USE [Operations]
GO
/****** Object:  StoredProcedure [FPA].[Merge_StandardMarginPBISalesOrdersCurrentDay]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [FPA].[Merge_StandardMarginPBISalesOrdersCurrentDay] 

AS BEGIN
	
		UPDATE o 
		SET COOP = [LIST_DOLLARS]*-ISNULL(sgc1.[CoOp],ISNULL(sgc2.[CoOp],ISNULL(sg1.[COOP],sg2.[COOP])))
			, [DIF RETURNS] = [LIST_DOLLARS]*-ISNULL(sgc1.[DIF Returns],ISNULL(sgc2.[DIF Returns],ISNULL(sg1.[DIF Returns],sg2.[DIF Returns])))
			, [Freight Allowance] = [LIST_DOLLARS]*-ISNULL(sgc1.[Freight Allowance],ISNULL(sgc2.[Freight Allowance],ISNULL(sg1.[Freight Allowance],sg2.[Freight Allowance])))
			, [Markdown] = [LIST_DOLLARS]*-ISNULL(sgc1.[Markdown],ISNULL(sgc2.[Markdown],ISNULL(sg1.[Markdown],sg2.[Markdown])))
			, [Cash Discounts] = [LIST_DOLLARS]*-ISNULL(sgc1.[Cash Discounts],ISNULL(sgc2.[Cash Discounts],ISNULL(sg1.[Cash Discounts],sg2.[Cash Discounts])))
			, [Other] = [LIST_DOLLARS]*-ISNULL(sgc1.[Other],ISNULL(sgc2.[Other],ISNULL(sg1.[Other],sg2.[Other])))
		FROM dbo.FactPBISalesOrdersCurrentDay o
			LEFT JOIN dbo.DimRevenueType r ON o.RevenueID = r.RevenueID
			LEFT JOIN dbo.DimCalendarFiscal cf ON o.DateKey = cf.DateKey
			LEFT JOIN dbo.DimCustomerMaster c ON o.CustomerID = c.CustomerID
			--LEFT JOIN dbo.DimDemandClass dc ON o.DemandClassID = dc.DemandClassID
			LEFT JOIN dbo.DimProductMaster p ON o.ProductID = p.ProductID
			--LEFT JOIN xref.SalesGridByCustomer sg ON sg.[Demand Class Code] = dc.DemandClassKey AND ISNULL(sg.[Account Number],'') = ISNULL(c.[CustomerKey],'') AND MONTH(cf.Month) = ISNULL(sg.Month,MONTH(cf.Month))
			LEFT JOIN xref.SalesGridBySKU sgc1 ON c.CustomerKey = CAST(sgc1.[Account Number] AS VARCHAR(50)) AND p.ProductKey = sgc1.SKU AND cf.Year = sgc1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sgc1.Month --match to year + month for Costco customer grid by SKU
			LEFT JOIN xref.SalesGridBySKU sgc2 ON c.CustomerKey = CAST(sgc2.[Account Number] AS VARCHAR(50)) AND p.ProductKey = sgc2.SKU AND cf.Year = sgc2.Year AND sgc2.Month IS NULL --everything else use month is NULL for Costco customer grid by SKU
			LEFT JOIN xref.SalesGridByCustomer sg1 ON c.CustomerKey = CAST(sg1.[Account Number] AS VARCHAR(50)) AND cf.Year = sg1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sg1.Month --match on a year + month for the customer grid
			LEFT JOIN xref.SalesGridByCustomer sg2 ON c.CustomerKey = CAST(sg2.[Account Number] AS VARCHAR(50)) AND cf.Year = sg2.Year AND sg1.[Account Number] IS NULL AND sg2.Month IS NULL  --else use the NULL month for the customer grid
		WHERE --cf.DateKey >= @startDate AND cf.DateKey < @endDate AND 
		o.RevenueID <> 5  --ignore invoiced freight
		OPTION (RECOMPILE)

			
END
		
GO
