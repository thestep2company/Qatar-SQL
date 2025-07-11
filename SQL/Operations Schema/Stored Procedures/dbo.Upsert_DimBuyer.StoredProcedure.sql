USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimBuyer]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_DimBuyer] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
	MERGE dbo.DimBuyer target
	USING Dim.Buyer source
	ON source.Buyer_Name = target.Buyer_Name
	WHEN NOT MATCHED BY TARGET THEN
	INSERT ( [Buyer_Name] )
	VALUES ( [Buyer_Name] );

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END
GO
