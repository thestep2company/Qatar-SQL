USE [Operations]
GO
/****** Object:  StoredProcedure [Manufacturing].[Merge_Main]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Manufacturing].[Merge_Main] AS BEGIN
	EXEC Manufacturing.Merge_Production
	EXEC Manufacturing.Merge_ScrapQuery
	EXEC Manufacturing.Merge_Shift
	EXEC Manufacturing.Merge_MACHINE_INDEX
	
END
GO
