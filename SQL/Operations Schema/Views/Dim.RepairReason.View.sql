USE [Operations]
GO
/****** Object:  View [Dim].[RepairReason]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Dim].[RepairReason] AS
SELECT DISTINCT
	DENSE_RANK() OVER (ORDER BY LEFT([REPAIR_SCRAP_REASON],2), [Org_Code]) AS RepairReasonID
	,ORG_CODE AS OrgCode
	,LEFT([REPAIR_SCRAP_REASON],2) AS [RepairReasonKey]
	,SUBSTRING([REPAIR_SCRAP_REASON],6,100) AS [RepairReasonName]
	,LEFT([REPAIR_SCRAP_REASON],2) + ': ' + SUBSTRING([REPAIR_SCRAP_REASON],6,100) AS [RepairReasonDesc]
	,RIGHT('0000000000'+LEFT([REPAIR_SCRAP_REASON],2),10) AS RepairReasonSort
FROM [Oracle].[Scrap] 
WHERE CurrentRecord = 1
GO
