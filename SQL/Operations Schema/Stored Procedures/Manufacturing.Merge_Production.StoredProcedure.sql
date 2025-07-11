USE [Operations]
GO
/****** Object:  StoredProcedure [Manufacturing].[Merge_Production]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--UPDATE Manufacturing.Production SET EndDate = GETDATE(), CurrentRecord = 0 WHERE TRANS_DATE_TIME >= DATEADD(DAY,-4,GETDATE())

	
	CREATE PROCEDURE [Manufacturing].[Merge_Production] AS BEGIN

		--clear current shift out
		DELETE FROM [Operations].[Manufacturing].[Production] WHERE TRANS_DATE_TIME >= DATEADD(HOUR,6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))

		CREATE TABLE #Production (
				[PRODUCTION_ID] [int] NOT NULL,
				[TRANS_DATE_TIME] [datetime] NOT NULL,
				[PART_NUMBER] [varchar](50) NULL,
				[PART_DESCRIPTION] [varchar](100) NULL,
				[PRODUCTION_QTY] [int] NULL,
				[LIST_LESS_7] [real] NULL,
				[TOTAL_PRICE] [real] NULL,
				[PLANNER_CODE] [varchar](50) NULL,
				[RESOURCE_HOURS] [real] NULL,
				[TOTAL_MACHINE_HOURS] [real] NULL,
				[FG_RESIN_WGT] [real] NULL,
				[FG_TOTAL_RESIN] [real] NULL,
				[UNIT_VOLUME] [real] NULL,
				[TOTAL_VOLUME] [real] NULL,
				[ORG_CODE] [varchar](3) NULL,
				[ORG_NAME] [varchar](50) NULL,
				[SHIFT] [char](1) NULL,
				[STD_COST] [real] NULL,
				[RESOURCE_COST] [real] NULL,
				[EARNED_OVERHEAD] [real] NULL,
				[MATERIAL_COST] [real] NULL,
				[MATERIAL_OVERHEAD_COST] [real] NULL,
				[OUTSIDE_PROCESSING_COST] [real] NULL,
				[TRANSACTION_ID] INT NULL,
				[LINE_CODE] [VARCHAR](25) NULL,
				[LINE_DESCRIPTION] [VARCHAR](50) NULL,
				[SHIFT_ID] INT NULL,
				[Fingerprint] [varchar](32) NULL,
		)

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

		INSERT INTO #Production (
			   [PRODUCTION_ID]
			  ,[TRANS_DATE_TIME]
			  ,[PART_NUMBER]
			  ,[PART_DESCRIPTION]
			  ,[PRODUCTION_QTY]
			  ,[LIST_LESS_7]
			  ,[TOTAL_PRICE]
			  ,[PLANNER_CODE]
			  ,[RESOURCE_HOURS]
			  ,[TOTAL_MACHINE_HOURS]
			  ,[FG_RESIN_WGT]
			  ,[FG_TOTAL_RESIN]
			  ,[UNIT_VOLUME]
			  ,[TOTAL_VOLUME]
			  ,[ORG_CODE]
			  ,[ORG_NAME]
			  ,[SHIFT]
			  ,[STD_COST]
			  ,[RESOURCE_COST]
			  ,[EARNED_OVERHEAD]
			  ,[MATERIAL_COST]
			  ,[MATERIAL_OVERHEAD_COST]
			  ,[OUTSIDE_PROCESSING_COST]
			  ,[TRANSACTION_ID]
			  ,[LINE_CODE]
			  ,[LINE_DESCRIPTION]
			  ,[SHIFT_ID]
			  ,[Fingerprint]
		)
		SELECT 
				[PRODUCTION_ID]
				,[TRANS_DATE_TIME]
				,[PART_NUMBER]
				,[PART_DESCRIPTION]
				,[PRODUCTION_QTY]
				,[LIST_LESS_7]
				,[TOTAL_PRICE]
				,[PLANNER_CODE]
				,[RESOURCE_HOURS]
				,[TOTAL_MACHINE_HOURS]
				,[FG_RESIN_WGT]
				,[FG_TOTAL_RESIN]
				,[UNIT_VOLUME]
				,[TOTAL_VOLUME]
				,[ORG_CODE]
				,[ORG_NAME]
				,[SHIFT]
				,[STD_COST]
				,[RESOURCE_COST]
				,[EARNED_OVERHEAD]
				,[MATERIAL_COST]
				,[MATERIAL_OVERHEAD_COST]
				,[OUTSIDE_PROCESSING_COST]
			    ,[TRANSACTION_ID]
			    ,[LINE_CODE]
			    ,[LINE_DESCRIPTION]
				,NULL AS [SHIFT_ID]
				,'XXX' AS Fingerprint
		FROM OPENQUERY(FINDLAND,
			 'SELECT 
				   [PRODUCTION_ID]
				  ,[TRANS_DATE_TIME]
				  ,[PART_NUMBER]
				  ,[PART_DESCRIPTION]
				  ,[PRODUCTION_QTY]
				  ,[LIST_LESS_7]
				  ,[TOTAL_PRICE]
				  ,[PLANNER_CODE]
				  ,[RESOURCE_HOURS]
				  ,[TOTAL_MACHINE_HOURS]
				  ,[FG_RESIN_WGT]
				  ,[FG_TOTAL_RESIN]
				  ,[UNIT_VOLUME]
				  ,[TOTAL_VOLUME]
				  ,[ORG_CODE]
				  ,[ORG_NAME]
				  ,[SHIFT]
				  ,[STD_COST]
				  ,[RESOURCE_COST]
				  ,[EARNED_OVERHEAD]
				  ,[MATERIAL_COST]
				  ,[MATERIAL_OVERHEAD_COST]
				  ,[OUTSIDE_PROCESSING_COST]
				  ,[TRANSACTION_ID]
				  ,[LINE_CODE]
				  ,[LINE_DESCRIPTION]
			 FROM [Manufacturing].[dbo].[PRODUCTION]
			 WHERE Trans_Date_Time >= DATEADD(DAY,-2,GETDATE()) 
				AND Transaction_ID IS NOT NULL
			'
		)

		UPDATE pro
		SET SHIFT_ID = s2.Shift_ID
		FROM #Production pro
			LEFT JOIN Manufacturing.Shift s2 ON pro.Shift = s2.Shift AND pro.ORG_CODE = s2.Org AND pro.TRANS_DATE_TIME >= s2.Start_Date_Time AND pro.TRANS_DATE_TIME < s2.End_Date_Time AND s2.CurrentRecord = 1

		UPDATE s 
		SET HasProduction = 1
		FROM [Manufacturing].[Shift] s
			INNER JOIN #production p ON s.Org = p.ORG_CODE AND s.Shift = p.SHIFT AND p.TRANS_DATE_TIME BETWEEN s.Start_Date_Time AND s.End_Date_Time
		WHERE s.CurrentRecord = 1

		--/* until query is corrected by IT */
		--EXEC Oracle.Merge_ResinWeight
		
		--UPDATE p1
		--SET p1.FG_RESIN_WGT = p2.FG_RESIN_WGT
		--	,p1.FG_TOTAL_RESIN = p2.FG_TOTAL_RESIN
		--FROM #Production p1
		--	INNER JOIN Oracle.ProductionResinPatch p2 ON p1.TRANSACTION_ID = p2.TRANSACTION_ID
		--WHERE p1.FG_TOTAL_RESIN = 0  AND (p2.FG_RESIN_WGT <> 0 OR p2.FG_TOTAL_RESIN <> 0)


		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Production','Manufacturing') SELECT @columnList
		*/

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

		UPDATE #Production
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				  CAST(ISNULL(PRODUCTION_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(TRANS_DATE_TIME,'') AS VARCHAR(100)) +  CAST(ISNULL(PART_NUMBER,'') AS VARCHAR(50)) +  CAST(ISNULL(PART_DESCRIPTION,'') AS VARCHAR(100)) +  CAST(ISNULL(PRODUCTION_QTY,'0') AS VARCHAR(100)) +  CAST(ISNULL(LIST_LESS_7,'0') AS VARCHAR(100)) +  CAST(ISNULL(TOTAL_PRICE,'0') AS VARCHAR(100)) +  CAST(ISNULL(PLANNER_CODE,'') AS VARCHAR(50)) +  CAST(ISNULL(RESOURCE_HOURS,'0') AS VARCHAR(100)) +  CAST(ISNULL(TOTAL_MACHINE_HOURS,'0') AS VARCHAR(100)) +  CAST(ISNULL(FG_RESIN_WGT,'0') AS VARCHAR(100)) +  CAST(ISNULL(FG_TOTAL_RESIN,'0') AS VARCHAR(100)) +  CAST(ISNULL(UNIT_VOLUME,'0') AS VARCHAR(100)) +  CAST(ISNULL(TOTAL_VOLUME,'0') AS VARCHAR(100)) +  CAST(ISNULL(ORG_CODE,'') AS VARCHAR(3)) +  CAST(ISNULL(ORG_NAME,'') AS VARCHAR(50)) +  CAST(ISNULL(SHIFT,'') AS VARCHAR(1)) +  CAST(ISNULL(STD_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(RESOURCE_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(EARNED_OVERHEAD,'0') AS VARCHAR(100)) +  CAST(ISNULL(MATERIAL_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(MATERIAL_OVERHEAD_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(OUTSIDE_PROCESSING_COST,'0') AS VARCHAR(100)) +  CAST(ISNULL(TRANSACTION_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(LINE_CODE,'') AS VARCHAR(32)) +  CAST(ISNULL(LINE_DESCRIPTION,'') AS VARCHAR(50)) +  CAST(ISNULL(Shift_ID,'0') AS VARCHAR(100)) 
			),1)),3,32);

		--expire records outside the merge
		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO Manufacturing.Production (
				 [PRODUCTION_ID]
				,[TRANS_DATE_TIME]
				,[PART_NUMBER]
				,[PART_DESCRIPTION]
				,[PRODUCTION_QTY]
				,[LIST_LESS_7]
				,[TOTAL_PRICE]
				,[PLANNER_CODE]
				,[RESOURCE_HOURS]
				,[TOTAL_MACHINE_HOURS]
				,[FG_RESIN_WGT]
				,[FG_TOTAL_RESIN]
				,[UNIT_VOLUME]
				,[TOTAL_VOLUME]
				,[ORG_CODE]
				,[ORG_NAME]
				,[SHIFT]
				,[STD_COST]
				,[RESOURCE_COST]
				,[EARNED_OVERHEAD]
				,[MATERIAL_COST]
				,[MATERIAL_OVERHEAD_COST]
				,[OUTSIDE_PROCESSING_COST]
				,[TRANSACTION_ID]
				,[LINE_CODE]
				,[LINE_DESCRIPTION]
				,[SHIFT_ID]
				,[Fingerprint]
		)
			SELECT 
				 a.[PRODUCTION_ID]
				,a.[TRANS_DATE_TIME]
				,a.[PART_NUMBER]
				,a.[PART_DESCRIPTION]
				,a.[PRODUCTION_QTY]
				,a.[LIST_LESS_7]
				,a.[TOTAL_PRICE]
				,a.[PLANNER_CODE]
				,a.[RESOURCE_HOURS]
				,a.[TOTAL_MACHINE_HOURS]
				,a.[FG_RESIN_WGT]
				,a.[FG_TOTAL_RESIN]
				,a.[UNIT_VOLUME]
				,a.[TOTAL_VOLUME]
				,a.[ORG_CODE]
				,a.[ORG_NAME]
				,a.[SHIFT]
				,a.[STD_COST]
				,a.[RESOURCE_COST]
				,a.[EARNED_OVERHEAD]
				,a.[MATERIAL_COST]
				,a.[MATERIAL_OVERHEAD_COST]
				,a.[OUTSIDE_PROCESSING_COST]
				,a.[TRANSACTION_ID]
				,a.[LINE_CODE]
				,a.[LINE_DESCRIPTION]
				,a.[SHIFT_ID]
				,a.[Fingerprint]
			FROM (
				MERGE Manufacturing.Production b
				USING (SELECT * FROM #Production) a
				ON a.Production_ID = b.Production_ID AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
						 [PRODUCTION_ID]
						,[TRANS_DATE_TIME]
						,[PART_NUMBER]
						,[PART_DESCRIPTION]
						,[PRODUCTION_QTY]
						,[LIST_LESS_7]
						,[TOTAL_PRICE]
						,[PLANNER_CODE]
						,[RESOURCE_HOURS]
						,[TOTAL_MACHINE_HOURS]
						,[FG_RESIN_WGT]
						,[FG_TOTAL_RESIN]
						,[UNIT_VOLUME]
						,[TOTAL_VOLUME]
						,[ORG_CODE]
						,[ORG_NAME]
						,[SHIFT]
						,[STD_COST]
						,[RESOURCE_COST]
						,[EARNED_OVERHEAD]
						,[MATERIAL_COST]
						,[MATERIAL_OVERHEAD_COST]
						,[OUTSIDE_PROCESSING_COST]
						,[TRANSACTION_ID]
						,[LINE_CODE]
						,[LINE_DESCRIPTION]
						,[SHIFT_ID]
						,[Fingerprint]
				)
				VALUES (
						 a.[PRODUCTION_ID]
						,a.[TRANS_DATE_TIME]
						,a.[PART_NUMBER]
						,a.[PART_DESCRIPTION]
						,a.[PRODUCTION_QTY]
						,a.[LIST_LESS_7]
						,a.[TOTAL_PRICE]
						,a.[PLANNER_CODE]
						,a.[RESOURCE_HOURS]
						,a.[TOTAL_MACHINE_HOURS]
						,a.[FG_RESIN_WGT]
						,a.[FG_TOTAL_RESIN]
						,a.[UNIT_VOLUME]
						,a.[TOTAL_VOLUME]
						,a.[ORG_CODE]
						,a.[ORG_NAME]
						,a.[SHIFT]
						,a.[STD_COST]
						,a.[RESOURCE_COST]
						,a.[EARNED_OVERHEAD]
						,a.[MATERIAL_COST]
						,a.[MATERIAL_OVERHEAD_COST]
						,a.[OUTSIDE_PROCESSING_COST]
						,a.[TRANSACTION_ID]
						,a.[LINE_CODE]
						,a.[LINE_DESCRIPTION]
						,a.[SHIFT_ID]
						,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						 a.[PRODUCTION_ID]
						,a.[TRANS_DATE_TIME]
						,a.[PART_NUMBER]
						,a.[PART_DESCRIPTION]
						,a.[PRODUCTION_QTY]
						,a.[LIST_LESS_7]
						,a.[TOTAL_PRICE]
						,a.[PLANNER_CODE]
						,a.[RESOURCE_HOURS]
						,a.[TOTAL_MACHINE_HOURS]
						,a.[FG_RESIN_WGT]
						,a.[FG_TOTAL_RESIN]
						,a.[UNIT_VOLUME]
						,a.[TOTAL_VOLUME]
						,a.[ORG_CODE]
						,a.[ORG_NAME]
						,a.[SHIFT]
						,a.[STD_COST]
						,a.[RESOURCE_COST]
						,a.[EARNED_OVERHEAD]
						,a.[MATERIAL_COST]
						,a.[MATERIAL_OVERHEAD_COST]
						,a.[OUTSIDE_PROCESSING_COST]
						,a.[TRANSACTION_ID]
						,a.[LINE_CODE]
						,a.[LINE_DESCRIPTION]
						,a.[SHIFT_ID]
						,a.[Fingerprint]
						,$Action AS Action
			) a
			WHERE Action = 'Update'
			;
		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		DROP TABLE #Production
	
	END 

	

GO
