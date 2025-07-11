USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Update_CurrentDayEstimateT4]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Update_CurrentDayEstimateT4] AS BEGIN
	BEGIN TRY
		BEGIN TRAN

		TRUNCATE TABLE [Output].[CurrentDayEstimateT4]

INSERT INTO [Output].[CurrentDayEstimateT4]
	  (
       [ORD_LINE_ID]
      ,[ORD_HEADER_ID]
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
      ,[Fingerprint]
      ,[StartDate]
      ,[EndDate]
      ,[CurrentRecord]
      ,[ACTUAL_SHIPMENT_DATE]
      ,[ORDER_LINE_NUM]
      ,[SHIPPING_METHOD_CODE]
      ,[Currency]
      ,[CUST_PO_NUMBER]
	  ,[RevenueID]
	  ,[RevenueName]
	  ,[HourID]
	  ,[Invoiced Freight]
	  ,[Customer Programs]
	  ,[Net Sales])
SELECT 	
       o.[ORD_LINE_ID]
      ,o.[ORD_HEADER_ID]
      ,o.[CUSTOMER_NAME]
      ,o.[CUSTOMER_NUM]
      ,o.[SALES_CHANNEL_CODE]
      ,o.[DEMAND_CLASS]
      ,o.[ORDER_DATE]
      ,o.[ORDER_NUM]
      ,o.[PART]
      ,o.[ORDERED_ITEM]
      ,o.[PART_DESC]
      ,o.[FLOW_STATUS_CODE]
      ,o.[QTY]
      ,o.[SELL_DOLLARS]
      ,o.[LIST_DOLLARS]
      ,o.[DATE_REQUESTED]
      ,o.[SCH_SHIP_DATE]
      ,o.[CANCEL_DATE]
      ,o.[PLANT]
      ,o.[CREATE_DATE]
      ,o.[ORD_LINE_CREATE_DATE]
      ,o.[ORD_LINE_LST_UPDATE_DATE]
      ,o.[SHIP_TO_ADDRESS1]
      ,o.[SHIP_TO_ADDRESS2]
      ,o.[SHIP_TO_ADDRESS3]
      ,o.[SHIP_TO_ADDRESS4]
      ,o.[SHIP_TO_CITY]
      ,o.[SHIP_TO_STATE]
      ,o.[SHIP_TO_POSTAL_CODE]
      ,o.[SHIP_TO_COUNTRY]
      ,o.[SHIP_TO_PROVINCE]
      ,o.[Fingerprint]
      ,o.[StartDate]
      ,o.[EndDate]
      ,o.[CurrentRecord]
      ,o.[ACTUAL_SHIPMENT_DATE]
      ,o.[ORDER_LINE_NUM]
      ,o.[SHIPPING_METHOD_CODE]
      ,o.[Currency]
      ,o.[CUST_PO_NUMBER]
	  ,1 AS RevenueID
	  ,'AAA-Sales' AS RevenueName
	  ,DATEPART(HOUR,ORDER_DATE) AS HourID
	  ,0 AS [Invoiced Freight]
	  ,[LIST_DOLLARS] * -ISNULL(sgc1.[Total Program %],ISNULL(sgc2.[Total Program %],ISNULL(sg1.[Total],ISNULL(sg2.[Total],ISNULL(sgf.[Total],0))))) AS [Customer Programs]
	  ,0 AS [Net Sales]
FROM Oracle.Orders o
LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(o.ORDER_DATE AS DATE) = cf.DateKey
LEFT JOIN dbo.DimDemandClass dc ON o.DEMAND_CLASS = dc.DemandClassKey
LEFT JOIN dbo.DimProductMaster pm ON o.PART = pm.ProductKey
LEFT JOIN xref.SalesGridBySKU sgc1 ON o.CUSTOMER_NUM = CAST(sgc1.[Account Number] AS VARCHAR(50)) AND o.PART = sgc1.SKU AND cf.Year = sgc1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sgc1.Month --match to year + month for customer grid by SKU
LEFT JOIN xref.SalesGridBySKU sgc2 ON o.CUSTOMER_NUM = CAST(sgc2.[Account Number] AS VARCHAR(50)) AND o.PART = sgc2.SKU AND cf.Year = sgc2.Year AND sgc2.Month IS NULL --everything else use month is NULL for customer grid by SKU
LEFT JOIN xref.SalesGridByCustomer sg1 ON o.CUSTOMER_NUM = CAST(sg1.[Account Number] AS VARCHAR(50)) AND cf.Year = sg1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sg1.Month --match on a year + month for the customer grid  --AND o.DEMAND_CLASS = sg1.[Demand Class Code]
LEFT JOIN xref.SalesGridByCustomer sg2 ON o.CUSTOMER_NUM = CAST(sg2.[Account Number] AS VARCHAR(50)) AND cf.Year = sg2.Year AND sg1.[Account Number] IS NULL AND sg2.Month IS NULL  --else use the NULL month for the customer grid  --AND o.DEMAND_CLASS = sg2.[Demand Class Code]
LEFT JOIN xref.[Customer Grid Misc] sgf ON o.DEMAND_CLASS = sgf.[Demand Class Code] --but you are in the misc grid
WHERE o.CurrentRecord = 1 AND dc.[Finance Reporting Channel] = 'E-COMMERCE' AND dc.[Ecommerce Type] = 'DROPSHIP' 
AND pm.[Part Type] = 'FINISHED GOODS'
AND cf.DateKey >= DATEADD(DAY,-4,CAST(GETDATE() AS DATE)) 
UNION ALL
SELECT 	
       o.[ORD_LINE_ID]
      ,o.[ORD_HEADER_ID]
      ,o.[CUSTOMER_NAME]
      ,o.[CUSTOMER_NUM]
      ,o.[SALES_CHANNEL_CODE]
      ,o.[DEMAND_CLASS]
      ,o.[ORDER_DATE]
      ,o.[ORDER_NUM]
      ,o.[PART]
      ,o.[ORDERED_ITEM]
      ,o.[PART_DESC]
      ,o.[FLOW_STATUS_CODE]
	  ,0 AS QTY
	  ,0 AS SELL_DOLLARS
	  ,CASE WHEN [RevenueID] = 5 THEN 0 ELSE pa.ADJUSTED_AMOUNT*CASE WHEN pa.ARITHMETIC_OPERATOR = 'AMT' THEN 1 ELSE o.QTY END * ISNULL(cc.CONVERSION_RATE,1) END AS LIST_DOLLARS
      ,o.[DATE_REQUESTED]
      ,o.[SCH_SHIP_DATE]
      ,o.[CANCEL_DATE]
      ,o.[PLANT]
      ,o.[CREATE_DATE]
      ,o.[ORD_LINE_CREATE_DATE]
      ,o.[ORD_LINE_LST_UPDATE_DATE]
      ,o.[SHIP_TO_ADDRESS1]
      ,o.[SHIP_TO_ADDRESS2]
      ,o.[SHIP_TO_ADDRESS3]
      ,o.[SHIP_TO_ADDRESS4]
      ,o.[SHIP_TO_CITY]
      ,o.[SHIP_TO_STATE]
      ,o.[SHIP_TO_POSTAL_CODE]
      ,o.[SHIP_TO_COUNTRY]
      ,o.[SHIP_TO_PROVINCE]
      ,o.[Fingerprint]
      ,o.[StartDate]
      ,o.[EndDate]
      ,o.[CurrentRecord]
      ,o.[ACTUAL_SHIPMENT_DATE]
      ,o.[ORDER_LINE_NUM]
      ,o.[SHIPPING_METHOD_CODE]
      ,o.[Currency]
      ,o.[CUST_PO_NUMBER]
	  ,rt.RevenueID
	  ,rt.RevenueName
	  ,DATEPART(HOUR,ORDER_DATE) AS HourID
	  ,CASE WHEN [RevenueID] = 5 THEN pa.ADJUSTED_AMOUNT*CASE WHEN pa.ARITHMETIC_OPERATOR = 'AMT' THEN 1 ELSE o.QTY END * ISNULL(cc.CONVERSION_RATE,1)  ELSE 0 END AS [Invoiced Freight]
	  ,CASE WHEN [RevenueID] <> 5 THEN pa.ADJUSTED_AMOUNT*CASE WHEN pa.ARITHMETIC_OPERATOR = 'AMT' THEN 1 ELSE o.QTY END * ISNULL(cc.CONVERSION_RATE,1)  * -ISNULL(sgc1.[Total Program %],ISNULL(sgc2.[Total Program %],ISNULL(sg1.[Total],ISNULL(sg2.[Total],ISNULL(sgf.[Total],0))))) ELSE 0 END AS [Customer Programs]
	  ,0 AS [Net Sales]
FROM Oracle.Orders o
LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(o.ORDER_DATE AS DATE) = cf.DateKey
LEFT JOIN dbo.DimDemandClass dc ON o.DEMAND_CLASS = dc.DemandClassKey
LEFT JOIN dbo.DimProductMaster pm ON o.PART = pm.ProductKey
INNER JOIN Oracle.OE_PRICE_ADJUSTMENTS_V pa ON pa.LINE_ID = o.ORD_LINE_ID AND pa.CurrentRecord = 1 --AND i.REVENUE_TYPE <> 'AAA-SALES'
LEFT JOIN dbo.DimRevenueType rt ON rt.RevenueKey = 
		case when pa.LIST_LINE_TYPE_CODE = 'TAX' THEN 'ZTAX-' + ISNULL(o.SHIP_TO_STATE,'NULL')
			when pa.Adjustment_Description LIKE '%FRT%MBS%' THEN 'FRTMBS' 
			when substring(pa.Adjustment_Description,1,7) in ('S2C DSF','S2C FRT') then 'SHIPHANDLING' 
			when substring(pa.Adjustment_Description,1,7) in ('S2C DEF','S2C COO') then 'ALLOWANCE' 
			when substring(pa.Adjustment_Description,1,7) = 'S2C TPI' THEN 'TPI' 
			when substring(pa.Adjustment_Description,1,4)='S2C ' then 'S2C_ADJ_OTHER'
			else 'OTHER'
		  end
LEFT JOIN Oracle.GL_DAILY_RATES cc ON CAST(o.ORDER_DATE AS DATE) = cc.CONVERSION_DATE AND o.Currency = cc.FROM_CURRENCY
LEFT JOIN xref.SalesGridBySKU sgc1 ON o.CUSTOMER_NUM = CAST(sgc1.[Account Number] AS VARCHAR(50)) AND o.PART = sgc1.SKU AND cf.Year = sgc1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sgc1.Month --match to year + month for customer grid by SKU
LEFT JOIN xref.SalesGridBySKU sgc2 ON o.CUSTOMER_NUM = CAST(sgc2.[Account Number] AS VARCHAR(50)) AND o.PART = sgc2.SKU AND cf.Year = sgc2.Year AND sgc2.Month IS NULL --everything else use month is NULL for customer grid by SKU
LEFT JOIN xref.SalesGridByCustomer sg1 ON o.CUSTOMER_NUM = CAST(sg1.[Account Number] AS VARCHAR(50)) AND cf.Year = sg1.Year AND CAST(cf.[Month Seasonality Sort] AS INT) = sg1.Month --match on a year + month for the customer grid  --AND o.DEMAND_CLASS = sg1.[Demand Class Code]
LEFT JOIN xref.SalesGridByCustomer sg2 ON o.CUSTOMER_NUM = CAST(sg2.[Account Number] AS VARCHAR(50)) AND cf.Year = sg2.Year AND sg1.[Account Number] IS NULL AND sg2.Month IS NULL  --else use the NULL month for the customer grid  --AND o.DEMAND_CLASS = sg2.[Demand Class Code]
LEFT JOIN xref.[Customer Grid Misc] sgf ON o.DEMAND_CLASS = sgf.[Demand Class Code] --but you are in the misc grid
WHERE o.CurrentRecord = 1 AND dc.[Finance Reporting Channel] = 'E-COMMERCE' AND dc.[Ecommerce Type] = 'DROPSHIP' 
AND pm.[Part Type] = 'FINISHED GOODS'
AND cf.DateKey >= DATEADD(DAY,-4,CAST(GETDATE() AS DATE)) 
AND pa.LIST_LINE_TYPE_CODE <> 'TAX'
;

UPDATE [Output].[CurrentDayEstimateT4]  SET [Net Sales] = [LIST_DOLLARS] + [Invoiced Freight] + [Customer Programs]

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		THROW
	END CATCH
END
GO
