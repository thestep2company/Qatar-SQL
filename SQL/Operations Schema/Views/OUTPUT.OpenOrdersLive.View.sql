USE [Operations]
GO
/****** Object:  View [OUTPUT].[OpenOrdersLive]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[OpenOrdersLive] AS 
WITH OpenOrderLogic AS (
	SELECT 
		   [ORD_LINE_ID]
		  ,[CUSTOMER_NAME]
		  ,[CUSTOMER_NUM]
		  ,[SALES_CHANNEL_CODE]
		  ,[DEMAND_CLASS]
		  ,[ORDER_DATE]
		  ,[ORDER_NUM]
		  ,[ORDER_LINE_NUM]
		  ,[CUST_PO_NUMBER]
		  ,[PART]
		  ,[ORDERED_ITEM]
		  ,[PART_DESC]
		  ,[FLOW_STATUS_CODE]
		  ,CASE WHEN o.FLOW_STATUS_CODE LIKE '%RETURN%' THEN -1 ELSE 1 END * o.[QTY] AS QTY
		  ,CASE WHEN o.FLOW_STATUS_CODE LIKE '%RETURN%' THEN -1 ELSE 1 END * o.[SELL_DOLLARS] * ISNULL(cc.CONVERSION_RATE,1) AS SELL_DOLLARS
		  ,CASE WHEN o.FLOW_STATUS_CODE LIKE '%RETURN%' THEN -1 ELSE 1 END * o.[LIST_DOLLARS] * ISNULL(cc.CONVERSION_RATE,1) AS LIST_DOLLARS
		  ,[DATE_REQUESTED]
		  ,[SCH_SHIP_DATE]
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
		  ,[SHIPPING_METHOD_CODE]
		  ,[Currency]
	  FROM [Oracle].[Orders] o
  		LEFT JOIN Oracle.GL_DAILY_RATES cc ON CAST(o.ORDER_DATE AS DATE) = cc.CONVERSION_DATE AND o.Currency = cc.FROM_CURRENCY
	  WHERE o.FLOW_STATUS_CODE NOT IN ('CLOSED','CANCELLED','DELETED')
		AND o.CurrentRecord = 1 
		AND o.CUSTOMER_NUM <> '1055833'
)
	SELECT oo.[CUSTOMER_NAME]
		  ,oo.[CUSTOMER_NUM]
		  ,oo.[SALES_CHANNEL_CODE]
		  ,oo.[DEMAND_CLASS]
		  ,oo.[ORDER_DATE]
		  ,oo.[ORDER_NUM]
		  ,oo.ORDER_LINE_NUM
		  ,oo.CUST_PO_NUMBER
		  ,oo.[PART]
		  ,oo.[ORDERED_ITEM]
		  ,oo.[PART_DESC]
		  ,oo.[FLOW_STATUS_CODE]
		  ,oo.QTY
		  ,oo.SELL_DOLLARS
		  ,oo.LIST_DOLLARS
		  ,oo.DATE_REQUESTED
		  ,oo.SCH_SHIP_DATE
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
		  ,oo.SHIPPING_METHOD_CODE
		  ,oo.Currency
	FROM OpenOrderLogic oo
	UNION ALL 
	SELECT 
		   oo.[CUSTOMER_NAME]
		  ,oo.[CUSTOMER_NUM]
		  ,oo.[SALES_CHANNEL_CODE]
		  ,oo.[DEMAND_CLASS]
		  ,oo.[ORDER_DATE]
		  ,oo.[ORDER_NUM]
		  ,oo.ORDER_LINE_NUM
		  ,oo.CUST_PO_NUMBER
		  ,oo.[PART]
		  ,oo.[ORDERED_ITEM]
		  ,oo.[PART_DESC]
		  ,oo.[FLOW_STATUS_CODE]
		  ,0 AS QTY
		  ,0 AS SELL_DOLLARS
		  ,pa.ADJUSTED_AMOUNT*CASE WHEN pa.ARITHMETIC_OPERATOR = 'AMT' THEN 1 ELSE oo.QTY END * ISNULL(cc.CONVERSION_RATE,1) AS LIST_DOLLARS
		  ,oo.DATE_REQUESTED
		  ,oo.SCH_SHIP_DATE
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
		  ,oo.SHIPPING_METHOD_CODE
		  ,oo.Currency
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
		LEFT JOIN Dim.[Geography] g ON UPPER(ISNULL(CASE WHEN oo.[SHIP_TO_POSTAL_CODE] LIKE '%-%' OR LEN(oo.[SHIP_TO_POSTAL_CODE]) >= 9 THEN LEFT(oo.[SHIP_TO_POSTAL_CODE],5) ELSE oo.[SHIP_TO_POSTAL_CODE] END,'MISSING')) = g.PostalCode AND UPPER(ISNULL(oo.[SHIP_TO_COUNTRY],'MISSING')) = g.Country
		LEFT JOIN Oracle.GL_DAILY_RATES cc ON CAST(oo.ORDER_DATE AS DATE) = cc.CONVERSION_DATE AND oo.Currency = cc.FROM_CURRENCY
	WHERE case when pa.LIST_LINE_TYPE_CODE = 'TAX' THEN 'TAX'
				when pa.Adjustment_Description LIKE '%FRT%MBS%' THEN 'FRTMBS' 
				when substring(pa.Adjustment_Description,1,7) in ('S2C DSF','S2C FRT') then 'SHIPHANDLING' 
				when substring(pa.Adjustment_Description,1,7) in ('S2C DEF','S2C COO') then 'ALLOWANCE' 
				when substring(pa.Adjustment_Description,1,7) = 'S2C TPI' THEN 'TPI' 
				when substring(pa.Adjustment_Description,1,4)='S2C ' then 'S2C_ADJ_OTHER'
				else 'OTHER'
			  end NOT IN ('TAX','SHIPHANDLING')
GO
