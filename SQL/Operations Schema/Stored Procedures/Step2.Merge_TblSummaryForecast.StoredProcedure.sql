USE [Operations]
GO
/****** Object:  StoredProcedure [Step2].[Merge_TblSummaryForecast]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Step2].[Merge_TblSummaryForecast]
AS BEGIN

	DROP TABLE IF EXISTS #TblSummaryForecast

	CREATE TABLE #SummaryForecast(
		[ID] [int] NOT NULL,
		[Year] [int] NULL,
		[Type] [varchar](2) NULL,
		[Customer] [varchar](8) NULL,
		[Part] [varchar](25) NULL,
		[Month] [int] NULL,
		[Week] [int] NULL,
		[Quantity] [int] NULL,
		[Dollars] [money] NULL,
		[Price] [money] NULL,
		[Buyer] [varchar](50) NULL,
		[Stores] [varchar](50) NULL,
		[UserAdded] [varchar](50) NULL,
		[DateAdded] [datetime] NOT NULL,
		[UserMod] [varchar](50) NULL,
		[DateMod] [datetime] NOT NULL
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

	INSERT INTO #SummaryForecast
	SELECT *
	FROM OPENQUERY(Step2sql,'
	  SELECT *
	  FROM [Step2Forecasting].[dbo].[tblSummaryForecast]
	  WHERE Year >= 2024
		--and (DateAdded > GETDATE() - 7 OR DateMod > GETDATE() - 7)
	')

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

	DELETE FROM t
	FROM Step2.tblSummaryForecast t 
		LEFT JOIN #SummaryForecast s ON s.ID = t.ID
	WHERE s.ID IS NULL

	INSERT INTO Step2.tblSummaryForecast
	SELECT s.*, GETDATE() AS StartDate 
	FROM #SummaryForecast s
		LEFT JOIN Step2.tblSummaryForecast t ON s.ID = t.ID
	WHERE t.ID IS NULL

	UPDATE t 
	SET t.Year = s.Year
		,t.Type = s.Type
		,t.Customer = s.Customer
		,t.Part = s.Part
		,t.Month = s.Month
		,t.Week = s.Week
		,t.Quantity = s.Quantity
		,t.Dollars = s.Dollars
		,t.Price = s.Price
		,t.Buyer = s.Buyer
		,t.Stores = s.Stores
		,t.UserAdded = s.UserAdded
		,t.DateAdded = s.DateAdded
		,t.UserMod = s.UserMod
		,t.DateMod = s.DateMod
	FROM Step2.tblSummaryForecast t
		INNER JOIN #SummaryForecast s ON s.ID = t.ID
	WHERE t.Quantity <> s.Quantity
		--OR t.DateMod <> s.DateMod

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END
GO
