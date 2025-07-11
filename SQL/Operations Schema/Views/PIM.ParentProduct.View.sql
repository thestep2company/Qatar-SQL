USE [Operations]
GO
/****** Object:  View [PIM].[ParentProduct]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [PIM].[ParentProduct] AS
SELECT DISTINCT 
	 'Parent_'+[Oracle Name] AS [Parent Name] 
	,[Part Type]
	,[SIOP Family]
	,[Category]
	,[Sub-Category]
	,[Make/Buy]
FROM PIM.ProductMaster
WHERE [Category] <> 'B2B'
GO
