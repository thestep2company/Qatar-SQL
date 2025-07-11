USE [Operations]
GO
/****** Object:  View [Fact].[Royalty]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Fact].[Royalty] AS
SELECT a.[4 Digit]
    ,cf.[Month Sort]
	,a.[Royalty License %]
FROM [xref].[Royalty] a
	LEFT JOIN dbo.DimCalendarFiscal cf ON a.Year = cf.Year
GROUP BY a.[4 Digit]
    ,cf.[Month Sort]
	,a.[Royalty License %]
GO
