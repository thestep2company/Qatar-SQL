USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimSource]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Reload_DimSource] 
AS BEGIN
	TRUNCATE TABLE dbo.DimSource
	SELECT * INTO dbo.DimSource FROM Dim.[Source]
END
GO
