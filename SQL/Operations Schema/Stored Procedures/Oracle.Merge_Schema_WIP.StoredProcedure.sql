USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Schema_WIP]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Schema_WIP] 
AS BEGIN

	EXEC [Oracle].[Merge_WIP]
	EXEC [Oracle].[Merge_WIPCompletion]
	EXEC [Oracle].[Merge_WIP_FLOW_SCHEDULES]
	EXEC [Oracle].[Merge_WIP_LINES]

END
GO
