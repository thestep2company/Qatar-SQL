USE [Operations]
GO
/****** Object:  View [Dim].[PayCode]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[PayCode] AS 
SELECT DISTINCT 
	  DENSE_RANK() OVER (ORDER BY [Paycode Name]) AS PayCodeID 
	  , CASE WHEN [Paycode Name] = 'Regular' THEN 'Regular'
			WHEN [PayCode Name] LIKE 'OT %' THEN 'Overtime' 
			WHEN [PayCode Name] LIKE 'Doubletime' THEN 'Doubletime' 
			WHEN [PayCode Name] LIKE 'Shift Diff%' THEN 'Shift Diff' 
			WHEN [PayCode Name] LIKE '%Heat%' THEN 'High Heat' 
			WHEN [PayCode Name] LIKE '%Vacation%' THEN 'Vacation' 
			WHEN [PayCode Name] LIKE '%Holiday%' THEN 'Holiday' 
			WHEN [Paycode Name] LIKE '%Bonus%' THEN 'Bonus'
			WHEN [Paycode Name] LIKE '%Trainging%' THEN 'Training'
			ELSE 'Other' 
		END AS [PaycodeCategory]
	  ,[PayCode Name]
FROM [Kronos].[EmployeeHours] WITH (NOLOCK)	
WHERE CurrentRecord = 1 
	AND [Paycode Type] = 'Regular'
	--AND ([PayCode Name] IN ('Regular', 'OT 1.0', 'OT 0.5', 'Lump Sum', 'Retroactive') OR [Paycode Name] LIKE 'Shift Diff%')
GO
