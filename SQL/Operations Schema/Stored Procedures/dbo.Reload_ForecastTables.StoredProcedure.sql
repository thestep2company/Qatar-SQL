USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_ForecastTables]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Reload_ForecastTables] 
AS BEGIN

	IF (SELECT DATEPART(HOUR,GETDATE())) > 6 BEGIN --don't run on regular schedule

		--Oracle Data
		EXEC [Oracle].[Merge_CustomerMaster]
		EXEC [Oracle].[Merge_INV_MTL_SYSTEM_ITEMS_B]
		EXEC [Oracle].[Merge_CustomerPriceList]
		EXEC [Oracle].[Merge_CST_ITEM_COST_TYPE_V]
		EXEC [Oracle].[Merge_Standards]
		EXEC [Oracle].[Merge_StandardsPending]

		--XREF Data
		EXEC [xref].[Merge_CustomerExtensionData]
		EXEC [xref].[Merge_DemandClass]
		EXEC [xref].[Merge_ProductExtensionData]
		EXEC [FPA].[Merge_SalesGrid]

		--Dim UPSERTS
		EXEC [dbo].[Upsert_DimCustomerMaster]
		EXEC [dbo].[Upsert_DimDemandClass]
		EXEC [dbo].[Upsert_DimProductMaster]

		--Fact UPSERTS
		EXEC dbo.Upsert_FactStandard
		EXEC dbo.Upsert_FactStandardPending

		--Fact Rewrites
		TRUNCATE TABLE dbo.FactPricing			INSERT INTO dbo.FactPricing SELECT * FROM Fact.Pricing --0:26
		TRUNCATE TABLE dbo.FactPriceList		INSERT INTO dbo.FactPriceList SELECT * FROM Fact.PriceList -- do we need both tables? DRA 20240618 ^^^

		--TRUNCATE TABLE dbo.FactStandard			INSERT INTO dbo.FactStandard SELECT * FROM Fact.Standard
		--TRUNCATE TABLE dbo.FactStandardPending	INSERT INTO dbo.FactStandard SELECT * FROM Fact.StandardPending
	END
END
GO
