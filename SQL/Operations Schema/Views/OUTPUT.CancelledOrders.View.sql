USE [Operations]
GO
/****** Object:  View [OUTPUT].[CancelledOrders]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[CancelledOrders] AS
SELECT * FROM Output.CancelHistory
GO
