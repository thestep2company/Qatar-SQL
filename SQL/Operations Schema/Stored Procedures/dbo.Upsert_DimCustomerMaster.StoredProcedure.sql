USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimCustomerMaster]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[Upsert_DimCustomerMaster] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	MERGE dbo.DimCustomerMaster target
	USING Dim.CustomerMaster source
	ON source.CustomerKey = target.CustomerKey
	WHEN MATCHED AND (
  		   source.[CustomerName]						<> target.[CustomerName]
		OR source.[CustomerDesc]						<> target.[CustomerDesc]
		OR source.[CustomerSort]						<> target.[CustomerSort]
		OR ISNULL(source.[SALES_CHANNEL_CODE],'')		<> ISNULL(target.[SALES_CHANNEL_CODE],'')
		OR ISNULL(source.[INSIDE_REP],'')				<> ISNULL(target.[INSIDE_REP],'')
		OR ISNULL(source.[TRAFFIC_PERSON],'')			<> ISNULL(target.[TRAFFIC_PERSON],'')
		OR ISNULL(source.[LABEL_FORMAT],'')				<> ISNULL(target.[LABEL_FORMAT],'')
		OR ISNULL(source.[BUSINESS_SEGMENT],'')			<> ISNULL(target.[BUSINESS_SEGMENT],'')
		OR ISNULL(source.[CUSTOMER_GROUP],'')			<> ISNULL(target.[CUSTOMER_GROUP],'')
		OR ISNULL(source.[FINANCE_CHANNEL],'')			<> ISNULL(target.[FINANCE_CHANNEL],'')
		OR source.[TERRITORY]							<> target.[TERRITORY]
		OR source.[SALESPERSON]							<> target.[SALESPERSON]
		OR source.[ORDER_TYPE]							<> target.[ORDER_TYPE]
		OR source.[DEMAND_CLASS_CODE]					<> target.[DEMAND_CLASS_CODE]
		OR source.[DEMAND_CLASS_NAME]					<> target.[DEMAND_CLASS_NAME]
		OR source.[FINANCE_REPORTING_CHANNEL]			<> target.[FINANCE_REPORTING_CHANNEL]
		OR source.[FEED_DEMAND_CLASS_NAME]				<> target.[FEED_DEMAND_CLASS_NAME]
		OR source.[FEED_CUSTOMER]						<> target.[FEED_CUSTOMER]
		OR ISNULL(source.[LastSaleDate],'1900-01-01')	<> ISNULL(target.[LastSaleDate],'1900-01-01')
		OR ISNULL(source.[FirstSaleDate],'1900-01-01')	<> ISNULL(target.[FirstSaleDate],'1900-01-01')
		OR ISNULL(source.[CreationDate],'1900-01-01')	<> ISNULL(target.[CreationDate],'1900-01-01')
		OR ISNULL(source.[International/Domestic/ CAD],'') <> ISNULL(target.[International/Domestic/ CAD],'')
		OR ISNULL(source.[Distribution Method],'')		<> ISNULL(target.[Distribution Method],'')
		OR ISNULL(source.[Selling Method],'')			<> ISNULL(target.[Selling Method],'')
		OR ISNULL(source.[DropShipType],'')				<> ISNULL(target.[DropShipType],'')
		OR ISNULL(source.[ParentCustomer],'')			<> ISNULL(target.[ParentCustomer],'')
		OR ISNULL(source.[Sales Representative],'')		<> ISNULL(target.[Sales Representative],'')
	) THEN -- Only update if we have a new max size for today
	UPDATE 
	SET 
		  [CustomerName]				= source.[CustomerName]				
		, [CustomerDesc]				= source.[CustomerDesc]				
		, [CustomerSort]				= source.[CustomerSort]				
		, [SALES_CHANNEL_CODE]			= source.[SALES_CHANNEL_CODE]		
		, [INSIDE_REP]					= source.[INSIDE_REP]				
		, [TRAFFIC_PERSON]				= source.[TRAFFIC_PERSON]			
		, [LABEL_FORMAT]				= source.[LABEL_FORMAT]				
		, [BUSINESS_SEGMENT]			= source.[BUSINESS_SEGMENT]			
		, [CUSTOMER_GROUP]				= source.[CUSTOMER_GROUP]			
		, [FINANCE_CHANNEL]				= source.[FINANCE_CHANNEL]			
		, [TERRITORY]					= source.[TERRITORY]					
		, [SALESPERSON]					= source.[SALESPERSON]				
		, [ORDER_TYPE]					= source.[ORDER_TYPE]				
		, [DEMAND_CLASS_CODE]			= source.[DEMAND_CLASS_CODE]			
		, [DEMAND_CLASS_NAME]			= source.[DEMAND_CLASS_NAME]			
		, [FINANCE_REPORTING_CHANNEL]	= source.[FINANCE_REPORTING_CHANNEL]	
		, [FEED_DEMAND_CLASS_NAME]		= source.[FEED_DEMAND_CLASS_NAME]	
		, [FEED_CUSTOMER]				= source.[FEED_CUSTOMER]
		, [LastSaleDate]				= source.[LastSaleDate]
		, [FirstSaleDate]				= source.[FirstSaleDate]
		, [CreationDate]				= source.[CreationDate]
		, [International/Domestic/ CAD]	= source.[International/Domestic/ CAD]
		, [Distribution Method]			= source.[Distribution Method]
		, [Selling Method]				= source.[Selling Method]
		, [DropShipType]				= source.[DropShipType]
		, [ParentCustomer]				= ISNULL(source.[ParentCustomer],'')
		, [Sales Representative]		= ISNULL(source.[Sales Representative],'')
	WHEN NOT MATCHED BY TARGET THEN -- Otherwise insert the new size
	INSERT
		( [CustomerKey]
		, [CustomerName]				
		, [CustomerDesc]				
		, [CustomerSort]				
		, [SALES_CHANNEL_CODE]		
		, [INSIDE_REP]				
		, [TRAFFIC_PERSON]			
		, [LABEL_FORMAT]				
		, [BUSINESS_SEGMENT]			
		, [CUSTOMER_GROUP]			
		, [FINANCE_CHANNEL]			
		, [TERRITORY]					
		, [SALESPERSON]				
		, [ORDER_TYPE]				
		, [DEMAND_CLASS_CODE]			
		, [DEMAND_CLASS_NAME]			
		, [FINANCE_REPORTING_CHANNEL]	
		, [FEED_DEMAND_CLASS_NAME]	
		, [FEED_CUSTOMER]				
		, [LastSaleDate]
		, [FirstSaleDate]
		, [CreationDate]
		, [International/Domestic/ CAD]
		, [Distribution Method]
		, [Selling Method]
		, [DropShipType]
		, [ParentCustomer]
		, [Sales Representative]
        )
	VALUES
        ( [CustomerKey]
		, [CustomerName]				
		, [CustomerDesc]				
		, [CustomerSort]				
		, [SALES_CHANNEL_CODE]		
		, [INSIDE_REP]				
		, [TRAFFIC_PERSON]			
		, [LABEL_FORMAT]				
		, [BUSINESS_SEGMENT]			
		, [CUSTOMER_GROUP]			
		, [FINANCE_CHANNEL]			
		, [TERRITORY]					
		, [SALESPERSON]				
		, [ORDER_TYPE]				
		, [DEMAND_CLASS_CODE]			
		, [DEMAND_CLASS_NAME]			
		, [FINANCE_REPORTING_CHANNEL]	
		, [FEED_DEMAND_CLASS_NAME]	
		, [FEED_CUSTOMER]				
		, [LastSaleDate]
		, [FirstSaleDate]
		, [CreationDate]
		, [International/Domestic/ CAD]
		, [Distribution Method]
		, [Selling Method]
		, [DropShipType]
		, ISNULL([ParentCustomer],'')
		, ISNULL([Sales Representative],'')
	);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

/*
	SELECT * FROM Dim.CustomerMaster source
		LEFT JOIN dbo.DimCustomerMaster target ON source.CustomerKey = target.CustomerKey
	WHERE --compare all fields or push a fingerprint?...
  		   (source.[CustomerName]					<> target.[CustomerName]
		OR source.[CustomerDesc]					<> target.[CustomerDesc]
		OR source.[CustomerSort]					<> target.[CustomerSort]
		OR ISNULL(source.[SALES_CHANNEL_CODE],'')	<> ISNULL(target.[SALES_CHANNEL_CODE],'')
		OR ISNULL(source.[INSIDE_REP],'')			<> ISNULL(target.[INSIDE_REP],'')
		OR ISNULL(source.[TRAFFIC_PERSON],'')		<> ISNULL(target.[TRAFFIC_PERSON],'')
		OR ISNULL(source.[LABEL_FORMAT],'')			<> ISNULL(target.[LABEL_FORMAT],'')
		OR ISNULL(source.[BUSINESS_SEGMENT],'')		<> ISNULL(target.[BUSINESS_SEGMENT],'')
		OR ISNULL(source.[CUSTOMER_GROUP],'')		<> ISNULL(target.[CUSTOMER_GROUP],'')
		OR ISNULL(source.[FINANCE_CHANNEL],'')		<> ISNULL(target.[FINANCE_CHANNEL],'')
		OR source.[TERRITORY]						<> target.[TERRITORY]
		OR source.[SALESPERSON]						<> target.[SALESPERSON]
		OR source.[ORDER_TYPE]						<> target.[ORDER_TYPE]
		OR source.[DEMAND_CLASS_CODE]				<> target.[DEMAND_CLASS_CODE]
		OR source.[DEMAND_CLASS_NAME]				<> target.[DEMAND_CLASS_NAME]
		OR source.[FINANCE_REPORTING_CHANNEL]		<> target.[FINANCE_REPORTING_CHANNEL]
		OR source.[FEED_DEMAND_CLASS_NAME]			<> target.[FEED_DEMAND_CLASS_NAME]
		OR source.[FEED_CUSTOMER]					<> target.[FEED_CUSTOMER]			
		OR ISNULL(source.[LastSaleDate],'1900-01-01')	<> ISNULL(target.[LastSaleDate],'1900-01-01')
		OR ISNULL(source.[FirstSaleDate],'1900-01-01')	<> ISNULL(target.[FirstSaleDate],'1900-01-01')
		OR ISNULL(source.[CreationDate],'1900-01-01')	<> ISNULL(target.[CreationDate],'1900-01-01')
		OR ISNULL(source.[International/Domestic/ CAD],'') <> ISNULL(target.[International/Domestic/ CAD],'')
		OR ISNULL(source.[Distribution Method],'')		<> ISNULL(target.[Distribution Method],'')
		OR ISNULL(source.[Selling Method],'')			<> ISNULL(target.[Selling Method],'')
		OR ISNULL(source.[DropShipType],'')			<> ISNULL(target.[DropShipType],'')
		OR ISNULL(source.[ParentCustomer],'')		<> ISNULL(target.[ParentCustomer],'')
		OR ISNULL(source.[Sales Representative],'') <> ISNULL(target.[Sales Representative],''))

*/

END
GO
