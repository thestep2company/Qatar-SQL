USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimWhereUsed]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Upsert_DimWhereUsed] AS BEGIN
	TRUNCATE TABLE dbo.DimWhereUsed 

	INSERT INTO dbo.DimWhereUsed 
	SELECT ProductID, ProductKey, ProductName, ProductDesc FROM Dim.WhereUsed
END
GO
