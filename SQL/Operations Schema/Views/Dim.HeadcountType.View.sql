USE [Operations]
GO
/****** Object:  View [Dim].[HeadcountType]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[HeadcountType] AS 
SELECT 0 AS HeadcountTypeID, 'Training' AS HeadcountTypeName UNION
SELECT 1 AS HeadcountTypeID, 'FTE' AS HeadcountTypeName
GO
