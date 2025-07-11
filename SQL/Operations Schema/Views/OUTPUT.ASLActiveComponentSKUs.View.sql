USE [Operations]
GO
/****** Object:  View [OUTPUT].[ASLActiveComponentSKUs]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[ASLActiveComponentSKUs] AS
WITH Components AS (
	SELECT DISTINCT CHILD_SKU
	FROM Oracle.MSC_ORDERS_V mov 
		LEFT JOIN  dbo.DimBillOfMaterial bom ON PARENT_PATH LIKE '%' + mov.ITEM_SEGMENTS + '%'
	WHERE  (mov.quantity <> 0	and mov.plan_id = 4  and mov.order_type = 5) AND ORDER_TYPE_TEXT = 'Planned Order' AND FIRM_PLANNED_TYPE = 1 AND CURRENTRECORD = 1 
	UNION
	SELECT [ITEM_SEGMENTS]	 
	FROM Oracle.PurchaseOrders
	WHERE START_OF_WEEK <= (SELECT MAX(DateKey) FROM dbo.DimCalendarFiscal) AND ORDER_TYPE_TEXT = 'Purchase order'
	GROUP BY [ITEM_SEGMENTS]

)
SELECT ProductKey, MIN(asl.VENDOR_NAME) AS VENDOR_NAME, CASE WHEN MIN(asl.VENDOR_NUMBER) <> MAX(asl.VENDOR_NUMBER) THEN MAX(asl.VENDOR_NAME) END AS VENDOR_NAME_ALTERNATE, MIN(b.PLANNER_CODE) AS PLANNER_CODE, MIN(b.BUYER_NAME) AS BUYER_NAME
FROM  dbo.DimProductMaster pm 
	LEFT JOIN Oracle.ApprovedSupplierList asl  ON pm.ProductKey = asl.ITEM_NUMBER AND asl.CurrentRecord = 1 AND DISABLE_FLAG IS NULL AND INACTIVE_DATE IS NULL
	LEFT JOIN Oracle.Buyer b ON pm.ProductKey = b.ITEM_NAME AND b.CurrentRecord = 1
	INNER JOIN Components c ON pm.ProductKey = c.CHILD_SKU
WHERE ProductKey < '400000'
GROUP BY ProductKey
HAVING MIN(asl.VENDOR_NAME) IS NOT NULL



GO
