USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimLocator]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Upsert_DimLocator] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	MERGE dbo.DimLocator target
	USING Dim.Locator source
	ON source.LocationKey = target.LocationKey AND source.LocatorKey = target.LocatorKey
	WHEN MATCHED AND (
		   ISNULL(source.[LocatorDesc],'')		<> ISNULL(target.[LocatorDesc],'')
		OR ISNULL(source.[LocationType],'')		<> ISNULL(target.[LocationType],'')
		OR ISNULL(source.[PickingOrder],'')		<> ISNULL(target.[PickingOrder],'')
		OR ISNULL(source.[SubInventoryCode],'')	<> ISNULL(target.[SubInventoryCode],'')
		OR ISNULL(source.[Segment1],'')			<> ISNULL(target.[Segment1],'')
		OR ISNULL(source.[Segment2],'')			<> ISNULL(target.[Segment2],'')
		OR ISNULL(source.[Segment3],'')			<> ISNULL(target.[Segment3],'')
	) THEN
	UPDATE 
	SET 
		  [LocatorDesc]			= source.[LocatorDesc]
		, [LocationType]		= source.[LocationType]
		, [PickingOrder]		= source.[PickingOrder]
		, [SubInventoryCode]	= source.[SubInventoryCode]
		, [Segment1]			= source.[Segment1]
		, [Segment2]			= source.[Segment2]
		, [Segment3]			= source.[Segment3]
	WHEN NOT MATCHED BY TARGET THEN
	INSERT
		( 
	  [LocatorKey]
      ,[LocationKey]
      ,[LocatorDesc]
      ,[LocationType]
      ,[PickingOrder]
      ,[SubinventoryCode]
      ,[Segment1]
      ,[Segment2]
      ,[Segment3]
        )
	VALUES
        ([LocatorKey]
      ,[LocationKey]
      ,[LocatorDesc]
      ,[LocationType]
      ,[PickingOrder]
      ,[SubinventoryCode]
      ,[Segment1]
      ,[Segment2]
      ,[Segment3]
	);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

/*
	SELECT * FROM Dim.Locator source
		LEFT JOIN dbo.DimLocator target ON source.LocationKey = target.LocationKey AND source.LocatorKey = target.LocatorKey
	WHERE 
		   ISNULL(source.[LocatorDesc],'')		<> ISNULL(target.[LocatorDesc],'')
		OR ISNULL(source.[LocationType],'')		<> ISNULL(target.[LocationType],'')
		OR ISNULL(source.[PickingOrder],'')		<> ISNULL(target.[PickingOrder],'')
		OR ISNULL(source.[SubInventoryCode],'')	<> ISNULL(target.[SubInventoryCode],'')
		OR ISNULL(source.[Segment1],'')			<> ISNULL(target.[Segment1],'')
		OR ISNULL(source.[Segment2],'')			<> ISNULL(target.[Segment2],'')
		OR ISNULL(source.[Segment3],'')			<> ISNULL(target.[Segment3],'')
*/

END

GO
