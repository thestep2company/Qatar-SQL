USE [Operations]
GO
/****** Object:  StoredProcedure [xref].[Merge_MachineOperator]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [xref].[Merge_MachineOperator] AS BEGIN
	
		CREATE TABLE #MachineOperator (
			[Date] [datetime] NULL,
			[Shift] [nvarchar](255) NULL,
			[Machine] [nvarchar](255) NULL,
			[Operator] [nvarchar](255) NULL,
			[Fingerprint] [varchar](32) NOT NULL
		)

		INSERT INTO #MachineOperator SELECT *, 'XXXXX' FROM Import.MachineOperator


		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('MachineOperator','Import') SELECT @columnList
		*/
		UPDATE #MachineOperator
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
					 CAST(ISNULL([Date],'') AS VARCHAR(100)) +  CAST(ISNULL([Shift],'') AS VARCHAR(255)) +  CAST(ISNULL([Machine],'') AS VARCHAR(255)) +  CAST(ISNULL([Operator],'') AS VARCHAR(255)) 
			),1)),3,32)


		--expire records outside the merge
		UPDATE target
		SET EndDate = GETDATE()
				,CurrentRecord = 0
		FROM [Import].[MachineOperator] source
			INNER JOIN xref.MachineOperator target ON source.Date = target.Date AND source.Shift = target.Shift



		INSERT INTO xref.MachineOperator (
					 [Date]
					,[Shift]
					,[Machine]
					,[Operator]
					,[Fingerprint]
		)
		SELECT 
			[Date]
			,[Shift]
			,[Machine]
			,[Operator]
			,[Fingerprint]

			FROM (
				MERGE xref.MachineOperator b
				USING (SELECT * FROM #MachineOperator) a
				ON a.Date = b.Date AND a.Shift = b.Shift AND a.Machine = b.Machine AND a.Operator = b.Operator AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					 [Date]
					,[Shift]
					,[Machine]
					,[Operator]
					,[Fingerprint]
				)
				VALUES (
					 a.[Date]
					,a.[Shift]
					,a.[Machine]
					,a.[Operator]
					,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					 a.[Date]
					,a.[Shift]
					,a.[Machine]
					,a.[Operator]
					,a.[Fingerprint]
					,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		DROP TABLE #MachineOperator
END


GO
