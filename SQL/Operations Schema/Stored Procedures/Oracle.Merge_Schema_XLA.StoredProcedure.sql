USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Schema_XLA]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_Schema_XLA] AS BEGIN

	--isolate into nightly GL procs
	--EXEC [Oracle].[Merge_XLA_AP_DIST]
	EXEC [Oracle].[Merge_XLA_AR_DIST]
	
	EXEC [Oracle].[Merge_XLA_RA]
	EXEC [Oracle].[Merge_XLA_RCV]
	
	EXEC [Oracle].[Merge_XLA_MTL]
	EXEC [Oracle].[Merge_XLA_WIP]

	EXEC [Oracle].[Merge_XLA_CUST_WRITE_OFFS]	

END
GO
