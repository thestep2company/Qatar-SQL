USE [Operations]
GO
/****** Object:  View [Fact].[ProductPricing]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE VIEW [Fact].[ProductPricing] AS 
	SELECT * FROM Oracle.Pricing pp WHERE CurrentRecord = 1
GO
