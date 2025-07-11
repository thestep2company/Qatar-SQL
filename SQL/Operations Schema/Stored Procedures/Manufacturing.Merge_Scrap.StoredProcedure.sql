USE [Operations]
GO
/****** Object:  StoredProcedure [Manufacturing].[Merge_Scrap]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	
	CREATE PROCEDURE [Manufacturing].[Merge_Scrap] AS BEGIN

			DECLARE @lastID INT, @sql VARCHAR(MAX)	
			SET @lastID = (SELECT MAX(Scrap_ID) FROM Manufacturing.Scrap)

			CREATE TABLE #Scrap (
				[SCRAP_ID] [int] NOT NULL,
				[START_DATE] [datetime] NULL,
				[END_DATE] [datetime] NULL,
				[CREATION_DATE] [datetime] NULL,
				[ORG_CODE] [varchar](3) NULL,
				[SHIFT] [char](1) NULL,
				[LINES] [varchar](8) NULL,
				[REPAIR_SCRAP_TYPE] [varchar](20) NULL,
				[REPAIR_SCRAP_REASON] [varchar](50) NULL,
				[COMP_ITEM] [varchar](20) NULL,
				[ROTO_DESCRIPTION] [varchar](50) NULL,
				[PIGMENT_RESIN] [varchar](25) NULL,
				[QTY] [real] NULL,
				[LBS_REPAIRED_SCRAPPED] [real] NULL,
				[CREATED_BY] [varchar](25) NULL,
				[ERROR_CODE] [varchar](2) NULL,
				[SHIFT_DATE] [datetime] NULL,
				[SHIFT_BY_CREATION_DATE] [char](1) NULL,
				[Fingerprint] [varchar](32) NOT NULL,
			)

			INSERT INTO #Scrap (
				   [SCRAP_ID]
				  ,[START_DATE]
				  ,[END_DATE]
				  ,[CREATION_DATE]
				  ,[ORG_CODE]
				  ,[SHIFT]
				  ,[LINES]
				  ,[REPAIR_SCRAP_TYPE]
				  ,[REPAIR_SCRAP_REASON]
				  ,[COMP_ITEM]
				  ,[ROTO_DESCRIPTION]
				  ,[PIGMENT_RESIN]
				  ,[QTY]
				  ,[LBS_REPAIRED_SCRAPPED]
				  ,[CREATED_BY]
				  ,[ERROR_CODE]
				  ,[SHIFT_DATE]
				  ,[SHIFT_BY_CREATION_DATE]
				  ,[Fingerprint]
			)
			SELECT 
					[SCRAP_ID]
					,[START_DATE]
					,[END_DATE]
					,[CREATION_DATE]
					,[ORG_CODE]
					,[SHIFT]
					,[LINES]
					,[REPAIR_SCRAP_TYPE]
					,[REPAIR_SCRAP_REASON]
					,[COMP_ITEM]
					,[ROTO_DESCRIPTION]
					,[PIGMENT_RESIN]
					,[QTY]
					,[LBS_REPAIRED_SCRAPPED]
					,[CREATED_BY]
					,[ERROR_CODE]
					,[SHIFT_DATE]
					,[SHIFT_BY_CREATION_DATE]
					,'XXXXXXXXX' AS Fingerprint
			FROM OPENQUERY(FINDLAND, 'SELECT 
						[SCRAP_ID]
						,[START_DATE]
						,[END_DATE]
						,[CREATION_DATE]
						,[ORG_CODE]
						,[SHIFT]
						,[LINES]
						,[REPAIR_SCRAP_TYPE]
						,[REPAIR_SCRAP_REASON]
						,[COMP_ITEM]
						,[ROTO_DESCRIPTION]
						,[PIGMENT_RESIN]
						,[QTY]
						,[LBS_REPAIRED_SCRAPPED]
						,[CREATED_BY]
						,[ERROR_CODE]
						,[SHIFT_DATE]
						,[SHIFT_BY_CREATION_DATE]
				 FROM [Manufacturing].[dbo].[Machine_Scrap]
				 WHERE Creation_Date >= DATEADD(DAY,-5,GETDATE())'
			)

		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Scrap','Manufacturing') SELECT @columnList
		*/
		UPDATE #Scrap
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				 CAST(ISNULL(SCRAP_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(START_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(END_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(CREATION_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(ORG_CODE,'') AS VARCHAR(3)) +  CAST(ISNULL(SHIFT,'') AS VARCHAR(1)) +  CAST(ISNULL(LINES,'') AS VARCHAR(8)) +  CAST(ISNULL(REPAIR_SCRAP_TYPE,'') AS VARCHAR(20)) +  CAST(ISNULL(REPAIR_SCRAP_REASON,'') AS VARCHAR(50)) +  CAST(ISNULL(COMP_ITEM,'') AS VARCHAR(20)) +  CAST(ISNULL(ROTO_DESCRIPTION,'') AS VARCHAR(50)) +  CAST(ISNULL(PIGMENT_RESIN,'') AS VARCHAR(25)) +  CAST(ISNULL(QTY,'0') AS VARCHAR(100)) +  CAST(ISNULL(LBS_REPAIRED_SCRAPPED,'0') AS VARCHAR(100)) +  CAST(ISNULL(CREATED_BY,'') AS VARCHAR(25)) +  CAST(ISNULL(ERROR_CODE,'') AS VARCHAR(2)) +  CAST(ISNULL(SHIFT_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(SHIFT_BY_CREATION_DATE,'') AS VARCHAR(1)) 
			),1)),3,32);

		--expire records outside the merge

		INSERT INTO Manufacturing.Scrap (
				[SCRAP_ID]
				,[START_DATE]
				,[END_DATE]
				,[CREATION_DATE]
				,[ORG_CODE]
				,[SHIFT]
				,[LINES]
				,[REPAIR_SCRAP_TYPE]
				,[REPAIR_SCRAP_REASON]
				,[COMP_ITEM]
				,[ROTO_DESCRIPTION]
				,[PIGMENT_RESIN]
				,[QTY]
				,[LBS_REPAIRED_SCRAPPED]
				,[CREATED_BY]
				,[ERROR_CODE]
				,[SHIFT_DATE]
				,[SHIFT_BY_CREATION_DATE]
				,[Fingerprint]
		)
			SELECT 
				 a.[SCRAP_ID]
				,a.[START_DATE]
				,a.[END_DATE]
				,a.[CREATION_DATE]
				,a.[ORG_CODE]
				,a.[SHIFT]
				,a.[LINES]
				,a.[REPAIR_SCRAP_TYPE]
				,a.[REPAIR_SCRAP_REASON]
				,a.[COMP_ITEM]
				,a.[ROTO_DESCRIPTION]
				,a.[PIGMENT_RESIN]
				,a.[QTY]
				,a.[LBS_REPAIRED_SCRAPPED]
				,a.[CREATED_BY]
				,a.[ERROR_CODE]
				,a.[SHIFT_DATE]
				,a.[SHIFT_BY_CREATION_DATE]
				,a.[Fingerprint]
			FROM (
				MERGE Manufacturing.Scrap b
				USING (SELECT * FROM #Scrap) a
				ON a.Scrap_ID = b.Scrap_ID AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
						[SCRAP_ID]
						,[START_DATE]
						,[END_DATE]
						,[CREATION_DATE]
						,[ORG_CODE]
						,[SHIFT]
						,[LINES]
						,[REPAIR_SCRAP_TYPE]
						,[REPAIR_SCRAP_REASON]
						,[COMP_ITEM]
						,[ROTO_DESCRIPTION]
						,[PIGMENT_RESIN]
						,[QTY]
						,[LBS_REPAIRED_SCRAPPED]
						,[CREATED_BY]
						,[ERROR_CODE]
						,[SHIFT_DATE]
						,[SHIFT_BY_CREATION_DATE]
						,[Fingerprint]
				)
				VALUES (
						a.[SCRAP_ID]
						,a.[START_DATE]
						,a.[END_DATE]
						,a.[CREATION_DATE]
						,a.[ORG_CODE]
						,a.[SHIFT]
						,a.[LINES]
						,a.[REPAIR_SCRAP_TYPE]
						,a.[REPAIR_SCRAP_REASON]
						,a.[COMP_ITEM]
						,a.[ROTO_DESCRIPTION]
						,a.[PIGMENT_RESIN]
						,a.[QTY]
						,a.[LBS_REPAIRED_SCRAPPED]
						,a.[CREATED_BY]
						,a.[ERROR_CODE]
						,a.[SHIFT_DATE]
						,a.[SHIFT_BY_CREATION_DATE]
						,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						 a.[SCRAP_ID]
						,a.[START_DATE]
						,a.[END_DATE]
						,a.[CREATION_DATE]
						,a.[ORG_CODE]
						,a.[SHIFT]
						,a.[LINES]
						,a.[REPAIR_SCRAP_TYPE]
						,a.[REPAIR_SCRAP_REASON]
						,a.[COMP_ITEM]
						,a.[ROTO_DESCRIPTION]
						,a.[PIGMENT_RESIN]
						,a.[QTY]
						,a.[LBS_REPAIRED_SCRAPPED]
						,a.[CREATED_BY]
						,a.[ERROR_CODE]
						,a.[SHIFT_DATE]
						,a.[SHIFT_BY_CREATION_DATE]
						,a.[Fingerprint]
						,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

			DROP TABLE #Scrap

	END
	
GO
