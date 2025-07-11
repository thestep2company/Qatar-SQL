USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[PersistPurchaseData]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PersistPurchaseData] AS BEGIN
	
	EXEC dbo.Upsert_DimAPInvoice
	EXEC dbo.Upsert_DimBuyer
	EXEC dbo.Upsert_DimPOCode
	EXEC dbo.Upsert_DimPOStatus
	EXEC dbo.Upsert_DimPOType
	EXEC dbo.Upsert_DimPurchaseOrder
	EXEC dbo.Upsert_DimVendor
	EXEC dbo.Upsert_DimLocator

	TRUNCATE TABLE dbo.FactPurchase					INSERT INTO dbo.FactPurchase SELECT * FROM Fact.Purchase
	TRUNCATE TABLE dbo.FactPurchasePriceVariance	INSERT INTO dbo.FactPurchasePriceVariance SELECT * FROM Fact.PurchasePriceVariance
	TRUNCATE TABLE dbo.FactInvoicePriceVariance		INSERT INTO dbo.FactInvoicePriceVariance SELECT * FROM Fact.InvoicePriceVariance

	TRUNCATE TABLE dbo.FactReceipt					INSERT INTO dbo.FactReceipt SELECT * FROM Fact.Receipt

END
GO
