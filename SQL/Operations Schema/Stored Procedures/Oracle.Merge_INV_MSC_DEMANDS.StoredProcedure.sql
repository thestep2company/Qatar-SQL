USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_INV_MSC_DEMANDS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_INV_MSC_DEMANDS] AS BEGIN

	DECLARE @startDate DATETIME = GETDATE()

	CREATE TABLE #MSC_Demands (
		[DEMAND_ID] [float] NOT NULL,
		[ITEM_NAME] [nvarchar](250) NULL,
		[DESCRIPTION] [nvarchar](240) NULL,
		[START_OF_WEEK] [datetime2](7) NULL,
		[USING_ASSEMBLY_DEMAND_DATE] [datetime2](7) NOT NULL,
		[USING_REQUIREMENT_QUANTITY] [float] NOT NULL,
		[ORGANIZATION_ID] [float] NOT NULL,
		[SOURCE_ORGANIZATION_ID] [float] NULL,
		[DEMAND_TYPE] [float] NOT NULL,
		[ORIGINATION_TYPE] [float] NULL,
		[DEMAND_PRIORITY] [float] NULL,
		[PLAN_ID] [float] NOT NULL,
		[PROMISE_DATE] [datetime2](7) NULL,
		[DEMAND_CLASS] [nvarchar](34) NULL,
		[FIRM_DATE] [datetime2](7) NULL,
		[ROW_ID] VARCHAR(50) NOT NULL,
		[FINGERPRINT] VARCHAR(32) NOT NULL
	)

	create clustered index rowID on #msc_demands (Row_ID)
	create nonclustered index fingerprint on #msc_demands (Fingerprint)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #MSC_Demands
	SELECT *, 'XXXXXX' FROM OPENQUERY(ASCP,
	'	select 
		md.demand_id
		,msi.item_name
		,msi.description
		,md.using_assembly_demand_date - to_char(md.using_assembly_demand_date,''D'')+1  START_OF_WEEK
		,md.using_assembly_demand_date
		,md.USING_REQUIREMENT_QUANTITY
		,md.organization_id
		,md.source_organization_id
		,md.demand_type
		,md.origination_type
		,md.demand_Priority
		,md.plan_id
		,md.promise_date
		,md.demand_class
		,md.firm_date
		,md.ROWID
	from msc_demands  md
		, msc_system_items msi
	where 1=1
		and md.inventory_item_id = msi.inventory_item_id
		and md.plan_id = msi.plan_id
		and md.organization_id = msi.organization_id
		and md.USING_REQUIREMENT_QUANTITY <> 0
		and md.plan_id = 4
		and ( md.source_organization_id < 0 or md.organization_id = md.source_organization_id  )
		and msi.item_name < ''400000'' 
	'
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('MSC_Demands','Oracle') SELECT @columnList
	*/
	UPDATE #MSC_Demands
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			  CAST(ISNULL([DEMAND_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([ITEM_NAME],'') AS VARCHAR(250)) +  CAST(ISNULL([DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([START_OF_WEEK],'') AS VARCHAR(100)) +  CAST(ISNULL([USING_ASSEMBLY_DEMAND_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([USING_REQUIREMENT_QUANTITY],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORGANIZATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([SOURCE_ORGANIZATION_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([DEMAND_TYPE],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORIGINATION_TYPE],'0') AS VARCHAR(100)) +  CAST(ISNULL([DEMAND_PRIORITY],'0') AS VARCHAR(100)) +  CAST(ISNULL([PLAN_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PROMISE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([DEMAND_CLASS],'') AS VARCHAR(34)) +  CAST(ISNULL([FIRM_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([ROW_ID],'') AS VARCHAR(50)) 
		),1)),3,32);


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Expire', GETDATE()


	--expire records outside the merge
	UPDATE a
	SET EndDate = @startDate, CurrentRecord = 0
	--SELECT COUNT(*)
	FROM Oracle.MSC_Demands a
		LEFT JOIN #MSC_Demands b ON a.Row_ID = b.Row_ID
	WHERE b.Row_ID IS NULL AND a.EndDate IS NULL

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.MSC_Demands (
	   [DEMAND_ID]
      ,[ITEM_NAME]
      ,[DESCRIPTION]
      ,[START_OF_WEEK]
      ,[USING_ASSEMBLY_DEMAND_DATE]
      ,[USING_REQUIREMENT_QUANTITY]
      ,[ORGANIZATION_ID]
      ,[SOURCE_ORGANIZATION_ID]
      ,[DEMAND_TYPE]
      ,[ORIGINATION_TYPE]
      ,[DEMAND_PRIORITY]
      ,[PLAN_ID]
      ,[PROMISE_DATE]
      ,[DEMAND_CLASS]
      ,[FIRM_DATE]
      ,[ROW_ID]
      ,[Fingerprint]
	)
		SELECT 
			   a.[DEMAND_ID]
			  ,a.[ITEM_NAME]
			  ,a.[DESCRIPTION]
			  ,a.[START_OF_WEEK]
			  ,a.[USING_ASSEMBLY_DEMAND_DATE]
			  ,a.[USING_REQUIREMENT_QUANTITY]
			  ,a.[ORGANIZATION_ID]
			  ,a.[SOURCE_ORGANIZATION_ID]
			  ,a.[DEMAND_TYPE]
			  ,a.[ORIGINATION_TYPE]
			  ,a.[DEMAND_PRIORITY]
			  ,a.[PLAN_ID]
			  ,a.[PROMISE_DATE]
			  ,a.[DEMAND_CLASS]
			  ,a.[FIRM_DATE]
			  ,a.[ROW_ID]
			  ,a.[Fingerprint]
		FROM (
			MERGE Oracle.MSC_Demands b
			USING (SELECT * FROM #MSC_Demands) a
			ON a.Row_ID = b.Row_ID AND b.CurrentRecord = 1 AND b.EndDate IS NULL--swap with business key of table
			WHEN NOT MATCHED BY TARGET 
			THEN INSERT (
				   [DEMAND_ID]
				  ,[ITEM_NAME]
				  ,[DESCRIPTION]
				  ,[START_OF_WEEK]
				  ,[USING_ASSEMBLY_DEMAND_DATE]
				  ,[USING_REQUIREMENT_QUANTITY]
				  ,[ORGANIZATION_ID]
				  ,[SOURCE_ORGANIZATION_ID]
				  ,[DEMAND_TYPE]
				  ,[ORIGINATION_TYPE]
				  ,[DEMAND_PRIORITY]
				  ,[PLAN_ID]
				  ,[PROMISE_DATE]
				  ,[DEMAND_CLASS]
				  ,[FIRM_DATE]
				  ,[ROW_ID]
				  ,[Fingerprint]
			)
			VALUES (
				   a.[DEMAND_ID]
				  ,a.[ITEM_NAME]
				  ,a.[DESCRIPTION]
				  ,a.[START_OF_WEEK]
				  ,a.[USING_ASSEMBLY_DEMAND_DATE]
				  ,a.[USING_REQUIREMENT_QUANTITY]
				  ,a.[ORGANIZATION_ID]
				  ,a.[SOURCE_ORGANIZATION_ID]
				  ,a.[DEMAND_TYPE]
				  ,a.[ORIGINATION_TYPE]
				  ,a.[DEMAND_PRIORITY]
				  ,a.[PLAN_ID]
				  ,a.[PROMISE_DATE]
				  ,a.[DEMAND_CLASS]
				  ,a.[FIRM_DATE]
				  ,a.[ROW_ID]
				  ,a.[Fingerprint]
			)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint 
			THEN UPDATE SET b.EndDate=@startDate
				,b.CurrentRecord=0
			----Existing records that are no longer in the data source (full compare only)
			--WHEN NOT MATCHED BY SOURCE 
			--THEN UPDATE SET b.EndDate=@startDate, CurrentRecord = 0
			OUTPUT 
				   a.[DEMAND_ID]
				  ,a.[ITEM_NAME]
				  ,a.[DESCRIPTION]
				  ,a.[START_OF_WEEK]
				  ,a.[USING_ASSEMBLY_DEMAND_DATE]
				  ,a.[USING_REQUIREMENT_QUANTITY]
				  ,a.[ORGANIZATION_ID]
				  ,a.[SOURCE_ORGANIZATION_ID]
				  ,a.[DEMAND_TYPE]
				  ,a.[ORIGINATION_TYPE]
				  ,a.[DEMAND_PRIORITY]
				  ,a.[PLAN_ID]
				  ,a.[PROMISE_DATE]
				  ,a.[DEMAND_CLASS]
				  ,a.[FIRM_DATE]
				  ,a.[ROW_ID]
				  ,a.[Fingerprint]
				  ,$Action AS Action
		) a
		WHERE Action = 'Update' 
		;

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END

GO
