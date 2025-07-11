USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimRepair]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_DimRepair] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	MERGE dbo.DimRepair target
	USING dbo.DimRepair source
	ON	ISNULL(source.RepairKey,'') = ISNULL(target.RepairKey,'')
	WHEN MATCHED AND (
  		source.RepairName				<> target.RepairName
		OR source.RepairDesc			<> target.RepairDesc
		OR ISNULL(source.RepairSort,'')	<> ISNULL(target.RepairSort,'')
		OR source.Scrap					<> target.Scrap
		OR source.Repair				<> target.Repair
	) THEN
	UPDATE 
	SET 
  		 RepairName	= source.RepairName
		,RepairDesc	= source.RepairDesc
		,RepairSort	= source.RepairSort
		,Scrap		= source.Scrap
		,Repair		= source.Repair
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
	     RepairKey
		,RepairName
		,RepairDesc
		,RepairSort
		,Scrap
		,Repair
    )
	VALUES (
	     RepairKey
		,RepairName
		,RepairDesc
		,RepairSort
		,Scrap
		,Repair
	);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

/*
	SELECT * FROM Dim.Repair source		
		LEFT JOIN dbo.DimRepair target 
	ON  source.RepairKey			= target.RepairKey
	WHERE
  		source.RepairName				<> target.RepairName
		OR source.RepairDesc			<> target.RepairDesc
		OR ISNULL(source.RepairSort,'')	<> ISNULL(target.RepairSort,'')
		OR source.Scrap					<> target.Scrap
		OR source.Repair				<> target.Repair
*/

END


GO
