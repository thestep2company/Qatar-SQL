USE [Operations]
GO
/****** Object:  StoredProcedure [Manufacturing].[Update_Main]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Manufacturing].[Update_Main] AS BEGIN
	EXEC Manufacturing.Update_Production
	EXEC Manufacturing.Update_ScrapQuery
	EXEC Manufacturing.Update_MACHINE_INDEX
END
GO
