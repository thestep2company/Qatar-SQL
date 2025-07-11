USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimRepairReason]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Upsert_DimRepairReason] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
	MERGE dbo.DimRepairReason target
	USING dbo.DimRepairReason source
	ON	ISNULL(source.RepairReasonKey,'') = ISNULL(target.RepairReasonKey,'')
		AND ISNULL(source.OrgCode,'') = ISNULL(target.OrgCode,'')
	WHEN MATCHED AND (
  		source.RepairReasonName				<> target.RepairReasonName
		OR source.RepairReasonDesc			<> target.RepairReasonDesc
		OR ISNULL(source.RepairReasonSort,'')	<> ISNULL(target.RepairReasonSort,'')
	) THEN
	UPDATE 
	SET 
  		 RepairReasonName	= source.RepairReasonName
		,RepairReasonDesc	= source.RepairReasonDesc
		,RepairReasonSort	= source.RepairReasonSort
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
		 OrgCode
	    ,RepairReasonKey
		,RepairReasonName
		,RepairReasonDesc
		,RepairReasonSort
    )
	VALUES (
	     OrgCode
	    ,RepairReasonKey
		,RepairReasonName
		,RepairReasonDesc
		,RepairReasonSort
	);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

/*
	SELECT * FROM Dim.RepairReason source		
		LEFT JOIN dbo.DimRepairReason target 
	ON  source.RepairReasonKey			= target.RepairReasonKey
		AND ISNULL(source.OrgCode,'') = ISNULL(target.OrgCode,'')
	WHERE
  		source.RepairReasonName				<> target.RepairReasonName
		OR source.RepairReasonDesc			<> target.RepairReasonDesc
		OR ISNULL(source.RepairReasonSort,'')	<> ISNULL(target.RepairReasonSort,'')
*/

END


GO
