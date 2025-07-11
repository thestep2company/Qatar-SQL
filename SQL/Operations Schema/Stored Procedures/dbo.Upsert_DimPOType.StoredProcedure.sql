USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimPOType]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_DimPOType] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
	MERGE dbo.DimPOType target
	USING Dim.POType source
	ON ISNULL(source.PO_Type,'') = ISNULL(target.PO_Type,'')
	WHEN NOT MATCHED BY TARGET THEN
	INSERT ( PO_Type )
	VALUES ( PO_Type );

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END
GO
