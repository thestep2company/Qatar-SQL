USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactPBISalesOrdersHoliday]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Upsert_FactPBISalesOrdersHoliday] AS BEGIN
BEGIN TRY 
	BEGIN TRAN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Truncate', GETDATE()
	
	TRUNCATE TABLE dbo.FactPBISalesOrdersHoliday
			
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

	INSERT 	INTO dbo.FactPBISalesOrdersHoliday
	SELECT 
		   o.ORDER_NUM
		  ,ISNULL(rt.RevenueID,0) AS RevenueID
		  ,ISNULL(c.CustomerID,0) AS CustomerID
		  --,ISNULL(g.GeographyID,0) AS GeographyID
		  ,ISNULL(p.ProductID,0) AS ProductID
		  ,ISNULL(l.LocationID,0) AS LocationID
		  ,ISNULL(dc.DemandClassID,0) AS DemandClassID
		  ,ISNULL(cf.DateID,0) AS DateID
		  ,cf.DateKey
		  ,DATEPART(HOUR,o.ORDER_DATE) AS HourID          
		  ,SUM(o.[SELL_DOLLARS] * ISNULL(cc.CONVERSION_RATE,1)) AS SELL_DOLLARS
		  ,SUM(o.[LIST_DOLLARS] * ISNULL(cc.CONVERSION_RATE,1)) AS ORIGINAL_LIST_DOLLARS
		  ,SUM(o.[LIST_DOLLARS] * ISNULL(cc.CONVERSION_RATE,1)) AS LIST_DOLLARS
		  ,SUM(s1.ItemCost * o.QTY) AS COGSSB
		  ,SUM(s2.ItemCost * o.QTY) AS COGSPV
		  ,SUM(o.[QTY]) AS Qty
		  ,CASE WHEN oo.ORD_LINE_ID IS NOT NULL THEN 1 ELSE 0 END AS IsOpen
		  ,0 AS IsInvoiced --CASE WHEN i.ORDER_NUM IS NOT NULL THEN 1 ELSE 0 END
		  ,0 AS [COOP]
		  ,0 AS [DIF RETURNS]
		  ,0 AS [Freight Allowance]
	      ,0 AS [Cash Discounts]
		  ,0 AS [Markdown]
		  ,0 AS [Other]
	FROM Oracle.Orders o
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(o.ORDER_DATE AS DATE) = cf.DateKey
		LEFT JOIN dbo.DimCustomerMaster c ON o.Customer_NUM = c.CustomerKey 
		LEFT JOIN dbo.DimProductMaster p ON o.PART = p.ProductKey
		LEFT JOIN dbo.DimLocation l ON o.PLANT = l.LocationKey
		LEFT JOIN dbo.DimDemandClass dc ON ISNULL(o.DEMAND_CLASS,c.DEMAND_CLASS_CODE) = dc.DemandClassKey
		LEFT JOIN dbo.DimRevenueType rt ON rt.RevenueKey = 'AAA-SALES'
		LEFT JOIN dbo.FactStandard s1 ON p.ProductID = s1.ProductID AND 3 = s1.LocationID AND cf.DateKey BETWEEN s1.StartDate AND s1.EndDate
		LEFT JOIN dbo.FactStandard s2 ON p.ProductID = s2.ProductID AND 2 = s2.LocationID AND cf.DateKey BETWEEN s2.StartDate AND s2.EndDate
		LEFT JOIN Oracle.OrdersOpen oo ON o.ORD_HEADER_ID = oo.ORD_HEADER_ID AND o.ORD_LINE_ID = oo.ORD_LINE_ID
		--LEFT JOIN Dim.[Geography] g ON UPPER(ISNULL(CASE WHEN o.[SHIP_TO_POSTAL_CODE] LIKE '%-%' OR LEN(o.[SHIP_TO_POSTAL_CODE]) >= 9 THEN LEFT(o.[SHIP_TO_POSTAL_CODE],5) ELSE o.[SHIP_TO_POSTAL_CODE] END,'MISSING')) = g.PostalCode AND UPPER(ISNULL(o.[SHIP_TO_COUNTRY],'MISSING')) = g.COuntry
		LEFT JOIN Oracle.GL_DAILY_RATES cc ON CAST(o.ORDER_DATE AS DATE) = cc.CONVERSION_DATE AND o.Currency = cc.FROM_CURRENCY
		--LEFT JOIN Oracle.Invoice i ON o.ORDER_NUM = i.ORDER_NUM AND o.ORDER_LINE_NUM = i.SO_LINE_NUM AND I.CurrentRecord = 1 AND i.REVENUE_TYPE = rt.RevenueKey
	WHERE (cf.[DateKey] >= DATEADD(DAY,-2,GETDATE()) AND cf.DateKey < GETDATE() 
		OR (cf.[DateKey] >= DATEADD(DAY,-364,DATEADD(DAY,-2,GETDATE())) AND cf.DateKey < DATEADD(DAY,-364,GETDATE()))
		OR (cf.[DateKey] >= DATEADD(DAY,-364*2,DATEADD(DAY,-2,GETDATE())) AND cf.DateKey < DATEADD(DAY,-364*2,GETDATE()))
		OR cf.HolidayName IS NOT NULL) AND o.CurrentRecord = 1
	GROUP BY o.ORDER_NUM
		  ,ISNULL(rt.RevenueID,0)
		  ,ISNULL(c.CustomerID,0) 
		  --,ISNULL(g.GeographyID,0) 
		  ,ISNULL(p.ProductID,0)
		  ,ISNULL(l.LocationID,0)
		  ,ISNULL(dc.DemandClassID,0)
		  ,ISNULL(cf.DateID,0)
		  ,cf.DateKey
		  ,DATEPART(HOUR,o.ORDER_DATE)
		  ,CASE WHEN oo.ORD_LINE_ID IS NOT NULL THEN 1 ELSE 0 END 
	UNION ALL
	SELECT 
			 o.ORDER_NUM
		    ,ISNULL(rt.RevenueID,0) AS RevenueID
			,ISNULL(c.CustomerID,0) AS CustomerID
			--,ISNULL(g.GeographyID,0) AS GeographyID
			,ISNULL(p.ProductID,0) AS ProductID
			,ISNULL(l.LocationID,0) AS LocationID
			,ISNULL(dc.DemandClassID,0) AS DemandClassID
			,ISNULL(cf.DateID,0) AS DateID
			,cf.DateKey
			,DATEPART(HOUR,o.ORDER_DATE) AS HourID    
			,0 AS [SELL_DOLLARS]
			,0 AS ORIGINAL_LIST_DOLLARS
			,SUM(pa.ADJUSTED_AMOUNT*o.QTY * ISNULL(cc.CONVERSION_RATE,1)) AS [LIST_DOLLARS]
			,0 AS COGSSB
			,0 AS COGSPV
			,0 AS [QTY]
			--,o.[FLOW_STATUS_CODE]
			,CASE WHEN oo.ORD_LINE_ID IS NOT NULL THEN 1 ELSE 0 END AS IsOpen
			,0 AS IsInvoiced --CASE WHEN i.ORDER_NUM IS NOT NULL THEN 1 ELSE 0 END
			,0 AS [COOP]
		    ,0 AS [DIF RETURNS]
		    ,0 AS [Freight Allowance]
	        ,0 AS [Cash Discounts]
		    ,0 AS [Markdown]
		    ,0 AS [Other]
	FROM Oracle.Orders o
		LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(o.ORDER_DATE AS DATE) = cf.DateKey
		LEFT JOIN dbo.DimCustomerMaster c ON o.Customer_NUM = c.CustomerKey 
		LEFT JOIN dbo.DimProductMaster p ON o.PART = p.ProductKey
		LEFT JOIN dbo.DimLocation l ON o.PLANT = l.LocationKey
		LEFT JOIN dbo.DimDemandClass dc ON ISNULL(o.DEMAND_CLASS,c.DEMAND_CLASS_CODE) = dc.DemandClassKey
		INNER JOIN Oracle.OE_PRICE_ADJUSTMENTS_V pa ON pa.LINE_ID = o.ORD_LINE_ID AND pa.CurrentRecord = 1--AND i.REVENUE_TYPE <> 'AAA-SALES'
		LEFT JOIN dbo.DimRevenueType rt ON rt.RevenueKey = 
			case when pa.LIST_LINE_TYPE_CODE = 'TAX' THEN 'ZTAX-' + ISNULL(o.SHIP_TO_STATE,'NULL')
				when pa.Adjustment_Description LIKE '%FRT%MBS%' THEN 'FRTMBS' 
				when substring(pa.Adjustment_Description,1,7) in ('S2C DSF','S2C FRT') then 'SHIPHANDLING' 
				when substring(pa.Adjustment_Description,1,7) in ('S2C DEF','S2C COO') then 'ALLOWANCE' 
				when substring(pa.Adjustment_Description,1,7) = 'S2C TPI' THEN 'TPI' 
				when substring(pa.Adjustment_Description,1,4)='S2C ' then 'S2C_ADJ_OTHER'
				else 'OTHER'
				end
		LEFT JOIN Oracle.OrdersOpen oo ON o.ORD_HEADER_ID = oo.ORD_HEADER_ID AND o.ORD_LINE_ID = oo.ORD_LINE_ID
		LEFT JOIN Dim.[Geography] g ON UPPER(ISNULL(CASE WHEN o.[SHIP_TO_POSTAL_CODE] LIKE '%-%' OR LEN(o.[SHIP_TO_POSTAL_CODE]) >= 9 THEN LEFT(o.[SHIP_TO_POSTAL_CODE],5) ELSE o.[SHIP_TO_POSTAL_CODE] END,'MISSING')) = g.PostalCode AND UPPER(ISNULL(o.[SHIP_TO_COUNTRY],'MISSING')) = g.COuntry
		LEFT JOIN Oracle.GL_DAILY_RATES cc ON CAST(o.ORDER_DATE AS DATE) = cc.CONVERSION_DATE AND o.Currency = cc.FROM_CURRENCY
		--LEFT JOIN Oracle.Invoice i ON o.ORDER_NUM = i.ORDER_NUM AND o.ORDER_LINE_NUM = i.SO_LINE_NUM AND I.CurrentRecord = 1 AND rt.RevenueKey = i.REVENUE_TYPE
	WHERE (cf.[DateKey] >= DATEADD(DAY,-2,GETDATE()) AND cf.DateKey < GETDATE() 
		OR (cf.[DateKey] >= DATEADD(DAY,-364,DATEADD(DAY,-2,GETDATE())) AND cf.DateKey < DATEADD(DAY,-364,GETDATE()))
		OR (cf.[DateKey] >= DATEADD(DAY,-364*2,DATEADD(DAY,-2,GETDATE())) AND cf.DateKey < DATEADD(DAY,-364*2,GETDATE()))
		OR cf.HolidayName IS NOT NULL) AND o.CurrentRecord = 1
		AND pa.LIST_LINE_TYPE_CODE <> 'TAX'
	GROUP BY o.ORDER_NUM
		    ,ISNULL(rt.RevenueID,0)
			,ISNULL(c.CustomerID,0)
			,ISNULL(p.ProductID,0)
			,ISNULL(l.LocationID,0)
			,ISNULL(dc.DemandClassID,0)
			,ISNULL(cf.DateID,0)
			,cf.DateKey
			,DATEPART(HOUR,o.ORDER_DATE)
			,CASE WHEN oo.ORD_LINE_ID IS NOT NULL THEN 1 ELSE 0 END

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		THROW
	END CATCH

END

GO
