USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimTimeSeries]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Reload_DimTimeSeries]
AS BEGIN

	TRUNCATE TABLE dbo.DimTimeSeries		
	INSERT INTO dbo.DimTimeSeries SELECT * FROM Dim.TimeSeries

END
GO
