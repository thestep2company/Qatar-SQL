USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Schema_JTF]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Schema_JTF]
AS BEGIN

	EXEC [Oracle].[Merge_JTF_RS_SALESREPS]
	EXEC [Oracle].[Merge_JTF_RS_RESOURCE_EXTNS_VL] 

END
GO
