USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Schema_DerivedQueries]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Schema_DerivedQueries] 
AS BEGIN

	--derived Oracle data
	EXEC [Oracle].[Merge_ApprovedSupplierList]
	EXEC [Oracle].[Merge_Buyer]
	EXEC [Oracle].[Merge_CancelledOrdersReasonDetail]
	EXEC [Oracle].[Merge_COGSActual]
	EXEC [Oracle].[Merge_Inventory]
	EXEC [Oracle].[Merge_PriceList]
	EXEC [Oracle].[Merge_CustomerPriceList]
	EXEC [Oracle].[Merge_DebitCreditMemo]
	--EXEC [Oracle].[Merge_Pricing]
	EXEC [Oracle].[Merge_RotoParts] --clean up BOM downloads and decommission
	EXEC [Oracle].[Merge_TradeManagement]

	EXEC Manufacturing.Merge_ProductionQuery
	EXEC Manufacturing.Merge_ScrapQuery

END
GO
