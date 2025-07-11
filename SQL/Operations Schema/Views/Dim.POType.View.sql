USE [Operations]
GO
/****** Object:  View [Dim].[POType]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[POType] AS 
SELECT ROW_NUMBER() OVER(ORDER BY PO_TYPE) AS POTypeID, PO_TYPE FROM Oracle.PurchaseOrder po WHERE CurrentRecord = 1 GROUP BY PO_TYPE
GO
