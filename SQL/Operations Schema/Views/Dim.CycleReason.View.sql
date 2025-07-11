USE [Operations]
GO
/****** Object:  View [Dim].[CycleReason]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[CycleReason] 
AS

SELECT ROW_NUMBER() OVER (ORDER BY ReasonKey) AS ReasonID
	, ReasonKey
	, ReasonName
	, ReasonKey + ': ' + [ReasonName] AS ReasonDesc
	, ISNULL(ReasonCategory,'Generic Missed Cycle/Operator') AS ReasonCategory
FROM xref.CycleReason
GROUP BY  [ReasonKey], [ReasonName] , ReasonCategory
GO
