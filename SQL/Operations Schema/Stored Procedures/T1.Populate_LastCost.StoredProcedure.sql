USE [Operations]
GO
/****** Object:  StoredProcedure [T1].[Populate_LastCost]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [T1].[Populate_LastCost] AS 

	TRUNCATE TABLE Fact.LastCost

	--retrieves the last cost invoiced for a SKU
	;WITH CTE AS (
		SELECT ROW_NUMBER() OVER (PARTITION BY SKU, DEM_CLASS ORDER BY [GL_Date] DESC) AS RowNumber
			  ,SKU
			  ,GL_DATE
			  ,DEM_CLASS AS DEMAND_CLASS
			  ,[COGS_AMOUNT]/QTY_INVOICED AS COGS_AMOUNT
		FROM Oracle.Invoice
		WHERE CurrentRecord = 1 AND ISNULL(COGS_AMOUNT,0) <> 0
			AND REVENUE_TYPE = 'AAA-SALES'
	)
	INSERT INTO Fact.LastCost
	SELECT SKU, DEMAND_CLASS, COGS_AMOUNT AS COGS 
	FROM CTE WHERE RowNumber = 1



GO
