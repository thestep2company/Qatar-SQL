USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimSaleType]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Reload_DimSaleType] AS BEGIN
	TRUNCATE TABLE dbo.DimSaleType
	SELECT * INTO dbo.DimSaleType FROM Dim.SaleType
END
GO
