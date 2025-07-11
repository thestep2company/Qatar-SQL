USE [Operations]
GO
/****** Object:  View [Dim].[ShiftOffset]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[ShiftOffset] AS 
SELECT 0 AS ShiftOffsetID, 'No Offset - Match Fiscal Week' AS ShiftOffsetName
UNION
SELECT 1 AS ShiftOffsetID, 'Offset 6 Hours - Do not split shifts' AS ShiftOffsetName
GO
