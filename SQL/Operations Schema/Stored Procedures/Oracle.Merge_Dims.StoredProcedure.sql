USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Dims]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_Dims] AS BEGIN

	EXEC [xref].[Merge_DemandClass]
	EXEC [Manufacturing].[Merge_ProductionDates]
	
	--Queries from Oracle
	EXEC [Oracle].[Merge_CustomerMaster] --:03
	EXEC [Oracle].[Merge_CustomerPartReference] --:20
	EXEC [Oracle].[Merge_ProductDates] 
	EXEC [Oracle].[Merge_ShipMethod]
	EXEC [Oracle].[Merge_GLDailyRates]

	--derived
	EXEC [Oracle].[Merge_Geography] --:01

END
GO
