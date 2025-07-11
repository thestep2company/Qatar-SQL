USE [Operations]
GO
/****** Object:  StoredProcedure [ADP].[Merge_Employee]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROCEDURE [ADP].[Merge_Employee] AS BEGIN

	CREATE TABLE #Employee (
		[Employee ID] [varchar](250) NULL,
		[Primary Location] [varchar](250) NULL,
		[Primary Job] [varchar](250) NULL,
		[Schedule Group Assignment Name] [varchar](250) NULL,
		[Accrual Profile Name] [varchar](250) NULL,
		[Employee Type] [varchar](250) NULL,
		[Employee Full Name] [varchar](250) NULL,
		[Hire Date] [datetime] NULL,
		[Date Terminated] [datetime] NULL,
		[Termination Reason] [varchar](250) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	)

	INSERT INTO #Employee
	SELECT 
		   [Person Number]
	      ,[Primary Location]
	      ,[Primary Job]
	      ,[Schedule Group Assignment Name]
	      ,[Accrual Profile Name]
	      ,CASE WHEN [Pay Rule] LIKE '% FT%' THEN 'Full-Time' ELSE 'Part-Time' END AS [Employee Type]
		  ,[Name]
	      ,[Hire Date] 
		  ,CASE WHEN [Employment Status] = 'Active' THEN '' ELSE [Employment Status Date] END AS [Date Terminated]
		  ,'' AS [Termination Reason]
		  ,'XXXXXXXXXXX' 
	FROM [ADP].[Employee Basic Summary] 
	WHERE [Primary Location] LIKE '%W84%'

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Employee','Kronos') SELECT @columnList
	*/
	UPDATE #Employee
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
				   CAST(ISNULL([Employee ID],'') AS VARCHAR(250)) +  CAST(ISNULL([Primary Location],'') AS VARCHAR(250)) +  CAST(ISNULL([Primary Job],'') AS VARCHAR(250)) +  CAST(ISNULL([Schedule Group Assignment Name],'') AS VARCHAR(250)) +  CAST(ISNULL([Accrual Profile Name],'') AS VARCHAR(250)) +  CAST(ISNULL([Employee Type],'') AS VARCHAR(250)) +  CAST(ISNULL([Employee Full Name],'') AS VARCHAR(250)) +  CAST(ISNULL([Hire Date],'') AS VARCHAR(100)) +  CAST(ISNULL([Date Terminated],'') AS VARCHAR(100)) +  CAST(ISNULL([Termination Reason],'') AS VARCHAR(250)) 
		),1)),3,32);


	--expire records outside the merge

		INSERT INTO Kronos.[Employee] (
			[Employee ID],
			[Primary Location],
			[Primary Job],
			[Schedule Group Assignment Name],
			[Accrual Profile Name],
			[Employee Type],
			[Employee Full Name],
			[Hire Date],
			[Date Terminated],
			[Termination Reason],
			[Fingerprint]
		)
			SELECT 
				a.[Employee ID],
				a.[Primary Location],
				a.[Primary Job],
				a.[Schedule Group Assignment Name],
				a.[Accrual Profile Name],
				a.[Employee Type],
				a.[Employee Full Name],
				a.[Hire Date],
				a.[Date Terminated],
				a.[Termination Reason],
				a.[Fingerprint]
			FROM (
				MERGE Kronos.[Employee] b
				USING (SELECT * FROM #employee) a
				ON a.[Employee ID] = b.[Employee ID] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					[Employee ID],
					[Primary Location],
					[Primary Job],
					[Schedule Group Assignment Name],
					[Accrual Profile Name],
					[Employee Type],
					[Employee Full Name],
					[Hire Date],
					[Date Terminated],
					[Termination Reason],
					[Fingerprint]
				)
				VALUES (
						a.[Employee ID],
						a.[Primary Location],
						a.[Primary Job],
						a.[Schedule Group Assignment Name],
						a.[Accrual Profile Name],
						a.[Employee Type],
						a.[Employee Full Name],
						a.[Hire Date],
						a.[Date Terminated],
						a.[Termination Reason],
						a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						a.[Employee ID],
						a.[Primary Location],
						a.[Primary Job],
						a.[Schedule Group Assignment Name],
						a.[Accrual Profile Name],
						a.[Employee Type],
						a.[Employee Full Name],
						a.[Hire Date],
						a.[Date Terminated],
						a.[Termination Reason],
						a.[Fingerprint],
					   $Action AS Action
			) a
			WHERE Action = 'Update'
			;

	DROP TABLE #Employee

END
GO
