USE [Operations]
GO
/****** Object:  View [Dim].[POStatus]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[POStatus] AS 
SELECT ROW_NUMBER() OVER(ORDER BY PO_STATUS) AS POStatusID, PO_STATUS FROM Oracle.PurchaseOrder po WHERE CurrentRecord = 1 GROUP BY PO_STATUS
GO
