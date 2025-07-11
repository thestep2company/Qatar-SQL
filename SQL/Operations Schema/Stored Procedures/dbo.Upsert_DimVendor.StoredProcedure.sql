USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimVendor]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_DimVendor] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
	MERGE dbo.DimVendor target
	USING Dim.Vendor source
	ON source.VendorKey = target.VendorKey
	WHEN MATCHED AND (
  		ISNULL(source.VendorName,'') <> ISNULL(target.VendorName,'')
		OR ISNULL(source.VendorDesc,'')	<> ISNULL(target.VendorDesc,'')
		OR ISNULL(source.VendorType,'')	<> ISNULL(target.VendorType,'')
	) THEN -- Only update if we have a new max size for today
	UPDATE 
	SET 
  		  VendorName = source.VendorName
		, VendorDesc = source.VendorDesc
		, VendorType = source.VendorType
	WHEN NOT MATCHED BY TARGET THEN -- Otherwise insert the new size
	INSERT
		(VendorKey
		,VendorName
		,VendorDesc
		,VendorType
        )
	VALUES
        (VendorKey
		,VendorName
		,VendorDesc
		,VendorType
	);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
/*
	SELECT * FROM Dim.Vendor v1
		LEFT JOIN dbo.DimVendor v2 ON v1.VendorKey = v2.VendorKey
	WHERE --compare all fields or push a fingerprint?...
		dc1.VendorName <> dc2.VendorName
		OR dc1.VendorDesc <> dc2.VendorDesc
*/

END
GO
