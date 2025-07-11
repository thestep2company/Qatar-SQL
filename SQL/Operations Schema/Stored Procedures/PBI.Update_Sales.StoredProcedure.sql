USE [Operations]
GO
/****** Object:  StoredProcedure [PBI].[Update_Sales]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [PBI].[Update_Sales] AS BEGIN

	DECLARE @monthStart DATE, @monthEnd DATE, @rolling3Day DATE, @startDate DATE, @today DATE

	SET @today = GETDATE()
	SET @rolling3Day = DATEADD(DAY,-35,GETDATE())

	;WITH MonthStart AS (SELECT [Month Sort] FROM dbo.DimCalendarFiscal cf WHERE DateKey = @today)
	SELECT @monthStart = MIN(DateKey) FROM dbo.DimCalendarFiscal cf
		INNER JOIN MonthStart ms ON cf.[Month Sort] = ms.[Month Sort] 

	;WITH MonthEnd AS (SELECT [Month Sort] FROM dbo.DimCalendarFiscal cf WHERE DateKey = @rolling3Day)
	SELECT @monthEnd = MIN(DateKey) FROM dbo.DimCalendarFiscal cf
		INNER JOIN MonthEnd me ON cf.[Month Sort] = me.[Month Sort]

	SELECT @monthStart, @monthEnd

	--run 3 day lookback except for first coupld days of close.  Back dating of records needs to comb the full month to post to PBI.
	IF @monthStart < @monthEnd	
		SET @startDate = @monthStart 
	ELSE 
		SET @startDate = @rolling3Day

	DELETE FROM dbo.FactUnitPrice WHERE LastGLDate >= @startDate
	INSERT INTO dbo.FactUnitPrice SELECT *  FROM [Fact].[UnitPrice] WHERE LastGLDate >= @startDate

	DELETE FROM dbo.FactPBISales  WHERE DateKey >= @startDate
	INSERT INTO dbo.FactPBISales SELECT *  FROM Fact.PBISales WHERE DateKey >= @startDate

	UPDATE s SET s.GeographyID = g2.ID
	FROM dbo.FactPBISales s
		LEFT JOIN Oracle.Geography g ON s.GeographyID = g.ID 
		LEFT JOIN ORacle.Geography g2 ON g.PostalCode = g2.PostalCode AND g.Country = g2.Country AND g2.CurrentRecord = 1
	WHERE g.CurrentRecord = 0

	--GRID
	EXEC [FPA].[Merge_StandardMarginPBI] @startDate

END
GO
