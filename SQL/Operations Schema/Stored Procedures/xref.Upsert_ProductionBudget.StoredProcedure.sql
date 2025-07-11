USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Upsert_ProductionBudget]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [xref].[Upsert_ProductionBudget] AS BEGIN
	INSERT INTO xref.ProductionBudget
	SELECT s.[Week]
		  ,s.[Location]
		  ,s.[Production $ Budget (Cost) - TOYS]
		  ,s.[Production $ Budget (Cost) - Custom]
		  ,s.[Machine Hrs (Budget) - TOYS]
		  ,s.[Machine Hrs (Budget) -Custom]
		  ,s.[Labor Earned OH]
		  ,s.[Mfg. Earned OH]
		  ,s.[Purchased OH Earned]
		  ,s.[Total Overhead Earned]
	FROM xref.dbo.ProductionBudget s
		LEFT JOIN xref.ProductionBudget t ON s.Week = t.Week AND s.Location = t.Location
	WHERE t.Week IS NULL

	UPDATE t 
	SET    t.[Production $ Budget (Cost) - TOYS] = s.[Production $ Budget (Cost) - TOYS]
		  ,t.[Production $ Budget (Cost) - Custom] = s.[Production $ Budget (Cost) - Custom]
		  ,t.[Machine Hrs (Budget) - TOYS] = s.[Machine Hrs (Budget) - TOYS]
		  ,t.[Machine Hrs (Budget) -Custom] = s.[Machine Hrs (Budget) -Custom]
		  ,t.[Labor Earned OH] = s.[Labor Earned OH]
		  ,t.[Mfg. Earned OH] = s.[Mfg. Earned OH]
		  ,t.[Purchased OH Earned] = s.[Purchased OH Earned]
		  ,t.[Total Overhead Earned] = s.[Total Overhead Earned]
	FROM xref.dbo.ProductionBudget s
		LEFT JOIN xref.ProductionBudget t ON s.Week = t.Week AND s.Location = t.Location
	WHERE    ISNULL(t.[Production $ Budget (Cost) - TOYS],0) <> ISNULL(s.[Production $ Budget (Cost) - TOYS],0)
		  OR ISNULL(t.[Production $ Budget (Cost) - Custom],0) <> ISNULL(s.[Production $ Budget (Cost) - Custom],0)
		  OR ISNULL(t.[Machine Hrs (Budget) - TOYS] ,0) <> ISNULL(s.[Machine Hrs (Budget) - TOYS],0)
		  OR ISNULL(t.[Machine Hrs (Budget) -Custom],0) <> ISNULL(s.[Machine Hrs (Budget) -Custom],0)
		  OR ISNULL(t.[Labor Earned OH],0) <> ISNULL(s.[Labor Earned OH],0)
		  OR ISNULL(t.[Mfg. Earned OH],0) <> ISNULL(s.[Mfg. Earned OH],0)
		  OR ISNULL(t.[Purchased OH Earned],0) <> ISNULL(s.[Purchased OH Earned],0)
		  OR ISNULL(t.[Total Overhead Earned],0) <> ISNULL(s.[Total Overhead Earned],0)
END
GO
