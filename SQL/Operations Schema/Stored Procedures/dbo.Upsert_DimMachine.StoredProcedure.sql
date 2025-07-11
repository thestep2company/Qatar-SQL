USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimMachine]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_DimMachine] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	MERGE dbo.DimMachine target
	USING Dim.Machine source
	ON	ISNULL(source.MachineKey,'') = ISNULL(target.MachineKey,'')
		AND ISNULL(source.LocationKey,'') = ISNULL(target.LocationKey,'')
	WHEN MATCHED AND (
  		source.MachineName					<> target.MachineName
		OR source.MachineDesc				<> target.MachineDesc
		OR ISNULL(source.MachineSort,'')	<> ISNULL(target.MachineSort,'')
		OR ISNULL(source.MachineModel,'')	<> ISNULL(target.MachineModel,'')
		OR ISNULL(source.MachineNumber,'')	<> ISNULL(target.MachineNumber,'')
		OR ISNULL(source.MachineCell,0)		<> ISNULL(target.MachineCell,0)
		OR source.CellPosition				<> target.CellPosition
		OR source.RoundsPerShift			<> target.RoundsPerShift
		OR source.CapacityRoundsPerShift	<> target.CapacityRoundsPerShift
	) THEN
	UPDATE 
	SET 
  		 MachineName			= source.MachineName
		,MachineDesc			= source.MachineDesc
		,MachineSort			= source.MachineSort
		,MachineModel			= source.MachineModel
		,MachineNumber			= source.MachineNumber
		,MachineCell			= source.MachineCell
		,CellPosition			= source.CellPosition
		,RoundsPerShift			= source.RoundsPerShift
		,CapacityRoundsPerShift	= source.CapacityRoundsPerShift
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
	       LocationKey
	      ,MachineKey
	      ,MachineName
	      ,MachineDesc
	      ,MachineSort
	      ,MachineModel
	      ,MachineNumber
	      ,MachineCell
	      ,CellPosition
	      ,RoundsPerShift
	      ,CapacityRoundsPerShift
    )
	VALUES (
	       LocationKey
	      ,MachineKey
	      ,MachineName
	      ,MachineDesc
	      ,MachineSort
	      ,MachineModel
	      ,MachineNumber
	      ,MachineCell
	      ,CellPosition
	      ,RoundsPerShift
	      ,CapacityRoundsPerShift
	);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

/*
	SELECT * FROM Dim.Machine source		
		LEFT JOIN dbo.DimMachine target 
	ON  ISNULL(source.LocationKey,'')	= ISNULL(target.LocationKey,'')
		AND source.MachineKey			= target.MachineKey
	WHERE
  		source.MachineName					<> target.MachineName
		OR source.MachineDesc				<> target.MachineDesc
		OR ISNULL(source.MachineSort,'')	<> ISNULL(target.MachineSort,'')
		OR ISNULL(source.MachineModel,'')	<> ISNULL(target.MachineModel,'')
		OR ISNULL(source.MachineNumber,'')	<> ISNULL(target.MachineNumber,'')
		OR ISNULL(source.MachineCell,0)		<> ISNULL(target.MachineCell,0)
		OR source.CellPosition				<> target.CellPosition
		OR source.RoundsPerShift			<> target.RoundsPerShift
		OR source.CapacityRoundsPerShift	<> target.CapacityRoundsPerShift
*/

END


GO
