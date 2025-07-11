USE [Operations]
GO
/****** Object:  View [Fact].[ChecklistQA]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[ChecklistQA] AS
SELECT 
	l.LocationID --ch.Location
	, m.MachineID --ch.MACHINE_NUM ch.MACHINE_SIZE
	, pm.ProductID --, ch.PRODUCT_NUMBER
	, cf.DateID -- CAST(ch.CREATE_DATE AS DATE) AS CreateDate
	, CAST(cd.DATE_SAVED AS DATE) AS SaveDate
	, ch.TEST_NUMBER
	, CAST(ch.TEST_NUMBER AS VARCHAR(7)) + '.' + CAST(cd.CHECK_NUMBER AS VARCHAR(2)) AS CHECK_NUMBER
	, cd.Test
	, CASE WHEN ISNULL(cd.CHECK_VALUE,'') = '' THEN 'Blank' ELSE cd.CHECK_VALUE END AS CHECK_VALUE
	, ch.INSPECTOR
	, cd.RESULTS_COMMENTS

	--*
FROM [QA].[QUALITY_CHECKLIST_HEADER] ch
	LEFT JOIN [QA].[QUALITY_CHECKLIST_RESULTS] cd ON ch.TEST_NUMBER = cd.TEST_NUMBER AND cd.CurrentRecord = 1
	LEFT JOIN dbo.DimProductMaster pm ON ch.PRODUCT_NUMBER = pm.ProductKey
	LEFT JOIN dbo.DimLocation l ON ch.Location = l.LocationKey
	LEFT JOIN dbo.DimCalendarFiscal cf ON cf.DateKey = CAST(ch.CREATE_DATE AS DATE)
	LEFT JOIN dbo.DimMachine m ON 'L' + ch.MACHINE_NUM + '_' + ch.MACHINE_SIZE = m.MachineKey AND ch.Location = m.LocationKey
WHERE --ch.PRODUCT_NUMBER = '856900' 
	--CAST(ch.CREATE_DATE AS DATE) >= '2022-05-29' --AND DATE_SAVED < '2019-01-01'
	ch.CurrentRecord = 1
	--AND CAST(ch.TEST_NUMBER AS VARCHAR(7)) + '.' + CAST(cd.CHECK_NUMBER AS VARCHAR(2)) = '199522.1'
GO
