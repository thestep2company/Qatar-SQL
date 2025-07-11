USE [Operations]
GO
/****** Object:  StoredProcedure [EDI].[Merge_CustomerInventory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [EDI].[Merge_CustomerInventory] AS BEGIN

		CREATE TABLE #inventory (
			[RECNUM] [decimal](8, 0) NOT NULL,
			[Active] [varchar](1) NOT NULL,
			[AccountNumber] [varchar](50) NOT NULL,
			[PartID] [varchar](50) NOT NULL,
			[InventoryItemID] [varchar](50) NOT NULL,
			[PartDescription] [varchar](240) NOT NULL,
			[UPCCode] [varchar](50) NOT NULL,
			[OrgCode] [varchar](50) NOT NULL,
			[CustomerPartID] [varchar](50) NOT NULL,
			[CustomerSKU] [varchar](50) NULL,
			[Quantity] [decimal](18, 0) NOT NULL,
			[UnitPrice] [decimal](18, 6) NOT NULL,
			[EffectiveDate] [datetime] NULL,
			[Discontinuedate] [datetime] NULL,
			[Discontinued] [varchar](50) NULL,
			[MinimumDaysShip] [decimal](10, 0) NULL,
			[MaximumDaysShip] [decimal](10, 0) NULL,
			[CustomerWarehouseCode] [varchar](50) NULL,
			[CheckOpenOrders] [varchar](1) NOT NULL,
			[CustomerQtyConversion] [varchar](1) NOT NULL,
			[ForecastQty] [decimal](10, 0) NOT NULL,
			[ForecastPercent] [decimal](18, 6) NOT NULL,
			[UseManualQty] [varchar](1) NOT NULL,
			[DemandClass] [varchar](50) NOT NULL,
			[ForecastPartID] [varchar](50) NOT NULL,
			[LastSendQty] [decimal](18, 0) NOT NULL,
			[LastSendDate] [datetime] NOT NULL,
			[Fingerprint] [varchar](32) NOT NULL
		)

		INSERT INTO #inventory
		SELECT 	[RECNUM]
				,[Active]
				,[AccountNumber]
				,[PartID]
				,[InventoryItemID]
				,[PartDescription]
				,[UPCCode]
				,[OrgCode]
				,[CustomerPartID]
				,[CustomerSKU]
				,[Quantity]
				,[UnitPrice]
				,[EffectiveDate]
				,[Discontinuedate]
				,[Discontinued]
				,[MinimumDaysShip]
				,[MaximumDaysShip]
				,[CustomerWarehouseCode]
				,[CheckOpenOrders]
				,[CustomerQtyConversion]
				,[ForecastQty]
				,[ForecastPercent]
				,[UseManualQty]
				,[DemandClass]
				,[ForecastPartID]
				,[LastSendQty]
				,[LastSendDate]
				,'XXX' AS Fingerprint	
		FROM OPENQUERY(DIEHARD,
			'SELECT 
				[RECNUM]
			  ,[Active]
			  ,[AccountNumber]
			  ,[PartID]
			  ,[InventoryItemID]
			  ,[PartDescription]
			  ,[UPCCode]
			  ,[OrgCode]
			  ,[CustomerPartID]
			  ,[CustomerSKU]
			  ,[Quantity]
			  ,[UnitPrice]
			  ,[StartDate] AS [EffectiveDate]
			  ,[Discontinuedate]
			  ,[Discontinued]
			  ,[MinimumDaysShip]
			  ,[MaximumDaysShip]
			  ,[CustomerWarehouseCode]
			  ,[CheckOpenOrders]
			  ,[CustomerQtyConversion]
			  ,[ForecastQty]
			  ,[ForecastPercent]
			  ,[UseManualQty]
			  ,[DemandClass]
			  ,[ForecastPartID]
			  ,[LastSendQty]
			  ,[LastSendDate]	
			FROM WinEDI.dbo.CustomerInventory
			'
		)

		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('CustomerInventory','EDI') SELECT @columnList
		*/
		UPDATE #inventory
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				  CAST(ISNULL([RecNum],'0') AS VARCHAR(100)) +  CAST(ISNULL([Active],'') AS VARCHAR(1)) +  CAST(ISNULL([AccountNumber],'') AS VARCHAR(50)) +  CAST(ISNULL([PartID],'') AS VARCHAR(50)) +  CAST(ISNULL([PartDescription],'') AS VARCHAR(240)) +  CAST(ISNULL([UPCCode],'') AS VARCHAR(50)) +  CAST(ISNULL([CustomerPartID],'') AS VARCHAR(50)) +  CAST(ISNULL([CustomerSKU],'') AS VARCHAR(50)) +  CAST(ISNULL([Quantity],'0') AS VARCHAR(100)) +  CAST(ISNULL([UnitPrice],'0') AS VARCHAR(100)) +  CAST(ISNULL([EffectiveDate],'') AS VARCHAR(100)) +  CAST(ISNULL([Discontinuedate],'') AS VARCHAR(100)) +  CAST(ISNULL([Discontinued],'') AS VARCHAR(50)) +  CAST(ISNULL([CustomerWarehouseCode],'') AS VARCHAR(50)) +  CAST(ISNULL([InventoryItemID],'') AS VARCHAR(50)) +  CAST(ISNULL([OrgCode],'') AS VARCHAR(50)) +  CAST(ISNULL([MinimumDaysShip],'0') AS VARCHAR(100)) +  CAST(ISNULL([MaximumDaysShip],'0') AS VARCHAR(100)) +  CAST(ISNULL([CheckOpenOrders],'') AS VARCHAR(1)) +  CAST(ISNULL([CustomerQtyConversion],'') AS VARCHAR(1)) +  CAST(ISNULL([ForecastQty],'0') AS VARCHAR(100)) +  CAST(ISNULL([ForecastPercent],'0') AS VARCHAR(100)) +  CAST(ISNULL([UseManualQty],'') AS VARCHAR(1)) +  CAST(ISNULL([DemandClass],'') AS VARCHAR(50)) +  CAST(ISNULL([ForecastPartID],'') AS VARCHAR(50)) +  CAST(ISNULL([LastSendQty],'0') AS VARCHAR(100)) +  CAST(ISNULL([LastSendDate],'') AS VARCHAR(100)) 
			),1)),3,32);

		--expire records outside the merge
		INSERT INTO EDI.[CustomerInventory] (
			   [RecNum]
			  ,[Active]
			  ,[AccountNumber]
			  ,[PartID]
			  ,[PartDescription]
			  ,[UPCCode]
			  ,[CustomerPartID]
			  ,[CustomerSKU]
			  ,[Quantity]
			  ,[UnitPrice]
			  ,[EffectiveDate]
			  ,[Discontinuedate]
			  ,[Discontinued]
			  ,[CustomerWarehouseCode]
			  ,[InventoryItemID]
			  ,[OrgCode]
			  ,[MinimumDaysShip]
			  ,[MaximumDaysShip]
			  ,[CheckOpenOrders]
			  ,[CustomerQtyConversion]
			  ,[ForecastQty]
			  ,[ForecastPercent]
			  ,[UseManualQty]
			  ,[DemandClass]
			  ,[ForecastPartID]
			  ,[LastSendQty]
			  ,[LastSendDate]
			  ,Fingerprint
		)
			SELECT 
					 a.[RecNum]
					,a.[Active]
					,a.[AccountNumber]
					,a.[PartID]
					,a.[PartDescription]
					,a.[UPCCode]
					,a.[CustomerPartID]
					,a.[CustomerSKU]
					,a.[Quantity]
					,a.[UnitPrice]
					,a.[EffectiveDate]
					,a.[Discontinuedate]
					,a.[Discontinued]
					,a.[CustomerWarehouseCode]
					,a.[InventoryItemID]
					,a.[OrgCode]
					,a.[MinimumDaysShip]
					,a.[MaximumDaysShip]
					,a.[CheckOpenOrders]
					,a.[CustomerQtyConversion]
					,a.[ForecastQty]
					,a.[ForecastPercent]
					,a.[UseManualQty]
					,a.[DemandClass]
					,a.[ForecastPartID]
					,a.[LastSendQty]
					,a.[LastSendDate]
					,a.Fingerprint
			FROM (
				MERGE EDI.[CustomerInventory] b
				USING (SELECT * FROM #inventory) a
				ON a.RecNum = b.RecNum AND a.Active = b.Active AND a.AccountNumber = b.AccountNumber AND a.PartID = b.PartID AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   	[RecNum]
					  ,[Active]
					  ,[AccountNumber]
					  ,[PartID]
					  ,[PartDescription]
					  ,[UPCCode]
					  ,[CustomerPartID]
					  ,[CustomerSKU]
					  ,[Quantity]
					  ,[UnitPrice]
					  ,[EffectiveDate]
					  ,[Discontinuedate]
					  ,[Discontinued]
					  ,[CustomerWarehouseCode]
					  ,[InventoryItemID]
					  ,[OrgCode]
					  ,[MinimumDaysShip]
					  ,[MaximumDaysShip]
					  ,[CheckOpenOrders]
					  ,[CustomerQtyConversion]
					  ,[ForecastQty]
					  ,[ForecastPercent]
					  ,[UseManualQty]
					  ,[DemandClass]
					  ,[ForecastPartID]
					  ,[LastSendQty]
					  ,[LastSendDate]
					  ,Fingerprint
				)
				VALUES (
					     a.[RecNum]
						,a.[Active]
						,a.[AccountNumber]
						,a.[PartID]
						,a.[PartDescription]
						,a.[UPCCode]
						,a.[CustomerPartID]
						,a.[CustomerSKU]
						,a.[Quantity]
						,a.[UnitPrice]
						,a.[EffectiveDate]
						,a.[Discontinuedate]
						,a.[Discontinued]
						,a.[CustomerWarehouseCode]
						,a.[InventoryItemID]
						,a.[OrgCode]
						,a.[MinimumDaysShip]
						,a.[MaximumDaysShip]
						,a.[CheckOpenOrders]
						,a.[CustomerQtyConversion]
						,a.[ForecastQty]
						,a.[ForecastPercent]
						,a.[UseManualQty]
						,a.[DemandClass]
						,a.[ForecastPartID]
						,a.[LastSendQty]
						,a.[LastSendDate]
						,a.Fingerprint
				)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
			THEN UPDATE SET b.EndDate=GETDATE()
				,b.CurrentRecord=0
			--Existing records that are no longer in the data source (full compare only)
			WHEN NOT MATCHED BY SOURCE AND b.CurrentRecord = 1
			THEN UPDATE SET b.EndDate=GETDATE()
			,b.CurrentRecord=0
				OUTPUT 
					     a.[RecNum]
						,a.[Active]
						,a.[AccountNumber]
						,a.[PartID]
						,a.[PartDescription]
						,a.[UPCCode]
						,a.[CustomerPartID]
						,a.[CustomerSKU]
						,a.[Quantity]
						,a.[UnitPrice]
						,a.[EffectiveDate]
						,a.[Discontinuedate]
						,a.[Discontinued]
						,a.[CustomerWarehouseCode]
						,a.[InventoryItemID]
						,a.[OrgCode]
						,a.[MinimumDaysShip]
						,a.[MaximumDaysShip]
						,a.[CheckOpenOrders]
						,a.[CustomerQtyConversion]
						,a.[ForecastQty]
						,a.[ForecastPercent]
						,a.[UseManualQty]
						,a.[DemandClass]
						,a.[ForecastPartID]
						,a.[LastSendQty]
						,a.[LastSendDate]
						,a.Fingerprint
					  ,$Action AS Action
			) a
			WHERE Action = 'Update' AND Fingerprint IS NOT NULL
			;

		DROP TABLE #inventory

END
GO
