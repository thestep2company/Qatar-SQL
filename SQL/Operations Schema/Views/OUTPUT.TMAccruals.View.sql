USE [Operations]
GO
/****** Object:  View [OUTPUT].[TMAccruals]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[TMAccruals] AS
SELECT * FROM Oracle.TMAccruals 
--WHERE PERIOD_YEAR*100 + PERIOD_NUM = 
--(
--	SELECT DISTINCT [Month Sort] FROM Dim.CalendarFiscal WHERE [MonthID] = (SELECT [MonthID] - 1 FROM Dim.CalendarFiscal WHERE DateKey = CAST(GETDATE() AS DATE))
--)
GO
