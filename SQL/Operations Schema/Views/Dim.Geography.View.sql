USE [Operations]
GO
/****** Object:  View [Dim].[Geography]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[Geography] AS 
SELECT ID AS GeographyID
	,PostalCode
	,[State]
	,Country
FROM Oracle.[Geography]
WHERE CurrentRecord = 1
GO
