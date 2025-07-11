USE [Operations]
GO
/****** Object:  StoredProcedure [MachineData].[Merge_MachineIndex]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [MachineData].[Merge_MachineIndex] AS BEGIN

	DROP TABLE IF EXISTS #MachineIndex 
		
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

	CREATE TABLE #MachineIndex(
		[RECNUM] [int] NOT NULL,
		[LogDateTime] [datetime] NULL,
		[DataType] [varchar](6) NULL,
		[MachineLocation] [int] NULL,
		[MachineNumber] [int] NULL,
		[MachineSize] [int] NULL,
		[Operator] [int] NULL,
		[ArmNumber] [int] NULL,
		[SQNumber_A] [varchar](6) NULL,
		[SQNumber_B] [varchar](6) NULL,
		[CycleTimeSetPoint] [varchar](8) NULL,
		[ActualWorkTime] [varchar](8) NULL,
		[ActualTimeInOven] [varchar](8) NULL,
		[CookCount] [int] NULL,
		[DeadArmCount] [int] NULL,
		[MissedCycleCount] [int] NULL,
		[ReasonCodeMissed] [int] NULL,
		[MissTimeTotal] [varchar](8) NULL,
		[Shift] [varchar](1) NULL,
		[Shift_ID] int NULL,
		[Fingerprint] [varchar](32) NULL
	)

	INSERT INTO #MachineIndex (
		   [RECNUM]
		  ,[LogDateTime]
		  ,[DataType]
		  ,[MachineLocation]
		  ,[MachineNumber]
		  ,[MachineSize]
		  ,[Operator]
		  ,[ArmNumber]
		  ,[SQNumber_A]
		  ,[SQNumber_B]
		  ,[CycleTimeSetPoint]
		  ,[ActualWorkTime]
		  ,[ActualTimeInOven]
		  ,[CookCount]
		  ,[DeadArmCount]
		  ,[MissedCycleCount]
		  ,[ReasonCodeMissed]
		  ,[MissTimeTotal]
	)
	SELECT 
		   [RECNUM]
		  ,[LogDateTime]
		  ,[DataType]
		  ,[MachineLocation]
		  ,[MachineNumber]
		  ,[MachineSize]
		  ,[Operator]
		  ,[ArmNumber]
		  ,[SQNumber_A]
		  ,[SQNumber_B]
		  ,[CycleTimeSetPoint]
		  ,[ActualWorkTime]
		  ,[ActualTimeInOven]
		  ,[CookCount]
		  ,[DeadArmCount]
		  ,[MissedCycleCount]
		  ,[ReasonCodeMissed]
		  ,[MissTimeTotal]
	FROM OPENQUERY(FINDLAND,
		'SELECT 
		   [RECNUM]
		  ,[LogDateTime]
		  ,[DataType]
		  ,[MachineLocation]
		  ,[MachineNumber]
		  ,[MachineSize]
		  ,[Operator]
		  ,[ArmNumber]
		  ,[SQNumber_A]
		  ,[SQNumber_B]
		  ,[CycleTimeSetPoint]
		  ,[ActualWorkTime]
		  ,[ActualTimeInOven]
		  ,[CookCount]
		  ,[DeadArmCount]
		  ,[MissedCycleCount]
		  ,[ReasonCodeMissed]
		  ,[MissTimeTotal] 
		FROM MachineData.dbo.[Index]
		WHERE [LogDateTime] > DATEADD(DAY,-3,GETDATE())'
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Update Shift', GETDATE()

	UPDATE mi 
	SET mi.Shift = s1.Shift --sets shift link do dim table (A,B,C,D)
		,mi.SHIFT_ID = s1.Shift_ID --sets THE exact shift to control screens (ID 5678)
	FROM #MachineIndex mi 
		INNER JOIN Manufacturing.Shift s1 ON mi.LogDateTime BETWEEN s1.Start_Date_Time AND s1.End_Date_Time AND s1.Org = CAST(mi.MachineLocation AS VARCHAR(4)) AND s1.CurrentRecord = 1

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('MachineData','[Index]') SELECT @columnList
	*/
	
	UPDATE #MachineIndex
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			  CAST(ISNULL([RECNUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([LogDateTime],'') AS VARCHAR(100)) +  CAST(ISNULL([DataType],'') AS VARCHAR(6)) +  CAST(ISNULL([MachineLocation],'0') AS VARCHAR(100)) +  CAST(ISNULL([MachineNumber],'0') AS VARCHAR(100)) +  CAST(ISNULL([MachineSize],'0') AS VARCHAR(100)) +  CAST(ISNULL([Operator],'0') AS VARCHAR(100)) +  CAST(ISNULL([ArmNumber],'0') AS VARCHAR(100)) +  CAST(ISNULL([SQNumber_A],'') AS VARCHAR(6)) +  CAST(ISNULL([SQNumber_B],'') AS VARCHAR(6)) +  CAST(ISNULL([CycleTimeSetPoint],'') AS VARCHAR(8)) +  CAST(ISNULL([ActualWorkTime],'') AS VARCHAR(8)) +  CAST(ISNULL([ActualTimeInOven],'') AS VARCHAR(8)) +  CAST(ISNULL([CookCount],'0') AS VARCHAR(100)) +  CAST(ISNULL([DeadArmCount],'0') AS VARCHAR(100)) +  CAST(ISNULL([MissedCycleCount],'0') AS VARCHAR(100)) +  CAST(ISNULL([ReasonCodeMissed],'0') AS VARCHAR(100)) +  CAST(ISNULL([MissTimeTotal],'') AS VARCHAR(8)) + CAST(ISNULL([Shift],'0') AS VARCHAR(1)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO MachineData.[MachineIndex] (
		 	[RECNUM]
			,[LogDateTime]
			,[DataType]
			,[MachineLocation]
			,[MachineNumber]
			,[MachineSize]
			,[Operator]
			,[ArmNumber]
			,[SQNumber_A]
			,[SQNumber_B]
			,[CycleTimeSetPoint]
			,[ActualWorkTime]
			,[ActualTimeInOven]
			,[CookCount]
			,[DeadArmCount]
			,[MissedCycleCount]
			,[ReasonCodeMissed]
			,[MissTimeTotal] 	
			,[Shift]
			,[Shift_ID]
			,[Fingerprint]
	)
		SELECT 
			a.[RECNUM]
			,a.[LogDateTime]
			,a.[DataType]
			,a.[MachineLocation]
			,a.[MachineNumber]
			,a.[MachineSize]
			,a.[Operator]
			,a.[ArmNumber]
			,a.[SQNumber_A]
			,a.[SQNumber_B]
			,a.[CycleTimeSetPoint]
			,a.[ActualWorkTime]
			,a.[ActualTimeInOven]
			,a.[CookCount]
			,a.[DeadArmCount]
			,a.[MissedCycleCount]
			,a.[ReasonCodeMissed]
			,a.[MissTimeTotal] 	
			,a.[Shift]
			,a.[Shift_ID]
			,a.[Fingerprint]
		FROM (
			MERGE MachineData.[MachineIndex] b
			USING (SELECT * FROM #MachineIndex) a
			ON a.RECNUM = b.RECNUM AND b.CurrentRecord = 1 --swap with business key of table
			WHEN NOT MATCHED --BY TARGET 
			THEN INSERT (
				[RECNUM]
				,[LogDateTime]
				,[DataType]
				,[MachineLocation]
				,[MachineNumber]
				,[MachineSize]
				,[Operator]
				,[ArmNumber]
				,[SQNumber_A]
				,[SQNumber_B]
				,[CycleTimeSetPoint]
				,[ActualWorkTime]
				,[ActualTimeInOven]
				,[CookCount]
				,[DeadArmCount]
				,[MissedCycleCount]
				,[ReasonCodeMissed]
				,[MissTimeTotal] 	
				,[Shift]
				,[Shift_ID]
				,[Fingerprint]
			)
			VALUES (
				a.[RECNUM]
				,a.[LogDateTime]
				,a.[DataType]
				,a.[MachineLocation]
				,a.[MachineNumber]
				,a.[MachineSize]
				,a.[Operator]
				,a.[ArmNumber]
				,a.[SQNumber_A]
				,a.[SQNumber_B]
				,a.[CycleTimeSetPoint]
				,a.[ActualWorkTime]
				,a.[ActualTimeInOven]
				,a.[CookCount]
				,a.[DeadArmCount]
				,a.[MissedCycleCount]
				,a.[ReasonCodeMissed]
				,a.[MissTimeTotal] 
				,a.[Shift]
				,a.[Shift_ID]
				,a.[Fingerprint]
			)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
			THEN UPDATE SET b.EndDate=GETDATE()
				,b.CurrentRecord=0
			OUTPUT 
				a.[RECNUM]
				,a.[LogDateTime]
				,a.[DataType]
				,a.[MachineLocation]
				,a.[MachineNumber]
				,a.[MachineSize]
				,a.[Operator]
				,a.[ArmNumber]
				,a.[SQNumber_A]
				,a.[SQNumber_B]
				,a.[CycleTimeSetPoint]
				,a.[ActualWorkTime]
				,a.[ActualTimeInOven]
				,a.[CookCount]
				,a.[DeadArmCount]
				,a.[MissedCycleCount]
				,a.[ReasonCodeMissed]
				,a.[MissTimeTotal] 	
				,a.[Shift]
				,a.[Shift_ID]
				,a.[Fingerprint]
				,$Action AS Action
		) a
		WHERE Action = 'Update'
		;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #MachineIndex
END
GO
