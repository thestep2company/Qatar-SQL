USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimM2MWhereUsed]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Upsert_DimM2MWhereUsed] AS BEGIN

	TRUNCATE TABLE dbo.DimM2MWhereUsed
	
	INSERT INTO dbo.DimM2MWhereUsed
	SELECT ProductID1, ProductID2, Quantity, Level  FROM Dim.M2MWhereUsed 
END
GO
