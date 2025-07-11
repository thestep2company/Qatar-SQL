USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[ForecastPrep04FileFormatCheck]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ForecastPrep04FileFormatCheck] AS BEGIN

  SELECT 'File Missing Required Field - Part' AS Error, *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE Part IS NULL
  UNION
  SELECT 'File Missing Required Field - M or B', *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE [M or B] IS NULL
  UNION
  SELECT 'File Missing Required Field - SIOP Family', *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE [SIOP Family] IS NULL
  UNION
  SELECT 'File Missing Required Field - Demand Class', *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE [Demand_Class] IS NULL
  UNION
  SELECT 'File Missing Required Field - Description', *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE [Description] IS NULL
  /*
  UNION
  SELECT 'Jan Units Missing', *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE [Jan] IS NULL
  UNION
  SELECT 'Jan $ Units Missing', *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE [Jan$] IS NULL
  UNION
  SELECT 'Feb Units Missing', *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE [Feb] IS NULL
  UNION
  SELECT 'Feb $ Missing', *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE [Feb$] IS NULL
  UNION
  SELECT 'Mar Units Missing', *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE [Mar] IS NULL
  UNION
  SELECT 'Mar $ Missing', *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE [Mar$] IS NULL
  UNION
  SELECT 'Apr Units Missing', *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE [Apr] IS NULL
  UNION
  SELECT 'Apr $ Missing', *
  FROM [XREF].[dbo].[ForecastSummary]
  WHERE [Apr$] IS NULL
  */
END

GO
