USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Merge_ProductExtensionData]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [xref].[Merge_ProductExtensionData] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

	--new records
	INSERT INTO xref.ProductExtensionData
	SELECT  
	   source.Product_Key
      ,source.Product_Name
      ,source.Child_Adult
      ,source.Product_Line
      ,source.Product_Group
	  ,source.[Product Name Consolidated]
	FROM XREF.dbo.ProductExtensionData source   --XREF.dbo.ProductExtensionData source
		LEFT JOIN xref.ProductExtensionData target ON source.Product_Key = target.Product_Key
	WHERE target.Product_Key IS NULL

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Update', GETDATE()

	--update existing
	UPDATE target
	SET 
		Product_Name = source.Product_Name
		,Child_Adult = source.Child_Adult
		,Product_Line = source.Product_Line
		,Product_Group = source.Product_Group
		,[Product Name Consolidated] = source.[Product Name Consolidated]
	--SELECT *
	FROM XREF.dbo.ProductExtensionData source --XREF.dbo.ProductExtensionData source
		INNER JOIN xref.ProductExtensionData target ON source.Product_Key = target.Product_Key
	WHERE (source.Product_Name <> target.Product_Name
		OR source.Child_Adult <> target.Child_Adult
		OR source.Product_Line <> target.Product_Line
		OR source.Product_Group <> target.Product_Group
		OR source.[Product Name Consolidated] <> target.[Product Name Consolidated]
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()

	--remove missing records in source
	DELETE FROM target
	--SELECT *
	FROM xref.ProductExtensionData target
		LEFT JOIN XREF.dbo.ProductExtensionData source ON source.Product_Key = target.Product_Key  --XREF.dbo.ProductExtensionData source
	WHERE source.Product_Key IS NULL

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END

GO
