USE [Operations]
GO
/****** Object:  View [Dim].[TimeSeries]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Dim].[TimeSeries] 
WITH SCHEMABINDING
AS
SELECT ID AS TimeSeriesID, TimeSeriesKey, TimeSeriesType, TimeSeriesName, TimeSeriesDesc, TimeSeriesSort, TimeSeriesTypeSort FROM dbo.TimeSeries
GO
