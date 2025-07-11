USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimDemandClass]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_DimDemandClass] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	MERGE dbo.DimDemandClass target
	USING Dim.DemandClass source
	ON source.DemandClassKey = target.DemandClassKey
	WHEN MATCHED AND (
  		   ISNULL(source.DemandClassName,'')					<> ISNULL(target.DemandClassName,'')
		OR ISNULL(source.DemandClassDesc,'')					<> ISNULL(target.DemandClassDesc,'')
		OR ISNULL(source.[Customer Rank],'')					<> ISNULL(target.[Customer Rank],'')
		OR ISNULL(source.[Customer Summary],'')					<> ISNULL(target.[Customer Summary],'')
		OR ISNULL(source.[Finance Reporting Channel],'')		<> ISNULL(target.[Finance Reporting Channel],'')
		OR ISNULL(source.[Customer Top Level],'')				<> ISNULL(target.[Customer Top Level],'')
		OR ISNULL(source.[Ecommerce Type],'')					<> ISNULL(target.[Ecommerce Type],'')
		OR ISNULL(source.[Territory],'')						<> ISNULL(target.[Territory],'')
		OR ISNULL(source.[Channel Code],'')						<> ISNULL(target.[Channel Code],'')
		OR ISNULL(source.[Distribution Reporting Channel],'')	<> ISNULL(target.[Distribution Reporting Channel],'')
		OR ISNULL(source.[Selling Method],'')					<> ISNULL(target.[Selling Method],'')  
		OR ISNULL(source.[Drop Ship/Other],'')					<> ISNULL(target.[Drop Ship/Other],'')
		OR ISNULL(source.[Parent Customer],'')					<> ISNULL(target.[Parent Customer],'')
		OR ISNULL(source.[International/Domestic/ CAD],'')		<> ISNULL(target.[International/Domestic/ CAD],'')
		OR ISNULL(source.[Distribution Method],'')				<> ISNULL(target.[Distribution Method],'')
		OR ISNULL(source.[CreateCustomerRecord],'')				<> ISNULL(target.[CreateCustomerRecord],'')
	) THEN -- Only update if we have a new max size for today
	UPDATE 
	SET 
  		  DemandClassName					= source.DemandClassName
		, DemandClassDesc					= source.DemandClassDesc
		, [Customer Rank]					= source.[Customer Rank]
		, [Customer Summary]				= source.[Customer Summary]
		, [Finance Reporting Channel]		= source.[Finance Reporting Channel]
		, [Customer Top Level]				= source.[Customer Top Level]
		, [Ecommerce Type]					= source.[Ecommerce Type]
		, [Territory]						= source.[Territory]
		, [Channel Code]					= source.[Channel Code]
		, [Distribution Reporting Channel]	= source.[Distribution Reporting Channel]    
		, [Selling Method]					= source.[Selling Method]	
		, [Drop Ship/Other]					= source.[Drop Ship/Other]
		, [Parent Customer]					= source.[Parent Customer]
		, [International/Domestic/ CAD]		= source.[International/Domestic/ CAD]
		, [Distribution Method]				= source.[Distribution Method]	
		, [CreateCustomerRecord]			= source.[CreateCustomerRecord]
	WHEN NOT MATCHED BY TARGET THEN -- Otherwise insert the new size
	INSERT
		(DemandClassKey
		,DemandClassName
		,DemandClassDesc
		,[Customer Rank]
		,[Customer Summary]
		,[Finance Reporting Channel]
		,[Customer Top Level]
		,[Ecommerce Type]
		,[Territory]
		,[Channel Code]
		,[Distribution Reporting Channel]
		,[Selling Method] 
		,[Drop Ship/Other]
		,[Parent Customer]
		,[International/Domestic/ CAD]
		,[Distribution Method]	
		,[CreateCustomerRecord]
        )
	VALUES
        (DemandClassKey
		,DemandClassName
		,DemandClassDesc
		,[Customer Rank]
		,[Customer Summary]
		,[Finance Reporting Channel]
		,[Customer Top Level]
		,[Ecommerce Type]
		,[Territory]
		,[Channel Code]
		,[Distribution Reporting Channel]
		,[Selling Method] 
		,[Drop Ship/Other]
		,[Parent Customer]
		,[International/Domestic/ CAD]
		,[Distribution Method]	
		,[CreateCustomerRecord]
	);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	/*
		SELECT * FROM Dim.DemandClass dc1
			LEFT JOIN dbo.DimDemandClass dc2 ON dc1.DemandClassKey = dc2.DemandClassKey
		WHERE --compare all fields or push a fingerprint?...
			ISNULL(dc1.DemandClassName,'') <> ISNULL(dc2.DemandClassName,'')
			OR dc1.DemandClassDesc <> dc2.DemandClassDesc
			OR dc1.[Customer Rank] <> dc2.[Customer Rank]
			OR dc1.[Customer Summary] <> dc2.[Customer Summary]
			OR dc1.[Finance Reporting Channel] <> dc2.[Finance Reporting Channel]
			OR dc1.[Customer Top Level] <> dc2.[Customer Top Level]
			OR dc1.[Ecommerce Type] <> dc2.[Ecommerce Type]
			OR dc1.[Territory] <> dc2.[Territory]
			OR dc1.[Channel Code] <> dc2.[Channel Code]
			OR dc1.[Distribution Reporting Channel] <> dc2.[Distribution Reporting Channel]
			OR dc1.[Selling Method]					<> dc2.[Selling Method]  
			OR dc1.[Drop Ship/Other]				<> dc2.[Drop Ship/Other]
			OR dc1.[Parent Customer]				<> dc2.[Parent Customer]
			OR dc1.[International/Domestic/ CAD]	<> dc2.[International/Domestic/ CAD]
			OR dc1.[Distribution Method]			<> dc2.[Distribution Method]					
			OR dc1.[CreateCustomerRecord]			<> dc2.[CreateCustomerRecord]

	*/

END
GO
