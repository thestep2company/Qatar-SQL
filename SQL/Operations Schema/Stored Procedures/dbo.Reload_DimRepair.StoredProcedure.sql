USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimRepair]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Reload_DimRepair] AS BEGIN
	SELECT * INTO dbo.DimRepair FROM Dim.Repair 
END
GO
