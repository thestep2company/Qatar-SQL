USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Schema_RA]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Schema_RA]
AS BEGIN

	EXEC [Oracle].[Merge_RA_CUST_TRX_LINE_SALESREPS_ALL] 

END
GO
