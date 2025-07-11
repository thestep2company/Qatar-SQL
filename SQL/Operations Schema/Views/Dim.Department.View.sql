USE [Operations]
GO
/****** Object:  View [Dim].[Department]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[Department] AS
SELECT SUBSTRING(AccountCombo,7,3) AS DepartmentKey
	, CAST(ISNULL(d.DepartmentName,'Unknown') AS VARCHAR(50)) AS DepartmentName
	, SUBSTRING(AccountCombo,7,3) + ': ' + ISNULL(d.DepartmentName,'Unknown') AS DepartmentDesc
	, SUBSTRING(AccountCombo,7,3) AS DepartmentSort
FROM xref.Account a
	LEFT JOIN xref.Department d ON SUBSTRING(AccountCombo,7,3) = d.DepartmentKey
GROUP BY SUBSTRING(AccountCombo,7,3), ISNULL(d.DepartmentName,'Unknown')
GO
