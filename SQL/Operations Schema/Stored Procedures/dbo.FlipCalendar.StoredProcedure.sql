USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[FlipCalendar]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FlipCalendar] AS BEGIN

	--DECLARE @monthID INT
	--SELECT @monthID=MonthID FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(GETDATE() AS DATE)

	--UPDATE dbo.DimCalendarFiscal SET CurrentMonthID = MonthID WHERE MonthID = @monthID
	--UPDATE dbo.DimCalendarFiscal SET CurrentMonthID = NULL WHERE MonthID <> @monthID

	;WITH CTE AS (
		SELECT MonthID FROM dbo.DimCalendarFiscal WHERE dateKey = CAST(GETDATE() AS DATE)
	)
	UPDATE cf 
	SET CurrentMonthID = cte.MonthID 
	FROM dbo.DimCalendarFiscal cf
		LEFT JOIN CTE ON cte.MonthID = cf.MonthID

  	;WITH CTE AS (
		SELECT WeekID FROM dbo.DimCalendarFiscal WHERE dateKey = CAST(GETDATE() AS DATE)
	)
	UPDATE cf 
	SET CurrentWeekID = cte.WeekID 
	FROM dbo.DimCalendarFiscal cf
		LEFT JOIN CTE ON cte.WeekID = cf.WeekID

	UPDATE dbo.DimCalendarFiscal SET CurrentYear = 'Current Year' WHERE Year = YEAR(GETDATE())
	UPDATE dbo.DimCalendarFiscal SET Future = CASE WHEN DateKey > GETDATE() THEN 'Future' END
	UPDATE dbo.DimCalendarFiscal SET History = CASE WHEN DateKey < CAST(GETDATE() AS DATE) THEN 'History' END

END
GO
