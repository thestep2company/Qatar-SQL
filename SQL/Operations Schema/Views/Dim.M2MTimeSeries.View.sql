USE [Operations]
GO
/****** Object:  View [Dim].[M2MTimeSeries]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[M2MTimeSeries] WITH SCHEMABINDING AS SELECT TimeSeriesID, DateID FROM dbo.M2MTimeSeries
GO
