USE [Operations]
GO
/****** Object:  View [Dim].[Aging]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[Aging] AS
SELECT 0 AS AgeID, -99999 Floor, 30 AS Ceiling, '0-30' AS Bucket, 10 AS Sort UNION
SELECT 1 AS AgeID, 31 Floor, 60 AS Ceiling, '31-60' AS Bucket, 11 AS Sort UNION
SELECT 2 AS AgeID, 61 Floor, 90 AS Ceiling, '61-90' AS Bucket, 12 AS Sort UNION
SELECT 3 AS AgeID, 91 Floor, 120 AS Ceiling, '91-120' AS Bucket, 13 AS Sort UNION
SELECT 4 AS AgeID, 121 Floor, 150 AS Ceiling, '121-150' AS Bucket, 14 AS Sort UNION
SELECT 5 AS AgeID, 151 Floor, 180 AS Ceiling, '151-180' AS Bucket, 15 AS Sort UNION
SELECT 6 AS AgeID, 181 Floor, 270 AS Ceiling, '181-270' AS Bucket, 16 AS Sort UNION
SELECT 7 AS AgeID, 271 Floor, 360 AS Ceiling, '271-360' AS Bucket, 17 AS Sort UNION
SELECT 8 AS AgeID, 361 Floor, 450 AS Ceiling, '361-450' AS Bucket, 18 AS Sort UNION
SELECT 9 AS AgeID, 451 Floor, 540 AS Ceiling, '451-540' AS Bucket, 19 AS Sort UNION
SELECT 10 AS AgeID, 541 Floor, 720 AS Ceiling, '541-720' AS Bucket, 20 AS Sort UNION
SELECT 11 AS AgeID, 721 Floor, 99999 AS Ceiling, '720+' AS Bucket, 21 AS Sort
GO
