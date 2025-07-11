USE [Operations]
GO
/****** Object:  StoredProcedure [Kronos].[Merge_EmployeeHours]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Kronos].[Merge_EmployeeHours] AS BEGIN

	DECLARE @procStartDate DATETIME = GETDATE()

	DECLARE @baseRowCount INT, @currentRowCount INT
	SELECT @baseRowCount = COUNT(*) FROM [Kronos].[Employee Hours by Worked Acct Daily]
	
	WAITFOR DELAY '00:00:15'
	SELECT @currentRowCount = COUNT(*) FROM [Kronos].[Employee Hours by Worked Acct Daily]
	
	WHILE @baseRowCount <>  @currentRowCount BEGIN
		SELECT @baseRowCount = COUNT(*) FROM [Kronos].[Employee Hours by Worked Acct Daily]
		WAITFOR DELAY '00:00:15'
		SELECT @currentRowCount = COUNT(*) FROM [Kronos].[Employee Hours by Worked Acct Daily]
	END

	CREATE TABLE #EmployeeHours (
		[Employee ID] [varchar](250) NOT NULL,
		[Employee Full Name] [varchar](250) NULL,
		[Employee Pay Rule] [varchar](250) NULL,
		[Hourly Wage] [money] NULL,
		[Primary Location] [varchar](250) NULL,
		[Primary Job] [varchar](250) NULL,
		[Home Labor Category] [varchar](250) NULL,
		[Job Name] [varchar](250) NOT NULL,
		[Job Transfer] [bit] NULL,
		[Paycode Type] [varchar](250) NOT NULL,
		[Paycode Name] [varchar](250) NOT NULL,
		[Work Date] [DATE] NOT NULL,
		[Actual Hours] [float] NULL,
		[Actual Wages] [money] NULL,
		[Labor Category Name] [varchar](250) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	)

	INSERT INTO #EmployeeHours (
		  [Employee ID]
		, [Employee Full Name]
		, [Employee Pay Rule]
		, [Hourly Wage]
		, [Primary Location]
		, [Primary Job]
		, [Home Labor Category]
		, [Job Name]
		, [Job Transfer]
		, [Paycode Type]
		, [Paycode Name]
		, [Work Date]
		, [Actual Hours]
		, [Actual Wages]
		, [Labor Category Name]
		, [Fingerprint]
	)
	SELECT [Employee Number] AS [Employee ID] 
		  ,[Employee Full Name]
		  ,[Employee Pay Rule]
		  ,CAST([Hourly Wage Rate] AS MONEY) AS [Hourly Wage]
		  ,[Primary Location (Path)]
		  ,[Primary Job]
		  ,ISNULL([Home Labor Category],'')
		  ,ISNULL([Job Name - Full Path (Worked)],'')
		  ,CAST(CASE WHEN [Actual Total Job Transfer Indicator] = 'True' THEN 1 ELSE 0 END AS BIT) AS [Job Transfer]
		  ,ISNULL([Paycode Type],'')
		  ,ISNULL([Paycode Name],'')
		  ,ISNULL(CAST([Actual Total Apply Date] AS DATE),'1900-01-01') AS [Work Date]
		  ,CAST([Actual Total Hours (Include Corrections)] AS FLOAT) AS [Actual Hours]
		  ,CASE WHEN [Actual Total Wages (Include Corrections)]  LIKE '%E%' THEN 0 ELSE CAST([Actual Total Wages (Include Corrections)] AS MONEY) END AS [Actual Wages]
		  ,ISNULL([Labor Category Name (Path)],'')
		  ,'XXXXXXXXXXX' AS Fingerprint
	FROM [Kronos].[Employee Hours by Worked Acct Daily]

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('EmployeeHoursTest','Kronos') SELECT @columnList
	*/
	UPDATE #EmployeeHours
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
				   CAST(ISNULL([Employee ID],'') AS VARCHAR(250)) +  CAST(ISNULL([Employee Full Name],'') AS VARCHAR(250)) +  CAST(ISNULL([Employee Pay Rule],'') AS VARCHAR(250)) +  CAST(ISNULL([Hourly Wage],'0') AS VARCHAR(100)) +  CAST(ISNULL([Primary Location],'') AS VARCHAR(250)) +  CAST(ISNULL([Primary Job],'') AS VARCHAR(250)) +  CAST(ISNULL([Home Labor Category],'') AS VARCHAR(250)) +  CAST(ISNULL([Job Name],'') AS VARCHAR(250)) +  CAST(ISNULL([Job Transfer],'') AS VARCHAR(100)) +  CAST(ISNULL([Paycode Type],'') AS VARCHAR(250)) +  CAST(ISNULL([Paycode Name],'') AS VARCHAR(250)) +  CAST(ISNULL([Work Date],'') AS VARCHAR(100)) +  CAST(ISNULL([Actual Hours],'0') AS VARCHAR(100)) +  CAST(ISNULL([Actual Wages],'0') AS VARCHAR(100)) +  CAST(ISNULL([Labor Category Name],'') AS VARCHAR(250)) 
		),1)),3,32);


	--expire existing employee records for a given day
	UPDATE b
	SET EndDate = @procStartDate, CurrentRecord = 0
	FROM (SELECT DISTINCT [Employee ID], [Work Date] FROM #EmployeeHours) a
		INNER JOIN Kronos.EmployeeHours b ON a.[Employee ID] = b.[Employee ID] AND a.[Work Date] = b.[Work Date]
	WHERE EndDate IS NULL

	INSERT INTO Kronos.EmployeeHours (
		 [Employee ID]
		, [Employee Full Name]
		, [Employee Pay Rule]
		, [Hourly Wage]
		, [Primary Location]
		, [Primary Job]
		, [Home Labor Category]
		, [Job Name]
		, [Job Transfer]
		, [Paycode Type]
		, [Paycode Name]
		, [Work Date]
		, [Actual Hours]
		, [Actual Wages]
		, [Labor Category Name]
		, [Fingerprint]
	)
	SELECT a.* FROM #EmployeeHours a
		LEFT JOIN Kronos.EmployeeHours b ON a.[Employee ID] = b.[Employee ID] AND a.[Work Date] = b.[Work Date] AND b.CurrentRecord = 1
	WHERE b.[Employee ID] IS NULL

	----make into checksum
	--SELECT SUM(ISNULL([Actual Hours],0)) AS [Actual Hours]
	--		,SUM(ISNULL([Actual Wages],0)) AS [Actual Wages]
	--		,COUNT(*) AS [Record Count]
	--FROM Kronos.EmployeeHours
	--WHERE CurrentRecord = 1 AND [Work Date] = CAST(GETDATE() AS DATE)

	--SELECT 
	--		SUM(CAST([Actual Total Hours (Include Corrections)] AS FLOAT)) AS [Actual Hours]
	--		,SUM(CAST([Actual Total Wages (Include Corrections)] AS MONEY)) AS [Actual Wages]
	--		,COUNT(*) AS [Record Count]
	--FROM [Kronos].[Employee Hours by Worked Acct Daily] WHERE CAST([Actual Total Apply Date] AS DATE) = CAST(GETDATE() AS DATE)

	;--180 days full snapshot retention, Saturdays further back
	/*
	WITH RetentionData AS (
		SELECT DateKey 
		FROM Dim.CalendarFiscal 
		WHERE [Day of Week Sort] >= 6
	)
	DELETE FROM msc 
	--SELECT COUNT(*)
	FROM Oracle.MSC_ORDERS_V msc WITH (NOLOCK)
		LEFT JOIN RetentionData rd ON rd.DateKey = CAST(StartDate AS DATE)
	WHERE CASE WHEN EndDate IS NOT NULL AND rd.DateKey IS NULL THEN 1 ELSE 0 END = 1
		AND CAST(StartDate AS DATE) < GETDATE() - 180
	*/

	DROP TABLE #EmployeeHours
END
GO
