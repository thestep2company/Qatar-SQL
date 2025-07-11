USE [Operations]
GO
/****** Object:  View [Dim].[Hour]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Dim].[Hour] WITH SCHEMABINDING AS 
	SELECT  0 AS HourID, '12am' AS HourName, '12:00am-12:59am' AS HourDesc, '00' AS HourSort, '12am-2am'  AS HourBlock, '00' AS HourBlockSort, 4 AS ShiftBlock12Hour, 2 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT  1 AS HourID,  '1am' AS HourName,  '1:00am-1:59am'  AS HourDesc, '01' AS HourSort, '12am-2am'  AS HourBlock, '00' AS HourBlockSort, 4 AS ShiftBlock12Hour, 2 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT  2 AS HourID,  '2am' AS HourName,  '2:00am-2:59am'  AS HourDesc, '02' AS HourSort,  '2am-4am'  AS HourBlock, '02' AS HourBlockSort, 5 AS ShiftBlock12Hour, 3 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT  3 AS HourID,  '3am' AS HourName,  '3:00am-3:59am'  AS HourDesc, '03' AS HourSort,  '2am-4am'  AS HourBlock, '02' AS HourBlockSort, 5 AS ShiftBlock12Hour, 3 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT  4 AS HourID,  '4am' AS HourName,  '4:00am-4:59am'  AS HourDesc, '04' AS HourSort,  '4am-6am'  AS HourBlock, '04' AS HourBlockSort, 6 AS ShiftBlock12Hour, 4 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT  5 AS HourID,  '5am' AS HourName,  '5:00am-5:59am'  AS HourDesc, '05' AS HourSort,  '4am-6am'  AS HourBlock, '04' AS HourBlockSort, 6 AS ShiftBlock12Hour, 4 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT  6 AS HourID,  '6am' AS HourName,  '6:00am-6:59am'  AS HourDesc, '06' AS HourSort,  '6am-8am'  AS HourBlock, '06' AS HourBlockSort, 1 AS ShiftBlock12Hour, 1 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT  7 AS HourID,  '7am' AS HourName,  '7:00am-7:59am'  AS HourDesc, '07' AS HourSort,  '6am-8am'  AS HourBlock, '06' AS HourBlockSort, 1 AS ShiftBlock12Hour, 1 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT  8 AS HourID,  '8am' AS HourName,  '8:00am-8:59am'  AS HourDesc, '08' AS HourSort, '8am-10am'  AS HourBlock, '08' AS HourBlockSort, 2 AS ShiftBlock12Hour, 2 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT  9 AS HourID,  '9am' AS HourName,  '9:00am-9:59am'  AS HourDesc, '09' AS HourSort, '8am-10am'  AS HourBlock, '08' AS HourBlockSort, 2 AS ShiftBlock12Hour, 2 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 10 AS HourID, '10am' AS HourName, '10:00am-10:59am' AS HourDesc, '10' AS HourSort, '10am-12pm' AS HourBlock, '10' AS HourBlockSort, 3 AS ShiftBlock12Hour, 3 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 11 AS HourID, '11am' AS HourName, '11:00am-11:59am' AS HourDesc, '11' AS HourSort, '10am-12pm' AS HourBlock, '10' AS HourBlockSort, 3 AS ShiftBlock12Hour, 3 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 12 AS HourID, '12pm' AS HourName, '12:00pm-12:59pm' AS HourDesc, '12' AS HourSort, '12pm-2pm'  AS HourBlock, '12' AS HourBlockSort, 4 AS ShiftBlock12Hour, 4 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 13 AS HourID,  '1pm' AS HourName,  '1:00pm-1:59pm'  AS HourDesc, '13' AS HourSort, '12pm-2pm'  AS HourBlock, '12' AS HourBlockSort, 4 AS ShiftBlock12Hour, 4 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 14 AS HourID,  '2pm' AS HourName,  '2:00pm-2:59pm'  AS HourDesc, '14' AS HourSort,  '2pm-4pm'  AS HourBlock, '14' AS HourBlockSort, 5 AS ShiftBlock12Hour, 1 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 15 AS HourID,  '3pm' AS HourName,  '3:00pm-3:59pm'  AS HourDesc, '15' AS HourSort,  '2pm-4pm'  AS HourBlock, '14' AS HourBlockSort, 5 AS ShiftBlock12Hour, 1 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 16 AS HourID,  '4pm' AS HourName,  '4:00pm-4:59pm'  AS HourDesc, '16' AS HourSort,  '4pm-6pm'  AS HourBlock, '16' AS HourBlockSort, 6 AS ShiftBlock12Hour, 2 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 17 AS HourID,  '5pm' AS HourName,  '5:00pm-5:59pm'  AS HourDesc, '17' AS HourSort,  '4pm-6pm'  AS HourBlock, '16' AS HourBlockSort, 6 AS ShiftBlock12Hour, 2 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 18 AS HourID,  '6pm' AS HourName,  '6:00pm-6:59pm'  AS HourDesc, '18' AS HourSort,  '6pm-8pm'  AS HourBlock, '18' AS HourBlockSort, 1 AS ShiftBlock12Hour, 3 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 19 AS HourID,  '7pm' AS HourName,  '7:00pm-7:59pm'  AS HourDesc, '19' AS HourSort,  '6pm-8pm'  AS HourBlock, '18' AS HourBlockSort, 1 AS ShiftBlock12Hour, 3 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 20 AS HourID,  '8pm' AS HourName,  '8:00pm-8:59pm'  AS HourDesc, '20' AS HourSort, '8pm-10pm'  AS HourBlock, '20' AS HourBlockSort, 2 AS ShiftBlock12Hour, 4 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 21 AS HourID,  '9pm' AS HourName,  '9:00pm-9:59pm'  AS HourDesc, '21' AS HourSort, '8pm-10pm'  AS HourBlock, '20' AS HourBlockSort, 2 AS ShiftBlock12Hour, 4 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 22 AS HourID, '10pm' AS HourName, '10:00pm-10:59pm' AS HourDesc, '22' AS HourSort, '10pm-12am' AS HourBlock, '22' AS HourBlockSort, 3 AS ShiftBlock12Hour, 1 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate UNION
	SELECT 23 AS HourID, '11pm' AS HourName, '11:00pm-11:59pm' AS HourDesc, '23' AS HourSort, '10pm-12am' AS HourBlock, '22' AS HourBlockSort, 3 AS ShiftBlock12Hour, 1 AS ShiftBlock8Hour, 0 AS CurrentHourtoDate 
GO
