USE [Operations]
GO
/****** Object:  StoredProcedure [Step2].[Merge_CustomerForecastInventory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [Step2].[Merge_CustomerForecastInventory] 
 AS BEGIN

	UPDATE Step2.CustomerForecastInventory SET CurrentRecord = 0 WHERE CurrentRecord = 1

	INSERT INTO Step2.CustomerForecastInventory (PartID, DemandClass, ForecastPercentage, CreateDate, CheckSum)
	SELECT PartID
		,DemandClass
		,ForecastPercentage
		,CreateDate
		,SUM(ForecastPercentage) OVER (PARTITION BY PartID) AS CheckSum
	FROM DIEHARD.WinEDI.dbo.CustomerForecastInventory
	WHERE CreateDate >= DATEADD(HOUR,-12,GETDATE())
	AND Description LIKE '%COMBO%'
  
END
GO
