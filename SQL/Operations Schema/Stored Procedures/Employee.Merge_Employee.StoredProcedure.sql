USE [Operations]
GO
/****** Object:  StoredProcedure [Employee].[Merge_Employee]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Employee].[Merge_Employee] AS BEGIN

	TRUNCATE TABLE Employee.Employee

	CREATE TABLE #Employee (
		[INDEX_ID] [int] NOT NULL,
		[FIRST_NAME] [varchar](50) NULL,
		[LAST_NAME] [varchar](50) NULL,
		[SITE] [varchar](25) NULL,
		[LOCATION] [varchar](25) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) 

	INSERT INTO #Employee
	SELECT *, 'XXXXXXXX'
	FROM OPENQUERY(FINDLAND,'SELECT * FROM Employee.dbo.Employees') 


	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Employee','Employee') SELECT @columnList
	*/
	UPDATE #Employee
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
				   CAST(ISNULL([INDEX_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([FIRST_NAME],'') AS VARCHAR(50)) +  CAST(ISNULL([LAST_NAME],'') AS VARCHAR(50)) +  CAST(ISNULL([SITE],'') AS VARCHAR(25)) +  CAST(ISNULL([LOCATION],'') AS VARCHAR(25)) 
		),1)),3,32);


	--expire records outside the merge

		INSERT INTO Employee.[Employee] (
		   [INDEX_ID]
		  ,[FIRST_NAME]
		  ,[LAST_NAME]
		  ,[SITE]
		  ,[LOCATION]
		  ,[Fingerprint]
		)
			SELECT 
				a.[INDEX_ID]
				,a.[FIRST_NAME]
				,a.[LAST_NAME]
				,a.[SITE]
				,a.[LOCATION]
				,a.[Fingerprint]
			FROM (
				MERGE Employee.[Employee] b
				USING (SELECT * FROM #employee) a
				ON a.[Index_ID] = b.[Index_ID] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					[INDEX_ID]
				  ,[FIRST_NAME]
				  ,[LAST_NAME]
				  ,[SITE]
				  ,[LOCATION]
				  ,[Fingerprint]
				)
				VALUES (
						a.[INDEX_ID]
					  ,a.[FIRST_NAME]
					  ,a.[LAST_NAME]
					  ,a.[SITE]
					  ,a.[LOCATION]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						a.[INDEX_ID]
					  ,a.[FIRST_NAME]
					  ,a.[LAST_NAME]
					  ,a.[SITE]
					  ,a.[LOCATION]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	DROP TABLE #employee

END
GO
