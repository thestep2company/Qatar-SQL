USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Merge_DemandClass]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [xref].[Merge_DemandClass] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

	--new records
	INSERT INTO xref.DemandClass
	SELECT  
	   source.[DEMAND CLASS CODE]
      ,source.[DEMAND CLASS NAME]
      ,source.[CUSTOMER - Demand Class]
      ,source.[Customer Rank]
      ,source.[Customer Summary]
      ,source.[Finance Reporting Channel]
      ,source.[Customer Top Level]
      ,source.[Ecommerce Type]
      ,source.[Territory]
      ,source.[Channel Code]
      ,source.[Distribution Reporting Channel]
	  ,source.[Selling Method] 
	  ,source.[Drop Ship/Other]
	  ,source.[Parent Customer]
	  ,source.[International/Domestic/ CAD]
	  ,source.[Distribution Method]
	  ,source.[CreateCustomerRecord]
	FROM xref.dbo.DemandClass source
		LEFT JOIN xref.DemandClass target ON source.[DEMAND CLASS CODE] = target.[DEMAND CLASS CODE]
	WHERE target.[DEMAND CLASS CODE] IS NULL

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Update', GETDATE()

	--update existing
	UPDATE target
	SET   
		target.[DEMAND CLASS CODE]				= source.[DEMAND CLASS CODE]
      ,	target.[DEMAND CLASS NAME]				= source.[DEMAND CLASS NAME]
      ,	target.[CUSTOMER - Demand Class]		= source.[CUSTOMER - Demand Class]
      ,	target.[Customer Rank]					= source.[Customer Rank]
      ,	target.[Customer Summary]				= source.[Customer Summary]
      ,	target.[Finance Reporting Channel]		= source.[Finance Reporting Channel]
      ,	target.[Customer Top Level]				= source.[Customer Top Level]
      ,	target.[Ecommerce Type]					= source.[Ecommerce Type]
      ,	target.[Territory]						= source.[Territory]
      ,	target.[Channel Code]					= source.[Channel Code]
      ,	target.[Distribution Reporting Channel]	= source.[Distribution Reporting Channel]
	  , target.[Selling Method]					= source.[Selling Method] 
	  , target.[Drop Ship/Other]				= source.[Drop Ship/Other]
	  , target.[Parent Customer]				= source.[Parent Customer]
	  , target.[International/Domestic/ CAD]	= source.[International/Domestic/ CAD]
	  , target.[Distribution Method]			= source.[Distribution Method]
	  , target.[CreateCustomerRecord]			= source.[CreateCustomerRecord]
	--SELECT *
	FROM xref.dbo.DemandClass source
		LEFT JOIN xref.DemandClass target ON source.[DEMAND CLASS CODE] = target.[DEMAND CLASS CODE]
	WHERE (
		   ISNULL(source.[DEMAND CLASS CODE],'')				<>		ISNULL(target.[DEMAND CLASS CODE],'')
		OR ISNULL(source.[DEMAND CLASS NAME],'')				<>		ISNULL(target.[DEMAND CLASS NAME],'')
		OR ISNULL(source.[CUSTOMER - Demand Class],'')			<>		ISNULL(target.[CUSTOMER - Demand Class],'')
		OR ISNULL(source.[Customer Rank],'')					<>		ISNULL(target.[Customer Rank],'')
		OR ISNULL(source.[Customer Summary],'')					<>		ISNULL(target.[Customer Summary],'')
		OR ISNULL(source.[Finance Reporting Channel],'')		<>		ISNULL(target.[Finance Reporting Channel],'')
		OR ISNULL(source.[Customer Top Level],'')				<>		ISNULL(target.[Customer Top Level],'')
		OR ISNULL(source.[Ecommerce Type],'')					<>		ISNULL(target.[Ecommerce Type],'')
		OR ISNULL(source.[Territory],'')						<>		ISNULL(target.[Territory],'')
		OR ISNULL(source.[Channel Code],'')						<>		ISNULL(target.[Channel Code],'')
		OR ISNULL(source.[Distribution Reporting Channel],'')	<>		ISNULL(target.[Distribution Reporting Channel],'')
		OR ISNULL(source.[Selling Method],'')					<>		ISNULL(target.[Selling Method],'')
		OR ISNULL(source.[Drop Ship/Other],'')					<>		ISNULL(target.[Drop Ship/Other],'')
		OR ISNULL(source.[Parent Customer],'')					<>		ISNULL(target.[Parent Customer],'')
		OR ISNULL(source.[International/Domestic/ CAD],'')		<>		ISNULL(target.[International/Domestic/ CAD],'')
		OR ISNULL(source.[Distribution Method],'')				<>		ISNULL(target.[Distribution Method],'')			
		OR ISNULL(source.[CreateCustomerRecord],0)				<>		ISNULL(target.[CreateCustomerRecord],0)
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()

	--remove missing records in source
	DELETE FROM target
	--SELECT *
	FROM xref.dbo.DemandClass source
		LEFT JOIN xref.DemandClass target ON source.[DEMAND CLASS CODE] = target.[DEMAND CLASS CODE]
	WHERE source.[DEMAND CLASS CODE] IS NULL

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()


END

GO
