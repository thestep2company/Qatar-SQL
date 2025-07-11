USE [Operations]
GO
/****** Object:  View [OUTPUT].[Step2DirectOrderNotes]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[Step2DirectOrderNotes] AS 
SELECT [Order Number]
      ,[Order Notes]
      ,[File Date]
      ,pm.[ProductKey]
	  ,pm.[ProductName]
      ,cm.[CustomerKey]
	  ,cm.[CustomerName]
	  ,cf.[Month Sort] AS Period
      ,[ReasonKey]
      ,[Cleansed Order Note]
  FROM [xref].[Step2DirectOrderNotes] notes
	LEFT JOIN dbo.DimProductMaster pm ON notes.ProductKey = pm.ProductKey 
	LEFT JOIN dbo.DimCustomerMaster cm ON notes.CustomerKey = cm.CustomerKey 
	LEFT JOIN dbo.DimCalendarFiscal cf ON notes.[File Date] = cf.[DateKey]
GO
