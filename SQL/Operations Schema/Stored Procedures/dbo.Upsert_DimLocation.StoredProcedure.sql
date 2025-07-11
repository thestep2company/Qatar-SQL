USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimLocation]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Upsert_DimLocation] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	MERGE dbo.DimLocation target
	USING Dim.Location source
	ON source.LocationKey = target.LocationKey
	WHEN MATCHED AND (
  		   source.[LocationName]				<> target.[LocationName]
		OR source.[LocationDesc]				<> target.[LocationDesc]
		OR source.[Sort]						<> target.[Sort]
		OR source.[LocationType]				<> target.[LocationType]
		OR source.[LocationCountry]				<> target.[LocationCountry]
		OR ISNULL(source.[ShiftScalar],0)		<> ISNULL(target.[ShiftScalar],0)
		OR ISNULL(source.[GLLocationID],0)		<> ISNULL(target.[GLLocationID],0)
		OR ISNULL(source.[WarehouseCapacity],0)	<> ISNULL(target.[WarehouseCapacity],0)
		OR ISNULL(source.[PhysicalLocation],'') <> ISNULL(target.[PhysicalLocation],'')
		OR ISNULL(source.[PlanID],0)			<> ISNULL(target.[PlanID],0)
		OR ISNULL(source.[COGSLocationID],0)	<> ISNULL(target.[COGSLocationID],0)
	) THEN
	UPDATE 
	SET 
		  [LocationName]		= source.[LocationName]
		, [LocationDesc]		= source.[LocationDesc]
		, [Sort]				= source.[Sort]
		, [LocationType]		= source.[LocationType]
		, [LocationCountry]		= source.[LocationCountry]
		, [ShiftScalar]			= source.[ShiftScalar]
		, [GLLocationID]		= source.[GLLocationID]
		, [WarehouseCapacity]	= source.[WarehouseCapacity]
		, [PhysicalLocation]	= source.[PhysicalLocation]
		, [PlanID]				= source.[PlanID]
		, [COGSLocationID]				= source.[COGSLocationID]
	WHEN NOT MATCHED BY TARGET THEN
	INSERT
		( 
	      [LocationKey]
		, [LocationName]		
		, [LocationDesc]		
		, [Sort]		
		, [LocationType]	
		, [LocationCountry]	
		, [ShiftScalar]	
		, [GLLocationID]		
		, [WarehouseCapacity]
		, [PhysicalLocation]
		, [PlanID]
		, [COGSLocationID]
        )
	VALUES
        ( [LocationKey]
		, [LocationName]
		, [LocationDesc]
		, [Sort]
		, [LocationType]
		, [LocationCountry]
		, [ShiftScalar]
		, [GLLocationID]
		, [WarehouseCapacity]
		, [PhysicalLocation]
		, [PlanID]
		, [COGSLocationID]
	);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

/*
	SELECT * FROM Dim.Location l1
		LEFT JOIN dbo.DimLocation l2 ON l1.LocationKey = l2.LocationKey
	WHERE --compare all fields or push a fingerprint?...
		   l1.[LocationName]		<> l2.[LocationName]		
		OR l1.[LocationDesc]		<> l2.[LocationDesc]		
		OR l1.[Sort]				<> l2.[Sort]		
		OR l1.[LocationType]		<> l2.[LocationType]	
		OR l1.[LocationCountry]		<> l2.[LocationCountry]	
		OR l1.[ShiftScalar]			<> l2.[ShiftScalar]	
		OR l1.[GLLocationID]		<> l2.[GLLocationID]		
		OR l1.[WarehouseCapacity]	<> l2.[WarehouseCapacity]	
		OR ISNULL(l1.[PhysicalLocation],'') <> ISNULL(l2.[PhysicalLocation],'')
		OR ISNULL(l1.[PlanID],0)	<> ISNULL(l2.[PlanID],0)
		OR ISNULL(l1.[COGSLocationID],0) <> ISNULL(l2.[COGSLocationID],0)
*/

END
GO
