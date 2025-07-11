USE [XREF]
GO
/****** Object:  StoredProcedure [dbo].[Merge_CustomerGridUpdates]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
CREATE PROCEDURE [dbo].[Merge_CustomerGridUpdates] AS BEGIN

WITH Grid AS (
  SELECT 
       ig.[Account Number]
      ,ig.[Account Name]
      ,ig.[Other]
      ,ig.[Freight Allowance]
      ,ig.[DIF Returns]
      ,ig.[Cash Discounts]
      ,ig.[Markdown]
      ,ig.[CoOp]
      ,ig.[Total]
      ,ig.[Commission]
      ,ig.[Invoiced Freight]
      ,ig.[Year]
      ,ig.[Month]
	  ,ROW_NUMBER() OVER (PARTITION BY ig.[Account Number] ORDER BY ig.[Year] ,ig.[Month] DESC) AS RowNum
  FROM [dbo].[Import_CustomerGridbyAccount] ig
  	LEFT JOIN dbo.[Customer Grid by Account] sg ON ig.[ACCOUNT NUMBER] = sg.[ACCOUNT NUMBER] AND ig.[Year] = sg.[Year] AND ISNULL(ig.[Month],0) = ISNULL(sg.[Month],0)
	WHERE sg.[ACCOUNT NUMBER] IS NULL
)
, Dates AS (	
	SELECT DISTINCT Year, CAST([Month Seasonality Sort] AS INT) AS Month
	FROM Operations.dbo.DimCalendarFiscal
)
INSERT INTO dbo.[Customer Grid by Account]
SELECT g.[Account Number]
      ,g.[Account Name]
      ,g.[Other]
      ,g.[Freight Allowance]
      ,g.[DIF Returns]
      ,g.[Cash Discounts]
      ,g.[Markdown]
      ,g.[CoOp]
      ,g.[Total]
      ,g.[Commission]
      ,g.[Invoiced Freight]
      ,d.[Year]
      ,d.[Month] 
FROM Grid g
	LEFT JOIN Dates d ON d.Year*100+d.Month >= g.Year*100+g.Month
WHERE RowNum = 1
ORDER BY g.[Account Number], d.Year, d.Month
	
	
	UPDATE sg
	SET  [Other] = ig.Other
		,[Freight Allowance] = ig.[Freight Allowance]
		,[DIF Returns] = ig.[DIF Returns]
		,[Cash Discounts] = ig.[Cash Discounts]
		,[Markdown] = ig.[Markdown]
		,[CoOP] = ig.[Coop]
		,Total = ig.Total
		,[Commission] = ig.[Commission]
		,[Invoiced Freight] = ig.[Invoiced Freight]
		FROM [dbo].[Import_CustomerGridbyAccount] ig
		LEFT JOIN dbo.[Customer Grid by Account] sg ON ig.[ACCOUNT NUMBER] = sg.[ACCOUNT NUMBER] --AND ig.[Year] = sg.[Year] AND ISNULL(ig.[Month],0) = ISNULL(sg.[Month],0)
	WHERE (sg.[Markdown] <> ig.[Markdown]
		OR sg.[Freight Allowance] <> ig.[Freight Allowance]
		OR sg.[DIF Returns] <> ig.[DIF Returns]
		OR sg.[Cash Discounts] <> ig.[Cash Discounts]
		OR sg.[CoOP] <> ig.[Coop]
		OR sg.[Other] <> ig.[Other]
		OR sg.Commission <> ig.[Commission]
		OR sg.Total <> ig.[Total]
		OR sg.[Invoiced Freight] <> ig.[Invoiced Freight])
		AND ((sg.Month >= ig.Month AND sg.Year = ig.Year) OR sg.Year > ig.Year)

		END
GO
