USE [Operations]
GO
/****** Object:  View [Dim].[Terms]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Dim].[Terms] AS 
WITH States AS (	
	SELECT SHIP_TO_STATE, SHIP_TO_COUNTRY, ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS RowNum
	FROM Oracle.Invoice 
	WHERE CurrentRecord = 1 AND SHIP_TO_COUNTRY = 'US'
	GROUP BY SHIP_TO_STATE, SHIP_TO_COUNTRY 
)
SELECT [ID] AS TermID
      ,[TERM_ID] AS TermKey
      ,[NAME] AS TermName
      ,[DESCRIPTION] AS TermDesc
	  --,CASE WHEN [DESCRIPTION] LIKE '%Davinci%' THEN SUBSTRING(CASE WHEN [DESCRIPTION] = 'Amazon-Davinci TX Toys' THEN 'Amazon-Davinci - TX Toys' ELSE [DESCRIPTION] END,18,2) END AS DavinciLocation
	  ,CASE WHEN [DESCRIPTION] LIKE '%Davinci%' THEN SHIP_TO_STATE END AS DavinciLocation
FROM [Oracle].[Terms] t
	LEFT JOIN States s ON REPLACE([DESCRIPTION],'-','- ') LIKE '% '+s.SHIP_TO_STATE+' %' AND RowNum <= 51
GO
