USE [Operations]
GO
/****** Object:  View [Error].[PricingDuplicate]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[PricingDuplicate] AS
SELECT p1.* FROM Oracle.Pricing p1
	LEFT JOIN Oracle.Pricing p2 ON p1.ProductKey = p2.ProductKey
WHERE p1.StartDate > p2.StartDate AND p1.StartDate < ISNULL(p2.EndDate,'9999-12-31')
GO
