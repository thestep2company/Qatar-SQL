USE [Operations]
GO
/****** Object:  View [xref].[ProductExtension]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--817
CREATE VIEW [xref].[ProductExtension] AS
WITH CTE AS (
	SELECT 
		 p.ProductKey		   
		,ProductDesc
		,pd.FirstProductionDate
		,pd.LastProductionDate
		,pd.FirstSaleDate
		,pd.LastSaleDate
		,pd.CreationDate
		,px.Product_Group AS ProductGroup--,ISNULL(ISNULL(pc.ProductGroup,Keyword),'OTHER') AS ProductGroup
		,px.Product_Line AS ProductLine
	    ,px.Child_Adult AS ChildAdult
		,px.[Product Name Consolidated] -- added 4.1.24
		,'' AS Department
		,CAST(dim.Height AS VARCHAR(10)) + 'H x ' + CAST(dim.Width AS VARCHAR(10)) + 'W x ' + CAST(dim.Depth AS VARCHAR(10)) + 'D' AS Dimensions
		,CAST(dim.Width*dim.Depth AS DECIMAL(9,2)) AS Footprint
		,CAST(dim.Height*dim.Width*dim.Depth AS DECIMAL(9,2)) AS Cube
		,dim.Size
		--,SUM(CASE WHEN DateKey >= DATEADD(YEAR,-1,GETDATE()) THEN Sales END) AS Sales 
		--,SUM(CASE WHEN DateKey >= DATEADD(YEAR,-1,GETDATE()) THEN Qty END) AS Units
		--,SUM(CASE WHEN DateKey >= DATEADD(YEAR,-1,GETDATE()) THEN Sales-COGS-COOP-[DIF RETURNS]-[Frieght Allowance]-[Cash Discounts]-[Markdown]-[Other] END) AS StandardMargin
		,ROW_NUMBER() OVER (PARTITION BY p.ProductKey ORDER BY px.Product_Group) AS RowNum
	FROM dbo.DimProductMaster p
		LEFT JOIN dbo.FactPBISales s ON s.ProductID = p.ProductID
		--LEFT JOIN xref.ProductGroup pc ON p.ProductName LIKE '%' + Keyword + '%'
		--LEFT JOIN xref.ProductLine pl ON p.ProductKey = pl.SKU
		LEFT JOIN xref.ProductExtensionData px ON p.ProductKey = px.Product_Key
		LEFT JOIN Oracle.ProductDates pd ON p.ProductKey = pd.PART_NUMBER
		LEFT JOIN xref.ProductDims dim ON dim.ProductKey = p.ProductKey
	WHERE
		[Part Type] = 'FINISHED GOODS'
		AND p.ProductKey NOT LIKE '%Placeholder%'
	GROUP BY 
		 p.ProductKey
		,ProductDesc
		,pd.FirstProductionDate
		,pd.LastProductionDate
		,pd.FirstSaleDate
		,pd.LastSaleDate
		,pd.CreationDate
		,px.Product_Group
		,px.Product_Line
		,px.Child_Adult
		,px.[Product Name Consolidated]  -- added 4.1.24
		,dim.Height 
		,dim.Width
		,dim.Depth
		,dim.Size
)
SELECT *
	--, ROUND(CUME_DIST() OVER (ORDER BY Sales DESC),4) AS SalesRank
	--, ROUND(CUME_DIST() OVER (ORDER BY StandardMargin DESC),4) AS StandardMarginRank
	--, ROUND(CUME_DIST() OVER (ORDER BY StandardMargin DESC),4) AS StandardMarginRank
FROM CTE WHERE RowNum = 1 
--ORDER BY StandardMargin DESC

GO
