USE [Operations]
GO
/****** Object:  View [Dim].[CustomerMaster]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Dim].[CustomerMaster] AS 
SELECT 
	   cm.[ID] AS CustomerID
      ,cm.[ACCOUNT_NUMBER] AS CustomerKey
      ,cm.[ACCOUNT_NAME] AS CustomerName
	  ,cm.[ACCOUNT_NUMBER] + ': ' + cm.[ACCOUNT_NAME] AS CustomerDesc
	  ,RIGHT('0000000000'+cm.[ACCOUNT_NUMBER],10) AS CustomerSort
      ,cm.[SALES_CHANNEL_CODE]
      ,cm.[INSIDE_REP]
      ,cm.[TRAFFIC_PERSON]
      ,cm.[LABEL_FORMAT]
      ,cm.[BUSINESS_SEGMENT]
      ,cm.[CUSTOMER_GROUP]
      ,cm.[FINANCE_CHANNEL]
      ,ISNULL(cm.[TERRITORY],'Missing') AS TERRITORY
      ,ISNULL(cm.[SALESPERSON],'Missing') AS SALESPERSON
      ,ISNULL(cm.[ORDER_TYPE],'Missing') AS ORDER_TYPE
      ,ISNULL(ISNULL(cm.[DEMAND_CLASS_CODE],cdc.[DemandClass]),'Missing') AS DEMAND_CLASS_CODE
	  ,ISNULL(dc.[DEMAND CLASS NAME],'Missing') AS DEMAND_CLASS_NAME
	  ,ISNULL(dc.[Finance Reporting Channel],'Missing') AS FINANCE_REPORTING_CHANNEL
	  ,ISNULL(dcf.FeedDemandClassName,ISNULL([DEMAND CLASS NAME],'Missing')) AS FEED_DEMAND_CLASS_NAME
	  ,CASE WHEN dcf.CustomerNumber IS NOT NULL THEN 'Feed Customer' ELSE 'No Inventory Feed' END FEED_CUSTOMER
	  ,cd.CreationDate
	  ,cd.FirstSaleDate
	  ,cd.LastSaleDate
	  ,cx.[International/Domestic/ CAD]
	  ,cx.[Distribution Method]
	  ,cx.[Selling Method]
	  ,ISNULL(cx.[DropShipType],'Other') AS DropShipType
	  ,cx.[ParentCustomer]
	  ,csr.[Sales Representative]
  FROM Oracle.CustomerMaster cm
	LEFT JOIN xref.CustomerDemandClass cdc ON cdc.[CustomerKey] = cm.[ACCOUNT_NUMBER] --demand class supplement when Oracle does not specify the demand class
	LEFT JOIN xref.DemandClass dc ON dc.[DEMAND CLASS CODE] = ISNULL(cm.[DEMAND_CLASS_CODE],cdc.[DemandClass]) --lookup oracle first, then use FP&A override to find demand class
	LEFT JOIN xref.DemandClassFeed dcf ON dcf.CustomerNumber = [ACCOUNT_NUMBER] --supplies the feed customer field
	LEFT JOIN Oracle.CustomerDates cd ON cd.CustomerKey = cm.[Account_Number]
	LEFT JOIN xref.CustomerExtensionData cx ON cm.[ACCOUNT_NUMBER] = cx.[CUSTOMER_NUM]
	LEFT JOIN xref.CommissionsSalesRep csr ON cm.ACCOUNT_NUMBER = csr.Number
  WHERE cm.CurrentRecord = 1 
  UNION ALL
  SELECT DISTINCT
	   CAST([AccountNumber] AS INT) AS CustomerID
      ,[AccountNumber] AS CustomerKey
      ,'Missing' AS CustomerName
	  ,[AccountNumber] + ': Missing' AS CustomerDesc
	  ,RIGHT('0000000000'+[AccountNumber],10) AS CustomerSort
      ,'Missing' AS [SALES_CHANNEL_CODE]
      ,'Missing' AS [INSIDE_REP]
      ,'Missing' AS [TRAFFIC_PERSON]
      ,'Missing' AS [LABEL_FORMAT]
      ,'Missing' AS [BUSINESS_SEGMENT]
      ,'Missing' AS [CUSTOMER_GROUP]
      ,'Missing' AS [FINANCE_CHANNEL]
      ,'Missing' AS [TERRITORY]
      ,'Missing' AS [SALESPERSON]
      ,'Missing' AS [ORDER_TYPE]
      ,'Missing' AS [DEMAND_CLASS_CODE]
	  ,'Missing' AS DEMAND_CLASS_NAME
	  ,'Missing' AS FINANCE_REPORTING_CHANNEL
	  ,'Missing' AS FEED_DEMAND_CLASS_NAME
	  ,'No Inventory Feed' AS FEED_CUSTOMER
	  ,NULL AS CreationDate
	  ,NULL AS FirstSaleDate
	  ,NULL AS LastSaleDate
	  ,NULL AS [International/Domestic/ CAD]
	  ,NULL AS [Distribution Method]
	  ,NULL AS [Selling Method]
	  ,NULL AS DropShipType
	  ,NULL AS ParentCustomer
	  ,NULL AS [Sales Representative]
  FROM [EDI].[CustomerInventory] i
	LEFT JOIN Oracle.CustomerMaster c ON i.AccountNumber = c.ACCOUNT_NUMBER AND c.CurrentRecord = 1
	LEFT JOIN xref.DemandClassFeed dcf ON dcf.CustomerNumber = [AccountNumber]
  WHERE i.Active = 'Y' 
	AND i.CurrentRecord = 1
	AND CAST(GETDATE() AS DATE) BETWEEN i.EffectiveDate AND i.DiscontinueDate
	AND c.ID IS NULL
UNION ALL
--SELECT -ROW_NUMBER() OVER (ORDER BY b.[Demand Class]) AS CustomerID 
--	, b.[Demand Class] + ' Placeholder' AS CustomerKey
--	, MAX(b.ACCOUNT_NAME) AS CustomerName
--	, MAX(b.ACCOUNT_NAME) AS CustomerDesc
--	, RIGHT('000000000'+b.[Demand Class],10) AS CustomerSort
--	,dc.[Channel Code] AS [SALES_CHANNEL_CODE]
--    ,'Placeholder' AS [INSIDE_REP]
--    ,'Placeholder' AS [TRAFFIC_PERSON]
--    ,'Placeholder' AS [LABEL_FORMAT]
--    ,'Placeholder' AS [BUSINESS_SEGMENT]
--    ,'Placeholder' AS [CUSTOMER_GROUP]
--    ,'Placeholder' AS [FINANCE_CHANNEL]
--    ,'Placeholder' AS [TERRITORY]
--    ,'Placeholder' AS [SALESPERSON]
--    ,'Placeholder' AS [ORDER_TYPE]
--    ,ISNULL(dc.[DemandClassKey],[Demand Class]) AS [DEMAND_CLASS_CODE]
--	,dc.[DemandClassName] AS DEMAND_CLASS_NAME
--	,dc.[Finance Reporting Channel] AS FINANCE_REPORTING_CHANNEL
--	,'Placeholder' AS FEED_DEMAND_CLASS_NAME
--	,'No Inventory Feed' AS FEED_CUSTOMER
--	,NULL AS CreationDate
--	,NULL AS FirstSaleDate
--	,NULL AS LastSaleDate
--	,dc.[International/Domestic/ CAD]
--	,dc.[Distribution Method]
--	,dc.[Selling Method]
--	,dc.[Drop Ship/Other]
--	,dc.[Parent Customer]
--	,NULL AS [Sales Representative]
--FROM xref.SalesForecast b
--	LEFT JOIN dbo.DimDemandClass dc ON b.[Demand Class] = dc.[DemandClassKey]
--WHERE ACCOUNT_NUMBER IS NULL AND ACCOUNT_NAME IS NOT NULL
--GROUP BY dc.[DemandClassKey]
--	, dc.[DemandClassName]
--	, dc.[Finance Reporting Channel]
--	, b.[Demand Class]
--	, dc.[Channel Code]
--	,dc.[International/Domestic/ CAD]
--	,dc.[Distribution Method]
--	,dc.[Selling Method]
--	,dc.[Drop Ship/Other]
--	,dc.[Parent Customer]
--UNION ALL
--SELECT -ROW_NUMBER() OVER (ORDER BY b.[Demand Class]) AS CustomerID 
--	, b.[Demand Class] + ' Roll' AS CustomerKey
--	, b.[Demand Class] + ' Roll' AS CustomerName
--	, b.[Demand Class] + ' Roll' AS CustomerDesc
--	, RIGHT('000000000'+b.[Demand Class],10) AS CustomerSort
--	,dc.[Channel Code] AS [SALES_CHANNEL_CODE]
--    ,'Roll' AS [INSIDE_REP]
--    ,'Roll' AS [TRAFFIC_PERSON]
--    ,'Roll' AS [LABEL_FORMAT]
--    ,'Roll' AS [BUSINESS_SEGMENT]
--    ,'Roll' AS [CUSTOMER_GROUP]
--    ,'Roll' AS [FINANCE_CHANNEL]
--    ,'Roll' AS [TERRITORY]
--    ,'Roll' AS [SALESPERSON]
--    ,'Roll' AS [ORDER_TYPE]
--    ,ISNULL(dc.[DemandClassKey],[Demand Class]) AS [DEMAND_CLASS_CODE]
--	,dc.[DemandClassName] AS DEMAND_CLASS_NAME
--	,dc.[Finance Reporting Channel] AS FINANCE_REPORTING_CHANNEL
--	,'Roll' AS FEED_DEMAND_CLASS_NAME
--	,'No Inventory Feed' AS FEED_CUSTOMER
--	,NULL AS CreationDate
--	,NULL AS FirstSaleDate
--	,NULL AS LastSaleDate
--	,dc.[International/Domestic/ CAD]
--	,dc.[Distribution Method]
--	,dc.[Selling Method]
--	,dc.[Drop Ship/Other]
--	,dc.[Parent Customer]
--	,NULL AS [Sales Representative]
--FROM xref.SalesForecast b
--	LEFT JOIN dbo.DimDemandClass dc ON b.[Demand Class] = dc.[DemandClassKey]
--WHERE ACCOUNT_NUMBER IS NULL AND ACCOUNT_NAME IS NOT NULL
--GROUP BY dc.[DemandClassKey]
--	, dc.[DemandClassName]
--	, dc.[Finance Reporting Channel]
--	, b.[Demand Class]
--	, dc.[Channel Code]
--	,dc.[International/Domestic/ CAD]
--	,dc.[Distribution Method]
--	,dc.[Selling Method]
--	,dc.[Drop Ship/Other]
--	,dc.[Parent Customer]
--UNION ALL
SELECT DISTINCT 0 AS CustomerID 
	, DemandClassKey AS CustomerKey
	, DemandClassName AS CustomerName
	, DemandClassKey + ': ' + DemandClassName AS CustomerDesc
	, RIGHT('000000000'+DemandClassKey,10) AS CustomerSort
	,'' AS [SALES_CHANNEL_CODE]
    ,'' AS [INSIDE_REP]
    ,'' AS [TRAFFIC_PERSON]
    ,'' AS [LABEL_FORMAT]
    ,'' AS [BUSINESS_SEGMENT]
    ,'' AS [CUSTOMER_GROUP]
    ,dc.[Finance Reporting Channel] AS [FINANCE_CHANNEL]
    ,'' AS [TERRITORY]
    ,'' AS [SALESPERSON]
    ,'' AS [ORDER_TYPE]
    ,dc.[DemandClassKey] AS [DEMAND_CLASS_CODE]
	,dc.[DemandClassName] AS DEMAND_CLASS_NAME
	,dc.[Finance Reporting Channel] AS FINANCE_REPORTING_CHANNEL
	,DemandClassName AS FEED_DEMAND_CLASS_NAME
	,'No Inventory Feed' AS FEED_CUSTOMER
	,NULL AS CreationDate
	,NULL AS FirstSaleDate
	,NULL AS LastSaleDate
	,dc.[International/Domestic/ CAD]
	,dc.[Distribution Method]
	,dc.[Selling Method]
	,dc.[Drop Ship/Other]
	,dc.[Parent Customer]
	,NULL AS [Sales Representative]
FROM dbo.DimDemandClass dc
	LEFT JOIN dbo.FactPBISales s ON dc.DemandClassID = s.DemandClassID
WHERE dc.CreateCustomerRecord = 1
UNION ALL
SELECT -1 AS CustomerID 
    , 'Adjustment' AS CustomerKey
	, 'Adjustment' AS CustomerName
	, 'Adjustment' AS CustomerDesc
	, '9999999999' AS CustomerSort
	, 'Adjustment' AS [SALES_CHANNEL_CODE]
    ,'Adjustment' AS [INSIDE_REP]
    ,'Adjustment' AS [TRAFFIC_PERSON]
    ,'Adjustment' AS [LABEL_FORMAT]
    ,'Adjustment' AS [BUSINESS_SEGMENT]
    ,'Adjustment' AS [CUSTOMER_GROUP]
    ,'Adjustment' AS [FINANCE_CHANNEL]
    ,'Adjustment' AS [TERRITORY]
    ,'Adjustment' AS [SALESPERSON]
    ,'Adjustment' AS [ORDER_TYPE]
    ,'Adjustment' AS [DEMAND_CLASS_CODE]
	,'Adjustment' AS DEMAND_CLASS_NAME
	,'Adjustment' AS FINANCE_REPORTING_CHANNEL
	,'Adjustment' AS FEED_DEMAND_CLASS_NAME
	,'No Inventory Feed' AS FEED_CUSTOMER
	,NULL AS CreationDate
	,NULL AS FirstSaleDate
	,NULL AS LastSaleDate
	,'Adjustment' AS [International/Domestic/ CAD]
	,NULL AS [Distribution Method]
	,NULL AS [Selling Method]
	,'Other' AS DropShipType
	,'Adjustment' AS ParentCustomer
	,NULL AS [Sales Representative]

GO
