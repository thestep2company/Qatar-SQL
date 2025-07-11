USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimPOCode]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_DimPOCode] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
	MERGE dbo.DimPOCode target
	USING Dim.POCode source
	ON ISNULL(source.PO_Code,'') = ISNULL(target.PO_Code,'')
	WHEN NOT MATCHED BY TARGET THEN
	INSERT ( PO_Code )
	VALUES ( PO_Code );

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END
GO
