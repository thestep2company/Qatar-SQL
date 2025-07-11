USE [Operations]
GO
/****** Object:  View [Dim].[Buyer]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[Buyer] AS 
SELECT ROW_NUMBER() OVER(ORDER BY BUYER_NAME) AS BuyerID ,BUYER_NAME FROM Oracle.PurchaseOrder po WHERE CurrentRecord = 1 GROUP BY BUYER_NAME
GO
