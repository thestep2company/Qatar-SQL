USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimM2MTimeSeries]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Reload_DimM2MTimeSeries]
AS BEGIN
	TRUNCATE TABLE dbo.DimM2MTimeSeries		
	INSERT INTO dbo.DimM2MTimeSeries SELECT * FROM Dim.M2MTimeSeries
END
GO
