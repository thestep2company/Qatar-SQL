USE [Operations]
GO
/****** Object:  View [Dim].[ShipMethod]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[ShipMethod] AS 
SELECT SHIP_METHOD_CODE, MAX(FREIGHT_CODE) AS FREIGHT_CODE FROM Oracle.ShipMethod WHERE CurrentRecord = 1 GROUP BY SHIP_METHOD_CODE
GO
