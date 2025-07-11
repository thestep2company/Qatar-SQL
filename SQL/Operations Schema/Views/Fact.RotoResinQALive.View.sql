USE [Operations]
GO
/****** Object:  View [Fact].[RotoResinQALive]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Fact].[RotoResinQALive] AS
SELECT INDEX_ID AS SampleID
	,DateID
	,DATEPART(HOUR,Date) AS HourID
	,ShiftID
	,pm1.ProductID AS ComponentID
	,pm2.ProductID AS ProductID
	,LocationID 
	,m.MachineID
	,qa.Component_Quantity AS BOM_Resin
	,qa.Actual_Component_Quantity AS Actual_Resin
	,qa.Actual_Component_Quantity-qa.Component_Quantity AS Variance_Resin
	,FORMAT(FLOOR((qa.Actual_Component_Quantity-qa.Component_Quantity)*20)*.05, '##0.00;(##0.00)') 
	+'-'+FORMAT((FLOOR((qa.Actual_Component_Quantity-qa.Component_Quantity)*20)+1)*.05, '##0.00;(##0.00)') AS Variance_Bucket
	,FLOOR((qa.Actual_Component_Quantity-qa.Component_Quantity)*20)*.05 AS Varaince_Bucket_Sort
	,CASE WHEN qa.ACTUAL_COMPONENT_QUANTITY <> 0 THEN (qa.Actual_Component_Quantity-qa.Component_Quantity)/qa.Actual_Component_Quantity ELSE 1 END AS Percent_Resin
	,FORMAT(FLOOR(CASE WHEN qa.ACTUAL_COMPONENT_QUANTITY <> 0 THEN (qa.Actual_Component_Quantity-qa.Component_Quantity)/qa.Actual_Component_Quantity ELSE 0 END*100)/100,'##0.00%;(##0.00%)')
	+'-'+FORMAT((FLOOR(CASE WHEN qa.ACTUAL_COMPONENT_QUANTITY <> 0 THEN (qa.Actual_Component_Quantity-qa.Component_Quantity)/qa.Actual_Component_Quantity ELSE 0 END*100)+1)/100,'##0.00%;(##0.00%)') AS Percent_Bucket
	,FLOOR(CASE WHEN qa.ACTUAL_COMPONENT_QUANTITY <> 0 THEN (qa.Actual_Component_Quantity-qa.Component_Quantity)/qa.Actual_Component_Quantity ELSE 0 END*100)/100 AS Percent_Bucket_Sort
	,u.UserID
	,qa.COMMENTS
	,d1.BucketID AS VarianceBucketID
	,d2.BucketID AS PercentBucketID
	--,'L' + LEFT(Machine,2) + '_' + SUBSTRING(Machine,6,3) AS MachineKey
FROM QA.[QUALITY_ROTO_RESIN_WEIGHTS] qa
	LEFT JOIN dbo.DimCalendarFiscal c ON CAST(Date AS DATE) = c.DateKey
	LEFT JOIN dbo.DimShift s ON qa.Shift = s.ShiftKey
	LEFT JOIN dbo.DimProductMaster pm1 ON pm1.ProductKey = qa.Assembly_Item
	LEFT JOIN dbo.DimProductMaster pm2 ON pm2.ProductKey = qa.Product_Number
	LEFT JOIN dbo.DimLocation l ON l.LocationKey = qa.[LOCATION_CODE]
	LEFT JOIN dbo.DimMachine m ON m.MachineKey = 'L' + LEFT(Machine,2) + '_' + SUBSTRING(Machine,6,3) AND m.LocationKey = l.LocationKey
	LEFT JOIN Dim.[User] u ON qa.USER_NAME = u.LastName + ', ' + u.FirstName
	LEFT JOIN dbo.DimDistribution d1 ON FLOOR((qa.Actual_Component_Quantity-qa.Component_Quantity)*20)*.05 = d1.BucketKey
	LEFT JOIN dbo.DimDistribution d2 ON FLOOR(CASE WHEN qa.ACTUAL_COMPONENT_QUANTITY <> 0 THEN (qa.Actual_Component_Quantity-qa.Component_Quantity)/qa.Actual_Component_Quantity ELSE 0 END*100)/100 = d2.BucketKey
  WHERE qa.CurrentRecord = 1 
  	AND c.DateKey  >=
			(
		SELECT MIN(DateKey) AS DateKey
			FROM Dim.M2MTimeSeries m2m
			LEFT JOIN Dim.TimeSeries ts ON m2m.TimeSeriesID = ts.TimeSeriesID
			LEFT JOIN dbo.DimCalendarFiscal cf ON m2m.DateID = cf.DateID
		WHERE ts.TimeSeriesKey = 'T4W'
		)
	--AND PRODUCT_NUMBER = '854699'
	--AND [DATE] >= '2022-05-01'
GO
