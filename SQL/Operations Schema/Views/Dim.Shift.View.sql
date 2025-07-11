USE [Operations]
GO
/****** Object:  View [Dim].[Shift]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[Shift] AS 
SELECT DISTINCT
	DENSE_RANK() OVER (ORDER BY [Shift]) AS ShiftID
	,UPPER([Shift]) AS ShiftKey
	,'Shift ' + UPPER([Shift]) AS ShiftName
	,'Shift ' + UPPER([Shift]) AS ShiftDesc
	,RIGHT('00000' + UPPER([Shift]),5) AS ShiftSort
FROM [Manufacturing].[Production]
WHERE CurrentRecord = 1
GO
