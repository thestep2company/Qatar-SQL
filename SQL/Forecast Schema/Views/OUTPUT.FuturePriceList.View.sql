USE [Forecast]
GO
/****** Object:  View [OUTPUT].[FuturePriceList]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[FuturePriceList] AS
SELECT * FROM dbo.FactPriceList WHERE StartDate > GETDATE()
GO
