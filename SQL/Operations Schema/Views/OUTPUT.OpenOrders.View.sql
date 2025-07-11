USE [Operations]
GO
/****** Object:  View [OUTPUT].[OpenOrders]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [OUTPUT].[OpenOrders] AS
WITH 
OpenOrderLogic AS (
	SELECT o.[ORD_LINE_ID]
		  ,o.[ORD_HEADER_ID]
		  ,rt.RevenueID
		  ,rt.RevenueKey
		  ,ISNULL(l.LocationID,0) AS LocationID
		  ,o.[CUSTOMER_NAME]
		  ,o.[CUSTOMER_NUM]
		  ,o.[SALES_CHANNEL_CODE]
		  ,o.[DEMAND_CLASS]
		  ,CAST(o.[ORDER_DATE] AS DATE) AS ORDER_DATE
		  ,o.[ORDER_NUM]
		  ,CAST(o.[PART] AS NVARCHAR(100)) AS PART
		  ,o.[ORDERED_ITEM]
		  ,o.[PART_DESC]
		  ,o.[FLOW_STATUS_CODE]
		  ,CASE WHEN o.FLOW_STATUS_CODE LIKE '%RETURN%' THEN -1 ELSE 1 END * o.[QTY] AS QTY
		  ,CASE WHEN o.FLOW_STATUS_CODE LIKE '%RETURN%' THEN -1 ELSE 1 END * o.[SELL_DOLLARS] * ISNULL(cc.CONVERSION_RATE,1) AS SELL_DOLLARS
		  ,CASE WHEN o.FLOW_STATUS_CODE LIKE '%RETURN%' THEN -1 ELSE 1 END * o.[LIST_DOLLARS] * ISNULL(cc.CONVERSION_RATE,1) AS LIST_DOLLARS
		  ,CAST(o.[DATE_REQUESTED] AS DATE) AS DATE_REQUESTED
		  ,CAST(o.[SCH_SHIP_DATE] AS DATE) AS SCH_SHIP_DATE
		  ,CAST(o.[ACTUAL_SHIPMENT_DATE] AS DATE) AS ACTUAL_SHIPMENT_DATE
		  ,CAST(o.[CANCEL_DATE] AS DATE) AS CANCEL_DATE
		  ,o.[PLANT]
		  ,CAST(o.[CREATE_DATE] AS DATE) AS CREATE_DATE
		  ,CAST(o.[ORD_LINE_CREATE_DATE] AS DATE) AS ORD_LINE_CREATE_DATE
		  ,CAST(o.[ORD_LINE_LST_UPDATE_DATE] AS DATE) AS ORD_LINE_LST_UPDATE_DATE
		  ,o.[SHIP_TO_ADDRESS1]
		  ,o.[SHIP_TO_ADDRESS2]
		  ,o.[SHIP_TO_ADDRESS3]
		  ,o.[SHIP_TO_ADDRESS4]
		  ,o.[SHIP_TO_CITY]
		  ,o.[SHIP_TO_STATE]
		  ,o.[SHIP_TO_POSTAL_CODE]
		  ,o.[SHIP_TO_COUNTRY]
		  ,o.[SHIP_TO_PROVINCE]
		  ,pm.[Contract Manufacturing]
		  ,cm.[Distribution Method]
		  ,cm.[DropShipType]
		  ,cm.FINANCE_REPORTING_CHANNEL
		  ,cm.[International/Domestic/ CAD]
		  ,cm.ParentCustomer
		  ,CASE WHEN o.FLOW_STATUS_CODE LIKE '%RETURN%' THEN DATEADD(WEEK,1,CAST(o.ORDER_DATE AS DATE))
				WHEN cm.[DropShipType] = 'Drop Ship' THEN ISNULL(CAST(o.[SCH_SHIP_DATE] AS DATE) ,CAST(o.[DATE_REQUESTED] AS DATE))
				WHEN o.[CANCEL_DATE] IS NOT NULL THEN CAST(o.[CANCEL_DATE] AS DATE)
				WHEN cm.[Distribution Method] = 'TL/LTL'OR cm.[Distribution Method] = 'Direct Sales, Donations' THEN DATEADD(DAY,9,CAST(o.[DATE_REQUESTED] AS DATE)) 
				WHEN cm.[Distribution Method] = 'International - Container' THEN DATEADD(DAY,29,CAST(o.[DATE_REQUESTED] AS DATE)) 
				WHEN cm.[Distribution Method] = 'International - TL' THEN DATEADD(DAY,21,CAST(o.[DATE_REQUESTED] AS DATE)) 
				WHEN cm.[Distribution Method] = 'International' THEN DATEADD(DAY,25,CAST(o.[DATE_REQUESTED] AS DATE)) 
				ELSE (CAST(o.[SCH_SHIP_DATE] AS DATE))
		   END ESTIMATED_SHIP_DATE,
		   o.SHIPPING_METHOD_CODE AS SHIP_METHOD_CODE,
		   o.Currency,
		   o.CUST_PO_NUMBER
	FROM 
		Oracle.OrdersOpen o 
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(o.ORDER_DATE AS DATE) = cf.DateKey 
		LEFT JOIN dbo.DimProductMaster pm ON o.PART = pm.ProductKey
		LEFT JOIN dbo.DimCustomerMaster cm ON o.CUSTOMER_NUM = cm.CustomerKey
		LEFT JOIN dbo.DimLocation l ON o.PLANT = l.LocationKey
		LEFT JOIN Oracle.GL_DAILY_RATES cc ON CAST(o.ORDER_DATE AS DATE) = cc.CONVERSION_DATE AND o.Currency = cc.FROM_CURRENCY
		LEFT JOIN dbo.DimRevenueType rt ON rt.RevenueKey = 'AAA-SALES'
	WHERE CUSTOMER_NUM <> '1055833' --Davinci Orders are actuallyinter org transfers.  Can use TermsID if we use more than this customer.
)
, OpenOrders AS (
	SELECT * FROM OpenOrderLogic
	UNION ALL 
	SELECT 
		   oo.[ORD_LINE_ID]
		  ,oo.[ORD_HEADER_ID]
		  ,rt.RevenueID
		  ,rt.RevenueKey
		  ,l.LocationID
		  ,oo.[CUSTOMER_NAME]
		  ,oo.[CUSTOMER_NUM]
		  ,oo.[SALES_CHANNEL_CODE]
		  ,oo.[DEMAND_CLASS]
		  ,oo.[ORDER_DATE]
		  ,oo.[ORDER_NUM]
		  ,oo.[PART]
		  ,oo.[ORDERED_ITEM]
		  ,oo.[PART_DESC]
		  ,oo.[FLOW_STATUS_CODE]
		  ,0 AS QTY
		  ,0 AS SELL_DOLLARS
		  ,pa.ADJUSTED_AMOUNT*CASE WHEN pa.ARITHMETIC_OPERATOR = 'AMT' THEN 1 ELSE oo.QTY END * ISNULL(cc.CONVERSION_RATE,1) AS LIST_DOLLARS
		  ,oo.DATE_REQUESTED
		  ,oo.SCH_SHIP_DATE
		  ,oo.ACTUAL_SHIPMENT_DATE
		  ,oo.CANCEL_DATE
		  ,oo.[PLANT]
		  ,oo.CREATE_DATE
		  ,oo.ORD_LINE_CREATE_DATE
		  ,oo.ORD_LINE_LST_UPDATE_DATE
		  ,oo.[SHIP_TO_ADDRESS1]
		  ,oo.[SHIP_TO_ADDRESS2]
		  ,oo.[SHIP_TO_ADDRESS3]
		  ,oo.[SHIP_TO_ADDRESS4]
		  ,oo.[SHIP_TO_CITY]
		  ,oo.[SHIP_TO_STATE]
		  ,oo.[SHIP_TO_POSTAL_CODE]
		  ,oo.[SHIP_TO_COUNTRY]
		  ,oo.[SHIP_TO_PROVINCE]
		  ,oo.[Contract Manufacturing]
		  ,oo.[Distribution Method]
		  ,oo.[DropShipType]
		  ,oo.FINANCE_REPORTING_CHANNEL
		  ,oo.[International/Domestic/ CAD]
		  ,oo.ParentCustomer
		  ,oo.ESTIMATED_SHIP_DATE
		  ,oo.SHIP_METHOD_CODE
		  ,oo.Currency
		  ,oo.CUST_PO_NUMBER
	FROM OpenOrderLogic oo
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(oo.ORDER_DATE AS DATE) = cf.DateKey
		LEFT JOIN dbo.DimCustomerMaster c ON oo.Customer_NUM = c.CustomerKey 
		LEFT JOIN dbo.DimProductMaster p ON oo.PART = p.ProductKey
		LEFT JOIN dbo.DimLocation l ON oo.PLANT = l.LocationKey
		LEFT JOIN dbo.DimDemandClass dc ON ISNULL(oo.DEMAND_CLASS,c.DEMAND_CLASS_CODE) = dc.DemandClassKey
		INNER JOIN Oracle.OrderAdjustmentOpen pa ON pa.LINE_ID = oo.ORD_LINE_ID 
		LEFT JOIN dbo.DimRevenueType rt ON rt.RevenueKey = 
			case when pa.LIST_LINE_TYPE_CODE = 'TAX' THEN 'ZTAX-' + ISNULL(oo.SHIP_TO_STATE,'NULL')
				when pa.Adjustment_Description LIKE '%FRT%MBS%' THEN 'FRTMBS' 
				when substring(pa.Adjustment_Description,1,7) in ('S2C DSF','S2C FRT') then 'SHIPHANDLING' 
				when substring(pa.Adjustment_Description,1,7) in ('S2C DEF','S2C COO') then 'ALLOWANCE' 
				when substring(pa.Adjustment_Description,1,7) = 'S2C TPI' THEN 'TPI' 
				when substring(pa.Adjustment_Description,1,4)='S2C ' then 'S2C_ADJ_OTHER'
				else 'OTHER'
			  end
		LEFT JOIN Dim.[Geography] g ON UPPER(ISNULL(CASE WHEN oo.[SHIP_TO_POSTAL_CODE] LIKE '%-%' OR LEN(oo.[SHIP_TO_POSTAL_CODE]) >= 9 THEN LEFT(oo.[SHIP_TO_POSTAL_CODE],5) ELSE oo.[SHIP_TO_POSTAL_CODE] END,'MISSING')) = g.PostalCode AND UPPER(ISNULL(oo.[SHIP_TO_COUNTRY],'MISSING')) = g.COuntry
		LEFT JOIN Oracle.GL_DAILY_RATES cc ON CAST(oo.ORDER_DATE AS DATE) = cc.CONVERSION_DATE AND oo.Currency = cc.FROM_CURRENCY
	WHERE case when pa.LIST_LINE_TYPE_CODE = 'TAX' THEN 'TAX'
				when pa.Adjustment_Description LIKE '%FRT%MBS%' THEN 'FRTMBS' 
				when substring(pa.Adjustment_Description,1,7) in ('S2C DSF','S2C FRT') then 'SHIPHANDLING' 
				when substring(pa.Adjustment_Description,1,7) in ('S2C DEF','S2C COO') then 'ALLOWANCE' 
				when substring(pa.Adjustment_Description,1,7) = 'S2C TPI' THEN 'TPI' 
				when substring(pa.Adjustment_Description,1,4)='S2C ' then 'S2C_ADJ_OTHER'
				else 'OTHER'
			  end <> ('TAX')
)
, OpenOrdersNet AS (
SELECT 
	   [ORD_LINE_ID]
      ,[ORD_HEADER_ID]
	  ,[RevenueID]
	  ,[RevenueKey]
	  ,[LocationID]
      ,[CUSTOMER_NAME]
      ,[CUSTOMER_NUM]
      ,[SALES_CHANNEL_CODE]
      ,[DEMAND_CLASS]
      ,[ORDER_DATE]
      ,[ORDER_NUM]
      ,[PART]
      ,[ORDERED_ITEM]
      ,[PART_DESC]
      ,[FLOW_STATUS_CODE]
      ,[QTY]
      ,[SELL_DOLLARS]
      ,[LIST_DOLLARS]
      ,[DATE_REQUESTED]
      ,[SCH_SHIP_DATE]
      ,[ACTUAL_SHIPMENT_DATE]
      ,[CANCEL_DATE]
      ,[PLANT]
      ,[CREATE_DATE]
      ,[ORD_LINE_CREATE_DATE]
      ,[ORD_LINE_LST_UPDATE_DATE]
      ,[SHIP_TO_ADDRESS1]
      ,[SHIP_TO_ADDRESS2]
      ,[SHIP_TO_ADDRESS3]
      ,[SHIP_TO_ADDRESS4]
      ,[SHIP_TO_CITY]
      ,[SHIP_TO_STATE]
      ,[SHIP_TO_POSTAL_CODE]
      ,[SHIP_TO_COUNTRY]
      ,[SHIP_TO_PROVINCE]
      ,[Contract Manufacturing]
      ,[Distribution Method]
      ,[DropShipType]
      ,[FINANCE_REPORTING_CHANNEL]
      ,[International/Domestic/ CAD]
      ,[ParentCustomer]
      ,ESTIMATED_SHIP_DATE
	  ,[SHIP_METHOD_CODE]
	  ,CUST_PO_NUMBER
	  ,CASE WHEN [RevenueID] <> 5 THEN [LIST_DOLLARS] * -ISNULL(sgc1.[Total Program %],ISNULL(sgc2.[Total Program %],ISNULL(sg1.[Total],ISNULL(sg2.[Total],ISNULL(sgf.[Total],0))))) ELSE 0 END AS [Customer Programs]
	FROM OpenOrders oo
			LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(oo.ORDER_DATE AS DATE) = cf.DateKey
			LEFT JOIN xref.SalesGridBySKU sgc1 ON oo.CUSTOMER_NUM = CAST(sgc1.[Account Number] AS VARCHAR(50)) AND oo.PART = sgc1.SKU AND cf.Year = sgc1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sgc1.Month --match to year + month for customer grid by SKU
			LEFT JOIN xref.SalesGridBySKU sgc2 ON oo.CUSTOMER_NUM = CAST(sgc2.[Account Number] AS VARCHAR(50)) AND oo.PART = sgc2.SKU AND cf.Year = sgc2.Year AND sgc2.Month IS NULL --everything else use month is NULL for customer grid by SKU
			LEFT JOIN xref.SalesGridByCustomer sg1 ON oo.CUSTOMER_NUM = CAST(sg1.[Account Number] AS VARCHAR(50)) AND cf.Year = sg1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sg1.Month --match on a year + month for the customer grid  --AND oo.DEMAND_CLASS = sg1.[Demand Class Code]
			LEFT JOIN xref.SalesGridByCustomer sg2 ON oo.CUSTOMER_NUM = CAST(sg2.[Account Number] AS VARCHAR(50)) AND cf.Year = sg2.Year AND sg1.[Account Number] IS NULL AND sg2.Month IS NULL  --else use the NULL month for the customer grid  --AND oo.DEMAND_CLASS = sg2.[Demand Class Code] 
			LEFT JOIN xref.[Customer Grid Misc] sgf ON oo.[DEMAND_CLASS] = sgf.[Demand Class Code] --but you are in the misc grid
)
SELECT 
	   [ORD_LINE_ID]
      ,[ORD_HEADER_ID]
	  ,[RevenueID]
	  ,[RevenueKey]
	  ,[LocationID]
      ,[CUSTOMER_NAME]
      ,[CUSTOMER_NUM]
      ,[SALES_CHANNEL_CODE]
      ,[DEMAND_CLASS]
      ,[ORDER_DATE]
      ,[ORDER_NUM]
      ,[PART]
      ,[ORDERED_ITEM]
      ,[PART_DESC]
      ,[FLOW_STATUS_CODE]
      ,[QTY]
      ,[SELL_DOLLARS]
      ,[LIST_DOLLARS]
      ,[DATE_REQUESTED]
      ,[SCH_SHIP_DATE]
      ,[ACTUAL_SHIPMENT_DATE]
      ,[CANCEL_DATE]
      ,[PLANT]
      ,[CREATE_DATE]
      ,[ORD_LINE_CREATE_DATE]
      ,[ORD_LINE_LST_UPDATE_DATE]
      ,[SHIP_TO_ADDRESS1]
      ,[SHIP_TO_ADDRESS2]
      ,[SHIP_TO_ADDRESS3]
      ,[SHIP_TO_ADDRESS4]
      ,[SHIP_TO_CITY]
      ,[SHIP_TO_STATE]
      ,[SHIP_TO_POSTAL_CODE]
      ,[SHIP_TO_COUNTRY]
      ,[SHIP_TO_PROVINCE]
      ,[Contract Manufacturing]
      ,[Distribution Method]
      ,[DropShipType]
      ,[FINANCE_REPORTING_CHANNEL]
      ,[International/Domestic/ CAD]
      ,[ParentCustomer]
      ,CASE WHEN ESTIMATED_SHIP_DATE < SCH_SHIP_DATE THEN DATEADD(DAY,9,SCH_SHIP_DATE) ELSE ESTIMATED_SHIP_DATE END AS [ESTIMATED_SHIP_DATE]
	  ,[SHIP_METHOD_CODE]
	  ,CUST_PO_NUMBER
	  ,[Customer Programs]
      ,cf1.[Month]
	  ,cf1.Quarter
	  ,cf1.Year
FROM OpenOrdersNet oo
	LEFT JOIN dbo.DimCalendarFiscal cf1 ON CASE WHEN ESTIMATED_SHIP_DATE < SCH_SHIP_DATE THEN DATEADD(DAY,9,SCH_SHIP_DATE) ELSE ESTIMATED_SHIP_DATE END = cf1.DateKey

GO
