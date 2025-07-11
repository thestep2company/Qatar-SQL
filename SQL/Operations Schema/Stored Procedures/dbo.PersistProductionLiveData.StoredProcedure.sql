USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[PersistProductionLiveData]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PersistProductionLiveData] AS BEGIN 

	TRUNCATE TABLE dbo.FactScrapLive INSERT INTO dbo.FactScrapLive SELECT * FROM Fact.ScrapLive
	TRUNCATE TABLE dbo.FactScrapLiveScreens INSERT INTO dbo.FactScrapLiveScreens SELECT * FROM Fact.ScrapLiveScreens
	TRUNCATE TABLE dbo.FactShiftHoursLive INSERT INTO dbo.FactShiftHoursLive SELECT sh.* FROM [Fact].[ShiftHoursLive] sh LEFT JOIN dbo.DimCalendarFiscal cf ON sh.DateID = cf.DateID WHERE cf.DateKey >= DATEADD(WEEK,-4,CAST(GETDATE() AS DATE))

END
GO
