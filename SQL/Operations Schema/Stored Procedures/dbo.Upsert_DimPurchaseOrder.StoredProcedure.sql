USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimPurchaseOrder]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_DimPurchaseOrder] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	MERGE dbo.DimPurchaseOrder target
	USING (
		SELECT DISTINCT 
			   [PO_NUMBER]
			  ,[LINE_NUMBER]
			  ,[SHIPMENT_LINE_NUMBER]
			  ,[PO_HEADER_ID]
			  ,[PO_LINE_ID]
			  ,[LINE_LOCATION_ID]
			  ,[BuyerID]
			  ,[VendorDesc]
			  ,[POStatusID]
			  ,[POTypeID]
			  ,[POCodeID]
			  ,[HEADER_CLOSED_CODE]
			  ,[LINE_CLOSED_CODE]
			  ,[CLOSED_CODE]
			  ,[SHIP_TO]
			  ,[BILL_TO]
			  ,[NOTE_TO_VENDOR]
			  ,[PO_CREATE_DATE]
			  ,[PO_LINE_CREATE_DATE]
			  ,[NEED_BY_DATE]
			  ,[PROMISED_DATE]
			  ,[PO_LINE_CANCEL_DATE]
			  ,[CANCEL_DATE]
		FROM [Operations].[Dim].[PurchaseOrder]
	) source
	ON	source.PO_HEADER_ID				= target.PO_HEADER_ID
		AND source.PO_LINE_ID			= target.PO_LINE_ID
		AND ISNULL(source.LINE_LOCATION_ID,0) = ISNULL(target.LINE_LOCATION_ID,0)
	WHEN MATCHED AND (
  		source.PO_NUMBER										<> target.PO_NUMBER
		OR source.LINE_NUMBER									<> target.LINE_NUMBER
		OR ISNULL(source.SHIPMENT_LINE_NUMBER,0)				<> ISNULL(target.SHIPMENT_LINE_NUMBER,0)
		OR ISNULL(source.BuyerID,0)								<> ISNULL(target.BuyerID,0)
		OR ISNULL(source.VendorDesc,0)							<> ISNULL(target.VendorDesc,0)
		OR ISNULL(source.POStatusID,0)							<> ISNULL(target.POStatusID,0)
		OR ISNULL(source.POTypeID,0)							<> ISNULL(target.POTypeID,0)
		OR ISNULL(source.POCodeID,0)							<> ISNULL(target.POCodeID,0)
		OR ISNULL(source.Header_Closed_Code,0)					<> ISNULL(target.Header_Closed_Code,0)
		OR ISNULL(source.Line_Closed_Code,0)					<> ISNULL(target.Line_Closed_Code,0)
		OR ISNULL(source.Closed_Code,0)							<> ISNULL(target.Closed_Code,0)
		OR ISNULL(source.[SHIP_TO],'')							<> ISNULL(target.[SHIP_TO],'')							
		OR ISNULL(source.[BILL_TO],'')							<> ISNULL(target.[BILL_TO],'')
		OR ISNULL(source.[NOTE_TO_VENDOR],'')					<> ISNULL(target.[NOTE_TO_VENDOR],'')
		OR ISNULL(source.[PO_CREATE_DATE],'1900-01-01')			<> ISNULL(target.[PO_CREATE_DATE],'1900-01-01')
		OR ISNULL(source.[PO_LINE_CREATE_DATE],'1900-01-01')	<> ISNULL(target.[PO_LINE_CREATE_DATE],'1900-01-01')
		OR ISNULL(source.[NEED_BY_DATE],'1900-01-01')			<> ISNULL(target.[NEED_BY_DATE],'1900-01-01')
		OR ISNULL(source.[PROMISED_DATE],'1900-01-01')			<> ISNULL(target.[PROMISED_DATE],'1900-01-01')
		OR ISNULL(source.[PO_LINE_CANCEL_DATE],'1900-01-01')	<> ISNULL(target.[PO_LINE_CANCEL_DATE],'1900-01-01')
		OR ISNULL(source.[CANCEL_DATE],'1900-01-01')			<> ISNULL(target.[CANCEL_DATE],'1900-01-01')
	) THEN
	UPDATE 
	SET 
  		 PO_NUMBER				= source.PO_NUMBER
		,LINE_NUMBER			= source.LINE_NUMBER
		,SHIPMENT_LINE_NUMBER	= source.SHIPMENT_LINE_NUMBER
		,BuyerID				= source.BuyerID
		,VendorDesc				= source.VendorDesc
		,POStatusID				= source.POStatusID
		,POTypeID				= source.POTypeID
		,POCodeID				= source.POCodeID
		,Header_Closed_Code		= source.Header_Closed_Code
		,Line_Closed_Code		= source.Line_Closed_Code
		,Closed_Code			= source.Closed_Code
		,[SHIP_TO]				= source.[SHIP_TO]
		,[BILL_TO]				= source.[BILL_TO]
		,[NOTE_TO_VENDOR]		= source.[NOTE_TO_VENDOR]
		,[PO_CREATE_DATE]		= source.[PO_CREATE_DATE]
		,[PO_LINE_CREATE_DATE]	= source.[PO_LINE_CREATE_DATE]
		,[NEED_BY_DATE]			= source.[NEED_BY_DATE]
		,[PROMISED_DATE]		= source.[PROMISED_DATE]
		,[PO_LINE_CANCEL_DATE]	= source.[PO_LINE_CANCEL_DATE]
		,[CANCEL_DATE]			= source.[CANCEL_DATE]
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
			 [PO_NUMBER]
			,[LINE_NUMBER]
			,[SHIPMENT_LINE_NUMBER]
			,[PO_HEADER_ID]
			,[PO_LINE_ID]
			,[LINE_LOCATION_ID]
			,[BuyerID]
			,[VendorDesc]
			,[POStatusID]
			,[POTypeID]
			,[POCodeID]
			,[HEADER_CLOSED_CODE]
			,[LINE_CLOSED_CODE]
			,[CLOSED_CODE]
			,[SHIP_TO]
			,[BILL_TO]
			,[NOTE_TO_VENDOR]
			,[PO_CREATE_DATE]
			,[PO_LINE_CREATE_DATE]
			,[NEED_BY_DATE]
			,[PROMISED_DATE]
			,[PO_LINE_CANCEL_DATE]
			,[CANCEL_DATE]
    )
	VALUES (
        	 [PO_NUMBER]
			,[LINE_NUMBER]
			,[SHIPMENT_LINE_NUMBER]
			,[PO_HEADER_ID]
			,[PO_LINE_ID]
			,[LINE_LOCATION_ID]
			,[BuyerID]
			,[VendorDesc]
			,[POStatusID]
			,[POTypeID]
			,[POCodeID]
			,[HEADER_CLOSED_CODE]
			,[LINE_CLOSED_CODE]
			,[CLOSED_CODE]
			,[SHIP_TO]
			,[BILL_TO]
			,[NOTE_TO_VENDOR]
			,[PO_CREATE_DATE]
			,[PO_LINE_CREATE_DATE]
			,[NEED_BY_DATE]
			,[PROMISED_DATE]
			,[PO_LINE_CANCEL_DATE]
			,[CANCEL_DATE]
	);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

/*
	SELECT * FROM (
		SELECT DISTINCT 
			   [PO_NUMBER]
			  ,[LINE_NUMBER]
			  ,[SHIPMENT_LINE_NUMBER]
			  ,[PO_HEADER_ID]
			  ,[PO_LINE_ID]
			  ,[LINE_LOCATION_ID]
			  ,[BuyerID]
			  ,[VendorDesc]
			  ,[POStatusID]
			  ,[POTypeID]
			  ,[POCodeID]
			  ,[HEADER_CLOSED_CODE]
			  ,[LINE_CLOSED_CODE]
			  ,[CLOSED_CODE]
			  ,[SHIP_TO]
			  ,[BILL_TO]
			  ,[NOTE_TO_VENDOR]
			  ,[PO_CREATE_DATE]
			  ,[PO_LINE_CREATE_DATE]
			  ,[NEED_BY_DATE]
			  ,[PROMISED_DATE]
			  ,[PO_LINE_CANCEL_DATE]
			  ,[CANCEL_DATE]
		FROM [Operations].[dbo].[DimPurchaseOrder]
	) source		
		LEFT JOIN dbo.DimPurchaseOrder target 
	ON  source.PO_HEADER_ID				= target.PO_HEADER_ID
		AND source.PO_LINE_ID			= target.PO_LINE_ID
		AND ISNULL(source.LINE_LOCATION_ID,0) = ISNULL(target.LINE_LOCATION_ID,0)
	WHERE --compare all fields or push a fingerprint?...
  		source.PO_NUMBER							<> target.PO_NUMBER
		OR source.LINE_NUMBER						<> target.LINE_NUMBER
		OR ISNULL(source.SHIPMENT_LINE_NUMBER,0)	<> ISNULL(target.SHIPMENT_LINE_NUMBER,0)
		OR ISNULL(source.BuyerID,0)					<> ISNULL(target.BuyerID,0)
		OR ISNULL(source.VendorDesc,0)				<> ISNULL(target.VendorDesc,0)
		OR ISNULL(source.POStatusID,0)				<> ISNULL(target.POStatusID,0)
		OR ISNULL(source.POTypeID,0)				<> ISNULL(target.POTypeID,0)
		OR ISNULL(source.POCodeID,0)				<> ISNULL(target.POCodeID,0)
		OR ISNULL(source.Header_Closed_Code,0)		<> ISNULL(target.Header_Closed_Code,0)
		OR ISNULL(source.Line_Closed_Code,0)		<> ISNULL(target.Line_Closed_Code,0)
		OR ISNULL(source.Closed_Code,0)				<> ISNULL(target.Closed_Code,0)
		OR ISNULL(source.[SHIP_TO],'')							<> ISNULL(target.[SHIP_TO],'')							
		OR ISNULL(source.[BILL_TO],'')							<> ISNULL(target.[BILL_TO],'')
		OR ISNULL(source.[NOTE_TO_VENDOR],'')					<> ISNULL(target.[NOTE_TO_VENDOR],'')
		OR ISNULL(source.[PO_CREATE_DATE],'1900-01-01')			<> ISNULL(target.[PO_CREATE_DATE],'1900-01-01')
		OR ISNULL(source.[PO_LINE_CREATE_DATE],'1900-01-01')	<> ISNULL(target.[PO_LINE_CREATE_DATE],'1900-01-01')
		OR ISNULL(source.[NEED_BY_DATE],'1900-01-01')			<> ISNULL(target.[NEED_BY_DATE],'1900-01-01')
		OR ISNULL(source.[PROMISED_DATE],'1900-01-01')			<> ISNULL(target.[PROMISED_DATE],'1900-01-01')
		OR ISNULL(source.[PO_LINE_CANCEL_DATE],'1900-01-01')	<> ISNULL(target.[PO_LINE_CANCEL_DATE],'1900-01-01')
		OR ISNULL(source.[CANCEL_DATE],'1900-01-01')			<> ISNULL(target.[CANCEL_DATE],'1900-01-01')
*/

END

GO
