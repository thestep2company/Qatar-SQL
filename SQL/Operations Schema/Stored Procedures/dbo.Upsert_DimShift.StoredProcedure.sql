USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimShift]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_DimShift] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	MERGE dbo.DimShift target
	USING dbo.DimShift source
	ON	ISNULL(source.ShiftKey,'') = ISNULL(target.ShiftKey,'')
	WHEN MATCHED AND (
  		source.ShiftName				<> target.ShiftName
		OR source.ShiftDesc			<> target.ShiftDesc
		OR ISNULL(source.ShiftSort,'')	<> ISNULL(target.ShiftSort,'')
	) THEN
	UPDATE 
	SET 
  		 ShiftName	= source.ShiftName
		,ShiftDesc	= source.ShiftDesc
		,ShiftSort	= source.ShiftSort
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
	     ShiftKey
		,ShiftName
		,ShiftDesc
		,ShiftSort
    )
	VALUES (
	     ShiftKey
		,ShiftName
		,ShiftDesc
		,ShiftSort
	);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

/*
	SELECT * FROM Dim.Shift source		
		LEFT JOIN dbo.DimShift target 
	ON  source.ShiftKey			= target.ShiftKey
	WHERE
  		source.ShiftName				<> target.ShiftName
		OR source.ShiftDesc			<> target.ShiftDesc
		OR ISNULL(source.ShiftSort,'')	<> ISNULL(target.ShiftSort,'')
*/

END


GO
