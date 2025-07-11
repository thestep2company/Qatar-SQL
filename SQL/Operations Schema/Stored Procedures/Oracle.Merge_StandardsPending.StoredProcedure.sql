USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_StandardsPending]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_StandardsPending] 
AS BEGIN

		CREATE TABLE #standards (
			[ProductKey] [nvarchar](40) NULL,
			[Organization_Name] [nvarchar](240) NULL,
			[Organization_Code] [nvarchar](3) NULL,
			[Machine] [nvarchar](10) NULL,
			[RoundsPerShift] INT NULL,
			[UnitsPerSpider] [float] NULL,
			[SpidersPerUnit] [float] NULL,
			[MachineHours] [float] NULL,
			[MachineRate] [numeric](4, 2) NULL,
			[MachineCost] [float] NULL,
			[LaborRate] [float] NULL,
			[RotoOperHours] [float] NULL,
			[RotoFloatHours] [float] NULL,
			[TotalRotoHours] [float] NULL,
			[TotalRotoCost] [float] NULL,
			[AssyLaborHours] [float] NULL,
			[AssyLeadHours] [float] NULL,
			[TotalAssyHours] [float] NULL,
			[TotalAssyCost] [float] NULL,
			[TotalProcessingCost] [float] NULL,
			[TotalStandardHours] [float] NULL,
			[Fingerprint] [varchar](32) NOT NULL
		)

		
		;WITH MachineLookup AS (
			SELECT '111' AS PlantKey, '110' AS MachineKey, 40 AS RoundsPerShift UNION
			SELECT '111' AS PlantKey, '190' AS MachineKey, 31 AS RoundsPerShift UNION 
			SELECT '111' AS PlantKey, '220' AS MachineKey, 24 AS RoundsPerShift UNION 
			SELECT '111' AS PlantKey, '280' AS MachineKey, 24 AS RoundsPerShift UNION  --19
			SELECT '122' AS PlantKey, '220' AS MachineKey, 24 AS RoundsPerShift UNION 
			SELECT '122' AS PlantKey, '190' AS MachineKey, 31 AS RoundsPerShift UNION 
			SELECT '133' AS PlantKey, '260' AS MachineKey, 24 AS RoundsPerShift UNION --19
			SELECT '133' AS PlantKey, '190' AS MachineKey, 31 AS RoundsPerShift UNION
			SELECT '133' AS PlantKey, '220' AS MachineKey, 24 AS RoundsPerShift UNION
			SELECT '133' AS PlantKey, '280' AS MachineKey, 24 AS RoundsPerShift UNION --19
			SELECT '122' AS PlantKey, '280' AS MachineKey, 24 AS RoundsPerShift --19
		)
		INSERT INTO #standards
		SELECT  
				SEGMENT1 AS ProductKey 
				,org.Organization_Name 
				,org.Organization_Code
				, MAX(CASE WHEN Resource_Code LIKE 'Machine%' THEN SUBSTRING(Resource_Code,8,10) END) AS Machine
				, SUM(ml.RoundsPerShift) AS RoundsPerShift
				, CASE WHEN ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Machine%' THEN usage_rate END),0) <> 0 THEN 1/(SUM(ml.RoundsPerShift)*4*2*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Machine%' THEN usage_rate END),0)/12) ELSE 0 END AS UnitsPerSpider
				, CASE WHEN ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Machine%' THEN usage_rate END),0) <> 0 THEN (SUM(ml.RoundsPerShift)*4*2*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Machine%' THEN usage_rate END),0)/12) ELSE 0 END AS SpidersPerUnit 
				, ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Machine%' THEN usage_rate END),0) AS MachineHours
				, ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Machine%' THEN resource_rate END),0) AS MachineRate
				, ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Machine%' THEN resource_rate END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Machine%' THEN usage_rate END),0) AS MachineCost
				, ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Roto_%' OR Resource_Code LIKE 'Assy_%' THEN RESOURCE_RATE END),0) AS LaborRate

				, ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Roto_Oper%' THEN usage_rate END),0) AS RotoOperHours
				, ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Roto_Float%' THEN usage_rate END),0) AS RotoFloatHours
				, ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Roto_Oper%' THEN usage_rate END),0) + ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Roto_Float%' THEN usage_rate END),0) AS TotalRotoHours
				, ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Roto_Oper%'  THEN RESOURCE_RATE END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Roto_Oper%' THEN usage_rate END),0) 
				+ ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Roto_Float%' THEN RESOURCE_RATE END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Roto_Float%' THEN usage_rate END),0) AS TotalRotoCost

				, ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Assy_Labor%' OR Resource_Code LIKE 'Trim_Labor%' OR Resource_Code LIKE 'Tan_AS_Lab%' OR Resource_Code LIKE 'Foam_Labor%' THEN usage_rate END),0) AS AssyLaborHours
				, ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Assy_Lead%'  OR Resource_Code LIKE 'Trim_Lead%'  OR Resource_Code LIKE 'Tan_LD_Lab%' OR Resource_Code LIKE 'Foam_Lead%'  THEN usage_rate END),0) AS AssyLeadHours
				, ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Assy_Labor%' OR Resource_Code LIKE 'Trim_Labor%' OR Resource_Code LIKE 'Tan_AS_Lab%' OR Resource_Code LIKE 'Foam_Labor%' THEN usage_rate END),0)
				+ ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Assy_Lead%'  OR Resource_Code LIKE 'Trim_Lead%'  OR Resource_Code LIKE 'Tan_LD_Lab%' OR Resource_Code LIKE 'Foam_Lead%'  THEN usage_rate END),0) AS TotalAssyHours

				, ISNULL(MAX(RESOURCE_RATE),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Assy_Labor%' OR Resource_Code LIKE 'Trim_Labor%' OR Resource_Code LIKE 'Tan_AS_Lab%' OR Resource_Code LIKE 'Foam_Labor%' THEN usage_rate END),0) 
				+ ISNULL(MAX(RESOURCE_RATE),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Assy_Lead%'  OR Resource_Code LIKE 'Trim_Lead%'  OR Resource_Code LIKE 'Tan_LD_Lab%' OR Resource_Code LIKE 'Foam_Lead%'  THEN usage_rate END),0) AS TotalAssyCost
				
				, ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Machine%' THEN resource_rate END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Machine%' THEN usage_rate END),0)
				+ ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Roto_Oper%'  THEN RESOURCE_RATE END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Roto_Oper%'  THEN usage_rate END),0) 
				+ ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Roto_Float%' THEN RESOURCE_RATE END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Roto_Float%' THEN usage_rate END),0)
				+ ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Assy_Labor%' THEN RESOURCE_RATE END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Assy_Labor%' THEN usage_rate END),0)
				+ ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Assy_Lead%'  THEN RESOURCE_RATE END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Assy_Lead%'  THEN usage_rate END),0)

				+ ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Trim_Labor%' THEN RESOURCE_RATE END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Trim_Labor%' THEN usage_rate END),0)
				+ ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Trim_Lead%'  THEN RESOURCE_RATE END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Trim_Lead%'  THEN usage_rate END),0)

				+ ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Tan_AS_Lab%' THEN RESOURCE_RATE END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Tan_AS_Lab%' THEN usage_rate END),0)
				+ ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Tan_LD_Lab%' THEN RESOURCE_RATE END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Tan_LD_Lab%' THEN usage_rate END),0)

				+ ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Foam_Labor%' THEN RESOURCE_RATE END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Foam_Labor%' THEN usage_rate END),0)
				+ ISNULL(MAX(CASE WHEN Resource_Code LIKE 'Foam_Lead%'  THEN RESOURCE_RATE END),0)*ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Foam_Lead%'  THEN usage_rate END),0)


				AS TotalProcessingCost
				, ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Machine%' THEN usage_rate END),0) --machine hours
				+ ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Roto_Oper%'  THEN usage_rate END),0) + ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Roto_Float%' THEN usage_rate END),0) --total roto
				+ ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Assy_Labor%' THEN usage_rate END),0) + ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Assy_Lead%'  THEN usage_rate END),0) --total assembly
				+ ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Trim_Labor%' THEN usage_rate END),0) + ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Trim_Lead%'  THEN usage_rate END),0) --total trim
				+ ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Tan_AS_Lab%' THEN usage_rate END),0) + ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Tan_LD_Lab%' THEN usage_rate END),0) --total 
				+ ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Foam_Labor%' THEN usage_rate END),0) + ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Foam_Lead%' THEN usage_rate END),0)
				AS TotalStandardHours
				,'XXXXXXXXXX' AS Fingerprint
		FROM OPENQUERY(PROD,'
				select distinct
					  msi.Segment1
					, org.organization_code         
					, borv.RESOURCE_SEQ_NUM         Resource_Seq_Num
					, borv.RESOURCE_CODE            Resource_code
					, borv.uom                      UOM
					, borv.STANDARD_RATE_FLAG       stand_rate_flag
					, borv.ASSIGNED_UNITS           Assigned_units
					, borv.USAGE_RATE_OR_AMOUNT     Usage_Rate
					, nvl(crcv.RESOURCE_RATE,0)     RESOURCE_RATE 
				from 
					bom_operational_routings  bor
					, mtl_system_items                  msi
					, BOM_OPERATION_SEQUENCES_V         bosv
					, BOM_OPERATION_RESOURCES_V         borv
					LEFT JOIN CST_RESOURCE_COSTS_V    crcv   on borv.resource_id = crcv.RESOURCE_ID and crcv.cost_type_code = ''Pending''  
					, ORG_ORGANIZATION_DEFINITIONS		org
				where 1=1
					AND bor.assembly_item_id  = msi.inventory_item_id
					AND bor.Organization_ID = msi.Organization_ID
					AND bor.common_routing_sequence_id = bosv.routing_sequence_id 
					AND bosv.effectivity_date <= sysdate AND NVL(  bosv.disable_date, sysdate ) >= sysdate
					AND bosv.include_in_rollup = 1                     
					AND bosv.OPERATION_SEQUENCE_ID = borv.OPERATION_SEQUENCE_ID                 
					AND bor.Organization_ID = org.Organization_ID
					AND borv.STANDARD_RATE_FLAG = 1
			'
		) D
			LEFT JOIN MachineLookup ml ON ml.PlantKey = d.ORGANIZATION_Code AND CASE WHEN Resource_Code LIKE 'Machine%' THEN SUBSTRING(Resource_Code,8,10) END = ml.MachineKey
			LEFT JOIN Oracle.ORG_ORGANIZATION_DEFINITIONS org ON d.Organization_code = org.Organization_code AND org.CurrentRecord = 1
		GROUP BY SEGMENT1, org.Organization_Code ,org.Organization_Name 
		HAVING ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Machine%' THEN usage_rate END),0) 
				+ ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Roto_Oper%'  THEN usage_rate END),0) + ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Roto_Float%' THEN usage_rate END),0) 
				+ ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Assy_Labor%' THEN usage_rate END),0) + ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Assy_Lead%'  THEN usage_rate END),0) 
				+ ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Trim_Labor%' THEN usage_rate END),0) + ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Trim_Lead%'  THEN usage_rate END),0) 
				+ ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Tan_AS_Lab%' THEN usage_rate END),0) + ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Tan_LD_Lab%' THEN usage_rate END),0) 
				+ ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Foam_Labor%' THEN usage_rate END),0) + ISNULL(SUM(CASE WHEN Resource_Code LIKE 'Foam_Lead%' THEN usage_rate END),0) <> 0 
			

		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Standards','Oracle') SELECT @columnList
		*/
		UPDATE #standards
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				 CAST(ISNULL(ProductKey,'') AS VARCHAR(40)) +  CAST(ISNULL(Organization_Name,'') AS VARCHAR(240)) +  CAST(ISNULL(Organization_Code,'') AS VARCHAR(3)) +  CAST(ISNULL(Machine,'') AS VARCHAR(10)) +  CAST(ISNULL(RoundsPerShift,'0') AS VARCHAR(100)) +  CAST(ISNULL(UnitsPerSpider,'0') AS VARCHAR(100)) +  CAST(ISNULL(SpidersPerUnit,'0') AS VARCHAR(100)) +  CAST(ISNULL(MachineHours,'0') AS VARCHAR(100)) +  CAST(ISNULL(MachineRate,'0') AS VARCHAR(100)) +  CAST(ISNULL(MachineCost,'0') AS VARCHAR(100)) +  CAST(ISNULL(LaborRate,'0') AS VARCHAR(100)) +  CAST(ISNULL(RotoOperHours,'0') AS VARCHAR(100)) +  CAST(ISNULL(RotoFloatHours,'0') AS VARCHAR(100)) +  CAST(ISNULL(TotalRotoHours,'0') AS VARCHAR(100)) +  CAST(ISNULL(TotalRotoCost,'0') AS VARCHAR(100)) +  CAST(ISNULL(AssyLaborHours,'0') AS VARCHAR(100)) +  CAST(ISNULL(AssyLeadHours,'0') AS VARCHAR(100)) +  CAST(ISNULL(TotalAssyHours,'0') AS VARCHAR(100)) +  CAST(ISNULL(TotalAssyCost,'0') AS VARCHAR(100)) +  CAST(ISNULL(TotalProcessingCost,'0') AS VARCHAR(100)) +  CAST(ISNULL(TotalStandardHours,'0') AS VARCHAR(100)) 
			),1)),3,32);

		--expire records outside the merge

		INSERT INTO Oracle.[StandardsPending] (
				   [ProductKey]
				  ,[Organization_Name]
				  ,[Organization_Code]
				  ,[Machine]
				  ,[RoundsPerShift]
				  ,[UnitsPerSpider]
				  ,[SpidersPerUnit]
				  ,[MachineHours]
				  ,[MachineRate]
				  ,[MachineCost]
				  ,[LaborRate]
				  ,[RotoOperHours]
				  ,[RotoFloatHours]
				  ,[TotalRotoHours]
				  ,[TotalRotoCost]
				  ,[AssyLaborHours]
				  ,[AssyLeadHours]
				  ,[TotalAssyHours]
				  ,[TotalAssyCost]
				  ,[TotalProcessingCost]
				  ,[TotalStandardHours]
				  ,[Fingerprint]
		)
			SELECT 
					a.[ProductKey]
					,a.[Organization_Name]
					,a.[Organization_Code]
					,a.[Machine]
					,a.[RoundsPerShift]
					,a.[UnitsPerSpider]
					,a.[SpidersPerUnit]
					,a.[MachineHours]
					,a.[MachineRate]
					,a.[MachineCost]
					,a.[LaborRate]
					,a.[RotoOperHours]
					,a.[RotoFloatHours]
					,a.[TotalRotoHours]
					,a.[TotalRotoCost]
					,a.[AssyLaborHours]
					,a.[AssyLeadHours]
					,a.[TotalAssyHours]
					,a.[TotalAssyCost]
					,a.[TotalProcessingCost]
					,a.[TotalStandardHours]
					,a.[Fingerprint]
			FROM (
				MERGE Oracle.[StandardsPending] b
				USING (SELECT * FROM #standards) a
				ON a.ProductKey = b.ProductKey AND a.Organization_Code = b.Organization_Code AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [ProductKey]
					  ,[Organization_Name]
					  ,[Organization_Code]
					  ,[Machine]
					  ,[RoundsPerShift]
					  ,[UnitsPerSpider]
					  ,[SpidersPerUnit]
					  ,[MachineHours]
					  ,[MachineRate]
					  ,[MachineCost]
					  ,[LaborRate]
					  ,[RotoOperHours]
					  ,[RotoFloatHours]
					  ,[TotalRotoHours]
					  ,[TotalRotoCost]
					  ,[AssyLaborHours]
					  ,[AssyLeadHours]
					  ,[TotalAssyHours]
					  ,[TotalAssyCost]
					  ,[TotalProcessingCost]
					  ,[TotalStandardHours]
					  ,[Fingerprint]
				)
				VALUES (
					   a.[ProductKey]
					  ,a.[Organization_Name]
					  ,a.[Organization_Code]
					  ,a.[Machine]
					  ,a.[RoundsPerShift]
					  ,a.[UnitsPerSpider]
					  ,a.[SpidersPerUnit]
					  ,a.[MachineHours]
					  ,a.[MachineRate]
					  ,a.[MachineCost]
					  ,a.[LaborRate]
					  ,a.[RotoOperHours]
					  ,a.[RotoFloatHours]
					  ,a.[TotalRotoHours]
					  ,a.[TotalRotoCost]
					  ,a.[AssyLaborHours]
					  ,a.[AssyLeadHours]
					  ,a.[TotalAssyHours]
					  ,a.[TotalAssyCost]
					  ,a.[TotalProcessingCost]
					  ,a.[TotalStandardHours]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[ProductKey]
					  ,a.[Organization_Name]
					  ,a.[Organization_Code]
					  ,a.[Machine]
					  ,a.[RoundsPerShift]
					  ,a.[UnitsPerSpider]
					  ,a.[SpidersPerUnit]
					  ,a.[MachineHours]
					  ,a.[MachineRate]
					  ,a.[MachineCost]
					  ,a.[LaborRate]
					  ,a.[RotoOperHours]
					  ,a.[RotoFloatHours]
					  ,a.[TotalRotoHours]
					  ,a.[TotalRotoCost]
					  ,a.[AssyLaborHours]
					  ,a.[AssyLeadHours]
					  ,a.[TotalAssyHours]
					  ,a.[TotalAssyCost]
					  ,a.[TotalProcessingCost]
					  ,a.[TotalStandardHours]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		DROP TABLE #standards
END
GO
