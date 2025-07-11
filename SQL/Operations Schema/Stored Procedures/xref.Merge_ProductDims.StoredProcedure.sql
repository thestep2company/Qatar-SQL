USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Merge_ProductDims]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [xref].[Merge_ProductDims] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

	--new records
	INSERT INTO xref.ProductDims
	SELECT  
	   source.ProductKey
      ,source.Height
      ,source.Width
      ,source.Depth
      ,source.Size
	FROM XREF.dbo.ProductDims source
		LEFT JOIN xref.ProductDims target ON source.ProductKey = target.ProductKey
	WHERE target.ProductKey IS NULL --AND target.ProductKey = '854899'

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Update', GETDATE()

	--update existing
	UPDATE target
	SET 
		 Height = source.Height
		,Width =  source.Width
		,Depth =  source.Depth
		,[Size] =   source.Size
	--SELECT *
	FROM XREF.dbo.ProductDims source
		INNER JOIN xref.ProductDims target ON source.ProductKey = target.ProductKey
	WHERE (source.Height <> target.Height
		OR source.Width  <> target.Width
		OR source.Depth  <> target.Depth
		OR ISNULL(source.Size,'')   <> ISNULL(target.[Size],'')
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END

GO
