USE [Operations]
GO
/****** Object:  View [Error].[MakeBuyOriginal]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[MakeBuyOriginal] AS
SELECT msib.Segment1,
	MakeBuy	AS Karen,
	CASE WHEN planning_make_buy_code = 1 THEN 'Make'	
		  WHEN planning_make_buy_code = 2 THEN 'Buy'
		  ELSE 'None'
	END AS Oracle
FROM Oracle.inv_mtl_system_items_b msib
	LEFT JOIN xref.ProductChannel pc ON RIGHT(msib.segment1,2) = pc.Suffix AND msib.segment1 >= '400000'  --AND LEN(msib.segment1) = 6
	LEFT JOIN xref.CategoryType ct ON ISNULL(msib.attribute1,'')  = ct.Category
	INNER JOIN xref.MakeBuy mb ON msib.Segment1 = mb.Item
WHERE msib.organization_id = 85 AND CurrentRecord = 1 
	AND MakeBuy	<> 
	CASE WHEN planning_make_buy_code = 1 THEN 'Make'	
		  WHEN planning_make_buy_code = 2 THEN 'Buy'
		  ELSE 'None'
	END
GO
