USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimPOStatus]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_DimPOStatus] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
	MERGE dbo.DimPOStatus target
	USING Dim.POStatus source
	ON ISNULL(source.PO_Status,'') = ISNULL(target.PO_Status,'')
	WHEN NOT MATCHED BY TARGET THEN
	INSERT ( PO_Status )
	VALUES ( PO_Status );

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END
GO
