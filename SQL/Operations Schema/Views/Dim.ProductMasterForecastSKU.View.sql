USE [Operations]
GO
/****** Object:  View [Dim].[ProductMasterForecastSKU]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



  CREATE VIEW [Dim].[ProductMasterForecastSKU] AS
  WITH CTE AS (
	  SELECT ISNULL([Part],'(blank)') AS [Part]
		,ISNULL([Part_Desc],'(blank)') AS [Part_Desc]
		,[Demand Class]	
		,CASE WHEN [Part_Desc] LIKE 'Reclass%' THEN 'RECLASS'
			 WHEN [Part_Desc] LIKE 'EE Toy%' THEN 'EETOY'
			 WHEN [Part_Desc] LIKE 'POLY%' THEN 'POLY'
			 WHEN [Part_Desc] LIKE 'Part%' THEN 'PART'
			 WHEN ISNULL([Part],'(blank)') = '(blank)' THEN 'BLANK'
			 ELSE [Part]
		END + '-' + ISNULL([Demand Class],'MISSING') AS [DerivedPart]
	  FROM xref.SalesForecast sf
		LEFT JOIN dbo.DimProductMaster pm 
	  ON --sf.PART 
	   CASE WHEN [Part_Desc] LIKE 'Reclass%' THEN 'RECLASS'
			 WHEN [Part_Desc] LIKE 'EE Toy%' THEN 'EETOY'
			 WHEN [Part_Desc] LIKE 'POLY%' THEN 'POLY'
			 WHEN [Part_Desc] LIKE 'Part%' THEN 'PART'
			 WHEN ISNULL([Part],'(blank)') = '(blank)' THEN 'BLANK'
			 ELSE [Part]
		END + '-' + ISNULL([Demand Class],'MISSING')
	  = pm.ProductKey
	  WHERE pm.ProductKey IS NULL 
		AND ([Jan - Sales] <> 0 OR [Feb - Sales] <> 0 OR [Mar - Sales] <> 0
		OR [Apr - Sales] <> 0 OR [May - Sales] <> 0 OR [Jun - Sales] <> 0
		OR [Jul - Sales] <> 0 OR [Aug - Sales] <> 0 OR [Sep - Sales] <> 0
		OR [Oct - Sales] <> 0 OR [Nov - Sales] <> 0 OR [Dec - Sales] <> 0
		)
		AND Period LIKE '%AF'
	  GROUP BY ISNULL([Part],'(blank)')
		,[Demand Class]	
		,[Part_Desc]
		,CASE WHEN [Part_Desc] LIKE 'Reclass%' THEN 'RECLASS'
			 WHEN [Part_Desc] LIKE 'EE Toy%' THEN 'EETOY'
			 WHEN [Part_Desc] LIKE 'POLY%' THEN 'POLY'
			 WHEN [Part_Desc] LIKE 'Part%' THEN 'PART'
			 WHEN ISNULL([Part],'(blank)') = '(blank)' THEN 'BLANK'
			 ELSE [Part]
		END + '-' + ISNULL([Demand Class],'MISSING')
		UNION
	  SELECT ISNULL([Part],'(blank)') AS [Part]
		,ISNULL([Part_Desc],'(blank)') AS [Part_Desc]
		,[Demand Class]	
		,CASE WHEN [Part_Desc] LIKE 'Reclass%' THEN 'RECLASS'
			 WHEN [Part_Desc] LIKE 'EE Toy%' THEN 'EETOY'
			 WHEN [Part_Desc] LIKE 'POLY%' THEN 'POLY'
			 WHEN [Part_Desc] LIKE 'Part%' THEN 'PART'
			 WHEN ISNULL([Part],'(blank)') = '(blank)' THEN 'BLANK'
			 ELSE [Part]
		END --+ '-' + ISNULL([Demand Class],'MISSING') AS [DerivedPart]
	  FROM xref.SalesBudget sf
		LEFT JOIN dbo.DimProductMaster pm ON sf.PART = pm.ProductKey
	  WHERE pm.ProductKey IS NULL 
		AND ([Jan - Sales] <> 0 OR [Feb - Sales] <> 0 OR [Mar - Sales] <> 0
		OR [Apr - Sales] <> 0 OR [May - Sales] <> 0 OR [Jun - Sales] <> 0
		OR [Jul - Sales] <> 0 OR [Aug - Sales] <> 0 OR [Sep - Sales] <> 0
		OR [Oct - Sales] <> 0 OR [Nov - Sales] <> 0 OR [Dec - Sales] <> 0
		)
		AND Period LIKE '%B'
	  GROUP BY ISNULL([Part],'(blank)')
		,[Demand Class]	
		,[Part_Desc]
		,CASE WHEN [Part_Desc] LIKE 'Reclass%' THEN 'RECLASS'
			 WHEN [Part_Desc] LIKE 'EE Toy%' THEN 'EETOY'
			 WHEN [Part_Desc] LIKE 'POLY%' THEN 'POLY'
			 WHEN [Part_Desc] LIKE 'Part%' THEN 'PART'
			 WHEN ISNULL([Part],'(blank)') = '(blank)' THEN 'BLANK'
			 ELSE [Part]
		END --+ '-' + ISNULL([Demand Class],'MISSING')
		)
		SELECT Part, MAX(Part_Desc) AS Part_Desc, [Demand Class], [DerivedPart] 
		FROM CTE GROUP BY Part, [Demand Class], [DerivedPart]
GO
