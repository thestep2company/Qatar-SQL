USE [Operations]
GO
/****** Object:  View [Dim].[Source]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Dim].[Source] AS
SELECT 0 AS SourceID, 'Sales Query' AS SourceName UNION
SELECT 1 AS SourceID, 'Reclass' AS SourceName UNION
SELECT 2 AS SourceID, 'Forecast Additions' AS SourceName UNION
SELECT 3 AS SourceID, 'Reconcile' AS SourceName UNION
SELECT 4 AS SourceID, 'Trade Management' AS SourceName
GO
