USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Schema_QP]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Schema_QP]
AS BEGIN

	EXEC [Oracle].[Merge_QP_LIST_LINES_V]
	EXEC [Oracle].[Merge_QP_SECU_LIST_HEADERS_V]

END
GO
