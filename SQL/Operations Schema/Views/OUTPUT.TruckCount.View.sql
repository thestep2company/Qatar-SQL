USE [Operations]
GO
/****** Object:  View [OUTPUT].[TruckCount]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[TruckCount] AS 
SELECT oo.Order_Num, FREIGHT_CODE, oo.SHIPPING_METHOD_CODE, oo.DATE_REQUESTED, oo.SCH_SHIP_DATE, oo.Plant, pm.ProductDesc AS Part, SUM(Qty*[Product Volume]) AS Cube, SUM(Qty) AS Qty, SUM(LIST_DOLLARS) AS LIST_DOLLARS, ProductID, DateID, LocationID, CustomerID, CASE WHEN FLOW_STATUS_CODE IN ('CLOSED','CANCELLED') THEN 'N' ELSE 'Y' END AS OpenOrder
FROM Oracle.Orders oo
	LEFT JOIN Dim.SHipMethod sm ON sm.SHIP_METHOD_CODE = oo.SHIPPING_METHOD_CODE
	LEFT JOIN dbo.DimProductMaster pm ON oo.PART = pm.ProductKey
	LEFT JOIN dbo.DimCalendarFiscal cf ON oo.DATE_REQUESTED = cf.DateKey
	LEFT JOIN dbo.DimLocation l ON oo.PLANT = l.LocationKey
	LEFT JOIN dbo.DimCustomerMaster cm ON oo.CUSTOMER_NUM = cm.CustomerKey
WHERE CurrentRecord = 1 AND (FLOW_STATUS_CODE NOT IN ('CLOSED','CANCELLED') OR ORDER_DATE >= CAST(GETDATE() AS DATE) OR SCH_SHIP_DATE >= CAST(GETDATE() AS DATE) OR CANCEL_DATE >= CAST(GETDATE() AS DATE))
GROUP BY Order_Num, FREIGHT_CODE ,oo.SHIPPING_METHOD_CODE, oo.DATE_REQUESTED, oo.SCH_SHIP_DATE, oo.Plant, pm.ProductDesc, ProductID, DateID, LocationID, CustomerID, CASE WHEN FLOW_STATUS_CODE IN ('CLOSED','CANCELLED') THEN 'N' ELSE 'Y' END
--ORDER BY LIST_DOLLARS DESC
GO
