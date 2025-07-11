USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimPayCode]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_DimPayCode] 
AS BEGIN

	INSERT INTO dbo.DimPayCode ([PaycodeCategory],[PayCode Name])
	SELECT s.[PaycodeCategory],s.[PayCode Name]
	FROM Dim.PayCode s 
		LEFT JOIN dbo.DimPayCode t
	ON s.[PayCode Name] = t.[PayCode Name]
	WHERE t.[PayCode Name] IS NULL

	UPDATE t
	SET t.[PayCodeCategory] = s.[PayCodeCategory]
	FROM Dim.PayCode s 
		LEFT JOIN dbo.DimPayCode t
	ON s.[PayCode Name] = t.[PayCode Name]
	WHERE ISNULL(s.[PayCodeCategory],'') <> ISNULL(t.[PaycodeCategory],'')
		
END
GO
