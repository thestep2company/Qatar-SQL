USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimProductMaster]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Upsert_DimProductMaster] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()
	
	MERGE dbo.DimProductMaster target
	USING Dim.ProductMaster source
	ON source.ProductKey = target.ProductKey
	WHEN MATCHED AND (
  		   ISNULL(source.[ProductName],'')					<> ISNULL(target.[ProductName],'')			
		OR ISNULL(source.[ProductDesc],'')					<> ISNULL(target.[ProductDesc],'')			
		OR ISNULL(source.[ProductSort],'')					<> ISNULL(target.[ProductSort],'')			
		OR ISNULL(source.[4 Digit],'')						<> ISNULL(target.[4 Digit],'')				
		OR source.[UOM]										<> target.[UOM]				
		OR source.[Item Type]								<> target.[Item Type]				
		OR source.[SIOP Family]								<> target.[SIOP Family]
		OR source.[Category]								<> target.[Category]				
		OR source.[SubCategory]								<> target.[SubCategory]			
		OR source.[CategoryType]							<> target.[CategoryType]
		OR source.[Brand]									<> target.[Brand]		
		OR source.[Inventory Status Code]					<> target.[Inventory Status Code]
		OR source.[Country of Origin]						<> target.[Country of Origin]
		OR source.[Part Class]								<> target.[Part Class]				
		OR ISNULL(source.[MakeBuy],'')						<> ISNULL(target.[MakeBuy],'')
		OR source.[Contract Manufacturing]					<> target.[Contract Manufacturing]
		OR source.[Channel]									<> target.[Channel]
		OR ISNULL(source.[Part Type],'')					<> ISNULL(target.[Part Type],'')
		OR source.[IMAP]									<> target.[IMAP]
		OR source.[NPD]										<> target.[NPD]
		OR source.[Product Volume]							<> target.[Product Volume]			
		OR ISNULL(source.[List Price],0)					<> ISNULL(target.[List Price],0)				
		OR ISNULL(source.[Royalty License Name],'')			<> ISNULL(target.[Royalty License Name],'')	
		OR ISNULL(source.[Shipping Method],'')				<> ISNULL(target.[Shipping Method],'')	
		OR ISNULL(source.[Cooler Size],'')					<> ISNULL(target.[Cooler Size],'')			
		OR ISNULL(source.FirstProductionDate,'1900-01-01')	<> ISNULL(target.FirstProductionDate,'1900-01-01') 
		OR ISNULL(source.LastProductionDate,'1900-01-01')	<> ISNULL(target.LastProductionDate,'1900-01-01')
		OR ISNULL(source.FirstSaleDate,'1900-01-01')		<> ISNULL(target.FirstSaleDate,'1900-01-01')
		OR ISNULL(source.LastSaleDate,'1900-01-01')			<> ISNULL(target.LastSaleDate,'1900-01-01')
		OR ISNULL(source.CreationDate,'1900-01-01')			<> ISNULL(target.CreationDate,'1900-01-01')
		OR ISNULL(source.ProductGroup,'')					<> ISNULL(target.ProductGroup,'')
		OR ISNULL(source.ProductLine,'')					<> ISNULL(target.ProductLine,'')
		OR ISNULL(source.Department,'')						<> ISNULL(target.Department,'')
		OR ISNULL(source.Dimensions,'')						<> ISNULL(target.Dimensions,'')
		OR ISNULL(source.FootPrint,0)						<> ISNULL(target.FootPrint,0)
		OR ISNULL(source.[Cube],0)							<> ISNULL(target.[Cube],0)
		OR ISNULL(source.[ChildAdult],'')					<> ISNULL(target.[ChildAdult],'')
		OR ISNULL(source.[Size],'')							<> ISNULL(target.[Size],'')
		OR ISNULL(source.[Step2 Custom],'')					<> ISNULL(target.[Step2 Custom],'')
		OR ISNULL(source.[DerivedProductKey],'')			<> ISNULL(target.[DerivedProductKey],'')
		OR ISNULL(source.[PlaceholderName],'')				<> ISNULL(target.[PlaceholderName],'')
		OR ISNULL(source.[PlaceholderDesc],'')				<> ISNULL(target.[PlaceholderDesc],'')
		OR ISNULL(source.[PlaceholderType],'')				<> ISNULL(target.[PlaceholderType],'')
		OR ISNULL(source.[Forecast Segment],'')				<> ISNULL(target.[Forecast Segment],'')
		OR ISNULL(source.[UPC],'')							<> ISNULL(target.[UPC],'')
		OR ISNULL(source.[4 Digit SKU],'')					<> ISNULL(target.[4 Digit SKU],'')
		OR ISNULL(source.[ProductStatus],'')				<> ISNULL(target.[ProductStatus],'')
		OR ISNULL(source.VENDOR_NAME,'')					<> ISNULL(target.VENDOR_NAME,'')			
		OR ISNULL(source.VENDOR_NAME_ALTERNATE,'')			<> ISNULL(target.VENDOR_NAME_ALTERNATE,'')	
		OR ISNULL(source.PLANNER_CODE,'')					<> ISNULL(target.PLANNER_CODE,'')			
		OR ISNULL(source.BUYER_NAME,'')						<> ISNULL(target.BUYER_NAME,'')	
		OR ISNULL(source.[Product Name Consolidated],'')	<> ISNULL(target.[Product Name Consolidated],'')	--Added 4.1.24
		OR ISNULL(source.Supercategory_NEW,'')				<> ISNULL(target.Supercategory_NEW,'')			
		OR ISNULL(source.[Category_NEW],'')			        <> ISNULL(target.[Category_NEW],'')	
		OR ISNULL(source.[Sub-Category_NEW],'')				<> ISNULL(target.[Sub-Category_NEW],'')			
		OR ISNULL(source.[ProductType_NEW],'')				<> ISNULL(target.[ProductType_NEW],'')	
		OR ISNULL(source.[Brand_NEW],'')	                <> ISNULL(target.[Brand_NEW],'')
		OR ISNULL(source.[License],'')	                    <> ISNULL(target.[License],'')
		OR ISNULL(source.[Product Family],'')	            <> ISNULL(target.[Product Family],'')
		OR ISNULL(source.[US Exclusive],'')	                <> ISNULL(target.[US Exclusive],'')
		OR ISNULL(source.[ABCD Code],'')	                <> ISNULL(target.[ABCD Code],'')
		OR ISNULL(source.[Safety Stock Variability],'')	    <> ISNULL(target.[Safety Stock Variability],'')
		OR ISNULL(source.[Weight_Assembled],'')	            <> ISNULL(target.[Weight_Assembled],'')
		OR ISNULL(source.[Volume_Assembled],'')	            <> ISNULL(target.[Volume_Assembled],'')
		OR ISNULL(source.[Length_Assembled],'')	            <> ISNULL(target.[Length_Assembled],'')
		OR ISNULL(source.[Width_Assembled],'')	            <> ISNULL(target.[Width_Assembled],'')
		OR ISNULL(source.[Height_Assembled],'')	            <> ISNULL(target.[Height_Assembled],'')
	) THEN 
	UPDATE 
	SET 
		  [ProductName]				  = source.[ProductName]			
		, [ProductDesc]				  = source.[ProductDesc]			
		, [ProductSort]				  = source.[ProductSort]			
		, [4 Digit]					  = source.[4 Digit]				
		, [UOM]						  = source.[UOM]					
		, [Item Type]				  = source.[Item Type]				
		, [SIOP Family]				  = source.[SIOP Family]			
		, [Category]				  = source.[Category]				
		, [SubCategory]				  = source.[SubCategory]			
		, [CategoryType]			  = source.[CategoryType]			
		, [Brand]					  = source.[Brand]					
		, [Inventory Status Code]	  = source.[Inventory Status Code]	
		, [Country of Origin]		  = source.[Country of Origin]		
		, [Part Class]				  = source.[Part Class]				
		, [MakeBuy]					  = source.[MakeBuy]				
		, [Contract Manufacturing]	  = source.[Contract Manufacturing]	
		, [Channel]					  = source.[Channel]				
		, [Part Type]				  = source.[Part Type]				
		, [IMAP]					  = source.[IMAP]					
		, [NPD]						  = source.[NPD]					
		, [Product Volume]			  = source.[Product Volume]			
		, [List Price]				  = source.[List Price]				
		, [Royalty License Name]	  = source.[Royalty License Name]	
		, [Shipping Method]			  = source.[Shipping Method]		
		, [Cooler Size]				  = source.[Cooler Size]			
		, FirstProductionDate		  = source.FirstProductionDate 
		, LastProductionDate		  = source.LastProductionDate
		, FirstSaleDate				  = source.FirstSaleDate
		, LastSaleDate				  = source.LastSaleDate
		, CreationDate				  = source.CreationDate
		, ProductGroup				  = source.ProductGroup
		, ProductLine				  = source.ProductLine
		, Department				  = source.Department
		, Dimensions				  = source.Dimensions
		, FootPrint					  = source.FootPrint
		, [Cube]					  = source.[Cube]
		, [ChildAdult]				  = source.[ChildAdult]
		, [Size]					  = source.[Size]
		, [Step2 Custom]			  = source.[Step2 Custom]
		, [DerivedProductKey]		  = source.[DerivedProductKey]
		, [PlaceholderName]			  = source.[PlaceholderName]
		, [PlaceholderDesc]			  = source.[PlaceholderDesc]
		, [PlaceholderType]			  = source.[PlaceholderType]
		, [Forecast Segment]		  = source.[Forecast Segment]
		, [UPC]						  = source.[UPC]
		, [4 Digit SKU]				  = source.[4 Digit SKU]
		, [ProductStatus]			  = source.[ProductStatus]
		, [VENDOR_NAME]				  = source.[VENDOR_NAME]
		, [VENDOR_NAME_ALTERNATE]	  = source.[VENDOR_NAME_ALTERNATE]
		, [PLANNER_CODE]			  = source.[PLANNER_CODE]
		, [BUYER_NAME]				  = source.[BUYER_NAME]
		, [Product Name Consolidated] = source.[Product Name Consolidated]   --Added 4.1.24
		, [Supercategory_NEW]		  = source.[Supercategory_NEW]			 --Added 1.13.25
		, [Category_NEW]	          = source.[Category_NEW]				 --Added 1.13.25
		, [Sub-Category_NEW]		  = source.[Sub-Category_NEW]			 --Added 1.13.25
		, [ProductType_NEW]			  = source.[ProductType_NEW]			 --Added 1.13.25
		, [Brand_NEW]				  = source.[Brand_NEW]					 --Added 1.13.25
		, [License]          		  = source.[License]					 --Added 5.5.25
		, [Product Family]   		  = source.[Product Family]				 --Added 5.5.25
		, [US Exclusive]    		  = source.[US Exclusive]				 --Added 5.5.25
		, [ABCD Code]		          = source.[ABCD Code]					 --Added 5.5.25
		, [Safety Stock Variability]  = source.[Safety Stock Variability]    --Added 5.5.25
		, [Weight_Assembled]		  = source.[Weight_Assembled]		     --Added 5.5.25
		, [Volume_Assembled]		  = source.[Volume_Assembled]		     --Added 5.5.25
		, [Length_Assembled]		  = source.[Length_Assembled]		     --Added 5.5.25
		, [Width_Assembled]		      = source.[Width_Assembled]		     --Added 5.5.25
		, [Height_Assembled]		  = source.[Height_Assembled]		     --Added 5.5.25
	WHEN NOT MATCHED BY TARGET THEN 
	INSERT
		([ProductKey] 
	    ,[ProductName]			
		,[ProductDesc]			
		,[ProductSort]			
		,[4 Digit]				
		,[UOM]					
		,[Item Type]				
		,[SIOP Family]			
		,[Category]				
		,[SubCategory]			
		,[CategoryType]			
		,[Brand]					
		,[Inventory Status Code]	
		,[Country of Origin]		
		,[Part Class]				
		,[MakeBuy]				
		,[Contract Manufacturing]	
		,[Channel]				
		,[Part Type]				
		,[IMAP]					
		,[NPD]					
		,[Product Volume]			
		,[List Price]				
		,[Royalty License Name]	
		,[Shipping Method]		
		,[Cooler Size]				
		,FirstProductionDate
		,LastProductionDate
		,FirstSaleDate
		,LastSaleDate
		,CreationDate
		,ProductGroup
		,ProductLine
		,Department
		,Dimensions
		,FootPrint
		,[Cube]
		,[ChildAdult]
		,[Size]
		,[Step2 Custom]
		,[DerivedProductKey]
		,[PlaceholderName]
		,[PlaceholderDesc]
		,[PlaceholderType]
		,[Forecast Segment]
		,[UPC]
		,[4 Digit SKU]
		,[ProductStatus]
		,[VENDOR_NAME]				
		,[VENDOR_NAME_ALTERNATE]	
		,[PLANNER_CODE]			
		,[BUYER_NAME]	
		,[Product Name Consolidated]  --Added 4.1.24
		,[Supercategory_NEW]
        ,[Category_NEW]
        ,[Sub-Category_NEW]
        ,[ProductType_NEW]
        ,[Brand_NEW]
		,[License]          		 
		,[Product Family]   		 
		,[US Exclusive]    		 
		,[ABCD Code]		         
		,[Safety Stock Variability] 
		,[Weight_Assembled]
		,[Volume_Assembled]
		,[Length_Assembled]
		,[Width_Assembled]	
		,[Height_Assembled]
        )
	VALUES
        (
		 [ProductKey]
		,[ProductName]			
		,[ProductDesc]			
		,[ProductSort]			
		,[4 Digit]				
		,[UOM]					
		,[Item Type]				
		,[SIOP Family]			
		,[Category]				
		,[SubCategory]			
		,[CategoryType]			
		,[Brand]					
		,[Inventory Status Code]	
		,[Country of Origin]		
		,[Part Class]				
		,[MakeBuy]				
		,[Contract Manufacturing]	
		,[Channel]				
		,[Part Type]				
		,[IMAP]					
		,[NPD]					
		,[Product Volume]			
		,[List Price]				
		,[Royalty License Name]	
		,[Shipping Method]		
		,[Cooler Size]			
		,FirstProductionDate
		,LastProductionDate
		,FirstSaleDate
		,LastSaleDate
		,CreationDate
		,ProductGroup
		,ProductLine
		,Department
		,Dimensions
		,FootPrint
		,[Cube]
		,[ChildAdult]
		,[Size]
		,[Step2 Custom]
		,[DerivedProductKey]
		,[PlaceholderName]
		,[PlaceholderDesc]
		,[PlaceholderType]
		,[Forecast Segment]
		,[UPC]
		,[4 Digit SKU]
		,[ProductStatus]
		,[VENDOR_NAME]				
		,[VENDOR_NAME_ALTERNATE]	
		,[PLANNER_CODE]			
		,[BUYER_NAME]
		,[Product Name Consolidated]  --Added 4.1.24
		,[Supercategory_NEW]
        ,[Category_NEW]
        ,[Sub-Category_NEW]
        ,[ProductType_NEW]
        ,[Brand_NEW]
		,[License]          		 
		,[Product Family]   		 
		,[US Exclusive]    		 
		,[ABCD Code]		         
		,[Safety Stock Variability]
		,[Weight_Assembled]
		,[Volume_Assembled]
		,[Length_Assembled]
		,[Width_Assembled]	
		,[Height_Assembled]
	);

	--hide unneeded records
	UPDATE pm 
	SET Visible = CASE WHEN v.ProductID IS NOT NULL THEN 1 ELSE 0 END 
	FROM dbo.DimProductMaster pm
		LEFT JOIN Fact.ProductIsVisible v ON pm.ProductID = v.ProductID 

	UPDATE pm 
	SET HasInventory = ISNULL(v.HasInventory,0) 
	FROM dbo.DimProductMaster pm
		LEFT JOIN Fact.ProductIsVisible v ON pm.ProductID = v.ProductID 


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
/*
	SELECT * FROM Dim.ProductMaster source
		LEFT JOIN dbo.DimProductMaster target ON source.ProductKey = target.ProductKey
	WHERE --compare all fields or push a fingerprint?...
  		   ISNULL(source.[ProductName],'')					<> ISNULL(target.[ProductName],'')			
		OR ISNULL(source.[ProductDesc],'')					<> ISNULL(target.[ProductDesc],'')			
		OR ISNULL(source.[ProductSort],'')					<> ISNULL(target.[ProductSort],'')			
		OR ISNULL(source.[4 Digit],'')						<> ISNULL(target.[4 Digit],'')				
		OR source.[UOM]										<> target.[UOM]				
		OR source.[Item Type]								<> target.[Item Type]				
		OR source.[SIOP Family]								<> target.[SIOP Family]
		OR source.[Category]								<> target.[Category]				
		OR source.[SubCategory]								<> target.[SubCategory]			
		OR source.[CategoryType]							<> target.[CategoryType]
		OR source.[Brand]									<> target.[Brand]		
		OR source.[Inventory Status Code]					<> target.[Inventory Status Code]
		OR source.[Country of Origin]						<> target.[Country of Origin]
		OR source.[Part Class]								<> target.[Part Class]				
		OR ISNULL(source.[MakeBuy],'')						<> ISNULL(target.[MakeBuy],'')
		OR source.[Contract Manufacturing]					<> target.[Contract Manufacturing]
		OR source.[Channel]									<> target.[Channel]
		OR ISNULL(source.[Part Type],'')					<> ISNULL(target.[Part Type],'')
		OR source.[IMAP]									<> target.[IMAP]
		OR source.[NPD]										<> target.[NPD]
		OR source.[Product Volume]							<> target.[Product Volume]			
		OR ISNULL(source.[List Price],0)					<> ISNULL(target.[List Price],0)				
		OR ISNULL(source.[Royalty License Name],'')			<> ISNULL(target.[Royalty License Name],'')	
		OR ISNULL(source.[Shipping Method],'')				<> ISNULL(target.[Shipping Method],'')	
		OR ISNULL(source.[Cooler Size],'')					<> ISNULL(target.[Cooler Size],'')					
		OR ISNULL(source.FirstProductionDate,'1900-01-01')	<> ISNULL(target.FirstProductionDate,'1900-01-01') 
		OR ISNULL(source.LastProductionDate,'1900-01-01')	<> ISNULL(target.LastProductionDate,'1900-01-01')
		OR ISNULL(source.FirstSaleDate,'1900-01-01')		<> ISNULL(target.FirstSaleDate,'1900-01-01')
		OR ISNULL(source.LastSaleDate,'1900-01-01')			<> ISNULL(target.LastSaleDate,'1900-01-01')
		OR ISNULL(source.CreationDate,'1900-01-01')			<> ISNULL(target.CreationDate,'1900-01-01')
		OR ISNULL(source.ProductGroup,'')					<> ISNULL(target.ProductGroup,'')
		OR ISNULL(source.ProductLine,'')					<> ISNULL(target.ProductLine,'')
		OR ISNULL(source.Department,'')						<> ISNULL(target.Department,'')
		OR ISNULL(source.Dimensions,'')						<> ISNULL(target.Dimensions,'')
		OR ISNULL(source.FootPrint,0)						<> ISNULL(target.FootPrint,0)
		OR ISNULL(source.[Cube],0)							<> ISNULL(target.[Cube],0)
		OR ISNULL(source.[ChildAdult],'')					<> ISNULL(target.[ChildAdult],'')
		OR ISNULL(source.[Size],'')							<> ISNULL(target.[Size],'')
		OR ISNULL(source.[Step2 Custom],'')					<> ISNULL(target.[Step2 Custom],'')
		OR ISNULL(source.[DerivedProductKey],'')			<> ISNULL(target.[DerivedProductKey],'')
		OR ISNULL(source.[PlaceholderName],'')				<> ISNULL(target.[PlaceholderName],'')
		OR ISNULL(source.[PlaceholderDesc],'')				<> ISNULL(target.[PlaceholderDesc],'')
		OR ISNULL(source.[PlaceholderType],'')				<> ISNULL(target.[PlaceholderType],'')
		OR ISNULL(source.[Forecast Segment],'')				<> ISNULL(target.[Forecast Segment],'')
		OR ISNULL(source.[UPC],'')							<> ISNULL(target.[UPC],'')		
		OR ISNULL(source.[4 Digit SKU],'')					<> ISNULL(target.[4 Digit SKU],'')		
		OR ISNULL(source.[ProductStatus],'')				<> ISNULL(target.[ProductStatus],'')		
		OR ISNULL(source.VENDOR_NAME,'')					<> ISNULL(target.VENDOR_NAME,'')			
		OR ISNULL(source.VENDOR_NAME_ALTERNATE,'')			<> ISNULL(target.VENDOR_NAME_ALTERNATE,'')	
		OR ISNULL(source.PLANNER_CODE,'')					<> ISNULL(target.PLANNER_CODE,'')			
		OR ISNULL(source.BUYER_NAME,'')						<> ISNULL(target.BUYER_NAME,'')	
*/

END
GO
