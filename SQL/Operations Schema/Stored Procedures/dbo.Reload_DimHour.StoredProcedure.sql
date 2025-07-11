USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimHour]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/

CREATE PROCEDURE [dbo].[Reload_DimHour] AS BEGIN

	SELECT [HourID]
		  ,[HourName]
		  ,[HourDesc]
		  ,[HourSort]
		  ,[HourBlock]
		  ,[HourBlockSort]
		  ,[ShiftBlock12Hour]
		  ,[ShiftBlock8Hour]
		  ,[CurrentHourtoDate]
	INTO dbo.DimHour
	FROM Dim.[Hour]

END
GO
