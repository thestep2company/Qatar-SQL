USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Merge_CommissionsSalesRep]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [xref].[Merge_CommissionsSalesRep] AS BEGIN


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

	--new records
	INSERT INTO xref.CommissionsSalesRep
	SELECT source.Number, source.Customer, source.[Sales Representative]
	FROM XREF.dbo.CommissionsSalesRep source
		LEFT JOIN xref.CommissionsSalesRep target ON source.Number = target.Number
	WHERE target.Number IS NULL --AND target.ProductKey = '854899'


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Update', GETDATE()

	--update existing
	UPDATE target
	SET 
		 [Customer] =  source.[Customer]
		,[Sales Representative] =  source.[Sales Representative]
	--SELECT *
	FROM XREF.dbo.CommissionsSalesRep source
		LEFT JOIN xref.CommissionsSalesRep target ON source.Number = target.Number
	WHERE (ISNULL(source.[Customer],'') <> ISNULL(target.[Customer],'')
		OR ISNULL(source.[Sales Representative],'')  <> ISNULL(target.[Sales Representative],'')
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
	
END

GO
