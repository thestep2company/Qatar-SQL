USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Update_DimHourCurrent]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Update_DimHourCurrent] AS BEGIN

UPDATE dbo.DimHour
SET [CurrentHourtoDate] = CASE WHEN HourID <= DATEPART(Hour,GETDATE()) THEN 1 ELSE 0 END 

END
GO
