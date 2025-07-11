USE [Operations]
GO
/****** Object:  View [Fact].[Step2DirectOrderNotes]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[Step2DirectOrderNotes] AS
SELECT ISNULL(cm.CustomerID,0) AS CustomerID, ISNULL(pm.ProductID,0) AS ProductID, cf.DateID,  ReasonKey, [Order Notes], [Cleansed Order Note]
FROM xref.Step2DirectOrderNotes x
	LEFT JOIN dbo.DimCalendarFiscal cf On [File Date] = cf.[DateKey]
	LEFT JOIN dbo.DimProductMaster pm ON pm.[ProductKey] = x.[ProductKey]
	LEFT JOIN dbo.DimCustomerMaster cm ON cm.[CustomerKey] = x.[CustomerKey]
GO
