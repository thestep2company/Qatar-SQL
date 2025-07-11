USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[PersistLaborData]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PersistLaborData]
AS BEGIN

	--dims first
	EXEC [dbo].[Upsert_DimLaborCategory]
	EXEC [dbo].[Upsert_DimLaborDepartment]
	EXEC [dbo].[Upsert_DimPayCode]

	--fact table
	EXEC [dbo].[Upsert_FactLabor]
END
GO
