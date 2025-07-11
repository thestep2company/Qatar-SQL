USE [Operations]
GO
/****** Object:  View [xref].[Step2DirectOrderNotesCustomerLookup]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [xref].[Step2DirectOrderNotesCustomerLookup] AS 

	WITH CTE AS(
		SELECT 
			distinct ss.*
			,CASE WHEN ss.value LIKE '%A%M%Z%' THEN 'AMAZON'			
				WHEN ss.value LIKE '%BE%B%B%' OR ss.Value LIKE '%BBB%' OR ss.Value LIKE '%BATH%' THEN 'BED BATH & BEYOND'
				WHEN ss.value LIKE '%BUY%' THEN 'BUYBUY BABY'
				WHEN ss.value LIKE '%COSTCO%' THEN 'COSTCO'
				WHEN ss.value LIKE '%HOMEGOODS%' THEN 'HOMEGOODS'
				WHEN ss.value LIKE '%HOMEDEPOT%' THEN 'HOME DEPOT'
				WHEN ss.value LIKE '%TOY%R%US%' THEN 'TOYS R US'
				WHEN ss.value LIKE '%WALMART%' OR ss.Value = 'WM' THEN 'WALMART'
				WHEN ss.value LIKE '%KOHL%' OR ss.value LIKE '%KHOL%' THEN 'KOHLS'
				WHEN ss.value LIKE '%ALDI%' THEN 'ALDI'
				WHEN ss.Value like '%TARGET%' THEN 'TARGET'
				WHEN ss.Value like '%WAYFAIR%' THEN 'WAYFAIR'
				WHEN ss.Value like '%LOWE%' THEN 'LOWE''S'
				WHEN ss.Value LIKE '%SAMS%' THEN 'SAM''S'
				WHEN ss.Value LIKE '%TJ%X%' THEN 'TJ MAXX'
				WHEN ss.Value LIKE '%S2D%' OR ss.Value LIKE '%STEP%2%' THEN 'STEP2'
				WHEN ss.Value LIKE '%ZUL%' THEN 'ZULILY'
				WHEN ss.Value LIKE '%MARSH%' THEN 'MARSHALLS'
			END AS CleanValue
		FROM xref.Step2DirectOrderNotes x
			CROSS APPLY string_split([Order Notes],',') ss
	)
	, CustomerSales AS (
		SELECT cm.CustomerID, cm.CustomerKey, cm.CustomerDesc, SUM(Sales) AS Sales, SUM(Sales-COGS-Coop-[DIF Returns]-[Frieght Allowance]-[Cash Discounts]-[Markdown]-[Other]) AS Margin
		FROM dbo.FactPBISales s 
			INNER JOIN dbo.DimCustomerMaster cm ON s.CustomerID = cm.CustomerID 
		WHERE RevenueID <> 5 
		GROUP BY cm.CustomerID, cm.CustomerKey, cm.CustomerDesc
	)
	, CustomerRank AS (
		SELECT cte.value, cte.CleanValue, Sales, CustomerID, CustomerKey, CustomerDesc, DENSE_RANK() OVER (PARTITION BY CleanValue ORDER BY Sales DESC) AS CustomerRanking
		FROM CTE
			LEFT JOIN CustomerSales cm 
		ON cm.CustomerDesc LIKE '%' + CleanValue + '%' 
		WHERE CleanValue IS NOT NULL
		GROUP BY cte.value, cte.CleanValue, Sales, CustomerID, CustomerKey, CustomerDesc
	)
	SELECT Value, CleanValue, CustomerKey FROM CustomerRank WHERE CustomerRanking = 1

GO
