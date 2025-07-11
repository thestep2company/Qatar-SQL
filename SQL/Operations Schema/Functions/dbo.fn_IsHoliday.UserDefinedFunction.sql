USE [Operations]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_IsHoliday]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_IsHoliday]
	(@test_date AS date)
RETURNS bit
AS BEGIN

	DECLARE @retval BIT = 0

	declare @ref_date date
	declare @ref_date_dow int

	SELECT  @ref_date = CASE MONTH(@test_date)
						  WHEN 1 THEN '1/1/' + CAST(YEAR(@test_date) AS VARCHAR)
						  WHEN 2 THEN '2/1/' + CAST(YEAR(@test_date) AS VARCHAR)
						  WHEN 5 THEN '5/31/' + CAST(YEAR(@test_date) AS VARCHAR)
						  WHEN 7 THEN '7/4/' + CAST(YEAR(@test_date) AS VARCHAR)
						  WHEN 9 THEN '9/1/' + CAST(YEAR(@test_date) AS VARCHAR)
						  WHEN 10 THEN '10/1/' + CAST(YEAR(@test_date) AS VARCHAR)
						  WHEN 11 THEN '11/1/' + CAST(YEAR(@test_date) AS VARCHAR)
						  WHEN 12 THEN '12/25/' + CAST(YEAR(@test_date) AS VARCHAR)
						END

	IF @ref_date IS NOT NULL
	begin
		SET @ref_date_dow = datepart(dw, @ref_date)

		IF @test_date IN (
			SELECT dateadd(d, CASE @ref_date_dow when 1 then 1 else 0 end, @ref_date) WHERE MONTH(@test_date) = 1 union --New Year's Day  1/1/yyyy (if sunday then monday)
			SELECT DATEADD(d, (9-@ref_date_dow)+case when @ref_date_dow in (1,2) then 7 else 14 end  ,@ref_date) WHERE MONTH(@test_date) = 1 UNION	 --Martin Luther King, Jr. Day  3rd Monday in January
			SELECT dateadd(d, (9-@ref_date_dow)+case when @ref_date_dow in (1,2) then 7 else 14 end  ,@ref_date) WHERE MONTH(@test_date) = 2 UNION	--Presidents' Day  3rd Monday in February
			SELECT dateadd(d, case when @ref_date_dow = 1 then -6 else 2-@ref_date_dow end,@ref_date) WHERE MONTH(@test_date) = 5 UNION	--Memorial Day  Last Monday in May
			SELECT dateadd(d, CASE @ref_date_dow when 1 then 1 else 0 end, @ref_date) WHERE MONTH(@test_date) = 7 UNION	--Independence Day  7/4/yyyy (if sunday then monday)
			SELECT dateadd(d, (9-@ref_date_dow)+case when @ref_date_dow in (1,2) then -7 else 0 end  ,@ref_date) WHERE MONTH(@test_date) = 9 UNION	--Labor Day  1st Monday in Sept
			SELECT dateadd(d, (9-@ref_date_dow)+case when @ref_date_dow in (1,2) then 0 else 7 end, @ref_date) WHERE MONTH(@test_date) = 10 UNION	--Columbus Day 2nd Monday in Oct
			SELECT dateadd(d, CASE DATEPART(dw,DATEADD(d,10,@ref_date)) when 1 then 1 else 0 end, DATEADD(d,10,@ref_date)) WHERE MONTH(@test_date) = 11 UNION	--Veterans' Day  11/11 (if sunday then monday)
			SELECT dateadd(d, (5-@ref_date_dow) + case when @ref_date_dow <=5 then 21 else 28 end, @ref_date) WHERE MONTH(@test_date) = 11 UNION	--Thanksgiving Day  4th Thursday in November
			SELECT dateadd(d, CASE @ref_date_dow when 1 then 1 else 0 end, @ref_date) WHERE MONTH(@test_date) = 12 	--Christmas Day  12/25  (if sunday then monday)

		) 
			SET @retval = 1
	END

	RETURN @retval

END
GO
