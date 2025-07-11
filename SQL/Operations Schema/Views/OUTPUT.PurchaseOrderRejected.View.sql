USE [Operations]
GO
/****** Object:  View [OUTPUT].[PurchaseOrderRejected]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[PurchaseOrderRejected] AS 
SELECT PO_NUMBER, LINE_NUMBER, ITEM, REMAINING_QUANTITY, StartDate
FROM [Oracle].[PurchaseOrder]
WHERE PO_STATUS = 'REJECTED' AND CurrentRecord = 1  AND REMAINING_QUANTITY = 0 --AND PO_NUMBER <> 1041495
GO
