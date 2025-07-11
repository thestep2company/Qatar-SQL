USE [Operations]
GO
/****** Object:  View [Fact].[ShiftHoursLive]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[ShiftHoursLive] AS
SELECT sh.* FROM Fact.ShiftHours sh
	LEFT JOIN dbo.DimCalendarFiscal cf ON sh.DateID = cf.DateID 
WHERE cf.DateKey >= DATEADD(WEEK,-4,CAST(GETDATE() AS DATE))
GO
