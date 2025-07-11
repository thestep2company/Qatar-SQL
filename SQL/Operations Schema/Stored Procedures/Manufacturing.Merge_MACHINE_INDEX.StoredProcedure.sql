USE [Operations]
GO
/****** Object:  StoredProcedure [Manufacturing].[Merge_MACHINE_INDEX]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	
	CREATE PROCEDURE [Manufacturing].[Merge_MACHINE_INDEX] AS BEGIN

		DELETE FROM Manufacturing.MACHINE_INDEX WHERE DATE_TIME >= DATEADD(HOUR,6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

		CREATE TABLE #MACHINE_INDEX (
			[INDEX_ID] [int] NOT NULL,
			[MACHINE_ID] [int] NOT NULL,
			[DATE_TIME] [datetime] NOT NULL,
			[REC_TYPE] [varchar](1) NOT NULL,
			[PLANT] [varchar](3) NOT NULL,
			[SHIFT] [varchar](1) NOT NULL,
			[MACHINE_NUM] [varchar](2) NOT NULL,
			[ARM_NUMBER] [varchar](1) NOT NULL,
			[MACHINE_SIZE] [varchar](3) NOT NULL,
			[SPIDER_SIDE_1] [varchar](50) NULL,
			[SPIDER_SIDE_2] [varchar](50) NULL,
			[CYCLE_COUNT] [int] NULL,
			[DEAD_ARM] [int] NULL,
			[MISSED_CYCLE] [int] NULL,
			[REASON_CODE] [int] NULL,
			[MISSED_TIME] [int] NULL,
			[OVEN_TEMP] [real] NULL,
			[CYCLE_TIME] [int] NULL,
			[COOLER_1_FAN_DELAY] [int] NULL,
			[COOLER_1_FAN_TIME] [int] NULL,
			[COOLER_2_WATER_DELAY] [int] NULL,
			[WATER_TIME] [int] NULL,
			[COOLER_2_FAN_TIME] [int] NULL,
			[OUTSIDE_AIR_TEMP] [real] NULL,
			[CREATE_DATE] [datetime] NULL,
			[REASON_DESCRIPTION] [varchar](100) NULL,
			[OPERATOR] [varchar](50) NULL,
			[COMPUTER_NAME] [varchar](25) NULL,
			[SHIFT_DATE] [datetime] NULL,
			[INDEX_TIME] [int] NULL,
			[OPERATOR_NAME] [varchar](50) NULL,
			[Shift_ID] [INT] NULL,
			[Fingerprint] [varchar](32) NOT NULL
		)


		INSERT INTO #MACHINE_INDEX (
			  [INDEX_ID]
			  ,[MACHINE_ID]
			  ,[DATE_TIME]
			  ,[REC_TYPE]
			  ,[PLANT]
			  ,[SHIFT]
			  ,[MACHINE_NUM]
			  ,[ARM_NUMBER]
			  ,[MACHINE_SIZE]
			  ,[SPIDER_SIDE_1]
			  ,[SPIDER_SIDE_2]
			  ,[CYCLE_COUNT]
			  ,[DEAD_ARM]
			  ,[MISSED_CYCLE]
			  ,[REASON_CODE]
			  ,[MISSED_TIME]
			  ,[OVEN_TEMP]
			  ,[CYCLE_TIME]
			  ,[COOLER_1_FAN_DELAY]
			  ,[COOLER_1_FAN_TIME]
			  ,[COOLER_2_WATER_DELAY]
			  ,[WATER_TIME]
			  ,[COOLER_2_FAN_TIME]
			  ,[OUTSIDE_AIR_TEMP]
			  ,[CREATE_DATE]
			  ,[REASON_DESCRIPTION]
			  ,[OPERATOR]
			  ,[COMPUTER_NAME]
			  ,[SHIFT_DATE]
			  ,[INDEX_TIME]
			  ,[OPERATOR_NAME]
			  ,[SHIFT_ID]
			  ,[Fingerprint]
		)
		SELECT 
			   [INDEX_ID]
			  ,[MACHINE_ID]
			  ,[DATE_TIME]
			  ,[REC_TYPE]
			  ,[PLANT]
			  ,[SHIFT]
			  ,[MACHINE_NUM]
			  ,[ARM_NUMBER]
			  ,[MACHINE_SIZE]
			  ,[SPIDER_SIDE_1]
			  ,[SPIDER_SIDE_2]
			  ,[CYCLE_COUNT]
			  ,[DEAD_ARM]
			  ,[MISSED_CYCLE]
			  ,[REASON_CODE]
			  ,[MISSED_TIME]
			  ,[OVEN_TEMP]
			  ,[CYCLE_TIME]
			  ,[COOLER_1_FAN_DELAY]
			  ,[COOLER_1_FAN_TIME]
			  ,[COOLER_2_WATER_DELAY]
			  ,[WATER_TIME]
			  ,[COOLER_2_FAN_TIME]
			  ,[OUTSIDE_AIR_TEMP]
			  ,[CREATE_DATE]
			  ,[REASON_DESCRIPTION]
			  ,[OPERATOR]
			  ,[COMPUTER_NAME]
			  ,[SHIFT_DATE]
			  ,[INDEX_TIME]
			  ,[OPERATOR_NAME]
			  ,NULL AS [SHIFT_ID]
			  ,'XXX' AS Fingerprint
		FROM OPENQUERY(FINDLAND,
			 'SELECT 
				   [INDEX_ID]
				  ,[MACHINE_ID]
				  ,[DATE_TIME]
				  ,[REC_TYPE]
				  ,[PLANT]
				  ,[SHIFT]
				  ,[MACHINE_NUM]
				  ,[ARM_NUMBER]
				  ,[MACHINE_SIZE]
				  ,[SPIDER_SIDE_1]
				  ,[SPIDER_SIDE_2]
				  ,[CYCLE_COUNT]
				  ,[DEAD_ARM]
				  ,[MISSED_CYCLE]
				  ,[REASON_CODE]
				  ,[MISSED_TIME]
				  ,[OVEN_TEMP]
				  ,[CYCLE_TIME]
				  ,[COOLER_1_FAN_DELAY]
				  ,[COOLER_1_FAN_TIME]
				  ,[COOLER_2_WATER_DELAY]
				  ,[WATER_TIME]
				  ,[COOLER_2_FAN_TIME]
				  ,[OUTSIDE_AIR_TEMP]
				  ,[CREATE_DATE]
				  ,[REASON_DESCRIPTION]
				  ,[OPERATOR]
				  ,[COMPUTER_NAME]
				  ,[SHIFT_DATE]
				  ,[INDEX_TIME]
				  ,[OPERATOR_NAME]
			 FROM [Manufacturing].[dbo].[MACHINE_INDEX]
			 WHERE CREATE_DATE >= DATEADD(DAY,-5,GETDATE())
		'
		)


		UPDATE pro
		SET SHIFT_ID = s2.Shift_ID
		FROM #MACHINE_INDEX pro
			LEFT JOIN Manufacturing.Shift s2 ON pro.Shift = s2.Shift AND pro.plant = s2.Org AND pro.DATE_TIME >= s2.Start_Date_Time AND pro.DATE_TIME < s2.End_Date_Time AND s2.CurrentRecord = 1


		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('MACHINE_INDEX','Manufacturing') SELECT @columnList
		*/

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

		UPDATE #MACHINE_INDEX
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				  --CAST(ISNULL(INDEX_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(MACHINE_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(DATE_TIME,'') AS VARCHAR(100)) +  CAST(ISNULL(REC_TYPE,'') AS VARCHAR(1)) +  CAST(ISNULL(PLANT,'') AS VARCHAR(3)) +  CAST(ISNULL(SHIFT,'') AS VARCHAR(1)) +  CAST(ISNULL(MACHINE_NUM,'') AS VARCHAR(2)) +  CAST(ISNULL(ARM_NUMBER,'') AS VARCHAR(1)) +  CAST(ISNULL(MACHINE_SIZE,'') AS VARCHAR(3)) +  CAST(ISNULL(SPIDER_SIDE_1,'') AS VARCHAR(50)) +  CAST(ISNULL(SPIDER_SIDE_2,'') AS VARCHAR(50)) +  CAST(ISNULL(CYCLE_COUNT,'0') AS VARCHAR(100)) +  CAST(ISNULL(DEAD_ARM,'0') AS VARCHAR(100)) +  CAST(ISNULL(MISSED_CYCLE,'0') AS VARCHAR(100)) +  CAST(ISNULL(REASON_CODE,'0') AS VARCHAR(100)) +  CAST(ISNULL(MISSED_TIME,'0') AS VARCHAR(100)) +  CAST(ISNULL(OVEN_TEMP,'0') AS VARCHAR(100)) +  CAST(ISNULL(CYCLE_TIME,'0') AS VARCHAR(100)) +  CAST(ISNULL(COOLER_1_FAN_DELAY,'0') AS VARCHAR(100)) +  CAST(ISNULL(COOLER_1_FAN_TIME,'0') AS VARCHAR(100)) +  CAST(ISNULL(COOLER_2_WATER_DELAY,'0') AS VARCHAR(100)) +  CAST(ISNULL(WATER_TIME,'0') AS VARCHAR(100)) +  CAST(ISNULL(COOLER_2_FAN_TIME,'0') AS VARCHAR(100)) +  CAST(ISNULL(OUTSIDE_AIR_TEMP,'0') AS VARCHAR(100)) +  CAST(ISNULL(CREATE_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(REASON_DESCRIPTION,'') AS VARCHAR(100)) +  CAST(ISNULL(OPERATOR,'') AS VARCHAR(50)) +  CAST(ISNULL(COMPUTER_NAME,'') AS VARCHAR(25)) +  CAST(ISNULL(SHIFT_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(INDEX_TIME,'0') AS VARCHAR(100)) +  CAST(ISNULL(OPERATOR_NAME,'') AS VARCHAR(50)) 
				  CAST(ISNULL(INDEX_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(MACHINE_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(DATE_TIME,'') AS VARCHAR(100)) +  CAST(ISNULL(REC_TYPE,'') AS VARCHAR(1)) +  CAST(ISNULL(PLANT,'') AS VARCHAR(3)) +  CAST(ISNULL(SHIFT,'') AS VARCHAR(1)) +  CAST(ISNULL(MACHINE_NUM,'') AS VARCHAR(2)) +  CAST(ISNULL(ARM_NUMBER,'') AS VARCHAR(1)) +  CAST(ISNULL(MACHINE_SIZE,'') AS VARCHAR(3)) +  CAST(ISNULL(SPIDER_SIDE_1,'') AS VARCHAR(50)) +  CAST(ISNULL(SPIDER_SIDE_2,'') AS VARCHAR(50)) +  CAST(ISNULL(CYCLE_COUNT,'0') AS VARCHAR(100)) +  CAST(ISNULL(DEAD_ARM,'0') AS VARCHAR(100)) +  CAST(ISNULL(MISSED_CYCLE,'0') AS VARCHAR(100)) +  CAST(ISNULL(REASON_CODE,'0') AS VARCHAR(100)) +  CAST(ISNULL(MISSED_TIME,'0') AS VARCHAR(100)) +  CAST(ISNULL(OVEN_TEMP,'0') AS VARCHAR(100)) +  CAST(ISNULL(CYCLE_TIME,'0') AS VARCHAR(100)) +  CAST(ISNULL(COOLER_1_FAN_DELAY,'0') AS VARCHAR(100)) +  CAST(ISNULL(COOLER_1_FAN_TIME,'0') AS VARCHAR(100)) +  CAST(ISNULL(COOLER_2_WATER_DELAY,'0') AS VARCHAR(100)) +  CAST(ISNULL(WATER_TIME,'0') AS VARCHAR(100)) +  CAST(ISNULL(COOLER_2_FAN_TIME,'0') AS VARCHAR(100)) +  CAST(ISNULL(OUTSIDE_AIR_TEMP,'0') AS VARCHAR(100)) +  CAST(ISNULL(CREATE_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(REASON_DESCRIPTION,'') AS VARCHAR(100)) +  CAST(ISNULL(OPERATOR,'') AS VARCHAR(50)) +  CAST(ISNULL(COMPUTER_NAME,'') AS VARCHAR(25)) +  CAST(ISNULL(SHIFT_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(INDEX_TIME,'0') AS VARCHAR(100)) +  CAST(ISNULL(OPERATOR_NAME,'') AS VARCHAR(50)) + CAST(ISNULL(Shift_ID,'0') AS VARCHAR(100)) 
			),1)),3,32);

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO Manufacturing.MACHINE_INDEX (
				 [INDEX_ID]
				  ,[MACHINE_ID]
				  ,[DATE_TIME]
				  ,[REC_TYPE]
				  ,[PLANT]
				  ,[SHIFT]
				  ,[MACHINE_NUM]
				  ,[ARM_NUMBER]
				  ,[MACHINE_SIZE]
				  ,[SPIDER_SIDE_1]
				  ,[SPIDER_SIDE_2]
				  ,[CYCLE_COUNT]
				  ,[DEAD_ARM]
				  ,[MISSED_CYCLE]
				  ,[REASON_CODE]
				  ,[MISSED_TIME]
				  ,[OVEN_TEMP]
				  ,[CYCLE_TIME]
				  ,[COOLER_1_FAN_DELAY]
				  ,[COOLER_1_FAN_TIME]
				  ,[COOLER_2_WATER_DELAY]
				  ,[WATER_TIME]
				  ,[COOLER_2_FAN_TIME]
				  ,[OUTSIDE_AIR_TEMP]
				  ,[CREATE_DATE]
				  ,[REASON_DESCRIPTION]
				  ,[OPERATOR]
				  ,[COMPUTER_NAME]
				  ,[SHIFT_DATE]
				  ,[INDEX_TIME]
				  ,[OPERATOR_NAME]
				  ,[SHIFT_ID]
				  ,[Fingerprint]
		)
			SELECT 
				  a.[INDEX_ID]
				  ,a.[MACHINE_ID]
				  ,a.[DATE_TIME]
				  ,a.[REC_TYPE]
				  ,a.[PLANT]
				  ,a.[SHIFT]
				  ,a.[MACHINE_NUM]
				  ,a.[ARM_NUMBER]
				  ,a.[MACHINE_SIZE]
				  ,a.[SPIDER_SIDE_1]
				  ,a.[SPIDER_SIDE_2]
				  ,a.[CYCLE_COUNT]
				  ,a.[DEAD_ARM]
				  ,a.[MISSED_CYCLE]
				  ,a.[REASON_CODE]
				  ,a.[MISSED_TIME]
				  ,a.[OVEN_TEMP]
				  ,a.[CYCLE_TIME]
				  ,a.[COOLER_1_FAN_DELAY]
				  ,a.[COOLER_1_FAN_TIME]
				  ,a.[COOLER_2_WATER_DELAY]
				  ,a.[WATER_TIME]
				  ,a.[COOLER_2_FAN_TIME]
				  ,a.[OUTSIDE_AIR_TEMP]
				  ,a.[CREATE_DATE]
				  ,a.[REASON_DESCRIPTION]
				  ,a.[OPERATOR]
				  ,a.[COMPUTER_NAME]
				  ,a.[SHIFT_DATE]
				  ,a.[INDEX_TIME]
				  ,a.[OPERATOR_NAME]
				  ,a.[SHIFT_ID]
				  ,a.[Fingerprint]
			FROM (
				MERGE Manufacturing.MACHINE_INDEX b
				USING (SELECT * FROM #Machine_Index) a
				ON a.Index_ID = b.Index_ID AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
						 [INDEX_ID]
						,[MACHINE_ID]
						,[DATE_TIME]
						,[REC_TYPE]
						,[PLANT]
						,[SHIFT]
						,[MACHINE_NUM]
						,[ARM_NUMBER]
						,[MACHINE_SIZE]
						,[SPIDER_SIDE_1]
						,[SPIDER_SIDE_2]
						,[CYCLE_COUNT]
						,[DEAD_ARM]
						,[MISSED_CYCLE]
						,[REASON_CODE]
						,[MISSED_TIME]
						,[OVEN_TEMP]
						,[CYCLE_TIME]
						,[COOLER_1_FAN_DELAY]
						,[COOLER_1_FAN_TIME]
						,[COOLER_2_WATER_DELAY]
						,[WATER_TIME]
						,[COOLER_2_FAN_TIME]
						,[OUTSIDE_AIR_TEMP]
						,[CREATE_DATE]
						,[REASON_DESCRIPTION]
						,[OPERATOR]
						,[COMPUTER_NAME]
						,[SHIFT_DATE]
						,[INDEX_TIME]
						,[OPERATOR_NAME]
						,[SHIFT_ID]
						,[Fingerprint]
				)
				VALUES (
						 a.[INDEX_ID]
					  ,a.[MACHINE_ID]
					  ,a.[DATE_TIME]
					  ,a.[REC_TYPE]
					  ,a.[PLANT]
					  ,a.[SHIFT]
					  ,a.[MACHINE_NUM]
					  ,a.[ARM_NUMBER]
					  ,a.[MACHINE_SIZE]
					  ,a.[SPIDER_SIDE_1]
					  ,a.[SPIDER_SIDE_2]
					  ,a.[CYCLE_COUNT]
					  ,a.[DEAD_ARM]
					  ,a.[MISSED_CYCLE]
					  ,a.[REASON_CODE]
					  ,a.[MISSED_TIME]
					  ,a.[OVEN_TEMP]
					  ,a.[CYCLE_TIME]
					  ,a.[COOLER_1_FAN_DELAY]
					  ,a.[COOLER_1_FAN_TIME]
					  ,a.[COOLER_2_WATER_DELAY]
					  ,a.[WATER_TIME]
					  ,a.[COOLER_2_FAN_TIME]
					  ,a.[OUTSIDE_AIR_TEMP]
					  ,a.[CREATE_DATE]
					  ,a.[REASON_DESCRIPTION]
					  ,a.[OPERATOR]
					  ,a.[COMPUTER_NAME]
					  ,a.[SHIFT_DATE]
					  ,a.[INDEX_TIME]
					  ,a.[OPERATOR_NAME]
					  ,a.[SHIFT_ID]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						 a.[INDEX_ID]
						,a.[MACHINE_ID]
						,a.[DATE_TIME]
						,a.[REC_TYPE]
						,a.[PLANT]
						,a.[SHIFT]
						,a.[MACHINE_NUM]
						,a.[ARM_NUMBER]
						,a.[MACHINE_SIZE]
						,a.[SPIDER_SIDE_1]
						,a.[SPIDER_SIDE_2]
						,a.[CYCLE_COUNT]
						,a.[DEAD_ARM]
						,a.[MISSED_CYCLE]
						,a.[REASON_CODE]
						,a.[MISSED_TIME]
						,a.[OVEN_TEMP]
						,a.[CYCLE_TIME]
						,a.[COOLER_1_FAN_DELAY]
						,a.[COOLER_1_FAN_TIME]
						,a.[COOLER_2_WATER_DELAY]
						,a.[WATER_TIME]
						,a.[COOLER_2_FAN_TIME]
						,a.[OUTSIDE_AIR_TEMP]
						,a.[CREATE_DATE]
						,a.[REASON_DESCRIPTION]
						,a.[OPERATOR]
						,a.[COMPUTER_NAME]
						,a.[SHIFT_DATE]
						,a.[INDEX_TIME]
						,a.[OPERATOR_NAME]
						,a.[SHIFT_ID]
						,a.[Fingerprint]
						,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	    UPDATE [Operations].[Manufacturing].[MACHINE_INDEX]  SET TransDate = CAST(DATE_TIME AS DATE), TransDateOffset = CAST(DATEADD(Hour,-6,DATE_TIME) AS DATE) WHERE StartDate >= DATEADD(HOUR,-1,GETDATE())
 
		DROP TABLE #MACHINE_INDEX
	
	END 

	

GO
