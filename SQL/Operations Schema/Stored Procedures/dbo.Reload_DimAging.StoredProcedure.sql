USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimAging]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Reload_DimAging] AS BEGIN
	TRUNCATE TABLE dbo.DimAging
	SELECT * INTO dbo.DimAging FROM Dim.Aging 
END
GO
