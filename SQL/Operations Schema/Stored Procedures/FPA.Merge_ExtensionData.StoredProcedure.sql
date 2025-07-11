USE [Operations]
GO
/****** Object:  StoredProcedure [FPA].[Merge_ExtensionData]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [FPA].[Merge_ExtensionData] AS BEGIN
	
	EXEC xref.Merge_CustomerExtensionData
	EXEC xref.Merge_DemandClass
	EXEC xref.Merge_ProductDims
	EXEC xref.Merge_ProductExtensionData
	EXEC xref.Merge_CommissionsSalesRep
	EXEC xref.Merge_Royalty

	EXEC xref.[Upsert_FinanceAdjustment]
	EXEC xref.[Upsert_FinanceAdjustmentActuals]
END
GO
