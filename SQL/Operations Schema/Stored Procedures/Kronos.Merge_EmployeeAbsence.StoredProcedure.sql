USE [Operations]
GO
/****** Object:  StoredProcedure [Kronos].[Merge_EmployeeAbsence]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Kronos].[Merge_EmployeeAbsence] AS BEGIN

	DECLARE @procStartDate DATETIME = GETDATE()

	CREATE TABLE #EmployeeAbsence (
		[Site] [varchar](50) NULL,
		[Department] [varchar](50) NULL,
		[Calendar Week] [varchar](50) NULL,
		[Scheduled Hours] [float] NULL,
		[Unexcused Absenteeism Hours] [float] NULL,
		[Excused Absenteeism Hours] [float] NULL,
		[Fingerprint] [varchar](32) NOT NULL,
	)

	INSERT INTO #EmployeeAbsence
	SELECT 	
		[Site],
		[Department],
		[Calendar Week],
		SUM(CAST(REPLACE([Scheduled Hours],',','') AS FLOAT)) AS [Scheduled Hours],
		SUM(CAST(REPLACE( [Unexcused Absenteeism Hours],',','') AS FLOAT)) AS [Unexcused Absenteeism Hours],
		SUM(CAST(REPLACE( [Excused Absenteeism Hours],',','') AS FLOAT)) AS [Excused Absenteeism Hours],
		'XXXXXXXXXXXX' AS Fingerprint  
	FROM Kronos.[S2F - Absence by Department]
	GROUP BY [Site],
		[Department],
		[Calendar Week]

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('EmployeeAbsence','Kronos') SELECT @columnList
	*/
	UPDATE #EmployeeAbsence
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
				     CAST(ISNULL([Site],'') AS VARCHAR(50)) +  CAST(ISNULL([Department],'') AS VARCHAR(50)) +  CAST(ISNULL([Calendar Week],'') AS VARCHAR(50)) +  CAST(ISNULL([Scheduled Hours],'0') AS VARCHAR(100)) +  CAST(ISNULL([Unexcused Absenteeism Hours],'0') AS VARCHAR(100)) +  CAST(ISNULL([Excused Absenteeism Hours],'0') AS VARCHAR(100)) 
		),1)),3,32);


	INSERT INTO Kronos.EmployeeAbsence (
		  [Site]
		, [Department]
		, [Calendar Week]
		, [Scheduled Hours]
		, [Unexcused Absenteeism Hours] 
		, [Excused Absenteeism Hours]
		, [Fingerprint]
		)
			SELECT 
				    a.[Site]
					, [Department]
					, [Calendar Week]
					, [Scheduled Hours]
					, [Unexcused Absenteeism Hours] 
					, [Excused Absenteeism Hours]
					, [Fingerprint]
			FROM (
				MERGE Kronos.EmployeeAbsence b
				USING (SELECT * FROM #EmployeeAbsence) a
				ON a.[Site] = b.[Site] AND a.[Department] = b.[Department] AND a.[Calendar Week] = b.[Calendar Week] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					  [Site]
					, [Department]
					, [Calendar Week]
					, [Scheduled Hours]
					, [Unexcused Absenteeism Hours] 
					, [Excused Absenteeism Hours]
					, [Fingerprint]
				)
				VALUES (
					  a.[Site]
					, a.[Department]
					, a.[Calendar Week]
					, a.[Scheduled Hours]
					, a.[Unexcused Absenteeism Hours] 
					, a.[Excused Absenteeism Hours]
					, a.[Fingerprint]	
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					  a.[Site]
					, a.[Department]
					, a.[Calendar Week]
					, a.[Scheduled Hours]
					, a.[Unexcused Absenteeism Hours] 
					, a.[Excused Absenteeism Hours]
					, a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;


	DROP TABLE #EmployeeAbsence

END
GO
