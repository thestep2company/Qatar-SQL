USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Merge_CustomerExtensionData]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [xref].[Merge_CustomerExtensionData] AS BEGIN


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

	--new records
	INSERT INTO xref.CustomerExtensionData
	SELECT source.[CUSTOMER_NUM], source.[International/Domestic/ CAD], source.[Distribution Method], source.[Selling Method], source.DropShipType, source.ParentCustomer
	FROM XREF.dbo.CustomerExtensionData source
		LEFT JOIN xref.CustomerExtensionData target ON source.Customer_Num = target.Customer_Num
	WHERE target.Customer_Num IS NULL --AND target.ProductKey = '854899'


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Update', GETDATE()

	--update existing
	UPDATE target
	SET 
		 [International/Domestic/ CAD] = source.[International/Domestic/ CAD]
		,[Distribution Method] =  source.[Distribution Method]
		,[Selling Method] =  source.[Selling Method]
		,DropShipType = source.DropShipType
		,ParentCustomer = source.ParentCustomer
	--SELECT *
	FROM XREF.dbo.CustomerExtensionData source
		INNER JOIN xref.CustomerExtensionData target ON source.Customer_Num = target.Customer_Num
	WHERE (ISNULL(source.[International/Domestic/ CAD],'') <> ISNULL(target.[International/Domestic/ CAD],'')
		OR ISNULL(source.[Distribution Method],'')  <> ISNULL(target.[Distribution Method],'')
		OR ISNULL(source.[Selling Method],'')  <> ISNULL(target.[Selling Method],'')
		OR ISNULL(source.DropShipType,'') <> ISNULL(target.[DropShipType],'')
		OR ISNULL(source.ParentCustomer,'') <> ISNULL(target.[ParentCustomer],'')
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
	
END

GO
