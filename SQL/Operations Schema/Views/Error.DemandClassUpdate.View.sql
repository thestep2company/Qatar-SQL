USE [Operations]
GO
/****** Object:  View [Error].[DemandClassUpdate]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[DemandClassUpdate] AS 
  SELECT 'Invoiced Sales' AS SaleType, Year, dc.DemandClassKey, cm.CustomerDesc, cm.DEMAND_CLASS_CODE, dc.DemandClassID AS DemandClassIDFrom, dc2.DemandClassID AS DemandClassID2, SUM(Sales) AS Sales, SUM(Qty) AS Qty, COUNT(*) AS RecordCount
  --UPDATE pbi SET pbi.DemandClassID = dc2.DemandClassID
  FROM dbo.FactPBISales pbi
	LEFT JOIN dbo.DimDemandClass dc ON pbi.DemandClassID = dc.DemandClassID
	LEFT JOIN dbo.DimCustomerMaster cm ON pbi.CustomerID = cm.CustomerID
	LEFT JOIN dbo.DimCalendarFiscal cf ON pbi.DateID = cf.DateID 
	LEFT JOIN dbo.DimDemandClass dc2 ON dc2.DemandClassKey = cm.DEMAND_CLASS_CODE
  WHERE Year >= 2019 AND dc.DemandClassKey <> cm.DEMAND_CLASS_CODE AND CustomerDesc	<> '1000099: S2C: SAMKO SALES' AND CustomerDesc <> '1015212: S2C: YALE RESIDENTIAL'
  GROUP BY Year, dc.DemandClassKey, cm.CustomerDesc, cm.DEMAND_CLASS_CODE, dc.DemandClassID, dc2.DemandClassID
  UNION

  SELECT 'Sales Orders' AS SaleType, Year, dc.DemandClassKey, cm.CustomerDesc, cm.DEMAND_CLASS_CODE, dc.DemandClassID AS DemandClassIDFrom, dc2.DemandClassID AS DemandClassID2, SUM(LIST_DOLLARS) AS Sales, SUM(Qty) AS Qty, COUNT(*) AS RecordCount
  --UPDATE pbi SET pbi.DemandClassID = dc2.DemandClassID
  FROM dbo.FactPBISalesOrders pbi
	LEFT JOIN dbo.DimDemandClass dc ON pbi.DemandClassID = dc.DemandClassID
	LEFT JOIN dbo.DimCustomerMaster cm ON pbi.CustomerID = cm.CustomerID
	LEFT JOIN dbo.DimCalendarFiscal cf ON pbi.DateID = cf.DateID 
	LEFT JOIN dbo.DimDemandClass dc2 ON dc2.DemandClassKey = cm.DEMAND_CLASS_CODE
  WHERE Year >= 2019 AND dc.DemandClassKey <> cm.DEMAND_CLASS_CODE AND CustomerDesc	<> '1000099: S2C: SAMKO SALES' AND CustomerDesc <> '1014692: S2C: KINGSLEY PARK' AND CustomerDesc <> '1004075: S2C: WAL-MART.COM (S2H PUERTO RICO)'--AND LIST_DOLLARS <> 0
  GROUP BY Year, dc.DemandClassKey, cm.CustomerDesc, cm.DEMAND_CLASS_CODE, dc.DemandClassID, dc2.DemandClassID

GO
