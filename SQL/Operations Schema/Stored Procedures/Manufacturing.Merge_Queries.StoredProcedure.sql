USE [Operations]
GO
/****** Object:  StoredProcedure [Manufacturing].[Merge_Queries]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Manufacturing].[Merge_Queries] AS BEGIN
	EXEC Manufacturing.Merge_ProductionQuery
	EXEC Manufacturing.Merge_ScrapQuery
END
GO
