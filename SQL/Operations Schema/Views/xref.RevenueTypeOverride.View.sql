USE [Operations]
GO
/****** Object:  View [xref].[RevenueTypeOverride]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [xref].[RevenueTypeOverride] AS 
SELECT [AccountID]
      ,[AccountName]
      ,[AccountCombo]
	  ,CASE WHEN AccountID = '1212' THEN 'CLEARING'
			WHEN AccountID = '1240' THEN 'DIF/RET'
			WHEN AccountID = '1260' THEN 'ALLOWANCES'
			WHEN AccountID = '1270' THEN 'DISCOUNTS'
			WHEN AccountID IN ('2350','2355','2358','2361') THEN 'CO-OP'
	  END AS RevenueName
	  ,CASE WHEN AccountID = '1212' THEN 'GL-1212'
			WHEN AccountID = '1240' THEN 'GL-1240'
			WHEN AccountID = '1260' THEN 'GL-1260'
			WHEN AccountID = '1270' THEN 'GL-1270'
			WHEN AccountID IN ('2350','2355','2358','2361') THEN 'GL-23XX'
	  END AS RevenueKey
  FROM xref.Account
  WHERE AccountID IN (
	'1212'
	,'1240'
	,'1260'
	,'1270'
	,'2350'
	,'2355'
	,'2358'
	,'2361'
)
GO
