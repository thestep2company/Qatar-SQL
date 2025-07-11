USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[PersistSalesData]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PersistSalesData] AS BEGIN

	EXEC dbo.Upsert_DimCustomerMaster
	EXEC dbo.Upsert_DimLocation
	EXEC dbo.Upsert_DimProductMaster --:22
	EXEC dbo.Upsert_DimDemandClass --1:35

	TRUNCATE TABLE dbo.FactPricing			INSERT INTO dbo.FactPricing SELECT * FROM Fact.Pricing --0:26
	TRUNCATE TABLE dbo.FactPriceList		INSERT INTO dbo.FactPriceList SELECT * FROM Fact.PriceList -- do we need both tables? DRA 20240618 ^^^
	
END


GO
